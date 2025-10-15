# iOS 架构设计集合 - 面试必备项目

一个包含 **6 个热门框架设计** 的完整 iOS 项目，每个框架都有完整的实现、演示和文档，是面试准备的最佳参考。

## 🎯 包含的架构框架

### ⭐⭐⭐⭐⭐ 1. 下载管理器 + 持久化
- **并发控制** - 最多3个任务并发，智能队列调度
- **断点续传** - 暂停后继续下载，不浪费流量
- **后台下载** - App 退到后台继续下载
- **任务持久化** - App 重启后自动恢复任务
- **线程安全** - GCD 并发队列 + barrier flag

### ⭐⭐⭐⭐⭐ 2. 图片加载框架
- **三级缓存** - 内存（NSCache）→ 磁盘 → 网络
- **防重复下载** - 多个请求合并为一次下载
- **自动清理** - LRU 策略，内存警告时自动清理
- **Cell 复用安全** - 防止图片错乱
- **UIImageView 扩展** - 一行代码加载图片

### ⭐⭐⭐⭐ 3. 路由框架（URL-Based）
- **URL 模式匹配** - 支持占位符 `app://user/:userId`
- **参数自动提取** - 路径参数 + Query 参数自动合并
- **拦截器机制** - 登录验证、权限检查、埋点统计
- **多种跳转方式** - Push / Present / Replace / Custom
- **外部 URL 唤起** - 支持 URL Scheme 和 Universal Links

### ⭐⭐⭐ 4. 日志框架
- **6个日志级别** - verbose / debug / info / warning / error / fatal
- **多种输出目标** - Console / File / Remote
- **文件自动轮转** - 超过 5MB 自动轮转
- **异步写入** - 不阻塞主线程
- **远程上报** - 批量上报错误日志

### ⭐⭐⭐⭐ 5. EventBus 消息通信
- **发布-订阅模式** - 一对多通信，解耦组件
- **类型安全** - 使用 Swift 泛型，编译时检查
- **优先级订阅** - critical / high / normal / low
- **粘性事件** - 先发布后订阅也能收到
- **线程安全** - NSRecursiveLock 保护

### ⭐⭐⭐⭐⭐ 6. MVVM 架构
- **数据绑定** - Observable 实现自动更新
- **职责分离** - View / ViewModel / Model
- **易于测试** - ViewModel 不依赖 UIKit
- **易于复用** - ViewModel 可跨页面复用

---

## 🚀 快速开始

### 运行项目
```bash
cd /Users/tangyumeng/Documents/ios-learn/jiagou
open jiagou.xcodeproj
⌘ + R (Command + R)
```

### 主页导航
主页以 TableView 卡片形式展示所有架构知识点，点击任意卡片即可进入演示：

```
主页
├─ 📦 下载管理器 → 完整功能演示
├─ 🖼️ 图片加载框架 → 代码已实现
├─ 🗺️ 路由框架 → 完整交互演示 ✅
├─ 📝 日志框架 → 代码已实现
├─ 📢 EventBus 消息通信 → 完整交互演示 ✅
└─ 🏗️ MVVM 架构 → 文档已完成
```

---

## 功能特性

### ✨ 核心功能
- ✅ **多任务并发下载** - 支持最多3个任务同时下载，其他任务自动排队
- ✅ **断点续传** - 支持暂停后继续下载，不浪费已下载的数据
- ✅ **后台下载** - App退到后台也能继续下载
- ✅ **实时进度** - 显示下载进度、速度、文件大小
- ✅ **任务管理** - 支持暂停、继续、取消、删除操作
- ✅ **状态管理** - 清晰的任务状态：等待、下载中、已暂停、已完成、失败、已取消
- ✅ **线程安全** - 使用GCD保证多线程环境下的数据安全

### 🎯 用户体验
- 直观的UI界面
- 流畅的操作体验
- 完成/失败提示
- 滑动删除任务
- 一键清除已完成任务

## 项目结构

```
jiagou/
├── DownloadTask.swift          # 下载任务模型
├── DownloadManager.swift       # 下载管理器（核心）
├── DownloadTaskCell.swift      # 任务列表Cell
├── ViewController.swift        # 主界面控制器
├── AppDelegate.swift           # App入口
└── SceneDelegate.swift         # 场景管理
```

## 技术架构

### 架构模式
采用**分层架构**设计：

```
┌─────────────────────────────┐
│     表示层 (UI Layer)        │
│  ViewController + Cell       │
└──────────────┬───────────────┘
               │
┌──────────────┴───────────────┐
│   业务层 (Business Layer)    │
│     DownloadManager          │
└──────────────┬───────────────┘
               │
┌──────────────┴───────────────┐
│    模型层 (Model Layer)       │
│       DownloadTask           │
└──────────────────────────────┘
```

### 设计模式
- **单例模式** - DownloadManager全局唯一实例
- **观察者模式** - 任务状态变化自动通知
- **代理模式** - Manager与ViewController通信
- **状态模式** - 清晰的任务状态管理

### 核心技术
- `URLSession` - 网络下载
- `URLSessionDownloadDelegate` - 下载回调
- `DispatchQueue` - 线程安全
- `Auto Layout` - 纯代码UI布局

## 使用方法

### 运行项目
1. 克隆或下载项目
2. 使用 Xcode 打开 `jiagou.xcodeproj`
3. 选择模拟器或真机
4. 点击运行 (⌘R)

### 添加下载任务
1. 点击右上角的 `+` 按钮
2. 选择测试文件或输入自定义URL
3. 任务自动开始下载

### 任务操作
- **暂停**: 点击任务右侧的"暂停"按钮
- **继续**: 暂停后可以点击"继续"按钮
- **删除**: 左滑任务，点击"删除"
- **清除已完成**: 点击左上角"清除已完成"按钮

## 代码示例

### 1. 添加下载任务
```swift
let url = URL(string: "https://example.com/file.zip")!
let task = DownloadManager.shared.addTask(url: url, fileName: "myfile.zip")
DownloadManager.shared.startDownload(taskId: task.id)
```

### 2. 监听下载进度
```swift
task.onProgressChanged = { task in
    print("进度: \(task.progress * 100)%")
    print("速度: \(task.formattedSpeed())")
}

task.onStateChanged = { task in
    print("状态: \(task.stateDescription())")
}
```

### 3. 控制下载
```swift
// 暂停
DownloadManager.shared.pauseDownload(taskId: task.id)

// 继续
DownloadManager.shared.startDownload(taskId: task.id)

// 取消
DownloadManager.shared.cancelDownload(taskId: task.id)

// 删除
DownloadManager.shared.removeTask(taskId: task.id)
```

### 4. 实现代理
```swift
extension YourViewController: DownloadManagerDelegate {
    func downloadManager(_ manager: DownloadManager, didCompleteTask task: DownloadTask) {
        print("✅ 下载完成: \(task.fileName)")
    }
    
    func downloadManager(_ manager: DownloadManager, didFailTask task: DownloadTask, withError error: Error) {
        print("❌ 下载失败: \(error.localizedDescription)")
    }
    
    func downloadManager(_ manager: DownloadManager, didUpdateTask task: DownloadTask) {
        // 更新UI
    }
}
```

## 配置说明

### 修改最大并发数
在 `DownloadManager.swift` 中修改：
```swift
private let maxConcurrentDownloads = 3  // 改为你想要的数量
```

### 修改下载目录
在 `DownloadManager.swift` 中修改：
```swift
private lazy var downloadDirectory: URL = {
    let paths = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
    let documentsDirectory = paths[0]
    return documentsDirectory.appendingPathComponent("Downloads")
}()
```

### 添加自定义测试URL
在 `ViewController.swift` 中修改：
```swift
private let testURLs = [
    "https://your-url-1.com/file1.zip",
    "https://your-url-2.com/file2.pdf",
    // ... 添加更多
]
```

## 文件说明

### DownloadTask.swift
下载任务模型，包含：
- 任务属性（URL、状态、进度等）
- 进度计算和速度计算
- 观察者回调机制
- 格式化工具方法

### DownloadManager.swift
下载管理器，负责：
- 任务的增删改查
- 并发控制和队列调度
- URLSession管理
- 文件操作
- 线程安全保障

### DownloadTaskCell.swift
自定义TableViewCell，显示：
- 文件名
- 下载状态
- 进度条和百分比
- 下载速度
- 操作按钮

### ViewController.swift
主界面控制器，实现：
- UI布局和交互
- 任务列表管理
- 代理回调处理
- 用户操作响应

## 高级特性

### 1. 线程安全
使用并发队列保护共享数据：
```swift
private let taskQueue = DispatchQueue(
    label: "com.jiagou.downloadmanager", 
    attributes: .concurrent
)

// 读操作
taskQueue.sync { ... }

// 写操作
taskQueue.async(flags: .barrier) { ... }
```

### 2. 内存管理
避免循环引用：
```swift
task.onProgressChanged = { [weak self] task in
    self?.updateUI(task)
}
```

### 3. 主线程更新UI
所有UI更新都在主线程：
```swift
DispatchQueue.main.async {
    // 更新UI
}
```

## 测试文件

项目内置了几个测试下载URL：
- 100MB测试文件
- 1GB大文件
- 视频文件（MP4）

这些文件来自可靠的测试服务器，可以安全下载。

## 注意事项

1. **网络权限**
   - 确保在 Info.plist 中配置了网络访问权限
   - 如需访问HTTP（非HTTPS）地址，需配置 App Transport Security

2. **存储空间**
   - 下载大文件前确保设备有足够的存储空间
   - 文件保存在 Documents/Downloads 目录

3. **后台下载限制**
   - 后台下载受系统限制，不是无限制的
   - 系统可能会根据电量、网络等条件暂停下载

4. **真机测试**
   - 部分功能在真机上表现更好
   - 后台下载建议在真机上测试

## 扩展建议

### 可以添加的功能
- [ ] 任务持久化（CoreData / Realm）
- [ ] 下载历史记录
- [ ] 下载优先级设置
- [ ] WiFi Only模式
- [ ] 流量统计
- [ ] 下载分类和文件管理
- [ ] 搜索和筛选功能
- [ ] 分享已下载文件
- [ ] 下载队列导入导出

### 优化方向
- [ ] 使用 Combine / RxSwift 简化异步操作
- [ ] 添加单元测试
- [ ] 性能监控和日志系统
- [ ] 支持 SwiftUI
- [ ] 多语言国际化
- [ ] 深色模式适配优化

## 架构分析

详细的架构分析请查看 [架构分析.md](./架构分析.md)，包含：
- 整体架构设计
- 设计模式详解
- 技术实现原理
- 性能优化策略
- 改进方向建议

## 系统要求

- iOS 13.0+
- Xcode 12.0+
- Swift 5.0+

## 开源协议

本项目仅供学习参考使用。

## 贡献

欢迎提交 Issue 和 Pull Request！

## 联系方式

如有问题或建议，欢迎讨论交流。

---

**Enjoy Coding! 🚀**

