# EventBus 高级功能 - 优先级 & 粘性事件

## ✅ 新增功能

EventBus 现在支持两个强大的高级功能：
1. **优先级订阅** - 控制事件处理顺序
2. **粘性事件** - 先发布后订阅也能收到

---

## 🎯 功能1：优先级订阅

### 概述
允许订阅者设置优先级，**高优先级的订阅者先收到事件通知**。

### 优先级级别
```swift
enum SubscriberPriority: Int {
    case low = 0        // 低优先级
    case normal = 50    // 普通优先级（默认）
    case high = 100     // 高优先级
    case critical = 200 // 最高优先级
}
```

### 使用方法

#### 基础用法
```swift
// 普通优先级（默认）
EventBus.shared.subscribe(OrderCreatedEvent.self, observer: self) { event in
    print("普通优先级：\(event.orderId)")
}

// 高优先级（先收到）
EventBus.shared.subscribe(OrderCreatedEvent.self, observer: self, priority: .high) { event in
    print("高优先级：\(event.orderId)")
}

// 低优先级（最后收到）
EventBus.shared.subscribe(OrderCreatedEvent.self, observer: self, priority: .low) { event in
    print("低优先级：\(event.orderId)")
}
```

#### 执行顺序
当发布事件时，按优先级从高到低依次通知：
```
发布事件 → critical → high → normal → low
          ⭐        ⭐      📌      📍
```

### 应用场景

#### 1. 日志记录（最高优先级）
```swift
EventBus.shared.subscribe(OrderCreatedEvent.self, observer: self, priority: .critical) { event in
    // 最先记录日志，确保不漏
    Logger.log("订单创建：\(event.orderId)")
}
```

#### 2. 核心业务逻辑（高优先级）
```swift
EventBus.shared.subscribe(OrderCreatedEvent.self, observer: self, priority: .high) { event in
    // 核心业务处理
    PaymentService.processOrder(event.orderId)
}
```

#### 3. UI 更新（普通优先级）
```swift
EventBus.shared.subscribe(OrderCreatedEvent.self, observer: self, priority: .normal) { event in
    // 更新界面
    self.updateOrderList()
}
```

#### 4. 统计分析（低优先级）
```swift
EventBus.shared.subscribe(OrderCreatedEvent.self, observer: self, priority: .low) { event in
    // 统计数据，不急
    Analytics.track("order_created", orderId: event.orderId)
}
```

---

## 🎯 功能2：粘性事件

### 概述
**粘性事件（Sticky Event）** 允许事件被缓存，即使在事件发布后才订阅，也能收到之前发布的事件。

### 工作原理
```
时间线：
[10:00] 发布粘性事件 A → 保存到缓存
[10:01] 订阅者 B 订阅  → 立即收到事件 A（从缓存）
[10:02] 订阅者 C 订阅  → 立即收到事件 A（从缓存）
```

### 使用方法

#### 发布粘性事件
```swift
let event = UserLoginEvent(userId: "123", userName: "张三")

// 普通发布（不缓存）
EventBus.shared.post(event)

// 粘性发布（缓存事件）
EventBus.shared.postSticky(event)
```

#### 订阅粘性事件
```swift
// 粘性订阅（会立即收到缓存的事件）
EventBus.shared.subscribeSticky(UserLoginEvent.self, observer: self) { event in
    print("收到登录事件：\(event.userName)")
    // 即使事件在订阅前就发布了，也能收到
}
```

#### 管理粘性事件
```swift
// 获取粘性事件
if let event = EventBus.shared.getStickyEvent(UserLoginEvent.self) {
    print("当前用户：\(event.userName)")
}

// 移除指定粘性事件
EventBus.shared.removeStickyEvent(UserLoginEvent.self)

// 移除所有粘性事件
EventBus.shared.removeAllStickyEvents()
```

### 应用场景

#### 1. 用户登录状态
```swift
// App 启动时发布用户登录事件
EventBus.shared.postSticky(UserLoginEvent(...))

// 任何页面随时订阅，都能收到登录信息
class ProfileViewController {
    override func viewDidLoad() {
        EventBus.shared.subscribeSticky(UserLoginEvent.self, observer: self) { event in
            self.loadUserProfile(userId: event.userId)
        }
    }
}
```

#### 2. 网络状态
```swift
// 网络状态变化时发布粘性事件
EventBus.shared.postSticky(NetworkStatusChangeEvent(isConnected: true))

// 任何页面都能获取当前网络状态
class DownloadViewController {
    override func viewDidLoad() {
        EventBus.shared.subscribeSticky(NetworkStatusChangeEvent.self, observer: self) { event in
            self.updateNetworkUI(isConnected: event.isConnected)
        }
    }
}
```

#### 3. 配置信息
```swift
// App 启动时加载配置
EventBus.shared.postSticky(ConfigLoadedEvent(config: appConfig))

// 任何模块都能获取配置
EventBus.shared.subscribeSticky(ConfigLoadedEvent.self, observer: self) { event in
    self.applyConfig(event.config)
}
```

---

## 📱 演示效果

### 运行演示
1. 打开 EventBus 演示页面
2. 向下滚动到 **"⭐ 高级功能"** 部分

### 测试优先级
```
点击 [测试：优先级（高→低）]

日志输出：
[10:00:00] 📤 测试优先级功能...
[10:00:00]    订阅3个不同优先级的订阅者
[10:00:00] 📣 发布测试事件...
[10:00:00]    ⭐ 最高优先级收到
[10:00:00]    📌 普通优先级收到
[10:00:00]    📍 低优先级收到
[10:00:00] ✅ 优先级测试完成
```

### 测试粘性事件
```
第1步：点击 [发布：粘性事件]
日志输出：
[10:00:00] 📤 发布粘性事件：STICKY-1234
[10:00:00]    提示：点击下方按钮订阅，仍能收到此事件

第2步：点击 [订阅：粘性事件（后订阅）]
日志输出：
[10:00:05] 📝 订阅粘性事件（后订阅）
[10:00:05] 📌 粘性订阅收到：STICKY-1234
[10:00:05]    商品：粘性事件测试商品
[10:00:05]    证明：后订阅也能收到之前发布的事件！
```

---

## 💻 完整代码示例

### 示例1：优先级处理订单
```swift
class OrderService {
    init() {
        // 最高优先级：记录日志
        EventBus.shared.subscribe(
            OrderCreatedEvent.self,
            observer: self,
            priority: .critical
        ) { event in
            Logger.log("订单创建：\(event.orderId)")
        }
        
        // 高优先级：扣除库存
        EventBus.shared.subscribe(
            OrderCreatedEvent.self,
            observer: self,
            priority: .high
        ) { event in
            InventoryService.deduct(orderId: event.orderId)
        }
        
        // 普通优先级：发送通知
        EventBus.shared.subscribe(
            OrderCreatedEvent.self,
            observer: self,
            priority: .normal
        ) { event in
            NotificationService.send(orderId: event.orderId)
        }
        
        // 低优先级：统计数据
        EventBus.shared.subscribe(
            OrderCreatedEvent.self,
            observer: self,
            priority: .low
        ) { event in
            Analytics.track("order_created")
        }
    }
}
```

### 示例2：用户状态管理
```swift
// AppDelegate.swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
    // 检查登录状态
    if let user = UserDefaults.standard.getUser() {
        // 发布粘性登录事件
        let event = UserLoginEvent(userId: user.id, userName: user.name)
        EventBus.shared.postSticky(event)
    }
    
    return true
}

// HomeViewController.swift
class HomeViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 订阅粘性事件，立即获取登录状态
        EventBus.shared.subscribeSticky(UserLoginEvent.self, observer: self) { event in
            self.updateUserInfo(userName: event.userName)
        }
    }
}

// ProfileViewController.swift
class ProfileViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 同样订阅粘性事件
        EventBus.shared.subscribeSticky(UserLoginEvent.self, observer: self) { event in
            self.loadUserProfile(userId: event.userId)
        }
    }
}
```

---

## 🎯 技术实现

### 优先级实现
```swift
// 1. 订阅者添加优先级属性
class EventSubscriber {
    let priority: SubscriberPriority
}

// 2. 订阅时按优先级排序
subscribers[eventName]?.sort { $0.priority > $1.priority }

// 3. 发布时按顺序通知
for subscriber in eventSubscribers {
    subscriber.handler(event)
}
```

### 粘性事件实现
```swift
// 1. 缓存事件
private var stickyEvents: [String: Event] = [:]

// 2. 发布粘性事件
func postSticky(_ event: Event) {
    stickyEvents[event.name] = event  // 保存
    post(event)  // 发布
}

// 3. 粘性订阅
func subscribeSticky(...) {
    subscribe(...)  // 正常订阅
    
    if let event = stickyEvents[eventName] {
        handler(event)  // 立即发送缓存的事件
    }
}
```

---

## 🎤 面试要点

### Q1: 优先级如何实现？
**A:** 
```
1. 订阅者添加优先级属性
2. 订阅时按优先级排序（高→低）
3. 发布时按顺序遍历通知
```

### Q2: 粘性事件有什么用？
**A:**
```
用途：
1. 保存应用状态（登录、网络）
2. 解决先发布后订阅的问题
3. 延迟加载的模块也能获取之前的事件

类似：
- Android 的 Sticky Broadcast
- LiveData 的 value
```

### Q3: 粘性事件会内存泄漏吗？
**A:**
```
不会，因为：
1. Event 是值类型（struct）
2. 缓存在 Dictionary 中
3. 可以主动移除：removeStickyEvent()
4. App 退出时自动清空
```

### Q4: 优先级 vs 同步发布？
**A:**
```
优先级：
- 控制处理顺序
- 仍然是异步的
- 不阻塞发布者

同步发布：
- 顺序执行
- 阻塞发布者
- 性能影响大

推荐：使用优先级，而非同步
```

---

## 📊 对比分析

### 普通订阅 vs 粘性订阅

| 特性 | 普通订阅 | 粘性订阅 |
|------|---------|---------|
| 订阅时机 | 任意 | 任意 |
| 收到事件 | 订阅后发布的 | 包括之前发布的 |
| 缓存事件 | ❌ | ✅ |
| 适用场景 | 一般事件 | 状态事件 |
| 内存占用 | 小 | 略大（缓存） |

### 优先级 vs 无优先级

| 对比项 | 无优先级 | 有优先级 |
|--------|---------|---------|
| 通知顺序 | 随机 | 可控 |
| 实现复杂度 | 简单 | 中等 |
| 性能影响 | 无 | 很小（排序） |
| 适用场景 | 一般事件 | 有依赖的事件 |

---

## ⚠️ 注意事项

### 优先级使用
```
✅ 合理的使用：
- 日志记录（critical）
- 核心业务（high）
- UI 更新（normal）
- 统计分析（low）

❌ 不当使用：
- 所有订阅都是 critical（失去意义）
- 依赖优先级做业务逻辑（应该解耦）
```

### 粘性事件使用
```
✅ 适合的场景：
- 用户登录状态
- 网络状态
- 应用配置
- 全局设置

❌ 不适合的场景：
- 一次性事件（订单创建）
- 频繁变化的事件（下载进度）
- 大量数据的事件（内存占用）
```

---

## 🚀 最佳实践

### 1. 优先级分配原则
```swift
critical (200) - 日志、监控、关键数据
high (100)     - 核心业务逻辑
normal (50)    - 普通业务、UI 更新（默认）
low (0)        - 统计、分析、非关键操作
```

### 2. 粘性事件清理
```swift
// 登出时清理
func logout() {
    EventBus.shared.removeStickyEvent(UserLoginEvent.self)
}

// App 进入后台时清理非必要的粘性事件
func applicationDidEnterBackground() {
    EventBus.shared.removeStickyEvent(TempDataEvent.self)
}
```

### 3. 内存管理
```swift
// 及时取消订阅
deinit {
    EventBus.shared.unsubscribeAll(observer: self)
}

// 避免循环引用
EventBus.shared.subscribe(..., observer: self) { [weak self] event in
    self?.handleEvent(event)
}
```

---

## 💡 总结

### 新增功能
✅ **优先级订阅** - 4个级别，自动排序  
✅ **粘性事件** - 缓存事件，先发后订  
✅ **粘性订阅** - 立即获取缓存事件  
✅ **事件管理** - 增删改查粘性事件  

### 技术亮点
⭐ 订阅者自动按优先级排序  
⭐ 粘性事件缓存管理  
⭐ 线程安全的实现  
⭐ 向后兼容（默认 normal 优先级）  

### 面试价值
🎯 展示高级特性设计能力  
🎯 理解优先级队列实现  
🎯 掌握状态管理方案  
🎯 实践内存管理技巧  

---

**EventBus 现在更加强大和灵活！🎉**

**立即运行项目，体验新功能！🚀**

