import Foundation

// MARK: - 任务数据模型
struct MVPTaskModel: Identifiable, Codable {
    let id: String
    var title: String
    var description: String
    var isCompleted: Bool
    var priority: TaskPriority
    var dueDate: Date?
    var createdAt: Date
    var updatedAt: Date
    
    init(id: String = UUID().uuidString, 
         title: String, 
         description: String = "", 
         isCompleted: Bool = false, 
         priority: TaskPriority = .medium,
         dueDate: Date? = nil) {
        self.id = id
        self.title = title
        self.description = description
        self.isCompleted = isCompleted
        self.priority = priority
        self.dueDate = dueDate
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    // 验证属性
    var isValid: Bool {
        return !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var validationErrors: [String] {
        var errors: [String] = []
        if title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors.append("任务标题不能为空")
        }
        if title.count > 100 {
            errors.append("任务标题不能超过100个字符")
        }
        if description.count > 500 {
            errors.append("任务描述不能超过500个字符")
        }
        return errors
    }
    
    // 格式化属性
    var formattedDueDate: String {
        guard let dueDate = dueDate else { return "无截止日期" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: dueDate)
    }
    
    var formattedCreatedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: createdAt)
    }
    
    var isOverdue: Bool {
        guard let dueDate = dueDate else { return false }
        return !isCompleted && dueDate < Date()
    }
    
    var statusText: String {
        if isCompleted {
            return "已完成"
        } else if isOverdue {
            return "已逾期"
        } else {
            return "进行中"
        }
    }
}

// MARK: - 任务优先级
enum TaskPriority: String, CaseIterable, Codable {
    case low = "低"
    case medium = "中"
    case high = "高"
    case urgent = "紧急"
    
    var color: String {
        switch self {
        case .low: return "systemBlue"
        case .medium: return "systemGreen"
        case .high: return "systemOrange"
        case .urgent: return "systemRed"
        }
    }
    
    var sortOrder: Int {
        switch self {
        case .urgent: return 0
        case .high: return 1
        case .medium: return 2
        case .low: return 3
        }
    }
}

// MARK: - 任务操作结果
enum TaskOperationResult {
    case success(String)
    case failure(String)
}

// MARK: - 任务数据服务协议
protocol TaskDataServiceProtocol {
    func fetchTasks(completion: @escaping ([MVPTaskModel]) -> Void)
    func fetchTask(id: String, completion: @escaping (MVPTaskModel?) -> Void)
    func createTask(_ task: MVPTaskModel, completion: @escaping (TaskOperationResult) -> Void)
    func updateTask(_ task: MVPTaskModel, completion: @escaping (TaskOperationResult) -> Void)
    func deleteTask(id: String, completion: @escaping (TaskOperationResult) -> Void)
    func searchTasks(query: String, completion: @escaping ([MVPTaskModel]) -> Void)
    func filterTasks(by priority: TaskPriority?, completion: @escaping ([MVPTaskModel]) -> Void)
    func sortTasks(by sortType: TaskSortType, completion: @escaping ([MVPTaskModel]) -> Void)
}

// MARK: - 任务排序类型
enum TaskSortType: String, CaseIterable {
    case createdAt = "创建时间"
    case dueDate = "截止时间"
    case priority = "优先级"
    case title = "标题"
    case status = "状态"
}

// MARK: - 模拟任务数据服务
class TaskDataService: TaskDataServiceProtocol {
    private var tasks: [MVPTaskModel] = []
    private let queue = DispatchQueue(label: "com.jiagou.taskdataservice", qos: .utility)
    
    init() {
        loadMockData()
    }
    
    private func loadMockData() {
        let mockTasks = [
            MVPTaskModel(
                title: "完成项目文档",
                description: "编写项目架构设计文档，包括类图和流程图",
                priority: .high,
                dueDate: Calendar.current.date(byAdding: .day, value: 3, to: Date())
            ),
            MVPTaskModel(
                title: "代码审查",
                description: "审查团队成员的代码，确保代码质量",
                priority: .medium,
                dueDate: Calendar.current.date(byAdding: .day, value: 1, to: Date())
            ),
            MVPTaskModel(
                title: "准备技术分享",
                description: "准备关于 iOS 架构设计的技术分享",
                priority: .urgent,
                dueDate: Calendar.current.date(byAdding: .hour, value: 2, to: Date())
            ),
            MVPTaskModel(
                title: "学习新技术",
                description: "学习 SwiftUI 和 Combine 框架",
                priority: .low,
                dueDate: Calendar.current.date(byAdding: .day, value: 7, to: Date())
            ),
            MVPTaskModel(
                title: "优化应用性能",
                description: "分析并优化应用启动时间和内存使用",
                priority: .high,
                dueDate: Calendar.current.date(byAdding: .day, value: 5, to: Date())
            ),
            MVPTaskModel(
                title: "修复 Bug",
                description: "修复用户反馈的崩溃问题",
                isCompleted: false,
                priority: .urgent,
                dueDate: Date().addingTimeInterval(-3600) // 1小时前，已逾期
            ),
            MVPTaskModel(
                title: "更新依赖库",
                description: "更新项目中的第三方依赖库到最新版本",
                isCompleted: true,
                priority: .medium,
                dueDate: Calendar.current.date(byAdding: .day, value: 2, to: Date())
            )
        ]
        
        tasks = mockTasks
    }
    
    func fetchTasks(completion: @escaping ([MVPTaskModel]) -> Void) {
        queue.async {
            // 模拟网络延迟
            Thread.sleep(forTimeInterval: 0.5)
            DispatchQueue.main.async {
                completion(self.tasks)
            }
        }
    }
    
    func fetchTask(id: String, completion: @escaping (MVPTaskModel?) -> Void) {
        queue.async {
            Thread.sleep(forTimeInterval: 0.3)
            DispatchQueue.main.async {
                completion(self.tasks.first(where: { $0.id == id }))
            }
        }
    }
    
    func createTask(_ task: MVPTaskModel, completion: @escaping (TaskOperationResult) -> Void) {
        queue.async {
            Thread.sleep(forTimeInterval: 0.8)
            DispatchQueue.main.async {
                self.tasks.append(task)
                completion(.success("任务创建成功"))
            }
        }
    }
    
    func updateTask(_ task: MVPTaskModel, completion: @escaping (TaskOperationResult) -> Void) {
        queue.async {
            Thread.sleep(forTimeInterval: 0.6)
            DispatchQueue.main.async {
                if let index = self.tasks.firstIndex(where: { $0.id == task.id }) {
                    var updatedTask = task
                    updatedTask.updatedAt = Date()
                    self.tasks[index] = updatedTask
                    completion(.success("任务更新成功"))
                } else {
                    completion(.failure("任务不存在"))
                }
            }
        }
    }
    
    func deleteTask(id: String, completion: @escaping (TaskOperationResult) -> Void) {
        queue.async {
            Thread.sleep(forTimeInterval: 0.4)
            DispatchQueue.main.async {
                if let index = self.tasks.firstIndex(where: { $0.id == id }) {
                    self.tasks.remove(at: index)
                    completion(.success("任务删除成功"))
                } else {
                    completion(.failure("任务不存在"))
                }
            }
        }
    }
    
    func searchTasks(query: String, completion: @escaping ([MVPTaskModel]) -> Void) {
        queue.async {
            Thread.sleep(forTimeInterval: 0.3)
            DispatchQueue.main.async {
                let filteredTasks = self.tasks.filter { task in
                    task.title.localizedCaseInsensitiveContains(query) ||
                    task.description.localizedCaseInsensitiveContains(query)
                }
                completion(filteredTasks)
            }
        }
    }
    
    func filterTasks(by priority: TaskPriority?, completion: @escaping ([MVPTaskModel]) -> Void) {
        queue.async {
            Thread.sleep(forTimeInterval: 0.2)
            DispatchQueue.main.async {
                if let priority = priority {
                    let filteredTasks = self.tasks.filter { $0.priority == priority }
                    completion(filteredTasks)
                } else {
                    completion(self.tasks)
                }
            }
        }
    }
    
    func sortTasks(by sortType: TaskSortType, completion: @escaping ([MVPTaskModel]) -> Void) {
        queue.async {
            Thread.sleep(forTimeInterval: 0.2)
            DispatchQueue.main.async {
                let sortedTasks = self.tasks.sorted { task1, task2 in
                    switch sortType {
                    case .createdAt:
                        return task1.createdAt > task2.createdAt
                    case .dueDate:
                        if let date1 = task1.dueDate, let date2 = task2.dueDate {
                            return date1 < date2
                        } else if task1.dueDate != nil {
                            return true
                        } else {
                            return false
                        }
                    case .priority:
                        return task1.priority.sortOrder < task2.priority.sortOrder
                    case .title:
                        return task1.title.localizedCaseInsensitiveCompare(task2.title) == .orderedAscending
                    case .status:
                        if task1.isCompleted != task2.isCompleted {
                            return !task1.isCompleted && task2.isCompleted
                        }
                        return task1.priority.sortOrder < task2.priority.sortOrder
                    }
                }
                completion(sortedTasks)
            }
        }
    }
}
