import UIKit

// MARK: - 任务详情 View Controller
class MVPTaskDetailViewController: UIViewController {
    
    // MARK: - UI Components
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16)
        label.textColor = .systemGray
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var priorityView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 8
        view.layer.borderWidth = 1
        return view
    }()
    
    private lazy var priorityLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 18, weight: .medium)
        return label
    }()
    
    private lazy var dueDateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16)
        label.textColor = .systemGray
        return label
    }()
    
    private lazy var createdDateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14)
        label.textColor = .systemGray2
        return label
    }()
    
    private lazy var updatedDateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14)
        label.textColor = .systemGray2
        return label
    }()
    
    private lazy var completionButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("标记为完成", for: .normal)
        button.setTitle("标记为未完成", for: .selected)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(toggleCompletion), for: .touchUpInside)
        return button
    }()
    
    private lazy var editButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("编辑任务", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(editTask), for: .touchUpInside)
        return button
    }()
    
    private lazy var deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("删除任务", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .systemRed
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(deleteTask), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Properties
    private var presenter: MVPTaskDetailPresenter!
    private var currentTask: MVPTaskModel?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupPresenter()
        presenter.viewDidLoad()
    }
    
    // MARK: - Setup
    private func setupUI() {
        title = "任务详情"
        view.backgroundColor = .systemBackground
        
        // Navigation bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "编辑",
            style: .plain,
            target: self,
            action: #selector(editTask)
        )
        
        // Add subviews
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(priorityView)
        priorityView.addSubview(priorityLabel)
        contentView.addSubview(statusLabel)
        contentView.addSubview(dueDateLabel)
        contentView.addSubview(createdDateLabel)
        contentView.addSubview(updatedDateLabel)
        contentView.addSubview(completionButton)
        contentView.addSubview(editButton)
        contentView.addSubview(deleteButton)
        
        // Constraints
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            priorityView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 20),
            priorityView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            priorityView.widthAnchor.constraint(equalToConstant: 100),
            priorityView.heightAnchor.constraint(equalToConstant: 40),
            
            priorityLabel.centerXAnchor.constraint(equalTo: priorityView.centerXAnchor),
            priorityLabel.centerYAnchor.constraint(equalTo: priorityView.centerYAnchor),
            
            statusLabel.topAnchor.constraint(equalTo: priorityView.bottomAnchor, constant: 20),
            statusLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            dueDateLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 16),
            dueDateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            dueDateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            createdDateLabel.topAnchor.constraint(equalTo: dueDateLabel.bottomAnchor, constant: 16),
            createdDateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            createdDateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            updatedDateLabel.topAnchor.constraint(equalTo: createdDateLabel.bottomAnchor, constant: 8),
            updatedDateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            updatedDateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            completionButton.topAnchor.constraint(equalTo: updatedDateLabel.bottomAnchor, constant: 30),
            completionButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            completionButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            completionButton.heightAnchor.constraint(equalToConstant: 50),
            
            editButton.topAnchor.constraint(equalTo: completionButton.bottomAnchor, constant: 16),
            editButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            editButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            editButton.heightAnchor.constraint(equalToConstant: 50),
            
            deleteButton.topAnchor.constraint(equalTo: editButton.bottomAnchor, constant: 16),
            deleteButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            deleteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            deleteButton.heightAnchor.constraint(equalToConstant: 50),
            deleteButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    private func setupPresenter() {
        presenter = MVPTaskDetailPresenter()
        presenter.setView(self)
    }
    
    func setTask(_ task: MVPTaskModel) {
        currentTask = task
        presenter.setCurrentTask(task)
    }
    
    // MARK: - Actions
    @objc private func toggleCompletion() {
        guard let task = currentTask else { return }
        presenter.toggleTaskCompletion(id: task.id)
    }
    
    @objc private func editTask() {
        guard let task = currentTask else { return }
        let editVC = MVPEditTaskViewController()
        editVC.setTask(task)
        editVC.onTaskUpdated = { [weak self] in
            self?.presenter.viewDidLoad()
        }
        let navController = UINavigationController(rootViewController: editVC)
        present(navController, animated: true)
    }
    
    @objc private func deleteTask() {
        let alert = UIAlertController(title: "删除任务", message: "确定要删除这个任务吗？此操作无法撤销。", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "删除", style: .destructive) { [weak self] _ in
            guard let task = self?.currentTask else { return }
            self?.presenter.deleteTask(id: task.id)
        })
        
        present(alert, animated: true)
    }
}

// MARK: - MVPTaskViewProtocol
extension MVPTaskDetailViewController: MVPTaskViewProtocol {
    
    func showLoading(_ isLoading: Bool) {
        // 可以显示加载指示器
    }
    
    func showTasks(_ tasks: [MVPTaskModel]) {
        // 详情页面不需要显示任务列表
    }
    
    func showError(_ message: String) {
        let alert = UIAlertController(title: "错误", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
    
    func showSuccess(_ message: String) {
        // 可以显示成功提示
        print("Success: \(message)")
    }
    
    func refreshTaskList() {
        // 详情页面不需要刷新任务列表
    }
    
    func showTaskDetail(_ task: MVPTaskModel) {
        currentTask = task
        updateUI(with: task)
    }
    
    func hideTaskDetail() {
        navigationController?.popViewController(animated: true)
    }
    
    func updateTaskInList(_ task: MVPTaskModel) {
        // 详情页面不需要更新列表
    }
    
    func removeTaskFromList(id: String) {
        // 详情页面不需要从列表移除
    }
    
    func showEmptyState(_ isEmpty: Bool) {
        // 详情页面不需要显示空状态
    }
    
    private func updateUI(with task: MVPTaskModel) {
        titleLabel.text = task.title
        descriptionLabel.text = task.description.isEmpty ? "无描述" : task.description
        priorityLabel.text = task.priority.rawValue
        statusLabel.text = task.statusText
        dueDateLabel.text = "截止时间：\(task.formattedDueDate)"
        createdDateLabel.text = "创建时间：\(task.formattedCreatedDate)"
        updatedDateLabel.text = "更新时间：\(DateFormatter().string(from: task.updatedAt))"
        
        // 设置优先级颜色
        switch task.priority {
        case .low:
            priorityView.backgroundColor = .systemBlue.withAlphaComponent(0.2)
            priorityView.layer.borderColor = UIColor.systemBlue.cgColor
            priorityLabel.textColor = .systemBlue
        case .medium:
            priorityView.backgroundColor = .systemGreen.withAlphaComponent(0.2)
            priorityView.layer.borderColor = UIColor.systemGreen.cgColor
            priorityLabel.textColor = .systemGreen
        case .high:
            priorityView.backgroundColor = .systemOrange.withAlphaComponent(0.2)
            priorityView.layer.borderColor = UIColor.systemOrange.cgColor
            priorityLabel.textColor = .systemOrange
        case .urgent:
            priorityView.backgroundColor = .systemRed.withAlphaComponent(0.2)
            priorityView.layer.borderColor = UIColor.systemRed.cgColor
            priorityLabel.textColor = .systemRed
        }
        
        // 设置完成状态
        completionButton.isSelected = task.isCompleted
        completionButton.backgroundColor = task.isCompleted ? .systemGreen : .systemBlue
        
        // 设置逾期状态
        if task.isOverdue {
            statusLabel.textColor = .systemRed
        } else if task.isCompleted {
            statusLabel.textColor = .systemGreen
        } else {
            statusLabel.textColor = .label
        }
    }
}

// MARK: - 添加任务 View Controller
class MVPAddTaskViewController: UIViewController {
    
    // MARK: - UI Components
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var titleTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "任务标题"
        textField.borderStyle = .roundedRect
        textField.font = .systemFont(ofSize: 16)
        return textField
    }()
    
    private lazy var descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = .systemFont(ofSize: 16)
        textView.layer.borderColor = UIColor.systemGray4.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 8
        textView.text = "任务描述（可选）"
        textView.textColor = .systemGray
        textView.delegate = self
        return textView
    }()
    
    private lazy var prioritySegmentedControl: UISegmentedControl = {
        let items = TaskPriority.allCases.map { $0.rawValue }
        let segmentedControl = UISegmentedControl(items: items)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.selectedSegmentIndex = 1 // 默认中等优先级
        return segmentedControl
    }()
    
    private lazy var dueDateSwitch: UISwitch = {
        let switchControl = UISwitch()
        switchControl.translatesAutoresizingMaskIntoConstraints = false
        switchControl.addTarget(self, action: #selector(dueDateSwitchChanged), for: .valueChanged)
        return switchControl
    }()
    
    private lazy var dueDatePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.datePickerMode = .dateAndTime
        picker.minimumDate = Date()
        picker.isHidden = true
        return picker
    }()
    
    private lazy var saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("创建任务", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(saveTask), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Properties
    var onTaskCreated: (() -> Void)?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Setup
    private func setupUI() {
        title = "添加任务"
        view.backgroundColor = .systemBackground
        
        // Navigation bar
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancel)
        )
        
        // Add subviews
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(titleTextField)
        contentView.addSubview(descriptionTextView)
        contentView.addSubview(prioritySegmentedControl)
        contentView.addSubview(dueDateSwitch)
        contentView.addSubview(dueDatePicker)
        contentView.addSubview(saveButton)
        
        // Labels
        let titleLabel = createLabel(text: "任务标题")
        let descriptionLabel = createLabel(text: "任务描述")
        let priorityLabel = createLabel(text: "优先级")
        let dueDateLabel = createLabel(text: "设置截止时间")
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(priorityLabel)
        contentView.addSubview(dueDateLabel)
        
        // Constraints
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            titleTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            titleTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            titleTextField.heightAnchor.constraint(equalToConstant: 44),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 20),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            descriptionTextView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 8),
            descriptionTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            descriptionTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            descriptionTextView.heightAnchor.constraint(equalToConstant: 100),
            
            priorityLabel.topAnchor.constraint(equalTo: descriptionTextView.bottomAnchor, constant: 20),
            priorityLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            priorityLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            prioritySegmentedControl.topAnchor.constraint(equalTo: priorityLabel.bottomAnchor, constant: 8),
            prioritySegmentedControl.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            prioritySegmentedControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            dueDateLabel.topAnchor.constraint(equalTo: prioritySegmentedControl.bottomAnchor, constant: 20),
            dueDateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            dueDateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            dueDateSwitch.topAnchor.constraint(equalTo: dueDateLabel.bottomAnchor, constant: 8),
            dueDateSwitch.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            dueDatePicker.topAnchor.constraint(equalTo: dueDateSwitch.bottomAnchor, constant: 16),
            dueDatePicker.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            dueDatePicker.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            saveButton.topAnchor.constraint(equalTo: dueDatePicker.bottomAnchor, constant: 30),
            saveButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            saveButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            saveButton.heightAnchor.constraint(equalToConstant: 50),
            saveButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    private func createLabel(text: String) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }
    
    // MARK: - Actions
    @objc private func cancel() {
        dismiss(animated: true)
    }
    
    @objc private func dueDateSwitchChanged() {
        dueDatePicker.isHidden = !dueDateSwitch.isOn
    }
    
    @objc private func saveTask() {
        guard let title = titleTextField.text, !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            showAlert(title: "错误", message: "请输入任务标题")
            return
        }
        
        let description = descriptionTextView.text == "任务描述（可选）" ? "" : descriptionTextView.text ?? ""
        let priority = TaskPriority.allCases[prioritySegmentedControl.selectedSegmentIndex]
        let dueDate = dueDateSwitch.isOn ? dueDatePicker.date : nil
        
        let task = MVPTaskModel(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            description: description.trimmingCharacters(in: .whitespacesAndNewlines),
            priority: priority,
            dueDate: dueDate
        )
        
        // 这里应该调用 Presenter 来创建任务
        // 为了简化，直接调用回调
        onTaskCreated?()
        dismiss(animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITextViewDelegate
extension MVPAddTaskViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .systemGray {
            textView.text = ""
            textView.textColor = .label
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "任务描述（可选）"
            textView.textColor = .systemGray
        }
    }
}

// MARK: - 编辑任务 View Controller
class MVPEditTaskViewController: UIViewController {
    
    // MARK: - Properties
    private var task: MVPTaskModel?
    var onTaskUpdated: (() -> Void)?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setTask(_ task: MVPTaskModel) {
        self.task = task
    }
    
    private func setupUI() {
        title = "编辑任务"
        view.backgroundColor = .systemBackground
        
        // 简化的编辑界面
        let label = UILabel()
        label.text = "编辑功能待实现"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancel)
        )
    }
    
    @objc private func cancel() {
        dismiss(animated: true)
    }
}
