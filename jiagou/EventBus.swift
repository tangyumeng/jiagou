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

// MARK: - 事件订阅者

/// 事件订阅者（使用 weak 包装避免循环引用）
class EventSubscriber {
    weak var observer: AnyObject?
    let queue: DispatchQueue?
    let handler: (Event) -> Void
    
    init(observer: AnyObject, queue: DispatchQueue?, handler: @escaping (Event) -> Void) {
        self.observer = observer
        self.queue = queue
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
    
    // 线程安全锁
    private let lock = NSRecursiveLock()
    
    // MARK: - 初始化
    private init() {}
    
    // MARK: - 订阅
    
    /// 订阅事件
    /// - Parameters:
    ///   - eventName: 事件名称
    ///   - observer: 观察者（用于自动取消订阅）
    ///   - queue: 回调队列（nil 表示当前队列）
    ///   - handler: 事件处理闭包
    func subscribe(
        _ eventName: String,
        observer: AnyObject,
        queue: DispatchQueue? = nil,
        handler: @escaping (Event) -> Void
    ) {
        lock.lock()
        defer { lock.unlock() }
        
        let subscriber = EventSubscriber(observer: observer, queue: queue, handler: handler)
        
        if subscribers[eventName] == nil {
            subscribers[eventName] = []
        }
        subscribers[eventName]?.append(subscriber)
        
        print("📝 订阅事件：\(eventName)")
    }
    
    /// 订阅事件（泛型版本，类型安全）
    func subscribe<T: Event>(
        _ eventType: T.Type,
        observer: AnyObject,
        queue: DispatchQueue? = nil,
        handler: @escaping (T) -> Void
    ) {
        let eventName = String(describing: eventType)
        subscribe(eventName, observer: observer, queue: queue) { event in
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
        
        // 通知所有订阅者
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
    
    /// 发布事件（延迟）
    func post(_ event: Event, delay: TimeInterval) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            self?.post(event)
        }
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
 
 // 2. 订阅事件
 EventBus.shared.subscribe("OrderCreated", observer: self) { event in
     if let orderEvent = event as? OrderCreatedEvent {
         print("订单创建：\(orderEvent.orderId)")
     }
 }
 
 // 或者使用泛型（类型安全）
 EventBus.shared.subscribe(OrderCreatedEvent.self, observer: self) { event in
     print("订单创建：\(event.orderId)")
 }
 
 // 3. 发布事件
 let event = OrderCreatedEvent(orderId: "123", amount: 99.99)
 EventBus.shared.post(event)
 
 // 4. 取消订阅（通常在 deinit 中）
 deinit {
     EventBus.shared.unsubscribeAll(observer: self)
 }
 
 */

