//
//  ImageCacheManager.swift
//  jiagou
//
//  图片缓存管理器 - 三级缓存（内存-磁盘-网络）
//

import UIKit

// MARK: - 缓存配置
struct ImageCacheConfig {
    // 内存缓存配置
    var memoryCountLimit: Int = 100              // 最多缓存 100 张图片
    var memoryCostLimit: Int = 1024 * 1024 * 50  // 内存最大 50MB
    
    // 磁盘缓存配置
    var diskCacheMaxAge: TimeInterval = 7 * 24 * 60 * 60  // 7天
    var diskCacheMaxSize: UInt = 100 * 1024 * 1024        // 磁盘最大 100MB
    
    // 下载配置
    var downloadTimeout: TimeInterval = 15  // 下载超时 15 秒
    var maxConcurrentDownloads: Int = 4     // 最多 4 个并发下载
}

// MARK: - 图片缓存管理器
class ImageCacheManager {
    
    // MARK: - 单例
    static let shared = ImageCacheManager()
    
    // MARK: - 属性
    
    // 配置
    var config = ImageCacheConfig()
    
    // 内存缓存 (NSCache 自动管理内存，在内存警告时自动清理)
    private let memoryCache = NSCache<NSString, UIImage>()
    
    // 磁盘缓存目录
    private lazy var diskCacheDirectory: URL = {
        let paths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        let cacheDirectory = paths[0].appendingPathComponent("ImageCache")
        
        // 创建目录
        if !FileManager.default.fileExists(atPath: cacheDirectory.path) {
            try? FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        }
        
        return cacheDirectory
    }()
    
    // 文件管理器
    private let fileManager = FileManager.default
    
    // I/O 队列（用于磁盘读写）
    private let ioQueue = DispatchQueue(label: "com.jiagou.imagecache.io", qos: .background)
    
    // 操作队列（用于下载操作）
    private let downloadQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 4  // 最多 4 个并发下载
        queue.qualityOfService = .userInitiated
        return queue
    }()
    
    // MARK: - 初始化
    private init() {
        setupMemoryCache()
        setupMemoryWarningObserver()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - 配置
    
    private func setupMemoryCache() {
        memoryCache.countLimit = config.memoryCountLimit
        memoryCache.totalCostLimit = config.memoryCostLimit
    }
    
    private func setupMemoryWarningObserver() {
        // 监听内存警告，自动清理内存缓存
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleMemoryWarning),
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )
    }
    
    @objc private func handleMemoryWarning() {
        clearMemoryCache()
        print("⚠️ 内存警告：已清理图片内存缓存")
    }
    
    // MARK: - 缓存键生成
    
    /// 根据 URL 生成缓存键（使用 MD5）
    private func cacheKey(for url: URL) -> String {
        return url.absoluteString.md5
    }
    
    /// 获取磁盘缓存文件路径
    private func diskCachePath(for key: String) -> URL {
        return diskCacheDirectory.appendingPathComponent(key)
    }
    
    // MARK: - 内存缓存操作
    
    /// 从内存缓存获取图片
    func imageFromMemory(for url: URL) -> UIImage? {
        let key = cacheKey(for: url) as NSString
        return memoryCache.object(forKey: key)
    }
    
    /// 保存图片到内存缓存
    func saveImageToMemory(_ image: UIImage, for url: URL) {
        let key = cacheKey(for: url) as NSString
        
        // 计算图片大小作为 cost
        let cost = image.imageCost
        memoryCache.setObject(image, forKey: key, cost: cost)
    }
    
    /// 从内存缓存移除图片
    func removeImageFromMemory(for url: URL) {
        let key = cacheKey(for: url) as NSString
        memoryCache.removeObject(forKey: key)
    }
    
    /// 清空内存缓存
    func clearMemoryCache() {
        memoryCache.removeAllObjects()
        print("🗑️ 已清空内存缓存")
    }
    
    // MARK: - 磁盘缓存操作
    
    /// 从磁盘缓存获取图片（异步）
    func imageFromDisk(for url: URL, completion: @escaping (UIImage?) -> Void) {
        let key = cacheKey(for: url)
        let path = diskCachePath(for: key)
        
        ioQueue.async { [weak self] in
            guard let self = self else { return }
            
            // 检查文件是否存在
            guard self.fileManager.fileExists(atPath: path.path) else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            
            // 检查文件是否过期
            if self.isCacheExpired(at: path) {
                try? self.fileManager.removeItem(at: path)
                DispatchQueue.main.async { completion(nil) }
                return
            }
            
            // 读取图片
            guard let data = try? Data(contentsOf: path),
                  let image = UIImage(data: data) else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            
            // 同时保存到内存缓存
            self.saveImageToMemory(image, for: url)
            
            DispatchQueue.main.async {
                completion(image)
            }
        }
    }
    
    /// 保存图片到磁盘缓存（异步）
    func saveImageToDisk(_ image: UIImage, for url: URL, completion: (() -> Void)? = nil) {
        let key = cacheKey(for: url)
        let path = diskCachePath(for: key)
        
        ioQueue.async { [weak self] in
            guard let data = image.jpegData(compressionQuality: 0.8) else {
                DispatchQueue.main.async { completion?() }
                return
            }
            
            do {
                try data.write(to: path)
                DispatchQueue.main.async { completion?() }
            } catch {
                print("❌ 保存图片到磁盘失败：\(error.localizedDescription)")
                DispatchQueue.main.async { completion?() }
            }
        }
    }
    
    /// 从磁盘缓存移除图片
    func removeImageFromDisk(for url: URL) {
        let key = cacheKey(for: url)
        let path = diskCachePath(for: key)
        
        ioQueue.async { [weak self] in
            try? self?.fileManager.removeItem(at: path)
        }
    }
    
    /// 清空磁盘缓存
    func clearDiskCache(completion: (() -> Void)? = nil) {
        ioQueue.async { [weak self] in
            guard let self = self else { return }
            
            try? self.fileManager.removeItem(at: self.diskCacheDirectory)
            try? self.fileManager.createDirectory(at: self.diskCacheDirectory, withIntermediateDirectories: true)
            
            print("🗑️ 已清空磁盘缓存")
            DispatchQueue.main.async { completion?() }
        }
    }
    
    /// 清理过期的磁盘缓存
    func cleanExpiredDiskCache() {
        ioQueue.async { [weak self] in
            guard let self = self else { return }
            
            guard let files = try? self.fileManager.contentsOfDirectory(
                at: self.diskCacheDirectory,
                includingPropertiesForKeys: [.contentModificationDateKey],
                options: .skipsHiddenFiles
            ) else { return }
            
            var deletedCount = 0
            for file in files {
                if self.isCacheExpired(at: file) {
                    try? self.fileManager.removeItem(at: file)
                    deletedCount += 1
                }
            }
            
            if deletedCount > 0 {
                print("🗑️ 已清理 \(deletedCount) 个过期缓存文件")
            }
            
            // 检查总大小，如果超过限制，删除最旧的文件
            self.cleanDiskCacheIfNeeded(files: files)
        }
    }
    
    /// 检查缓存是否过期
    private func isCacheExpired(at path: URL) -> Bool {
        guard let attributes = try? fileManager.attributesOfItem(atPath: path.path),
              let modificationDate = attributes[.modificationDate] as? Date else {
            return true
        }
        
        let age = Date().timeIntervalSince(modificationDate)
        return age > config.diskCacheMaxAge
    }
    
    /// 如果磁盘缓存超过大小限制，删除最旧的文件
    private func cleanDiskCacheIfNeeded(files: [URL]) {
        // 计算总大小
        var totalSize: UInt = 0
        var fileInfos: [(url: URL, size: UInt, modificationDate: Date)] = []
        
        for file in files {
            guard let attributes = try? fileManager.attributesOfItem(atPath: file.path),
                  let size = attributes[.size] as? UInt,
                  let modificationDate = attributes[.modificationDate] as? Date else {
                continue
            }
            
            totalSize += size
            fileInfos.append((file, size, modificationDate))
        }
        
        // 如果没有超过限制，直接返回
        guard totalSize > config.diskCacheMaxSize else { return }
        
        // 按修改时间排序（最旧的在前）
        fileInfos.sort { $0.modificationDate < $1.modificationDate }
        
        // 删除文件直到低于限制
        let targetSize = config.diskCacheMaxSize / 2  // 删到一半
        var deletedCount = 0
        
        for fileInfo in fileInfos {
            guard totalSize > targetSize else { break }
            
            try? fileManager.removeItem(at: fileInfo.url)
            totalSize -= fileInfo.size
            deletedCount += 1
        }
        
        print("🗑️ 磁盘缓存超限，已删除 \(deletedCount) 个最旧的文件")
    }
    
    // MARK: - 统一缓存操作
    
    /// 从缓存获取图片（优先内存，其次磁盘）
    func cachedImage(for url: URL, completion: @escaping (UIImage?) -> Void) {
        // 1. 先从内存获取
        if let image = imageFromMemory(for: url) {
            completion(image)
            return
        }
        
        // 2. 从磁盘获取
        imageFromDisk(for: url) { image in
            completion(image)
        }
    }
    
    /// 保存图片到缓存（同时保存到内存和磁盘）
    func cacheImage(_ image: UIImage, for url: URL) {
        // 保存到内存
        saveImageToMemory(image, for: url)
        
        // 保存到磁盘
        saveImageToDisk(image, for: url)
    }
    
    /// 从所有缓存移除图片
    func removeImage(for url: URL) {
        removeImageFromMemory(for: url)
        removeImageFromDisk(for: url)
    }
    
    /// 清空所有缓存
    func clearAllCache(completion: (() -> Void)? = nil) {
        clearMemoryCache()
        clearDiskCache(completion: completion)
    }
    
    // MARK: - 缓存统计
    
    /// 获取磁盘缓存大小
    func getDiskCacheSize(completion: @escaping (UInt) -> Void) {
        ioQueue.async { [weak self] in
            guard let self = self else { return }
            
            guard let files = try? self.fileManager.contentsOfDirectory(
                at: self.diskCacheDirectory,
                includingPropertiesForKeys: [.fileSizeKey],
                options: .skipsHiddenFiles
            ) else {
                DispatchQueue.main.async { completion(0) }
                return
            }
            
            var totalSize: UInt = 0
            for file in files {
                if let attributes = try? self.fileManager.attributesOfItem(atPath: file.path),
                   let size = attributes[.size] as? UInt {
                    totalSize += size
                }
            }
            
            DispatchQueue.main.async { completion(totalSize) }
        }
    }
    
    /// 获取磁盘缓存文件数量
    func getDiskCacheCount(completion: @escaping (Int) -> Void) {
        ioQueue.async { [weak self] in
            guard let self = self else { return }
            
            let count = (try? self.fileManager.contentsOfDirectory(at: self.diskCacheDirectory, includingPropertiesForKeys: nil))?.count ?? 0
            
            DispatchQueue.main.async { completion(count) }
        }
    }
}

// MARK: - UIImage 扩展
extension UIImage {
    /// 计算图片内存占用大小
    var imageCost: Int {
        guard let cgImage = cgImage else { return 0 }
        return cgImage.bytesPerRow * cgImage.height
    }
}

// MARK: - String MD5 扩展
extension String {
    /// 计算 MD5 值（用于生成缓存键）
    var md5: String {
        guard let data = self.data(using: .utf8) else { return self }
        
        // 简化版：使用 hash 代替真正的 MD5
        // 实际项目中应该使用 CommonCrypto 的 CC_MD5
        let hash = data.hashValue
        return String(format: "%02x", abs(hash))
    }
}

