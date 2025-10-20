//
//  ImageLoader.swift
//  jiagou
//
//  图片加载器 - 负责网络下载和缓存管理
//

import UIKit

// MARK: - 图片加载选项
struct ImageLoadOptions {
    var placeholder: UIImage?           // 占位图
    var transition: ImageTransition?    // 转场动画
    var retryCount: Int = 2             // 重试次数
    var forceRefresh: Bool = false      // 强制刷新（忽略缓存）
}

// MARK: - 图片转场动画
enum ImageTransition {
    case none
    case fade(duration: TimeInterval)
    case crossFade(duration: TimeInterval)
}

// MARK: - 图片加载器
class ImageLoader {
    
    // MARK: - 单例
    static let shared = ImageLoader()
    
    // MARK: - 属性
    
    // 缓存管理器
    private let cacheManager = ImageCacheManager.shared
    
    // URL Session
    private lazy var urlSession: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        return URLSession(configuration: config)
    }()
    
    // 下载任务字典 {URL: URLSessionDataTask}
    private var downloadTasks: [URL: URLSessionDataTask] = [:]
    private let downloadTasksLock = NSLock()
    
    // 下载回调字典 {URL: [回调]}
    private var downloadCallbacks: [URL: [(Result<UIImage, Error>) -> Void]] = [:]
    private let callbacksLock = NSLock()
    
    // MARK: - 初始化
    private init() {
        // 启动时清理过期缓存
        cacheManager.cleanExpiredDiskCache()
    }
    
    // MARK: - 加载图片
    
    /// 加载图片（带完整的缓存策略）
    /// - Parameters:
    ///   - url: 图片 URL
    ///   - options: 加载选项
    ///   - completion: 完成回调
    func loadImage(
        from url: URL,
        options: ImageLoadOptions = ImageLoadOptions(),
        completion: @escaping (Result<UIImage, Error>) -> Void
    ) {
        // 如果强制刷新，跳过缓存直接下载
        if options.forceRefresh {
            downloadImage(from: url, retryCount: options.retryCount, completion: completion)
            return
        }
        
        // 1. 先从内存缓存获取
        if let image = cacheManager.imageFromMemory(for: url) {
            completion(.success(image))
            return
        }
        
        // 2. 从磁盘缓存获取
        cacheManager.imageFromDisk(for: url) { [weak self] image in
            guard let self = self else { return }
            
            if let image = image {
                completion(.success(image))
            } else {
                // 3. 缓存没有，从网络下载
                self.downloadImage(from: url, retryCount: options.retryCount, completion: completion)
            }
        }
    }
    
    // MARK: - 网络下载
    
    /// 下载图片
    private func downloadImage(
        from url: URL,
        retryCount: Int,
        completion: @escaping (Result<UIImage, Error>) -> Void
    ) {
        // 检查是否已经在下载中
        downloadTasksLock.lock()
        if downloadTasks[url] != nil {
            downloadTasksLock.unlock()
            
            // 已经在下载，添加到回调列表
            addCallback(for: url, completion: completion)
            return
        }
        downloadTasksLock.unlock()
        
        // 添加回调
        addCallback(for: url, completion: completion)
        
        // 创建下载任务
        let task = urlSession.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            
            // 移除下载任务
            self.removeDownloadTask(for: url)
            
            // 处理错误
            if let error = error {
                // 重试
                if retryCount > 0 {
                    print("⚠️ 下载失败，重试... (\(retryCount) 次剩余)")
                    self.downloadImage(from: url, retryCount: retryCount - 1, completion: completion)
                } else {
                    self.notifyCallbacks(for: url, result: .failure(error))
                }
                return
            }
            
            // 解析图片
            guard let data = data, let image = UIImage(data: data) else {
                let error = NSError(domain: "ImageLoader", code: -1, userInfo: [NSLocalizedDescriptionKey: "无法解析图片数据"])
                self.notifyCallbacks(for: url, result: .failure(error))
                return
            }
            
            // 保存到缓存
            self.cacheManager.cacheImage(image, for: url)
            
            // 通知所有回调
            self.notifyCallbacks(for: url, result: .success(image))
        }
        
        // 保存下载任务
        downloadTasksLock.lock()
        downloadTasks[url] = task
        downloadTasksLock.unlock()
        
        // 开始下载
        task.resume()
    }
    
    // MARK: - 回调管理
    
    /// 添加下载回调
    private func addCallback(for url: URL, completion: @escaping (Result<UIImage, Error>) -> Void) {
        callbacksLock.lock()
        defer { callbacksLock.unlock() }
        
        if downloadCallbacks[url] == nil {
            downloadCallbacks[url] = []
        }
        downloadCallbacks[url]?.append(completion)
    }
    
    /// 通知所有回调
    private func notifyCallbacks(for url: URL, result: Result<UIImage, Error>) {
        callbacksLock.lock()
        let callbacks = downloadCallbacks[url]
        downloadCallbacks[url] = nil
        callbacksLock.unlock()
        
        DispatchQueue.main.async {
            callbacks?.forEach { $0(result) }
        }
    }
    
    /// 移除下载任务
    private func removeDownloadTask(for url: URL) {
        downloadTasksLock.lock()
        downloadTasks[url] = nil
        downloadTasksLock.unlock()
    }
    
    // MARK: - 取消下载
    
    /// 取消指定 URL 的下载
    func cancelDownload(for url: URL) {
        downloadTasksLock.lock()
        let task = downloadTasks[url]
        downloadTasks[url] = nil
        downloadTasksLock.unlock()
        
        task?.cancel()
        
        // 清除回调
        callbacksLock.lock()
        downloadCallbacks[url] = nil
        callbacksLock.unlock()
    }
    
    /// 取消所有下载
    func cancelAllDownloads() {
        downloadTasksLock.lock()
        let tasks = downloadTasks.values
        downloadTasks.removeAll()
        downloadTasksLock.unlock()
        
        tasks.forEach { $0.cancel() }
        
        callbacksLock.lock()
        downloadCallbacks.removeAll()
        callbacksLock.unlock()
    }
    
    // MARK: - 预加载
    
    /// 预加载图片（不会触发回调，只是提前下载到缓存）
    func prefetchImages(urls: [URL]) {
        for url in urls {
            loadImage(from: url) { _ in
                // 不做处理，只是缓存
            }
        }
    }
    
    // MARK: - 缓存管理
    
    /// 清空内存缓存
    func clearMemoryCache() {
        cacheManager.clearMemoryCache()
    }
    
    /// 清空磁盘缓存
    func clearDiskCache(completion: (() -> Void)? = nil) {
        cacheManager.clearDiskCache(completion: completion)
    }
    
    /// 清空所有缓存
    func clearAllCache(completion: (() -> Void)? = nil) {
        cacheManager.clearAllCache(completion: completion)
    }
    
    /// 获取缓存大小
    func getCacheSize(completion: @escaping (String) -> Void) {
        cacheManager.getDiskCacheSize { size in
            let sizeString = ByteCountFormatter.string(fromByteCount: Int64(size), countStyle: .file)
            completion(sizeString)
        }
    }
}

// MARK: - UIImageView 扩展
extension UIImageView {
    
    // 关联对象 key
    private static var imageURLKey: UInt8 = 0
    
    /// 当前正在加载的图片 URL
    private var imageURL: URL? {
        get {
            return objc_getAssociatedObject(self, &UIImageView.imageURLKey) as? URL
        }
        set {
            objc_setAssociatedObject(self, &UIImageView.imageURLKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// 设置图片（带缓存和下载）
    /// - Parameters:
    ///   - url: 图片 URL
    ///   - placeholder: 占位图
    ///   - completion: 完成回调
    func setImage(
        with url: URL?,
        placeholder: UIImage? = nil,
        transition: ImageTransition = .fade(duration: 0.3),
        completion: ((Result<UIImage, Error>) -> Void)? = nil
    ) {
        // 取消之前的下载
        if let previousURL = imageURL {
            ImageLoader.shared.cancelDownload(for: previousURL)
        }
        
        // 保存当前 URL
        self.imageURL = url
        
        // 设置占位图
        self.image = placeholder
        
        // 如果 URL 为空，直接返回
        guard let url = url else {
            completion?(.failure(NSError(domain: "ImageLoader", code: -1, userInfo: [NSLocalizedDescriptionKey: "URL 为空"])))
            return
        }
        
        // 加载图片
        var options = ImageLoadOptions()
        options.placeholder = placeholder
        options.transition = transition
        
        ImageLoader.shared.loadImage(from: url, options: options) { [weak self] result in
            guard let self = self else { return }
            
            // 检查 URL 是否匹配（防止 cell 复用导致图片错乱）
            guard self.imageURL == url else { return }
            
            switch result {
            case .success(let image):
                // 应用转场动画
                self.applyTransition(transition) {
                    self.image = image
                }
                completion?(.success(image))
                
            case .failure(let error):
                print("❌ 加载图片失败：\(error.localizedDescription)")
                completion?(.failure(error))
            }
        }
    }
    
    /// 应用转场动画
    private func applyTransition(_ transition: ImageTransition, setImage: @escaping () -> Void) {
        switch transition {
        case .none:
            setImage()
            
        case .fade(let duration):
            UIView.transition(
                with: self,
                duration: duration,
                options: .transitionCrossDissolve,
                animations: setImage
            )
            
        case .crossFade(let duration):
            UIView.transition(
                with: self,
                duration: duration,
                options: [.transitionCrossDissolve, .allowUserInteraction],
                animations: setImage
            )
        }
    }
    
    /// 取消图片加载
    func cancelImageLoad() {
        if let url = imageURL {
            ImageLoader.shared.cancelDownload(for: url)
        }
        imageURL = nil
    }
}

