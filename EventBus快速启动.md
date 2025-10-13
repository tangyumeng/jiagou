# EventBus 演示 - 快速启动指南

## 🚀 三种启动方式

### 方式1：在现有下载管理器中添加入口（推荐）

打开 `ViewController.swift`，添加导航栏按钮：

```swift
override func viewDidLoad() {
    super.viewDidLoad()
    
    // ... 现有代码 ...
    
    // 添加 EventBus 演示入口
    let eventBusButton = UIBarButtonItem(
        title: "EventBus",
        style: .plain,
        target: self,
        action: #selector(openEventBusDemo)
    )
    navigationItem.rightBarButtonItems?.append(eventBusButton)
}

@objc private func openEventBusDemo() {
    let demoVC = EventBusExampleViewController()
    navigationController?.pushViewController(demoVC, animated: true)
}
```

### 方式2：修改 SceneDelegate 直接打开

打开 `SceneDelegate.swift`，替换 rootViewController：

```swift
func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let windowScene = (scene as? UIWindowScene) else { return }
    
    let window = UIWindow(windowScene: windowScene)
    
    // 方案A：直接打开 EventBus 演示
    let eventBusVC = EventBusExampleViewController()
    let navController = UINavigationController(rootViewController: eventBusVC)
    
    window.rootViewController = navController
    window.makeKeyAndVisible()
    self.window = window
}
```

### 方式3：在 TabBar 中添加标签页

如果使用 TabBarController：

```swift
func setupTabBar() {
    let tabBarController = UITabBarController()
    
    // 下载管理器
    let downloadVC = ViewController()
    downloadVC.tabBarItem = UITabBarItem(title: "下载", image: UIImage(systemName: "arrow.down.circle"), tag: 0)
    let downloadNav = UINavigationController(rootViewController: downloadVC)
    
    // EventBus 演示
    let eventBusVC = EventBusExampleViewController()
    eventBusVC.tabBarItem = UITabBarItem(title: "EventBus", image: UIImage(systemName: "bubble.left.and.bubble.right"), tag: 1)
    let eventBusNav = UINavigationController(rootViewController: eventBusVC)
    
    tabBarController.viewControllers = [downloadNav, eventBusNav]
    
    window?.rootViewController = tabBarController
}
```

---

## 🎮 使用步骤

### 1. 运行项目
```bash
⌘ + R (Command + R)
```

### 2. 打开 EventBus 演示页面
- 点击导航栏的 "EventBus" 按钮
- 或者直接进入演示页面（如果修改了 SceneDelegate）

### 3. 测试各种事件
1. **下载事件**
   - 点击"发布：下载完成事件" → 查看日志输出
   - 点击"发布：下载进度事件" → 查看进度更新

2. **订单事件**
   - 点击"发布：订单创建事件" → 查看订单信息
   - 点击"发布：多个订单事件" → 查看批量处理

3. **主题事件**
   - 点击"发布：主题切换事件" → 观察界面变化

### 4. 观察日志
日志会实时显示在页面顶部的文本框中，包括：
- 🕐 时间戳
- 📝 事件类型
- 📊 事件数据
- ✅ 处理结果

---

## 📱 预期效果

```
运行后你会看到：

┌─────────────────────────────────────┐
│ < EventBus 演示                     │
├─────────────────────────────────────┤
│ 日志显示区域：                       │
│ [10:30:45] ✅ EventBus 示例已启动   │
│ [10:30:45] 📝 已订阅所有事件...     │
│ [10:30:50] 📤 发布：下载完成事件     │
│ [10:30:50] 📥 收到下载完成事件...   │
│ [10:30:50]    文件大小：10 GB       │
├─────────────────────────────────────┤
│ 📦 下载事件                          │
│ [发布：下载完成事件]                 │
│ [发布：下载进度事件]                 │
│                                     │
│ 🛒 订单事件                          │
│ [发布：订单创建事件]                 │
│ [发布：多个订单事件]                 │
│                                     │
│ 🎨 主题事件                          │
│ [发布：主题切换事件]                 │
│                                     │
│ [清除日志]                          │
└─────────────────────────────────────┘
```

点击按钮后，日志会实时更新，显示：
- 事件发布的时间
- 事件的详细信息
- 多个订阅者的响应

---

## 🔍 核心知识点演示

### 1. 一对多通信
发布一个事件 → 多个订阅者同时收到

**示例：** 发布"订单创建"事件
- 统计服务收到 → 记录数据
- 通知服务收到 → 发送通知
- 积分服务收到 → 增加积分

### 2. 类型安全
使用泛型订阅，编译时检查类型

```swift
// ✅ 类型安全
EventBus.shared.subscribe(OrderCreatedEvent.self, observer: self) { event in
    print(event.orderId)  // 自动推断类型
}
```

### 3. 解耦
事件发布者不需要知道谁在监听

```swift
// 发布者（DownloadManager）
EventBus.shared.post(DownloadCompletedEvent(...))

// 订阅者（任何地方）
EventBus.shared.subscribe(DownloadCompletedEvent.self, observer: self) { ... }
```

### 4. 线程控制
可以指定回调在哪个线程执行

```swift
// 主线程回调（更新 UI）
EventBus.shared.subscribe(Event.self, observer: self, queue: .main) { ... }

// 后台线程回调（耗时操作）
EventBus.shared.subscribe(Event.self, observer: self, queue: .global()) { ... }
```

---

## 🎯 学习路径

### 第一步：理解基本概念（5分钟）
- 什么是 EventBus？
- 发布-订阅模式
- 为什么需要 EventBus？

### 第二步：运行演示（10分钟）
- 启动项目
- 点击各个按钮
- 观察日志输出
- 理解事件流转

### 第三步：阅读代码（20分钟）
- 查看 `EventBus.swift` - 核心实现
- 查看 `EventBusExample.swift` - 使用示例
- 理解订阅和发布的流程

### 第四步：实际应用（30分钟）
- 在下载管理器中集成 EventBus
- 发布下载完成事件
- 在其他地方订阅事件
- 测试效果

### 第五步：面试准备（15分钟）
- EventBus vs NotificationCenter？
- EventBus vs Delegate？
- 如何避免循环引用？
- 如何保证线程安全？

---

## 💡 实战练习

### 练习1：为下载管理器添加 EventBus

```swift
// 在 DownloadManager.swift 中
func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
    // ... 现有代码 ...
    
    // 发布下载完成事件
    let event = DownloadCompletedEvent(
        fileName: task.fileName,
        fileSize: task.totalBytes
    )
    EventBus.shared.post(event)
}
```

### 练习2：创建自定义事件

```swift
// 定义下载失败事件
struct DownloadFailedEvent: Event {
    var name: String { "DownloadFailed" }
    let fileName: String
    let error: String
}

// 发布
EventBus.shared.post(DownloadFailedEvent(fileName: "file.zip", error: "网络错误"))

// 订阅
EventBus.shared.subscribe(DownloadFailedEvent.self, observer: self) { event in
    print("下载失败：\(event.fileName), 原因：\(event.error)")
}
```

### 练习3：多个页面监听同一事件

```swift
// PageA.swift
EventBus.shared.subscribe(UserLoginEvent.self, observer: self) { event in
    print("PageA 收到登录事件")
    self.loadUserData()
}

// PageB.swift
EventBus.shared.subscribe(UserLoginEvent.self, observer: self) { event in
    print("PageB 收到登录事件")
    self.updateUI()
}

// PageC.swift
EventBus.shared.subscribe(UserLoginEvent.self, observer: self) { event in
    print("PageC 收到登录事件")
    self.refreshContent()
}

// 登录成功后，一次发布，三个页面都收到
EventBus.shared.post(UserLoginEvent(userId: "123", userName: "张三"))
```

---

## 🐛 常见问题

### Q1: 日志不显示？
**A:** 检查是否正确订阅了事件，observer 参数应该是 self

### Q2: 内存泄漏？
**A:** 确保在闭包中使用 `[weak self]`，并在 deinit 中取消订阅

### Q3: 回调不在主线程？
**A:** 使用 `queue: .main` 参数指定主线程回调

### Q4: 订阅无效？
**A:** 检查 observer 是否被释放，EventBus 自动清理已释放的订阅者

---

## 📚 相关资源

### 项目文件
- `EventBus.swift` - 核心实现（约 200 行）
- `EventBusExample.swift` - 完整演示（约 500 行）
- `EventBus使用说明.md` - 详细文档

### 学习材料
- 观察者模式
- 发布-订阅模式
- Swift 泛型编程
- iOS 多线程编程

---

**现在就运行项目，体验 EventBus 的强大功能！🚀**

## ✅ 检查清单

运行前确认：
- [ ] 已将 EventBusExample.swift 添加到项目
- [ ] 已修改 ViewController 或 SceneDelegate
- [ ] 项目可以成功编译
- [ ] 准备好观察日志输出

运行后确认：
- [ ] 页面成功打开
- [ ] 日志显示"已订阅所有事件"
- [ ] 点击按钮有日志输出
- [ ] 理解事件的发布和订阅流程

---

**准备就绪，立即体验！💪**

