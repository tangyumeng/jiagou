# 下载管理器 - MVVM 架构改造方案

## 📦 架构对比

### 当前架构（MVC）

```
┌────────────────────────────────┐
│      ViewController            │
│  - UI展示                       │
│  - 业务逻辑（混在一起）         │
│  - 直接操作 DownloadManager     │
└──────────┬─────────────────────┘
           │
┌──────────▼─────────────────────┐
│    DownloadManager              │
│  - 业务逻辑                     │
│  - 数据管理                     │
└─────────────────────────────────┘
```

**问题：**
- ❌ ViewController 臃肿（God Class）
- ❌ 业务逻辑和 UI 耦合
- ❌ 难以测试
- ❌ 难以复用

### MVVM 架构

```
┌────────────────────────────────┐
│         View                   │
│      (ViewController)          │
│  - 纯 UI 展示                  │
│  - 绑定 ViewModel              │
└──────────┬─────────────────────┘
           │ 数据绑定
           │ (观察者模式)
┌──────────▼─────────────────────┐
│       ViewModel                │
│  - 业务逻辑                    │
│  - 数据转换                    │
│  - 状态管理                    │
└──────────┬─────────────────────┘
           │
┌──────────▼─────────────────────┐
│       Model                    │
│  (DownloadManager + Task)      │
│  - 数据模型                    │
│  - 网络请求                    │
└─────────────────────────────────┘
```

**优点：**
- ✅ 职责清晰
- ✅ 易于测试
- ✅ 易于复用
- ✅ 业务逻辑独立

---

## 💻 MVVM 实现代码

### 1. ViewModel

```swift
import Foundation

// MARK: - 下载任务 ViewModel
class DownloadTaskViewModel {
    
    // MARK: - 模型
    private let task: DownloadTask
    private let manager = DownloadManager.shared
    
    // MARK: - 可观察属性（绑定到 View）
    
    // 文件名
    var fileName: String {
        return task.fileName
    }
    
    // 状态描述
    var stateDescription: Observable<String> = Observable("")
    
    // 进度百分比
    var progressText: Observable<String> = Observable("0%")
    
    // 下载速度
    var speedText: Observable<String> = Observable("")
    
    // 进度值（0-1）
    var progress: Observable<Float> = Observable(0.0)
    
    // 按钮标题（"暂停" 或 "继续"）
    var buttonTitle: Observable<String> = Observable("暂停")
    
    // 按钮是否可用
    var buttonEnabled: Observable<Bool> = Observable(false)
    
    // MARK: - 初始化
    init(task: DownloadTask) {
        self.task = task
        setupBindings()
        updateUI()
    }
    
    // MARK: - 绑定
    private func setupBindings() {
        // 监听任务状态变化
        task.onStateChanged = { [weak self] _ in
            self?.updateUI()
        }
        
        // 监听进度变化
        task.onProgressChanged = { [weak self] _ in
            self?.updateUI()
        }
    }
    
    // MARK: - 更新 UI 数据
    private func updateUI() {
        stateDescription.value = task.stateDescription()
        progressText.value = String(format: "%.1f%%", task.progress * 100)
        speedText.value = task.formattedSpeed()
        progress.value = Float(task.progress)
        
        // 更新按钮状态
        switch task.state {
        case .downloading:
            buttonTitle.value = "暂停"
            buttonEnabled.value = true
        case .paused:
            buttonTitle.value = "继续"
            buttonEnabled.value = true
        case .waiting:
            buttonTitle.value = "等待中"
            buttonEnabled.value = false
        case .completed:
            buttonTitle.value = "已完成"
            buttonEnabled.value = false
        case .failed:
            buttonTitle.value = "重试"
            buttonEnabled.value = true
        case .cancelled:
            buttonTitle.value = "已取消"
            buttonEnabled.value = false
        }
    }
    
    // MARK: - 用户操作
    
    /// 切换下载状态（暂停/继续）
    func toggleDownload() {
        switch task.state {
        case .downloading:
            manager.pauseDownload(taskId: task.id)
        case .paused, .failed:
            manager.startDownload(taskId: task.id)
        default:
            break
        }
    }
    
    /// 删除任务
    func deleteTask() {
        manager.removeTask(taskId: task.id)
    }
}

// MARK: - 下载列表 ViewModel
class DownloadListViewModel {
    
    // MARK: - 属性
    private let manager = DownloadManager.shared
    
    // 任务列表（可观察）
    var taskViewModels: Observable<[DownloadTaskViewModel]> = Observable([])
    
    // 标题
    var title: String {
        return "下载管理器"
    }
    
    // MARK: - 初始化
    init() {
        manager.delegate = self
        loadTasks()
    }
    
    // MARK: - 数据加载
    private func loadTasks() {
        let tasks = manager.getAllTasks()
        taskViewModels.value = tasks.map { DownloadTaskViewModel(task: $0) }
    }
    
    // MARK: - 用户操作
    
    /// 添加下载任务
    func addTask(url: URL, fileName: String?) {
        let task = manager.addTask(url: url, fileName: fileName)
        manager.startDownload(taskId: task.id)
        loadTasks()
    }
    
    /// 清除已完成任务
    func clearCompletedTasks() {
        manager.clearCompletedTasks()
        loadTasks()
    }
    
    /// 获取任务数量
    var taskCount: Int {
        return taskViewModels.value.count
    }
}

// MARK: - DownloadManagerDelegate
extension DownloadListViewModel: DownloadManagerDelegate {
    func downloadManager(_ manager: DownloadManager, didUpdateTask task: DownloadTask) {
        // ViewModel 会自动更新，无需手动刷新
    }
    
    func downloadManager(_ manager: DownloadManager, didCompleteTask task: DownloadTask) {
        print("✅ 下载完成：\(task.fileName)")
    }
    
    func downloadManager(_ manager: DownloadManager, didFailTask task: DownloadTask, withError error: Error) {
        print("❌ 下载失败：\(task.fileName)")
    }
}
```

### 2. Observable（数据绑定）

```swift
// MARK: - 可观察对象（用于数据绑定）
class Observable<T> {
    
    // 值（didSet 触发回调）
    var value: T {
        didSet {
            listener?(value)
        }
    }
    
    // 监听器
    private var listener: ((T) -> Void)?
    
    // 初始化
    init(_ value: T) {
        self.value = value
    }
    
    // 绑定（View 订阅变化）
    func bind(listener: @escaping (T) -> Void) {
        self.listener = listener
        listener(value)  // 立即执行一次
    }
}
```

### 3. View（ViewController）

```swift
import UIKit

// MARK: - MVVM 版本的 ViewController
class DownloadListViewController: UIViewController {
    
    // MARK: - ViewModel
    private let viewModel = DownloadListViewModel()
    
    // MARK: - UI
    private let tableView = UITableView()
    
    // MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        bindViewModel()
    }
    
    // MARK: - 设置 UI
    private func setupUI() {
        title = viewModel.title
        view.backgroundColor = .systemBackground
        
        // 配置 TableView...
        tableView.register(DownloadTaskCell.self, forCellReuseIdentifier: "Cell")
        tableView.delegate = self
        tableView.dataSource = self
        
        view.addSubview(tableView)
        // Auto Layout...
    }
    
    // MARK: - 绑定 ViewModel
    private func bindViewModel() {
        // 监听任务列表变化，自动刷新 UI
        viewModel.taskViewModels.bind { [weak self] _ in
            self?.tableView.reloadData()
        }
    }
    
    // MARK: - 用户操作
    @objc private func addTask() {
        // 弹出输入框，获取 URL
        // ...
        let url = URL(string: "https://example.com/file.zip")!
        viewModel.addTask(url: url, fileName: nil)
    }
    
    @objc private func clearCompleted() {
        viewModel.clearCompletedTasks()
    }
}

// MARK: - TableView DataSource
extension DownloadListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.taskCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! DownloadTaskCell
        
        let taskVM = viewModel.taskViewModels.value[indexPath.row]
        cell.configure(with: taskVM)  // 配置 Cell
        
        return cell
    }
}

// MARK: - Cell 配置
extension DownloadTaskCell {
    func configure(with viewModel: DownloadTaskViewModel) {
        // 绑定 ViewModel 的数据到 UI
        fileNameLabel.text = viewModel.fileName
        
        viewModel.stateDescription.bind { [weak self] text in
            self?.stateLabel.text = text
        }
        
        viewModel.progressText.bind { [weak self] text in
            self?.progressLabel.text = text
        }
        
        viewModel.speedText.bind { [weak self] text in
            self?.speedLabel.text = text
        }
        
        viewModel.progress.bind { [weak self] value in
            self?.progressView.progress = value
        }
        
        viewModel.buttonTitle.bind { [weak self] title in
            self?.actionButton.setTitle(title, for: .normal)
        }
        
        viewModel.buttonEnabled.bind { [weak self] enabled in
            self?.actionButton.isEnabled = enabled
        }
        
        // 按钮点击事件
        actionButton.addTarget(viewModel, action: #selector(viewModel.toggleDownload), for: .touchUpInside)
    }
}
```

---

## 🎯 MVVM 核心概念

### 1. **Model**
- ✅ 纯数据模型
- ✅ 不包含 UI 逻辑
- ✅ 可复用

```swift
// Model 只负责数据和基本操作
class DownloadTask {
    var progress: Double
    var state: DownloadState
    // ...
}
```

### 2. **View**
- ✅ 纯 UI 展示
- ✅ 不包含业务逻辑
- ✅ 绑定 ViewModel

```swift
// View 只负责 UI，从 ViewModel 获取数据
class ViewController {
    let viewModel = MyViewModel()
    
    func bindViewModel() {
        viewModel.title.bind { title in
            self.titleLabel.text = title
        }
    }
}
```

### 3. **ViewModel**
- ✅ 业务逻辑
- ✅ 数据转换
- ✅ 状态管理
- ✅ 不依赖 UIKit

```swift
// ViewModel 处理业务逻辑，不依赖 UI
class MyViewModel {
    var title: Observable<String> = Observable("")
    
    func loadData() {
        // 业务逻辑
        title.value = "新标题"  // 自动通知 View 更新
    }
}
```

### 4. **数据绑定**
- ✅ View 观察 ViewModel
- ✅ ViewModel 变化自动更新 View
- ✅ 单向数据流

```swift
// Observable 实现数据绑定
class Observable<T> {
    var value: T {
        didSet {
            listener?(value)  // 值改变，通知监听者
        }
    }
    
    func bind(listener: @escaping (T) -> Void) {
        self.listener = listener
        listener(value)
    }
}
```

---

## 📊 优势对比

| 对比项 | MVC | MVVM |
|--------|-----|------|
| 职责划分 | 不清晰 | 清晰 |
| ViewController | 臃肿 | 轻量 |
| 业务逻辑 | 分散 | 集中在 ViewModel |
| 可测试性 | 困难 | 容易（ViewModel 独立） |
| 可复用性 | 低 | 高（ViewModel 可复用） |
| 学习成本 | 低 | 中 |
| 代码量 | 少 | 多 |

---

## 🎤 面试要点

### 1. MVVM vs MVC？

```
MVC问题：
- Controller 臃肿（God Class）
- 业务逻辑和 UI 耦合
- 难以测试（依赖 UIKit）

MVVM优势：
- ViewModel 独立（不依赖 UIKit）
- 职责清晰
- 易于测试
- 易于复用
```

### 2. 数据绑定如何实现？

```swift
// 方案1：闭包（本示例）
class Observable<T> {
    var value: T {
        didSet { listener?(value) }
    }
}

// 方案2：KVO
@objc dynamic var title: String

// 方案3：RxSwift / Combine
let title = BehaviorSubject<String>(value: "")
```

### 3. ViewModel 能否访问 UIKit？

```
❌ 不能！

原因：
1. ViewModel 应该独立于 UI
2. 便于单元测试（不需要模拟 UI）
3. 可复用（可用于不同平台）

正确做法：
ViewModel 只暴露数据和操作
View 负责将数据展示到 UI
```

---

## 💡 总结

### MVVM 架构的价值

✅ **职责清晰** - 每层各司其职  
✅ **易于测试** - ViewModel 可独立测试  
✅ **易于维护** - 业务逻辑集中  
✅ **易于复用** - ViewModel 可复用  
✅ **更好的协作** - UI 和业务逻辑分离  

### 适用场景

✅ 复杂的业务逻辑  
✅ 需要单元测试  
✅ 团队协作开发  
✅ 需要跨平台复用  

### 不适用场景

❌ 简单的 UI 展示  
❌ 一次性的项目  
❌ 快速原型开发  

---

**MVVM 是现代 iOS 开发的主流架构！🏗️**

