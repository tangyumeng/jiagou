# EventBus 使用说明

## 📦 文件清单

1. **EventBus.swift** - EventBus 核心实现
2. **EventBusExample.swift** - 完整的演示代码（新增）

---

## 🚀 快速开始

### 1. 在现有 ViewController 中打开演示页面

```swift
// 在 ViewController.swift 中添加按钮
@objc private func openEventBusExample() {
    let exampleVC = EventBusExampleViewController()
    navigationController?.pushViewController(exampleVC, animated: true)
}

// 添加到导航栏
navigationItem.rightBarButtonItem = UIBarButtonItem(
    title: "EventBus",
    style: .plain,
    target: self,
    action: #selector(openEventBusExample)
)
```

### 2. 或者在 SceneDelegate 中直接打开

```swift
func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let windowScene = (scene as? UIWindowScene) else { return }
    
    let window = UIWindow(windowScene: windowScene)
    
    // 创建演示页面
    let exampleVC = EventBusExampleViewController()
    let navController = UINavigationController(rootViewController: exampleVC)
    
    window.rootViewController = navController
    window.makeKeyAndVisible()
    self.window = window
}
```

---

## 🎯 演示功能

### 1. 下载事件演示
- **下载完成事件** - 模拟文件下载完成
- **下载进度事件** - 模拟实时下载进度更新

### 2. 订单事件演示
- **订单创建事件** - 模拟创建订单
- **多个订单事件** - 模拟批量创建订单（延迟发布）

### 3. 主题事件演示
- **主题切换事件** - 模拟深色/浅色模式切换

---

## 📱 界面说明

```
┌─────────────────────────────────┐
│   EventBus 演示                  │
├─────────────────────────────────┤
│  日志显示区域                    │
│  [2023-10-13 10:30:45] 消息...  │
│  [2023-10-13 10:30:46] 消息...  │
├─────────────────────────────────┤
│  📦 下载事件                     │
│  [发布：下载完成事件]            │
│  [发布：下载进度事件]            │
├─────────────────────────────────┤
│  🛒 订单事件                     │
│  [发布：订单创建事件]            │
│  [发布：多个订单事件]            │
├─────────────────────────────────┤
│  🎨 主题事件                     │
│  [发布：主题切换事件]            │
├─────────────────────────────────┤
│  [清除日志]                      │
└─────────────────────────────────┘
```

---

## 💻 代码示例

### 1. 定义事件

```swift
struct DownloadCompletedEvent: Event {
    var name: String { "DownloadCompleted" }
    let fileName: String
    let fileSize: Int64
}
```

### 2. 订阅事件

```swift
// 方式1：使用字符串
EventBus.shared.subscribe("DownloadCompleted", observer: self) { event in
    if let downloadEvent = event as? DownloadCompletedEvent {
        print("下载完成：\(downloadEvent.fileName)")
    }
}

// 方式2：使用泛型（推荐，类型安全）
EventBus.shared.subscribe(DownloadCompletedEvent.self, observer: self) { event in
    print("下载完成：\(event.fileName)")
}
```

### 3. 发布事件

```swift
let event = DownloadCompletedEvent(
    fileName: "file.zip",
    fileSize: 1024 * 1024 * 100  // 100MB
)

// 立即发布
EventBus.shared.post(event)

// 延迟发布
EventBus.shared.post(event, delay: 2.0)  // 2秒后
```

### 4. 取消订阅

```swift
// 取消指定事件
EventBus.shared.unsubscribe("DownloadCompleted", observer: self)

// 取消所有订阅（通常在 deinit 中）
deinit {
    EventBus.shared.unsubscribeAll(observer: self)
}
```

---

## 🎯 实际应用场景

### 场景1：下载管理器通知 UI 更新

```swift
// DownloadManager.swift
func downloadDidComplete(task: DownloadTask) {
    let event = DownloadCompletedEvent(
        fileName: task.fileName,
        fileSize: task.totalBytes
    )
    EventBus.shared.post(event)
}

// ViewController.swift
EventBus.shared.subscribe(DownloadCompletedEvent.self, observer: self) { event in
    // 更新 UI
    self.showCompletionAlert(fileName: event.fileName)
}
```

### 场景2：用户登录后通知各模块

```swift
// LoginViewController.swift
func loginSuccess(user: User) {
    let event = UserLoginEvent(userId: user.id, userName: user.name)
    EventBus.shared.post(event)
}

// HomeViewController.swift
EventBus.shared.subscribe(UserLoginEvent.self, observer: self) { event in
    self.loadUserData(userId: event.userId)
}

// ProfileViewController.swift
EventBus.shared.subscribe(UserLoginEvent.self, observer: self) { event in
    self.updateProfile(userName: event.userName)
}
```

### 场景3：多个服务监听同一事件

```swift
// 订单创建后，多个服务同时处理

// 统计服务
class StatisticsService {
    init() {
        EventBus.shared.subscribe(OrderCreatedEvent.self, observer: self) { event in
            // 统计数据
            Analytics.track("order_created", orderId: event.orderId)
        }
    }
}

// 通知服务
class NotificationService {
    init() {
        EventBus.shared.subscribe(OrderCreatedEvent.self, observer: self) { event in
            // 发送通知
            self.sendNotification(orderId: event.orderId)
        }
    }
}

// 积分服务
class PointsService {
    init() {
        EventBus.shared.subscribe(OrderCreatedEvent.self, observer: self) { event in
            // 增加积分
            self.addPoints(amount: event.amount)
        }
    }
}
```

---

## 🔍 调试技巧

### 1. 查看所有订阅者

在 EventBus.swift 中添加调试方法：

```swift
func printAllSubscribers() {
    print("📊 当前订阅情况：")
    for (eventName, subscribers) in subscribers {
        print("  \(eventName): \(subscribers.count) 个订阅者")
    }
}
```

### 2. 添加日志

```swift
EventBus.shared.subscribe(OrderCreatedEvent.self, observer: self) { event in
    print("📝 收到事件：OrderCreated, orderId=\(event.orderId)")
}
```

---

## ⚠️ 注意事项

### 1. 内存管理

```swift
// ❌ 错误：会导致循环引用
EventBus.shared.subscribe("Event", observer: self) { event in
    self.handleEvent()  // 强引用 self
}

// ✅ 正确：使用 weak
EventBus.shared.subscribe("Event", observer: self) { [weak self] event in
    self?.handleEvent()
}
```

### 2. 取消订阅

```swift
// 必须在 deinit 中取消订阅
deinit {
    EventBus.shared.unsubscribeAll(observer: self)
}
```

### 3. 线程安全

```swift
// EventBus 内部已处理线程安全
// 可以在任何线程发布和订阅

// 指定回调队列
EventBus.shared.subscribe(
    Event.self,
    observer: self,
    queue: .main  // 主线程回调
) { event in
    // 更新 UI
}
```

---

## 🎤 面试要点

### EventBus vs NotificationCenter

| 对比项 | EventBus | NotificationCenter |
|--------|---------|-------------------|
| 类型安全 | ✅ 泛型 | ❌ Any |
| 事件定义 | 结构体 | 字符串 |
| 参数传递 | 强类型 | userInfo 字典 |
| 自动清理 | ✅ weak | ❌ 需手动移除 |
| 线程控制 | ✅ 可指定队列 | ❌ 当前线程 |

### EventBus vs Delegate

| 对比项 | EventBus | Delegate |
|--------|---------|----------|
| 通信方式 | 一对多 | 一对一 |
| 耦合度 | 低（解耦） | 中（需要协议） |
| 适用场景 | 跨模块 | 相邻层级 |

### EventBus vs RxSwift

| 对比项 | EventBus | RxSwift |
|--------|---------|---------|
| 学习成本 | 低 | 高 |
| 功能丰富度 | 基础 | 强大 |
| 代码量 | 少 | 多 |
| 响应式编程 | ❌ | ✅ |

---

## 📈 性能优化

### 1. 清理已释放订阅者

EventBus 自动清理，无需手动处理：

```swift
// EventBus.swift 中的实现
subscriber.observer == nil  // 自动清理
```

### 2. 避免频繁发布

```swift
// ❌ 避免在循环中频繁发布
for i in 0..<1000 {
    EventBus.shared.post(ProgressEvent(progress: i))
}

// ✅ 节流发布
var lastPublishTime = Date()
if Date().timeIntervalSince(lastPublishTime) > 0.1 {
    EventBus.shared.post(ProgressEvent(...))
    lastPublishTime = Date()
}
```

---

## 🚀 扩展方向

### 1. 添加事件优先级

```swift
func subscribe(_ eventName: String, priority: Int, observer: AnyObject, handler: @escaping (Event) -> Void)
```

### 2. 添加事件过滤

```swift
func subscribe<T: Event>(_ eventType: T.Type, filter: @escaping (T) -> Bool, handler: @escaping (T) -> Void)
```

### 3. 添加事件历史记录

```swift
var eventHistory: [Event] = []
func getEventHistory() -> [Event]
```

---

**EventBus 演示已就绪，立即运行查看效果！🎉**

