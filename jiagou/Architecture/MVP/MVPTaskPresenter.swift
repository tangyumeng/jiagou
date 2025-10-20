import Foundation

// MARK: - MVP View 协议
protocol MVPTaskViewProtocol: AnyObject {
    func showLoading(_ isLoading: Bool)
    func showTasks(_ tasks: [MVPTaskModel])
    func showError(_ message: String)
    func showSuccess(_ message: String)
    func refreshTaskList()
    func showTaskDetail(_ task: MVPTaskModel)
    func hideTaskDetail()
    func updateTaskInList(_ task: MVPTaskModel)
    func removeTaskFromList(id: String)
    func showEmptyState(_ isEmpty: Bool)
}

// MARK: - MVP Presenter 协议
protocol MVPTaskPresenterProtocol: AnyObject {
    func viewDidLoad()
    func loadTasks()
    func refreshTasks()
    func createTask(title: String, description: String, priority: TaskPriority, dueDate: Date?)
    func updateTask(_ task: MVPTaskModel)
    func deleteTask(id: String)
    func toggleTaskCompletion(id: String)
    func selectTask(_ task: MVPTaskModel)
    func searchTasks(query: String)
    func filterTasks(by priority: TaskPriority?)
    func sortTasks(by sortType: TaskSortType)
    func clearSearch()
    func showTaskDetail(_ task: MVPTaskModel)
    func hideTaskDetail()
}

// MARK: - 任务列表 Presenter
class MVPTaskListPresenter: MVPTaskPresenterProtocol {
    
    // MARK: - Properties
    weak var view: MVPTaskViewProtocol?
    private let dataService: TaskDataServiceProtocol
    private var tasks: [MVPTaskModel] = []
    private var filteredTasks: [MVPTaskModel] = []
    private var currentSearchQuery: String = ""
    private var currentFilter: TaskPriority?
    private var currentSortType: TaskSortType = .createdAt
    
    // MARK: - Initialization
    init(dataService: TaskDataServiceProtocol = TaskDataService()) {
        self.dataService = dataService
    }
    
    func setView(_ view: MVPTaskViewProtocol) {
        self.view = view
    }
    
    // MARK: - Public Methods
    func viewDidLoad() {
        loadTasks()
    }
    
    func loadTasks() {
        view?.showLoading(true)
        dataService.fetchTasks { [weak self] tasks in
            DispatchQueue.main.async {
                self?.view?.showLoading(false)
                self?.tasks = tasks
                self?.applyFiltersAndSort()
                self?.view?.showTasks(self?.filteredTasks ?? [])
                self?.view?.showEmptyState(tasks.isEmpty)
            }
        }
    }
    
    func refreshTasks() {
        loadTasks()
    }
    
    func createTask(title: String, description: String, priority: TaskPriority, dueDate: Date?) {
        // 验证输入
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            view?.showError("任务标题不能为空")
            return
        }
        
        guard title.count <= 100 else {
            view?.showError("任务标题不能超过100个字符")
            return
        }
        
        guard description.count <= 500 else {
            view?.showError("任务描述不能超过500个字符")
            return
        }
        
        let newTask = MVPTaskModel(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            description: description.trimmingCharacters(in: .whitespacesAndNewlines),
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
                    self?.loadTasks() // 重新加载任务列表
                case .failure(let error):
                    self?.view?.showError(error)
                }
            }
        }
    }
    
    func updateTask(_ task: MVPTaskModel) {
        // 验证输入
        guard !task.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            view?.showError("任务标题不能为空")
            return
        }
        
        guard task.title.count <= 100 else {
            view?.showError("任务标题不能超过100个字符")
            return
        }
        
        guard task.description.count <= 500 else {
            view?.showError("任务描述不能超过500个字符")
            return
        }
        
        view?.showLoading(true)
        dataService.updateTask(task) { [weak self] result in
            DispatchQueue.main.async {
                self?.view?.showLoading(false)
                switch result {
                case .success(let message):
                    self?.view?.showSuccess(message)
                    self?.updateTaskInLocalList(task)
                case .failure(let error):
                    self?.view?.showError(error)
                }
            }
        }
    }
    
    func deleteTask(id: String) {
        view?.showLoading(true)
        dataService.deleteTask(id: id) { [weak self] result in
            DispatchQueue.main.async {
                self?.view?.showLoading(false)
                switch result {
                case .success(let message):
                    self?.view?.showSuccess(message)
                    self?.removeTaskFromLocalList(id: id)
                case .failure(let error):
                    self?.view?.showError(error)
                }
            }
        }
    }
    
    func toggleTaskCompletion(id: String) {
        guard let index = tasks.firstIndex(where: { $0.id == id }) else { return }
        
        var task = tasks[index]
        task.isCompleted.toggle()
        task.updatedAt = Date()
        
        updateTask(task)
    }
    
    func selectTask(_ task: MVPTaskModel) {
        showTaskDetail(task)
    }
    
    func searchTasks(query: String) {
        currentSearchQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if currentSearchQuery.isEmpty {
            clearSearch()
            return
        }
        
        view?.showLoading(true)
        dataService.searchTasks(query: currentSearchQuery) { [weak self] searchResults in
            DispatchQueue.main.async {
                self?.view?.showLoading(false)
                self?.filteredTasks = searchResults
                self?.view?.showTasks(searchResults)
                self?.view?.showEmptyState(searchResults.isEmpty)
            }
        }
    }
    
    func filterTasks(by priority: TaskPriority?) {
        currentFilter = priority
        applyFiltersAndSort()
        view?.showTasks(filteredTasks)
        view?.showEmptyState(filteredTasks.isEmpty)
    }
    
    func sortTasks(by sortType: TaskSortType) {
        currentSortType = sortType
        applyFiltersAndSort()
        view?.showTasks(filteredTasks)
    }
    
    func clearSearch() {
        currentSearchQuery = ""
        applyFiltersAndSort()
        view?.showTasks(filteredTasks)
        view?.showEmptyState(filteredTasks.isEmpty)
    }
    
    func showTaskDetail(_ task: MVPTaskModel) {
        view?.showTaskDetail(task)
    }
    
    func hideTaskDetail() {
        view?.hideTaskDetail()
    }
    
    // MARK: - Private Methods
    private func applyFiltersAndSort() {
        var result = tasks
        
        // 应用搜索过滤
        if !currentSearchQuery.isEmpty {
            result = result.filter { task in
                task.title.localizedCaseInsensitiveContains(currentSearchQuery) ||
                task.description.localizedCaseInsensitiveContains(currentSearchQuery)
            }
        }
        
        // 应用优先级过滤
        if let filter = currentFilter {
            result = result.filter { $0.priority == filter }
        }
        
        // 应用排序
        result = result.sorted { task1, task2 in
            switch currentSortType {
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
        
        filteredTasks = result
    }
    
    private func updateTaskInLocalList(_ task: MVPTaskModel) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
        }
        
        if let filteredIndex = filteredTasks.firstIndex(where: { $0.id == task.id }) {
            filteredTasks[filteredIndex] = task
        }
        
        view?.updateTaskInList(task)
    }
    
    private func removeTaskFromLocalList(id: String) {
        tasks.removeAll { $0.id == id }
        filteredTasks.removeAll { $0.id == id }
        view?.removeTaskFromList(id: id)
    }
}

// MARK: - 任务详情 Presenter
class MVPTaskDetailPresenter: MVPTaskPresenterProtocol {
    
    // MARK: - Properties
    weak var view: MVPTaskViewProtocol?
    private let dataService: TaskDataServiceProtocol
    private var currentTask: MVPTaskModel?
    
    // MARK: - Initialization
    init(dataService: TaskDataServiceProtocol = TaskDataService()) {
        self.dataService = dataService
    }
    
    func setView(_ view: MVPTaskViewProtocol) {
        self.view = view
    }
    
    func setCurrentTask(_ task: MVPTaskModel) {
        self.currentTask = task
    }
    
    // MARK: - Public Methods
    func viewDidLoad() {
        guard let task = currentTask else {
            view?.showError("任务不存在")
            return
        }
        view?.showTaskDetail(task)
    }
    
    func loadTasks() {
        // 详情页面不需要加载任务列表
    }
    
    func refreshTasks() {
        // 详情页面不需要刷新任务列表
    }
    
    func createTask(title: String, description: String, priority: TaskPriority, dueDate: Date?) {
        // 详情页面不创建新任务
    }
    
    func updateTask(_ task: MVPTaskModel) {
        view?.showLoading(true)
        dataService.updateTask(task) { [weak self] result in
            DispatchQueue.main.async {
                self?.view?.showLoading(false)
                switch result {
                case .success(let message):
                    self?.view?.showSuccess(message)
                    self?.currentTask = task
                    self?.view?.showTaskDetail(task)
                case .failure(let error):
                    self?.view?.showError(error)
                }
            }
        }
    }
    
    func deleteTask(id: String) {
        view?.showLoading(true)
        dataService.deleteTask(id: id) { [weak self] result in
            DispatchQueue.main.async {
                self?.view?.showLoading(false)
                switch result {
                case .success(let message):
                    self?.view?.showSuccess(message)
                    self?.view?.hideTaskDetail()
                case .failure(let error):
                    self?.view?.showError(error)
                }
            }
        }
    }
    
    func toggleTaskCompletion(id: String) {
        guard let task = currentTask, task.id == id else { return }
        
        var updatedTask = task
        updatedTask.isCompleted.toggle()
        updatedTask.updatedAt = Date()
        
        updateTask(updatedTask)
    }
    
    func selectTask(_ task: MVPTaskModel) {
        // 详情页面不需要选择任务
    }
    
    func searchTasks(query: String) {
        // 详情页面不需要搜索
    }
    
    func filterTasks(by priority: TaskPriority?) {
        // 详情页面不需要过滤
    }
    
    func sortTasks(by sortType: TaskSortType) {
        // 详情页面不需要排序
    }
    
    func clearSearch() {
        // 详情页面不需要清除搜索
    }
    
    func showTaskDetail(_ task: MVPTaskModel) {
        currentTask = task
        view?.showTaskDetail(task)
    }
    
    func hideTaskDetail() {
        view?.hideTaskDetail()
    }
}
