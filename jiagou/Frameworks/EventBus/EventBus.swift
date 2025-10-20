//
//  EventBus.swift
//  jiagou
//
//  EventBus 消息通信框架 - 组件间解耦通信
//

import Foundation

// MARK: - 事件协议

/// 事件协议（所有事件都需要遵循）
protocol Event {
    var name: String { get }
}

// MARK: - 优先级定义

/// 订阅优先级
enum SubscriberPriority: Int, Comparable {
    case low = 0        // 低优先级
    case normal = 50    // 普通优先级（默认）
    case high = 100     // 高优先级
    case critical = 200 // 最高优先级
    
    static func < (lhs: SubscriberPriority, rhs: SubscriberPriority) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

// MARK: - 事件订阅者

/// 事件订阅者（使用 weak 包装避免循环引用）
class EventSubscriber {
    weak var observer: AnyObject?
    let queue: DispatchQueue?
    let priority: SubscriberPriority
    let handler: (Event) -> Void
    
    init(observer: AnyObject, queue: DispatchQueue?, priority: SubscriberPriority, handler: @escaping (Event) -> Void) {
        self.observer = observer
        self.queue = queue
        self.priority = priority
        self.handler = handler
    }
}

// MARK: - EventBus

/// 事件总线（单例）
class EventBus {
    
    // MARK: - 单例
    static let shared = EventBus()
    
    // MARK: - 属性
    
    // 订阅者字典 {EventName: [Subscriber]}
    private var subscribers: [String: [EventSubscriber]] = [:]
    
    // 粘性事件字典 {EventName: Event}（保存最后一次发布的事件）
    private var stickyEvents: [String: Event] = [:]
    
    // 线程安全锁
    private let lock = NSRecursiveLock()
    
    // MARK: - 初始化
    private init() {}
    
    // MARK: - 订阅
    
    /// 订阅事件
    /// - Parameters:
    ///   - eventName: 事件名称
    ///   - observer: 观察者（用于自动取消订阅）
    ///   - priority: 优先级（默认 normal）
    ///   - queue: 回调队列（nil 表示当前队列）
    ///   - handler: 事件处理闭包
    func subscribe(
        _ eventName: String,
        observer: AnyObject,
        priority: SubscriberPriority = .normal,
        queue: DispatchQueue? = nil,
        handler: @escaping (Event) -> Void
    ) {
        lock.lock()
        defer { lock.unlock() }
        
        let subscriber = EventSubscriber(observer: observer, queue: queue, priority: priority, handler: handler)
        
        if subscribers[eventName] == nil {
            subscribers[eventName] = []
        }
        subscribers[eventName]?.append(subscriber)
        
        // 按优先级排序（优先级高的在前面）
        subscribers[eventName]?.sort { $0.priority > $1.priority }
        
        print("📝 订阅事件：\(eventName) [优先级: \(priority)]")
    }
    
    /// 订阅事件（泛型版本，类型安全）
    func subscribe<T: Event>(
        _ eventType: T.Type,
        observer: AnyObject,
        priority: SubscriberPriority = .normal,
        queue: DispatchQueue? = nil,
        handler: @escaping (T) -> Void
    ) {
        let eventName = String(describing: eventType)
        subscribe(eventName, observer: observer, priority: priority, queue: queue) { event in
            if let typedEvent = event as? T {
                handler(typedEvent)
            }
        }
    }
    
    // MARK: - 粘性订阅
    
    /// 订阅粘性事件（会立即收到上一次发布的事件）
    /// - Parameters:
    ///   - eventName: 事件名称
    ///   - observer: 观察者（用于自动取消订阅）
    ///   - priority: 优先级（默认 normal）
    ///   - queue: 回调队列（nil 表示当前队列）
    ///   - handler: 事件处理闭包
    func subscribeSticky(
        _ eventName: String,
        observer: AnyObject,
        priority: SubscriberPriority = .normal,
        queue: DispatchQueue? = nil,
        handler: @escaping (Event) -> Void
    ) {
        // 先订阅事件
        subscribe(eventName, observer: observer, priority: priority, queue: queue, handler: handler)
        
        // 检查是否有粘性事件，如果有则立即发送
        lock.lock()
        let stickyEvent = stickyEvents[eventName]
        lock.unlock()
        
        if let event = stickyEvent {
            if let queue = queue {
                queue.async {
                    handler(event)
                }
            } else {
                handler(event)
            }
            print("📌 发送粘性事件：\(eventName)")
        }
    }
    
    /// 订阅粘性事件（泛型版本，类型安全）
    func subscribeSticky<T: Event>(
        _ eventType: T.Type,
        observer: AnyObject,
        priority: SubscriberPriority = .normal,
        queue: DispatchQueue? = nil,
        handler: @escaping (T) -> Void
    ) {
        let eventName = String(describing: eventType)
        subscribeSticky(eventName, observer: observer, priority: priority, queue: queue) { event in
            if let typedEvent = event as? T {
                handler(typedEvent)
            }
        }
    }
    
    // MARK: - 取消订阅
    
    /// 取消订阅指定事件
    func unsubscribe(_ eventName: String, observer: AnyObject) {
        lock.lock()
        defer { lock.unlock() }
        
        subscribers[eventName]?.removeAll { $0.observer === observer }
        
        if subscribers[eventName]?.isEmpty == true {
            subscribers.removeValue(forKey: eventName)
        }
        
        print("🗑️ 取消订阅：\(eventName)")
    }
    
    /// 取消观察者的所有订阅
    func unsubscribeAll(observer: AnyObject) {
        lock.lock()
        defer { lock.unlock() }
        
        for eventName in subscribers.keys {
            subscribers[eventName]?.removeAll { $0.observer === observer }
            
            if subscribers[eventName]?.isEmpty == true {
                subscribers.removeValue(forKey: eventName)
            }
        }
        
        print("🗑️ 取消所有订阅")
    }
    
    // MARK: - 发布
    
    /// 发布事件
    func post(_ event: Event) {
        lock.lock()
        let eventSubscribers = subscribers[event.name] ?? []
        lock.unlock()
        
        // 清理已释放的订阅者
        cleanupSubscribers(for: event.name)
        
        // 通知所有订阅者（已按优先级排序）
        for subscriber in eventSubscribers {
            guard subscriber.observer != nil else { continue }
            
            if let queue = subscriber.queue {
                queue.async {
                    subscriber.handler(event)
                }
            } else {
                subscriber.handler(event)
            }
        }
        
        print("📣 发布事件：\(event.name)")
    }
    
    /// 发布粘性事件（会保存事件，供后续订阅者接收）
    func postSticky(_ event: Event) {
        // 先保存粘性事件
        lock.lock()
        stickyEvents[event.name] = event
        lock.unlock()
        
        // 然后发布事件
        post(event)
        
        print("📌 发布粘性事件：\(event.name)")
    }
    
    /// 发布事件（延迟）
    func post(_ event: Event, delay: TimeInterval) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            self?.post(event)
        }
    }
    
    /// 发布粘性事件（延迟）
    func postSticky(_ event: Event, delay: TimeInterval) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            self?.postSticky(event)
        }
    }
    
    // MARK: - 粘性事件管理
    
    /// 移除指定的粘性事件
    func removeStickyEvent(_ eventName: String) {
        lock.lock()
        defer { lock.unlock() }
        
        stickyEvents.removeValue(forKey: eventName)
        print("🗑️ 移除粘性事件：\(eventName)")
    }
    
    /// 移除指定类型的粘性事件
    func removeStickyEvent<T: Event>(_ eventType: T.Type) {
        let eventName = String(describing: eventType)
        removeStickyEvent(eventName)
    }
    
    /// 移除所有粘性事件
    func removeAllStickyEvents() {
        lock.lock()
        defer { lock.unlock() }
        
        stickyEvents.removeAll()
        print("🗑️ 移除所有粘性事件")
    }
    
    /// 获取粘性事件
    func getStickyEvent(_ eventName: String) -> Event? {
        lock.lock()
        defer { lock.unlock() }
        
        return stickyEvents[eventName]
    }
    
    /// 获取粘性事件（泛型版本）
    func getStickyEvent<T: Event>(_ eventType: T.Type) -> T? {
        let eventName = String(describing: eventType)
        return getStickyEvent(eventName) as? T
    }
    
    // MARK: - 清理
    
    /// 清理已释放的订阅者
    private func cleanupSubscribers(for eventName: String) {
        lock.lock()
        defer { lock.unlock() }
        
        subscribers[eventName]?.removeAll { $0.observer == nil }
        
        if subscribers[eventName]?.isEmpty == true {
            subscribers.removeValue(forKey: eventName)
        }
    }
    
    /// 清理所有订阅者
    func removeAllSubscribers() {
        lock.lock()
        defer { lock.unlock() }
        
        subscribers.removeAll()
    }
}

// MARK: - 内置事件

/// 用户登录事件
struct UserLoginEvent: Event {
    var name: String { "UserLogin" }
    let userId: String
    let userName: String
}

/// 用户登出事件
struct UserLogoutEvent: Event {
    var name: String { "UserLogout" }
}

/// 网络状态变化事件
struct NetworkStatusChangeEvent: Event {
    var name: String { "NetworkStatusChange" }
    let isConnected: Bool
}

// MARK: - 使用示例

/*
 
 // 1. 定义事件
 struct OrderCreatedEvent: Event {
     var name: String { "OrderCreated" }
     let orderId: String
     let amount: Double
 }
 
 // 2. 普通订阅事件
 EventBus.shared.subscribe(OrderCreatedEvent.self, observer: self) { event in
     print("订单创建：\(event.orderId)")
 }
 
 // 3. 带优先级订阅（高优先级先收到）
 EventBus.shared.subscribe(OrderCreatedEvent.self, observer: self, priority: .high) { event in
     print("高优先级处理：\(event.orderId)")
 }
 
 EventBus.shared.subscribe(OrderCreatedEvent.self, observer: self, priority: .low) { event in
     print("低优先级处理：\(event.orderId)")
 }
 
 // 4. 发布普通事件
 let event = OrderCreatedEvent(orderId: "123", amount: 99.99)
 EventBus.shared.post(event)
 
 // 5. 发布粘性事件（后续订阅也能收到）
 EventBus.shared.postSticky(event)
 
 // 6. 粘性订阅（会立即收到上一次发布的事件）
 EventBus.shared.subscribeSticky(OrderCreatedEvent.self, observer: self) { event in
     print("粘性订阅收到：\(event.orderId)")
 }
 
 // 7. 移除粘性事件
 EventBus.shared.removeStickyEvent(OrderCreatedEvent.self)
 
 // 8. 取消订阅（通常在 deinit 中）
 deinit {
     EventBus.shared.unsubscribeAll(observer: self)
 }
 
 */

