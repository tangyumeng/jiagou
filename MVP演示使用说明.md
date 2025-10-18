# MVP 设计模式演示使用说明

## 📝 功能概述

本项目新增了完整的 MVP (Model-View-Presenter) 设计模式演示，使用纯 UIKit 实现，展示了现代 iOS 开发中的架构设计最佳实践。

**核心特性**:
- ✅ 完整的三层架构（Model-View-Presenter）
- ✅ 任务管理完整功能（CRUD 操作）
- ✅ 搜索、排序、过滤功能
- ✅ 优先级管理
- ✅ 截止时间设置
- ✅ 纯 UIKit 实现（无 SwiftUI）
- ✅ 易于测试的架构设计

---

## 🚀 快速启动

### 从主页进入

1. 运行项目
2. 在主页找到 **"MVP 架构"** 按钮（青色）
3. 点击进入 MVP 演示界面

### 代码启动

```swift
let mvpVC = MVPDemoViewController()
navigationController?.pushViewController(mvpVC, animated: true)
```

---

## 📊 功能演示

### 1. 任务列表演示

**主要功能**:
- ✅ 任务列表展示
- ✅ 搜索功能（标题和描述）
- ✅ 优先级过滤
- ✅ 多种排序方式
- ✅ 任务完成状态切换
- ✅ 左滑删除和编辑
- ✅ 下拉刷新

**操作步骤**:
```
1. 点击 "📋 任务列表演示"
2. 查看预设的 7 个示例任务
3. 在搜索框输入关键词进行搜索
4. 使用优先级过滤器筛选任务
5. 点击排序按钮选择排序方式
6. 点击任务左侧的圆圈切换完成状态
7. 左滑任务进行删除或编辑
8. 下拉列表进行刷新
```

### 2. 任务详情演示

**主要功能**:
- ✅ 任务详细信息展示
- ✅ 优先级颜色标识
- ✅ 状态显示（进行中/已完成/已逾期）
- ✅ 截止时间显示
- ✅ 创建和更新时间
- ✅ 完成状态切换
- ✅ 编辑和删除功能

**操作步骤**:
```
1. 从任务列表点击任意任务
2. 查看任务的完整信息
3. 点击 "标记为完成/未完成" 切换状态
4. 点击 "编辑任务" 修改信息
5. 点击 "删除任务" 删除任务
```

### 3. 添加任务演示

**主要功能**:
- ✅ 任务标题输入
- ✅ 任务描述输入
- ✅ 优先级选择
- ✅ 截止时间设置
- ✅ 输入验证

**操作步骤**:
```
1. 在任务列表页面点击右上角 "+" 按钮
2. 输入任务标题（必填）
3. 输入任务描述（可选）
4. 选择优先级（低/中/高/紧急）
5. 开启截止时间开关并选择时间
6. 点击 "创建任务" 保存
```

---

## 🏗️ 架构说明

### MVP 三层架构

```
┌─────────────────────────────────────┐
│              View                    │
│         (用户界面层)                 │
│                                     │
│  • MVPTaskListViewController        │
│  • MVPTaskDetailViewController      │
│  • MVPTaskCell                      │
│  • 只负责显示和用户交互              │
└──────────────┬──────────────────────┘
               │ 用户操作
               │ 界面更新
               ↓
┌─────────────────────────────────────┐
│            Presenter                 │
│         (业务逻辑层)                │
│                                     │
│  • MVPTaskListPresenter             │
│  • MVPTaskDetailPresenter           │
│  • 处理业务逻辑                      │
│  • 协调 Model 和 View               │
│  • 数据转换和验证                    │
│  • 可独立测试                        │
└──────────────┬──────────────────────┘
               │ 数据请求
               │ 业务处理
               ↓
┌─────────────────────────────────────┐
│              Model                   │
│         (数据模型层)                 │
│                                     │
│  • MVPTaskModel                     │
│  • TaskDataServiceProtocol          │
│  • TaskDataService                  │
│  • 数据结构定义                      │
│  • 数据访问服务                      │
│  • 数据持久化                        │
└─────────────────────────────────────┘
```

### 数据流向

```
用户操作 → View → Presenter → Model
Model → Presenter → View → 界面更新
```

**特点**:
- View 和 Model 不直接通信
- Presenter 作为中间层
- 职责分离清晰
- 易于单元测试

---

## 💻 代码使用示例

### 基本使用

```swift
// 1. 创建 Presenter
let presenter = MVPTaskListPresenter()
presenter.setView(viewController)

// 2. 加载任务
presenter.loadTasks()

// 3. 创建任务
presenter.createTask(
    title: "新任务",
    description: "任务描述",
    priority: .high,
    dueDate: Date()
)

// 4. 更新任务
var task = existingTask
task.isCompleted = true
presenter.updateTask(task)

// 5. 删除任务
presenter.deleteTask(id: taskId)
```

### View 协议实现

```swift
class TaskViewController: UIViewController, MVPTaskViewProtocol {
    private var presenter: MVPTaskListPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPresenter()
        presenter.viewDidLoad()
    }
    
    private func setupPresenter() {
        presenter = MVPTaskListPresenter()
        presenter.setView(self)
    }
    
    // MARK: - MVPTaskViewProtocol
    func showTasks(_ tasks: [MVPTaskModel]) {
        // 更新 UI
        tableView.reloadData()
    }
    
    func showError(_ message: String) {
        // 显示错误提示
        let alert = UIAlertController(title: "错误", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
    
    func showLoading(_ isLoading: Bool) {
        // 显示/隐藏加载指示器
        if isLoading {
            // 显示加载动画
        } else {
            // 隐藏加载动画
        }
    }
}
```

### Presenter 实现

```swift
class MVPTaskListPresenter: MVPTaskPresenterProtocol {
    weak var view: MVPTaskViewProtocol?
    private let dataService: TaskDataServiceProtocol
    
    init(dataService: TaskDataServiceProtocol = TaskDataService()) {
        self.dataService = dataService
    }
    
    func setView(_ view: MVPTaskViewProtocol) {
        self.view = view
    }
    
    func loadTasks() {
        view?.showLoading(true)
        dataService.fetchTasks { [weak self] tasks in
            DispatchQueue.main.async {
                self?.view?.showLoading(false)
                self?.view?.showTasks(tasks)
            }
        }
    }
    
    func createTask(title: String, description: String, priority: TaskPriority, dueDate: Date?) {
        // 验证输入
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            view?.showError("任务标题不能为空")
            return
        }
        
        let newTask = MVPTaskModel(
            title: title,
            description: description,
            priority: priority,
            dueDate: dueDate
        )
        
        view?.showLoading(true)
        dataService.createTask(newTask) { [weak self] result in
            DispatchQueue.main.async {
                self?.view?.showLoading(false)
                switch result {
                case .success(let message):
                    self?.view?.showSuccess(message)
                    self?.loadTasks()
                case .failure(let error):
                    self?.view?.showError(error)
                }
            }
        }
    }
}
```

---

## 🔧 高级功能

### 1. 搜索和过滤

```swift
// 搜索任务
presenter.searchTasks(query: "重要")

// 按优先级过滤
presenter.filterTasks(by: .high)

// 清除搜索
presenter.clearSearch()
```

### 2. 排序功能

```swift
// 按创建时间排序
presenter.sortTasks(by: .createdAt)

// 按优先级排序
presenter.sortTasks(by: .priority)

// 按截止时间排序
presenter.sortTasks(by: .dueDate)
```

### 3. 任务状态管理

```swift
// 切换完成状态
presenter.toggleTaskCompletion(id: taskId)

// 检查任务是否逾期
let isOverdue = task.isOverdue

// 获取任务状态文本
let statusText = task.statusText
```

### 4. 数据验证

```swift
// 验证任务模型
if task.isValid {
    // 任务有效
} else {
    // 显示验证错误
    let errors = task.validationErrors
    for error in errors {
        print("验证错误: \(error)")
    }
}
```

---

## 🎯 使用场景

### 场景1：任务管理应用

```swift
// 创建任务管理 Presenter
let taskPresenter = MVPTaskListPresenter()

// 设置 View
taskPresenter.setView(taskViewController)

// 加载任务
taskPresenter.loadTasks()

// 用户创建新任务
taskPresenter.createTask(
    title: "完成项目文档",
    description: "编写详细的项目文档",
    priority: .high,
    dueDate: Calendar.current.date(byAdding: .day, value: 3, to: Date())
)
```

### 场景2：数据展示应用

```swift
// 搜索功能
presenter.searchTasks(query: "紧急")

// 过滤高优先级任务
presenter.filterTasks(by: .urgent)

// 按截止时间排序
presenter.sortTasks(by: .dueDate)
```

### 场景3：状态管理

```swift
// 标记任务完成
presenter.toggleTaskCompletion(id: taskId)

// 更新任务信息
var updatedTask = task
updatedTask.title = "更新后的标题"
presenter.updateTask(updatedTask)

// 删除任务
presenter.deleteTask(id: taskId)
```

---

## 📚 API 文档

### MVPTaskPresenterProtocol

**方法**:

| 方法 | 说明 |
|------|------|
| `viewDidLoad()` | 视图加载完成 |
| `loadTasks()` | 加载任务列表 |
| `refreshTasks()` | 刷新任务列表 |
| `createTask(title:description:priority:dueDate:)` | 创建新任务 |
| `updateTask(_:)` | 更新任务 |
| `deleteTask(id:)` | 删除任务 |
| `toggleTaskCompletion(id:)` | 切换任务完成状态 |
| `selectTask(_:)` | 选择任务 |
| `searchTasks(query:)` | 搜索任务 |
| `filterTasks(by:)` | 按优先级过滤 |
| `sortTasks(by:)` | 排序任务 |
| `clearSearch()` | 清除搜索 |

### MVPTaskViewProtocol

**方法**:

| 方法 | 说明 |
|------|------|
| `showLoading(_:)` | 显示/隐藏加载状态 |
| `showTasks(_:)` | 显示任务列表 |
| `showError(_:)` | 显示错误信息 |
| `showSuccess(_:)` | 显示成功信息 |
| `refreshTaskList()` | 刷新任务列表 |
| `showTaskDetail(_:)` | 显示任务详情 |
| `hideTaskDetail()` | 隐藏任务详情 |
| `updateTaskInList(_:)` | 更新列表中的任务 |
| `removeTaskFromList(id:)` | 从列表中移除任务 |
| `showEmptyState(_:)` | 显示/隐藏空状态 |

### MVPTaskModel

**属性**:

| 属性 | 类型 | 说明 |
|------|------|------|
| `id` | `String` | 任务唯一标识 |
| `title` | `String` | 任务标题 |
| `description` | `String` | 任务描述 |
| `isCompleted` | `Bool` | 是否完成 |
| `priority` | `TaskPriority` | 优先级 |
| `dueDate` | `Date?` | 截止时间 |
| `createdAt` | `Date` | 创建时间 |
| `updatedAt` | `Date` | 更新时间 |

**方法**:

| 方法 | 说明 |
|------|------|
| `isValid` | 验证任务是否有效 |
| `validationErrors` | 获取验证错误列表 |
| `formattedDueDate` | 格式化的截止时间 |
| `formattedCreatedDate` | 格式化的创建时间 |
| `isOverdue` | 是否逾期 |
| `statusText` | 状态文本 |

---

## 🎨 演示界面说明

### 主界面布局

```
┌──────────────────────────────────────┐
│        MVP 设计模式演示               │
├──────────────────────────────────────┤
│  Model-View-Presenter 架构模式        │
│                                      │
│  • Model: 数据和业务逻辑              │
│  • View: 用户界面                    │
│  • Presenter: 连接 Model 和 View      │
├──────────────────────────────────────┤
│  [ 📋 任务列表演示 ]                  │
│  [ 🏗️ MVP 架构图 ]                   │
│  [ 💻 代码示例 ]                     │
│  [ ⚖️ 模式对比 ]                     │
└──────────────────────────────────────┘
```

### 任务列表界面

```
┌──────────────────────────────────────┐
│  任务管理                    [+] [排序] │
├──────────────────────────────────────┤
│  [搜索框]                            │
│  [全部] [低] [中] [高] [紧急]          │
├──────────────────────────────────────┤
│  ○ 完成项目文档              [高] 进行中 │
│  ○ 代码审查                  [中] 进行中 │
│  ● 准备技术分享              [紧急] 进行中│
│  ○ 学习新技术                [低] 进行中 │
│  ○ 优化应用性能              [高] 进行中 │
│  ○ 修复 Bug                 [紧急] 已逾期│
│  ● 更新依赖库                [中] 已完成 │
└──────────────────────────────────────┘
```

### 任务详情界面

```
┌──────────────────────────────────────┐
│  任务详情                    [编辑]    │
├──────────────────────────────────────┤
│  完成项目文档                        │
│  编写项目架构设计文档，包括类图和流程图  │
│  [高]                               │
│  状态：进行中                        │
│  截止时间：2025-10-19 18:00          │
│  创建时间：2025-10-16 20:00          │
│  更新时间：2025-10-16 20:00          │
├──────────────────────────────────────┤
│  [ 标记为完成 ]                      │
│  [ 编辑任务 ]                        │
│  [ 删除任务 ]                        │
└──────────────────────────────────────┘
```

---

## 💡 最佳实践

### 1. Presenter 设计

**职责分离**:
```swift
// ✅ 好的做法：Presenter 只处理业务逻辑
class TaskPresenter {
    func loadTasks() {
        // 业务逻辑
        dataService.fetchTasks { [weak self] tasks in
            // 数据处理
            self?.view?.showTasks(tasks)
        }
    }
}

// ❌ 不好的做法：Presenter 处理 UI 细节
class TaskPresenter {
    func loadTasks() {
        // 不应该直接操作 UI 组件
        tableView.reloadData()
    }
}
```

**依赖注入**:
```swift
// ✅ 好的做法：支持依赖注入
class TaskPresenter {
    private let dataService: TaskDataServiceProtocol
    
    init(dataService: TaskDataServiceProtocol) {
        self.dataService = dataService
    }
}

// 测试时可以注入 Mock 服务
let mockService = MockTaskDataService()
let presenter = TaskPresenter(dataService: mockService)
```

### 2. View 设计

**协议实现**:
```swift
// ✅ 好的做法：实现 View 协议
class TaskViewController: UIViewController, MVPTaskViewProtocol {
    // 实现所有协议方法
}

// ❌ 不好的做法：不实现协议
class TaskViewController: UIViewController {
    // 没有协议约束，容易遗漏方法
}
```

**弱引用**:
```swift
// ✅ 好的做法：使用弱引用避免循环引用
class TaskPresenter {
    weak var view: MVPTaskViewProtocol?
}

// ❌ 不好的做法：强引用导致循环引用
class TaskPresenter {
    var view: MVPTaskViewProtocol? // 强引用
}
```

### 3. Model 设计

**数据验证**:
```swift
// ✅ 好的做法：在 Model 中验证数据
struct TaskModel {
    var title: String
    
    var isValid: Bool {
        return !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var validationErrors: [String] {
        var errors: [String] = []
        if title.isEmpty {
            errors.append("标题不能为空")
        }
        return errors
    }
}
```

**服务抽象**:
```swift
// ✅ 好的做法：使用协议抽象服务
protocol TaskDataServiceProtocol {
    func fetchTasks(completion: @escaping ([TaskModel]) -> Void)
}

// 实现类
class TaskDataService: TaskDataServiceProtocol {
    // 具体实现
}

// Mock 实现
class MockTaskDataService: TaskDataServiceProtocol {
    // 测试实现
}
```

---

## 🧪 单元测试

### Presenter 测试

```swift
class TaskPresenterTests: XCTestCase {
    var presenter: TaskPresenter!
    var mockView: MockTaskView!
    var mockDataService: MockTaskDataService!
    
    override func setUp() {
        super.setUp()
        mockView = MockTaskView()
        mockDataService = MockTaskDataService()
        presenter = TaskPresenter(dataService: mockDataService)
        presenter.setView(mockView)
    }
    
    func testLoadTasks() {
        // Given
        let expectedTasks = [TaskModel(id: "1", title: "Test Task")]
        mockDataService.mockTasks = expectedTasks
        
        // When
        presenter.loadTasks()
        
        // Then
        XCTAssertTrue(mockView.showLoadingCalled)
        XCTAssertEqual(mockView.displayedTasks, expectedTasks)
    }
    
    func testCreateTaskWithEmptyTitle() {
        // When
        presenter.createTask(title: "", description: "", priority: .medium, dueDate: nil)
        
        // Then
        XCTAssertTrue(mockView.showErrorCalled)
        XCTAssertEqual(mockView.errorMessage, "任务标题不能为空")
    }
}

class MockTaskView: MVPTaskViewProtocol {
    var showLoadingCalled = false
    var displayedTasks: [TaskModel] = []
    var showErrorCalled = false
    var errorMessage: String = ""
    
    func showLoading(_ isLoading: Bool) {
        showLoadingCalled = isLoading
    }
    
    func showTasks(_ tasks: [TaskModel]) {
        displayedTasks = tasks
    }
    
    func showError(_ message: String) {
        showErrorCalled = true
        errorMessage = message
    }
    
    // 其他协议方法...
}
```

### Model 测试

```swift
class TaskModelTests: XCTestCase {
    func testTaskValidation() {
        // Given
        let validTask = TaskModel(id: "1", title: "Valid Task")
        let invalidTask = TaskModel(id: "2", title: "")
        
        // Then
        XCTAssertTrue(validTask.isValid)
        XCTAssertFalse(invalidTask.isValid)
        XCTAssertEqual(invalidTask.validationErrors.count, 1)
    }
    
    func testTaskStatus() {
        // Given
        let completedTask = TaskModel(id: "1", title: "Task", isCompleted: true)
        let overdueTask = TaskModel(
            id: "2", 
            title: "Task", 
            dueDate: Date().addingTimeInterval(-3600)
        )
        
        // Then
        XCTAssertEqual(completedTask.statusText, "已完成")
        XCTAssertTrue(overdueTask.isOverdue)
        XCTAssertEqual(overdueTask.statusText, "已逾期")
    }
}
```

---

## ⚠️ 注意事项

### 1. 内存管理

```swift
// ✅ 使用弱引用避免循环引用
class TaskPresenter {
    weak var view: MVPTaskViewProtocol?
}

// ✅ 在闭包中使用 weak self
dataService.fetchTasks { [weak self] tasks in
    DispatchQueue.main.async {
        self?.view?.showTasks(tasks)
    }
}
```

### 2. 线程安全

```swift
// ✅ 确保 UI 更新在主线程
dataService.fetchTasks { [weak self] tasks in
    DispatchQueue.main.async {
        self?.view?.showTasks(tasks)
    }
}
```

### 3. 错误处理

```swift
// ✅ 完善的错误处理
dataService.createTask(task) { [weak self] result in
    DispatchQueue.main.async {
        switch result {
        case .success(let message):
            self?.view?.showSuccess(message)
        case .failure(let error):
            self?.view?.showError(error)
        }
    }
}
```

### 4. 数据验证

```swift
// ✅ 在 Presenter 中验证数据
func createTask(title: String, description: String, priority: TaskPriority, dueDate: Date?) {
    guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
        view?.showError("任务标题不能为空")
        return
    }
    
    // 继续创建任务...
}
```

---

## 🔍 调试技巧

### 1. Presenter 调试

```swift
class TaskPresenter {
    func loadTasks() {
        print("🔄 Presenter: 开始加载任务")
        view?.showLoading(true)
        
        dataService.fetchTasks { [weak self] tasks in
            print("📦 Presenter: 收到 \(tasks.count) 个任务")
            DispatchQueue.main.async {
                self?.view?.showLoading(false)
                self?.view?.showTasks(tasks)
                print("✅ Presenter: 任务加载完成")
            }
        }
    }
}
```

### 2. View 调试

```swift
extension TaskViewController: MVPTaskViewProtocol {
    func showTasks(_ tasks: [TaskModel]) {
        print("🖥️ View: 显示 \(tasks.count) 个任务")
        tableView.reloadData()
    }
    
    func showError(_ message: String) {
        print("❌ View: 显示错误 - \(message)")
        // 显示错误提示
    }
}
```

### 3. Model 调试

```swift
extension TaskModel {
    var debugDescription: String {
        return """
        TaskModel {
            id: \(id)
            title: \(title)
            isCompleted: \(isCompleted)
            priority: \(priority.rawValue)
            dueDate: \(dueDate?.description ?? "nil")
        }
        """
    }
}
```

---

## 📊 性能优化

### 1. 数据加载优化

```swift
// ✅ 使用分页加载
func loadTasks(page: Int = 1, pageSize: Int = 20) {
    dataService.fetchTasks(page: page, pageSize: pageSize) { [weak self] tasks in
        // 处理分页数据
    }
}
```

### 2. 内存优化

```swift
// ✅ 及时释放不需要的数据
class TaskPresenter {
    private var tasks: [TaskModel] = []
    
    func clearTasks() {
        tasks.removeAll()
    }
}
```

### 3. UI 优化

```swift
// ✅ 避免频繁的 UI 更新
private var isUpdating = false

func updateTasks(_ newTasks: [TaskModel]) {
    guard !isUpdating else { return }
    isUpdating = true
    
    DispatchQueue.main.async {
        self.tasks = newTasks
        self.tableView.reloadData()
        self.isUpdating = false
    }
}
```

---

## 🎓 学习要点

### 1. 设计模式

- **MVP 模式**: Model-View-Presenter 三层架构
- **协议模式**: 定义接口，实现解耦
- **依赖注入**: 提高可测试性
- **观察者模式**: View 监听 Presenter 的状态变化

### 2. iOS 开发

- **UIKit**: 纯 UIKit 实现，无 SwiftUI 依赖
- **协议**: 使用协议定义接口
- **弱引用**: 避免循环引用
- **线程安全**: 主线程更新 UI

### 3. 架构设计

- **职责分离**: 每层只负责自己的职责
- **依赖倒置**: 依赖抽象而不是具体实现
- **单一职责**: 每个类只有一个变化的原因
- **开闭原则**: 对扩展开放，对修改关闭

---

## 📝 总结

MVP 设计模式演示展示了：

1. ✅ 完整的三层架构实现
2. ✅ 任务管理完整功能
3. ✅ 搜索、排序、过滤功能
4. ✅ 优先级和状态管理
5. ✅ 纯 UIKit 实现
6. ✅ 易于测试的架构设计
7. ✅ 最佳实践示例

这是学习 MVP 架构设计的优秀示例，展示了如何构建一个可维护、可测试的 iOS 应用。

---

## 🚀 下一步

- 体验任务管理功能
- 查看架构图和代码示例
- 理解 MVP 模式的优势
- 在自己的项目中应用 MVP 模式

祝学习愉快！📝
