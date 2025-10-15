//
//  RouteDataCache.swift
//  jiagou
//
//  路由数据缓存 - 用于传递复杂对象
//

import Foundation
import UIKit

/// 路由数据缓存管理器
/// 用于存储无法通过 URL 传递的复杂对象（UIImage、NSData、自定义对象等）
class RouteDataCache {
    
    // MARK: - 单例
    static let shared = RouteDataCache()
    
    // MARK: - 缓存项
    private struct CacheItem {
        let object: Any
        let timestamp: Date
        let ttl: TimeInterval  // Time To Live（生存时间）
        
        var isExpired: Bool {
            return Date().timeIntervalSince(timestamp) > ttl
        }
    }
    
    // MARK: - 属性
    
    /// 缓存存储
    private var cache: [String: CacheItem] = [:]
    
    /// 线程安全队列
    private let queue = DispatchQueue(label: "com.jiagou.router.datacache", attributes: .concurrent)
    
    /// 清理定时器
    private var cleanupTimer: Timer?
    
    // MARK: - 初始化
    
    private init() {
        startCleanupTimer()
    }
    
    deinit {
        cleanupTimer?.invalidate()
    }
    
    // MARK: - 存储对象
    
    /// 存储对象并返回唯一 ID
    /// - Parameters:
    ///   - object: 要存储的对象（任意类型）
    ///   - ttl: 生存时间（秒），默认 5 分钟，超时自动清理
    /// - Returns: 唯一 ID，用于后续获取对象
    func store<T>(_ object: T, ttl: TimeInterval = 300) -> String {
        let id = UUID().uuidString
        let item = CacheItem(object: object, timestamp: Date(), ttl: ttl)
        
        queue.async(flags: .barrier) { [weak self] in
            self?.cache[id] = item
            print("📦 RouteDataCache: 存储对象 [\(id)] TTL=\(ttl)秒")
        }
        
        return id
    }
    
    // MARK: - 获取对象
    
    /// 获取对象（不移除）
    /// - Parameter id: 对象 ID
    /// - Returns: 对象（如果存在且未过期）
    func get<T>(_ id: String) -> T? {
        var result: T?
        
        queue.sync { [weak self] in
            guard let item = self?.cache[id] else {
                print("⚠️ RouteDataCache: 对象不存在 [\(id)]")
                return
            }
            
            if item.isExpired {
                print("⚠️ RouteDataCache: 对象已过期 [\(id)]")
                return
            }
            
            result = item.object as? T
            if result != nil {
                print("✅ RouteDataCache: 获取对象 [\(id)]")
            } else {
                print("❌ RouteDataCache: 类型不匹配 [\(id)]")
            }
        }
        
        return result
    }
    
    /// 获取对象并从缓存中移除（推荐）
    /// - Parameter id: 对象 ID
    /// - Returns: 对象（如果存在且未过期）
    func fetch<T>(_ id: String) -> T? {
        var result: T?
        
        queue.sync(flags: .barrier) { [weak self] in
            guard let item = self?.cache[id] else {
                print("⚠️ RouteDataCache: 对象不存在 [\(id)]")
                return
            }
            
            // 移除对象
            self?.cache.removeValue(forKey: id)
            
            if item.isExpired {
                print("⚠️ RouteDataCache: 对象已过期 [\(id)]")
                return
            }
            
            result = item.object as? T
            if result != nil {
                print("✅ RouteDataCache: 获取并移除对象 [\(id)]")
            } else {
                print("❌ RouteDataCache: 类型不匹配 [\(id)]")
            }
        }
        
        return result
    }
    
    // MARK: - 移除对象
    
    /// 移除指定对象
    /// - Parameter id: 对象 ID
    func remove(_ id: String) {
        queue.async(flags: .barrier) { [weak self] in
            if self?.cache.removeValue(forKey: id) != nil {
                print("🗑️ RouteDataCache: 移除对象 [\(id)]")
            }
        }
    }
    
    /// 清空所有缓存
    func removeAll() {
        queue.async(flags: .barrier) { [weak self] in
            let count = self?.cache.count ?? 0
            self?.cache.removeAll()
            print("🗑️ RouteDataCache: 清空所有缓存（共 \(count) 个）")
        }
    }
    
    // MARK: - 清理过期对象
    
    /// 清理过期对象
    private func cleanupExpiredItems() {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            
            let beforeCount = self.cache.count
            self.cache = self.cache.filter { !$0.value.isExpired }
            let afterCount = self.cache.count
            
            if beforeCount != afterCount {
                print("🧹 RouteDataCache: 清理过期对象（\(beforeCount - afterCount) 个）")
            }
        }
    }
    
    /// 启动清理定时器（每分钟检查一次）
    private func startCleanupTimer() {
        DispatchQueue.main.async { [weak self] in
            self?.cleanupTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
                self?.cleanupExpiredItems()
            }
        }
    }
    
    // MARK: - 调试
    
    /// 缓存中的对象数量
    var cacheCount: Int {
        var count = 0
        queue.sync {
            count = cache.count
        }
        return count
    }
    
    /// 打印缓存状态
    func printCacheStatus() {
        queue.sync { [weak self] in
            guard let self = self else { return }
            print("📊 RouteDataCache 状态：")
            print("  - 缓存对象数：\(self.cache.count)")
            for (id, item) in self.cache {
                let elapsed = Date().timeIntervalSince(item.timestamp)
                let remaining = item.ttl - elapsed
                print("  - [\(id)]: \(type(of: item.object)), 剩余 \(Int(remaining))秒")
            }
        }
    }
}

// MARK: - 便捷方法

extension RouteDataCache {
    
    /// 存储 UIImage
    func storeImage(_ image: UIImage, ttl: TimeInterval = 300) -> String {
        return store(image, ttl: ttl)
    }
    
    /// 获取 UIImage
    func fetchImage(_ id: String) -> UIImage? {
        return fetch(id)
    }
    
    /// 存储 Data
    func storeData(_ data: Data, ttl: TimeInterval = 300) -> String {
        return store(data, ttl: ttl)
    }
    
    /// 获取 Data
    func fetchData(_ id: String) -> Data? {
        return fetch(id)
    }
}

