import UIKit

// MARK: - 任务列表 View Controller
class MVPTaskListViewController: UIViewController {
    
    // MARK: - UI Components
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MVPTaskCell.self, forCellReuseIdentifier: MVPTaskCell.identifier)
        tableView.separatorStyle = .singleLine
        tableView.backgroundColor = .systemBackground
        return tableView
    }()
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.delegate = self
        searchBar.placeholder = "搜索任务..."
        searchBar.searchBarStyle = .minimal
        return searchBar
    }()
    
    private lazy var filterSegmentedControl: UISegmentedControl = {
        let items = ["全部"] + TaskPriority.allCases.map { $0.rawValue }
        let segmentedControl = UISegmentedControl(items: items)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(filterChanged), for: .valueChanged)
        return segmentedControl
    }()
    
    private lazy var sortButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            title: "排序",
            style: .plain,
            target: self,
            action: #selector(showSortOptions)
        )
        return button
    }()
    
    private lazy var addButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(showAddTask)
        )
        return button
    }()
    
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshTasks), for: .valueChanged)
        return refreshControl
    }()
    
    private lazy var emptyStateView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        view.isHidden = true
        
        let imageView = UIImageView(image: UIImage(systemName: "checklist"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .systemGray3
        imageView.contentMode = .scaleAspectFit
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "暂无任务"
        label.textColor = .systemGray2
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .center
        
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("添加任务", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.addTarget(self, action: #selector(showAddTask), for: .touchUpInside)
        
        view.addSubview(imageView)
        view.addSubview(label)
        view.addSubview(button)
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            imageView.widthAnchor.constraint(equalToConstant: 60),
            imageView.heightAnchor.constraint(equalToConstant: 60),
            
            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            button.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 16),
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        return view
    }()
    
    private lazy var loadingView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.8)
        view.isHidden = true
        
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.startAnimating()
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "加载中..."
        label.textColor = .systemGray
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .center
        
        view.addSubview(activityIndicator)
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
            
            label.topAnchor.constraint(equalTo: activityIndicator.bottomAnchor, constant: 16),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        
        return view
    }()
    
    // MARK: - Properties
    private var presenter: MVPTaskListPresenter!
    private var tasks: [MVPTaskModel] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupPresenter()
        presenter.viewDidLoad()
    }
    
    // MARK: - Setup
    private func setupUI() {
        title = "任务管理"
        view.backgroundColor = .systemBackground
        
        // Navigation bar
        navigationItem.rightBarButtonItems = [addButton, sortButton]
        
        // Add subviews
        view.addSubview(searchBar)
        view.addSubview(filterSegmentedControl)
        view.addSubview(tableView)
        view.addSubview(emptyStateView)
        view.addSubview(loadingView)
        
        // Table view setup
        tableView.refreshControl = refreshControl
        
        // Constraints
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            filterSegmentedControl.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 8),
            filterSegmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            filterSegmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            tableView.topAnchor.constraint(equalTo: filterSegmentedControl.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyStateView.topAnchor.constraint(equalTo: tableView.topAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: tableView.leadingAnchor),
            emptyStateView.trailingAnchor.constraint(equalTo: tableView.trailingAnchor),
            emptyStateView.bottomAnchor.constraint(equalTo: tableView.bottomAnchor),
            
            loadingView.topAnchor.constraint(equalTo: view.topAnchor),
            loadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupPresenter() {
        presenter = MVPTaskListPresenter()
        presenter.setView(self)
    }
    
    // MARK: - Actions
    @objc private func refreshTasks() {
        presenter.refreshTasks()
        refreshControl.endRefreshing()
    }
    
    @objc private func showAddTask() {
        let addTaskVC = MVPAddTaskViewController()
        addTaskVC.onTaskCreated = { [weak self] in
            self?.presenter.refreshTasks()
        }
        let navController = UINavigationController(rootViewController: addTaskVC)
        present(navController, animated: true)
    }
    
    @objc private func filterChanged() {
        let selectedIndex = filterSegmentedControl.selectedSegmentIndex
        if selectedIndex == 0 {
            presenter.filterTasks(by: nil)
        } else {
            let priority = TaskPriority.allCases[selectedIndex - 1]
            presenter.filterTasks(by: priority)
        }
    }
    
    @objc private func showSortOptions() {
        let alert = UIAlertController(title: "排序方式", message: nil, preferredStyle: .actionSheet)
        
        for sortType in TaskSortType.allCases {
            alert.addAction(UIAlertAction(title: sortType.rawValue, style: .default) { [weak self] _ in
                self?.presenter.sortTasks(by: sortType)
            })
        }
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        
        // iPad support
        if let popover = alert.popoverPresentationController {
            popover.barButtonItem = sortButton
        }
        
        present(alert, animated: true)
    }
}

// MARK: - MVPTaskViewProtocol
extension MVPTaskListViewController: MVPTaskViewProtocol {
    
    func showLoading(_ isLoading: Bool) {
        loadingView.isHidden = !isLoading
    }
    
    func showTasks(_ tasks: [MVPTaskModel]) {
        self.tasks = tasks
        tableView.reloadData()
    }
    
    func showError(_ message: String) {
        let alert = UIAlertController(title: "错误", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
    
    func showSuccess(_ message: String) {
        // 可以显示 Toast 或 HUD
        print("Success: \(message)")
    }
    
    func refreshTaskList() {
        tableView.reloadData()
    }
    
    func showTaskDetail(_ task: MVPTaskModel) {
        let detailVC = MVPTaskDetailViewController()
        detailVC.setTask(task)
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func hideTaskDetail() {
        // 列表页面不需要隐藏详情
    }
    
    func updateTaskInList(_ task: MVPTaskModel) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
            tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
        }
    }
    
    func removeTaskFromList(id: String) {
        if let index = tasks.firstIndex(where: { $0.id == id }) {
            tasks.remove(at: index)
            tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .fade)
        }
    }
    
    func showEmptyState(_ isEmpty: Bool) {
        emptyStateView.isHidden = !isEmpty
    }
}

// MARK: - UITableViewDataSource
extension MVPTaskListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MVPTaskCell.identifier, for: indexPath) as! MVPTaskCell
        let task = tasks[indexPath.row]
        cell.configure(with: task)
        cell.onToggleCompletion = { [weak self] in
            self?.presenter.toggleTaskCompletion(id: task.id)
        }
        return cell
    }
}

// MARK: - UITableViewDelegate
extension MVPTaskListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let task = tasks[indexPath.row]
        presenter.selectTask(task)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let task = tasks[indexPath.row]
        
        let deleteAction = UIContextualAction(style: .destructive, title: "删除") { [weak self] _, _, completion in
            self?.presenter.deleteTask(id: task.id)
            completion(true)
        }
        deleteAction.image = UIImage(systemName: "trash")
        
        let editAction = UIContextualAction(style: .normal, title: "编辑") { [weak self] _, _, completion in
            let editVC = MVPEditTaskViewController()
            editVC.setTask(task)
            editVC.onTaskUpdated = { [weak self] in
                self?.presenter.refreshTasks()
            }
            let navController = UINavigationController(rootViewController: editVC)
            self?.present(navController, animated: true)
            completion(true)
        }
        editAction.image = UIImage(systemName: "pencil")
        editAction.backgroundColor = .systemBlue
        
        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
    }
}

// MARK: - UISearchBarDelegate
extension MVPTaskListViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        presenter.searchTasks(query: searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        presenter.clearSearch()
    }
}

// MARK: - 任务 Cell
class MVPTaskCell: UITableViewCell {
    
    static let identifier = "MVPTaskCell"
    
    var onToggleCompletion: (() -> Void)?
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.numberOfLines = 2
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14)
        label.textColor = .systemGray
        label.numberOfLines = 2
        return label
    }()
    
    private lazy var priorityLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .center
        label.layer.cornerRadius = 8
        label.layer.masksToBounds = true
        return label
    }()
    
    private lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12)
        label.textColor = .systemGray
        return label
    }()
    
    private lazy var completionButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "circle"), for: .normal)
        button.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .selected)
        button.tintColor = .systemBlue
        button.addTarget(self, action: #selector(toggleCompletion), for: .touchUpInside)
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(completionButton)
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(priorityLabel)
        contentView.addSubview(statusLabel)
        
        NSLayoutConstraint.activate([
            completionButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            completionButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            completionButton.widthAnchor.constraint(equalToConstant: 24),
            completionButton.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: completionButton.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: priorityLabel.leadingAnchor, constant: -8),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            priorityLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            priorityLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            priorityLabel.widthAnchor.constraint(equalToConstant: 50),
            priorityLabel.heightAnchor.constraint(equalToConstant: 20),
            
            statusLabel.topAnchor.constraint(equalTo: priorityLabel.bottomAnchor, constant: 4),
            statusLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            statusLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    
    func configure(with task: MVPTaskModel) {
        titleLabel.text = task.title
        descriptionLabel.text = task.description.isEmpty ? "无描述" : task.description
        priorityLabel.text = task.priority.rawValue
        statusLabel.text = task.statusText
        
        // 设置优先级颜色
        switch task.priority {
        case .low:
            priorityLabel.backgroundColor = .systemBlue.withAlphaComponent(0.2)
            priorityLabel.textColor = .systemBlue
        case .medium:
            priorityLabel.backgroundColor = .systemGreen.withAlphaComponent(0.2)
            priorityLabel.textColor = .systemGreen
        case .high:
            priorityLabel.backgroundColor = .systemOrange.withAlphaComponent(0.2)
            priorityLabel.textColor = .systemOrange
        case .urgent:
            priorityLabel.backgroundColor = .systemRed.withAlphaComponent(0.2)
            priorityLabel.textColor = .systemRed
        }
        
        // 设置完成状态
        completionButton.isSelected = task.isCompleted
        titleLabel.textColor = task.isCompleted ? .systemGray : .label
        descriptionLabel.textColor = task.isCompleted ? .systemGray2 : .systemGray
        
        // 设置逾期状态
        if task.isOverdue {
            statusLabel.textColor = .systemRed
        } else if task.isCompleted {
            statusLabel.textColor = .systemGreen
        } else {
            statusLabel.textColor = .systemGray
        }
    }
    
    @objc private func toggleCompletion() {
        onToggleCompletion?()
    }
}
