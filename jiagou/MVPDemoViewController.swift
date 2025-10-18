import UIKit

// MARK: - MVP 演示主控制器
class MVPDemoViewController: UIViewController {
    
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
        label.text = "MVP 设计模式演示"
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textAlignment = .center
        label.textColor = .label
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Model-View-Presenter 架构模式"
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textAlignment = .center
        label.textColor = .systemGray
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = """
        MVP (Model-View-Presenter) 是一种架构设计模式，将应用程序分为三个主要组件：
        
        • Model: 数据和业务逻辑
        • View: 用户界面
        • Presenter: 连接 Model 和 View 的中间层
        
        相比 MVC，MVP 模式提供了更好的分离关注点和可测试性。
        """
        label.font = .systemFont(ofSize: 16)
        label.textColor = .label
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()
    
    private lazy var taskListButton: UIButton = {
        let button = createDemoButton(
            title: "📋 任务列表演示",
            subtitle: "完整的任务管理功能",
            backgroundColor: .systemBlue
        )
        button.addTarget(self, action: #selector(showTaskList), for: .touchUpInside)
        return button
    }()
    
    private lazy var architectureButton: UIButton = {
        let button = createDemoButton(
            title: "🏗️ MVP 架构图",
            subtitle: "查看架构设计图",
            backgroundColor: .systemGreen
        )
        button.addTarget(self, action: #selector(showArchitecture), for: .touchUpInside)
        return button
    }()
    
    private lazy var codeExampleButton: UIButton = {
        let button = createDemoButton(
            title: "💻 代码示例",
            subtitle: "查看核心代码实现",
            backgroundColor: .systemOrange
        )
        button.addTarget(self, action: #selector(showCodeExample), for: .touchUpInside)
        return button
    }()
    
    private lazy var comparisonButton: UIButton = {
        let button = createDemoButton(
            title: "⚖️ 模式对比",
            subtitle: "MVP vs MVC vs MVVM",
            backgroundColor: .systemPurple
        )
        button.addTarget(self, action: #selector(showComparison), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadCodeExamples()
    }
    
    // MARK: - Setup
    private func setupUI() {
        title = "MVP 设计模式"
        view.backgroundColor = .systemBackground
        
        // Add subviews
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(taskListButton)
        contentView.addSubview(architectureButton)
        contentView.addSubview(codeExampleButton)
        contentView.addSubview(comparisonButton)
        
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
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            descriptionLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 20),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            taskListButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 30),
            taskListButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            taskListButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            taskListButton.heightAnchor.constraint(equalToConstant: 80),
            
            architectureButton.topAnchor.constraint(equalTo: taskListButton.bottomAnchor, constant: 16),
            architectureButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            architectureButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            architectureButton.heightAnchor.constraint(equalToConstant: 80),
            
            codeExampleButton.topAnchor.constraint(equalTo: architectureButton.bottomAnchor, constant: 16),
            codeExampleButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            codeExampleButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            codeExampleButton.heightAnchor.constraint(equalToConstant: 80),
            
            comparisonButton.topAnchor.constraint(equalTo: codeExampleButton.bottomAnchor, constant: 16),
            comparisonButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            comparisonButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            comparisonButton.heightAnchor.constraint(equalToConstant: 80),
            comparisonButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    private func createDemoButton(title: String, subtitle: String, backgroundColor: UIColor) -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = backgroundColor
        button.layer.cornerRadius = 12
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.layer.shadowOpacity = 0.1
        
        // 创建垂直布局
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 4
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.font = .systemFont(ofSize: 14)
        subtitleLabel.textColor = .white.withAlphaComponent(0.9)
        subtitleLabel.textAlignment = .center
        
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subtitleLabel)
        
        button.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: button.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: button.trailingAnchor, constant: -16)
        ])
        
        return button
    }
    
    // MARK: - Actions
    @objc private func showTaskList() {
        let taskListVC = MVPTaskListViewController()
        navigationController?.pushViewController(taskListVC, animated: true)
    }
    
    @objc private func showArchitecture() {
        let architectureVC = MVPArchitectureViewController()
        navigationController?.pushViewController(architectureVC, animated: true)
    }
    
    @objc private func showCodeExample() {
        let codeExampleVC = MVPCodeExampleViewController()
        navigationController?.pushViewController(codeExampleVC, animated: true)
    }
    
    @objc private func showComparison() {
        let comparisonVC = MVPModeComparisonViewController()
        navigationController?.pushViewController(comparisonVC, animated: true)
    }
    
    // MARK: - Code Examples
    private func loadCodeExamples() {
        // 这里可以预加载一些代码示例
        print("MVP Demo loaded with code examples")
    }
}

// MARK: - MVP 架构图控制器
class MVPArchitectureViewController: UIViewController {
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        title = "MVP 架构图"
        view.backgroundColor = .systemBackground
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        let architectureLabel = UILabel()
        architectureLabel.translatesAutoresizingMaskIntoConstraints = false
        architectureLabel.text = """
        ┌─────────────────────────────────────┐
        │            MVP 架构图                │
        └─────────────────────────────────────┘
        
        ┌─────────────────────────────────────┐
        │              View                    │
        │         (用户界面层)                 │
        │                                     │
        │  • UIViewController                 │
        │  • UITableView                      │
        │  • UIButton, UILabel 等             │
        │  • 只负责显示和用户交互              │
        └──────────────┬──────────────────────┘
                       │ 用户操作
                       │ 界面更新
                       ↓
        ┌─────────────────────────────────────┐
        │            Presenter                 │
        │         (业务逻辑层)                │
        │                                     │
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
        │  • 数据结构定义                      │
        │  • 数据访问服务                      │
        │  • 网络请求处理                      │
        │  • 数据持久化                        │
        └─────────────────────────────────────┘
        
        数据流向：
        View → Presenter → Model
        Model → Presenter → View
        
        特点：
        • View 和 Model 不直接通信
        • Presenter 作为中间层
        • 职责分离清晰
        • 易于单元测试
        """
        architectureLabel.font = .systemFont(ofSize: 14)
        architectureLabel.numberOfLines = 0
        architectureLabel.textColor = .label
        
        contentView.addSubview(architectureLabel)
        
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
            
            architectureLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            architectureLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            architectureLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            architectureLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
}

// MARK: - MVP 代码示例控制器
class MVPCodeExampleViewController: UIViewController {
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        title = "MVP 代码示例"
        view.backgroundColor = .systemBackground
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        let codeLabel = UILabel()
        codeLabel.translatesAutoresizingMaskIntoConstraints = false
        codeLabel.text = """
        // MARK: - MVP 核心代码示例
        
        // 1. Model 层
        struct TaskModel {
            let id: String
            var title: String
            var isCompleted: Bool
        }
        
        protocol TaskDataServiceProtocol {
            func fetchTasks(completion: @escaping ([TaskModel]) -> Void)
            func updateTask(_ task: TaskModel, completion: @escaping (Bool) -> Void)
        }
        
        // 2. View 协议
        protocol TaskViewProtocol: AnyObject {
            func showTasks(_ tasks: [TaskModel])
            func showError(_ message: String)
            func showLoading(_ isLoading: Bool)
        }
        
        // 3. Presenter 层
        class TaskPresenter {
            weak var view: TaskViewProtocol?
            private let dataService: TaskDataServiceProtocol
            
            init(dataService: TaskDataServiceProtocol) {
                self.dataService = dataService
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
            
            func toggleTaskCompletion(_ task: TaskModel) {
                var updatedTask = task
                updatedTask.isCompleted.toggle()
                
                dataService.updateTask(updatedTask) { [weak self] success in
                    if success {
                        self?.loadTasks()
                    } else {
                        self?.view?.showError("更新失败")
                    }
                }
            }
        }
        
        // 4. View 层
        class TaskViewController: UIViewController, TaskViewProtocol {
            private var presenter: TaskPresenter!
            @IBOutlet weak var tableView: UITableView!
            
            override func viewDidLoad() {
                super.viewDidLoad()
                setupPresenter()
                presenter.loadTasks()
            }
            
            private func setupPresenter() {
                presenter = TaskPresenter(dataService: TaskDataService())
                presenter.setView(self)
            }
            
            // MARK: - TaskViewProtocol
            func showTasks(_ tasks: [TaskModel]) {
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
            }
        }
        
        // 5. 使用示例
        let taskVC = TaskViewController()
        // Presenter 自动处理业务逻辑
        // View 只负责显示
        // Model 只负责数据
        """
        codeLabel.font = .systemFont(ofSize: 12)
        codeLabel.numberOfLines = 0
        codeLabel.textColor = .label
        
        contentView.addSubview(codeLabel)
        
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
            
            codeLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            codeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            codeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            codeLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
}

// MARK: - MVP 模式对比控制器
class MVPModeComparisonViewController: UIViewController {
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        title = "架构模式对比"
        view.backgroundColor = .systemBackground
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        let comparisonLabel = UILabel()
        comparisonLabel.translatesAutoresizingMaskIntoConstraints = false
        comparisonLabel.text = """
        ┌─────────────────────────────────────────────────────────┐
        │                架构模式对比表                            │
        └─────────────────────────────────────────────────────────┘
        
        ┌─────────────┬─────────────┬─────────────┬─────────────┐
        │    特性     │    MVC      │    MVP      │    MVVM     │
        ├─────────────┼─────────────┼─────────────┼─────────────┤
        │  View 职责  │  显示+逻辑  │   仅显示    │   仅显示    │
        │  Controller │  业务逻辑   │  Presenter  │  ViewModel  │
        │  数据绑定   │   手动      │   手动      │   自动      │
        │  测试难度   │    困难     │    容易     │    容易     │
        │  学习成本   │    低       │    中       │    高       │
        │  适用场景   │  简单应用   │  中等应用   │  复杂应用   │
        └─────────────┴─────────────┴─────────────┴─────────────┘
        
        MVC (Model-View-Controller):
        • 优点：简单易懂，学习成本低
        • 缺点：Controller 容易变胖，难以测试
        • 适用：小型项目，快速原型
        
        MVP (Model-View-Presenter):
        • 优点：职责分离清晰，易于测试
        • 缺点：需要手动处理数据绑定
        • 适用：中等复杂度项目，需要高测试覆盖率
        
        MVVM (Model-View-ViewModel):
        • 优点：数据绑定自动化，响应式编程
        • 缺点：学习成本高，调试复杂
        • 适用：大型项目，复杂 UI 交互
        
        选择建议：
        • 简单项目 → MVC
        • 需要测试 → MVP
        • 复杂交互 → MVVM
        • 团队技能 → 根据团队熟悉度选择
        """
        comparisonLabel.font = .systemFont(ofSize: 14)
        comparisonLabel.numberOfLines = 0
        comparisonLabel.textColor = .label
        
        contentView.addSubview(comparisonLabel)
        
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
            
            comparisonLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            comparisonLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            comparisonLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            comparisonLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
}
