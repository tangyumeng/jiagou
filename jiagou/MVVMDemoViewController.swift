//
//  MVVMDemoViewController.swift
//  jiagou
//
//  MVVM 设计模式演示控制器
//

import UIKit
import SwiftUI

// MARK: - MVVM 演示控制器

/// MVVM 设计模式演示控制器
class MVVMDemoViewController: UIViewController {
    
    // MARK: - UI 组件
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    
    // 演示按钮
    private let userListButton = UIButton(type: .system)
    private let userLoginButton = UIButton(type: .system)
    private let architectureButton = UIButton(type: .system)
    private let codeExampleButton = UIButton(type: .system)
    
    // MARK: - 生命周期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "MVVM 设计模式演示"
        view.backgroundColor = .systemBackground
        
        setupUI()
        setupActions()
    }
    
    // MARK: - UI 设置
    
    private func setupUI() {
        // 滚动视图
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        // 标题
        titleLabel.text = "MVVM 设计模式"
        titleLabel.font = .systemFont(ofSize: 28, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        
        // 描述
        descriptionLabel.text = """
        MVVM (Model-View-ViewModel) 是一种架构设计模式，将应用程序分为三个主要部分：
        
        📱 View (视图层)
        • 负责用户界面显示
        • 处理用户交互
        • 绑定到 ViewModel 的数据
        
        🧠 ViewModel (视图模型层)
        • 包含业务逻辑和状态管理
        • 处理数据转换和验证
        • 与 Model 层通信
        
        📊 Model (数据模型层)
        • 定义数据结构
        • 处理数据持久化
        • 提供数据访问接口
        
        优势：
        ✅ 清晰的职责分离
        ✅ 易于测试和维护
        ✅ 支持数据绑定
        ✅ 提高代码复用性
        """
        descriptionLabel.font = .systemFont(ofSize: 16)
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(descriptionLabel)
        
        // 演示按钮
        setupDemoButtons()
        
        // 布局约束
        NSLayoutConstraint.activate([
            // 滚动视图
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // 内容视图
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // 标题
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // 描述
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // 用户列表按钮
            userListButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 30),
            userListButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            userListButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            userListButton.heightAnchor.constraint(equalToConstant: 50),
            
            // 用户登录按钮
            userLoginButton.topAnchor.constraint(equalTo: userListButton.bottomAnchor, constant: 12),
            userLoginButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            userLoginButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            userLoginButton.heightAnchor.constraint(equalToConstant: 50),
            
            // 架构图按钮
            architectureButton.topAnchor.constraint(equalTo: userLoginButton.bottomAnchor, constant: 12),
            architectureButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            architectureButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            architectureButton.heightAnchor.constraint(equalToConstant: 50),
            
            // 代码示例按钮
            codeExampleButton.topAnchor.constraint(equalTo: architectureButton.bottomAnchor, constant: 12),
            codeExampleButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            codeExampleButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            codeExampleButton.heightAnchor.constraint(equalToConstant: 50),
            codeExampleButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    private func setupDemoButtons() {
        // 用户列表按钮
        userListButton.setTitle("📱 用户列表演示 (SwiftUI)", for: .normal)
        userListButton.backgroundColor = .systemBlue
        userListButton.setTitleColor(.white, for: .normal)
        userListButton.layer.cornerRadius = 8
        userListButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        userListButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(userListButton)
        
        // 用户登录按钮
        userLoginButton.setTitle("🔐 用户登录演示 (SwiftUI)", for: .normal)
        userLoginButton.backgroundColor = .systemGreen
        userLoginButton.setTitleColor(.white, for: .normal)
        userLoginButton.layer.cornerRadius = 8
        userLoginButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        userLoginButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(userLoginButton)
        
        // 架构图按钮
        architectureButton.setTitle("🏗️ MVVM 架构图", for: .normal)
        architectureButton.backgroundColor = .systemPurple
        architectureButton.setTitleColor(.white, for: .normal)
        architectureButton.layer.cornerRadius = 8
        architectureButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        architectureButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(architectureButton)
        
        // 代码示例按钮
        codeExampleButton.setTitle("💻 代码示例说明", for: .normal)
        codeExampleButton.backgroundColor = .systemOrange
        codeExampleButton.setTitleColor(.white, for: .normal)
        codeExampleButton.layer.cornerRadius = 8
        codeExampleButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        codeExampleButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(codeExampleButton)
    }
    
    private func setupActions() {
        userListButton.addTarget(self, action: #selector(showUserList), for: .touchUpInside)
        userLoginButton.addTarget(self, action: #selector(showUserLogin), for: .touchUpInside)
        architectureButton.addTarget(self, action: #selector(showArchitecture), for: .touchUpInside)
        codeExampleButton.addTarget(self, action: #selector(showCodeExample), for: .touchUpInside)
    }
    
    // MARK: - 按钮动作
    
    @objc private func showUserList() {
        let userListView = MVVMUserListView()
        let hostingController = UIHostingController(rootView: userListView)
        hostingController.title = "用户列表 (MVVM)"
        navigationController?.pushViewController(hostingController, animated: true)
    }
    
    @objc private func showUserLogin() {
        let userLoginView = MVVMUserLoginView()
        let hostingController = UIHostingController(rootView: userLoginView)
        hostingController.title = "用户登录 (MVVM)"
        navigationController?.pushViewController(hostingController, animated: true)
    }
    
    @objc private func showArchitecture() {
        let architectureVC = MVVMArchitectureViewController()
        navigationController?.pushViewController(architectureVC, animated: true)
    }
    
    @objc private func showCodeExample() {
        let codeExampleVC = MVVMCodeExampleViewController()
        navigationController?.pushViewController(codeExampleVC, animated: true)
    }
}

// MARK: - MVVM 架构图控制器

/// MVVM 架构图展示控制器
class MVVMArchitectureViewController: UIViewController {
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let titleLabel = UILabel()
    private let architectureImageView = UIImageView()
    private let descriptionLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "MVVM 架构图"
        view.backgroundColor = .systemBackground
        
        setupUI()
    }
    
    private func setupUI() {
        // 滚动视图
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        // 标题
        titleLabel.text = "MVVM 架构层次图"
        titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        
        // 架构图（使用文本绘制）
        architectureImageView.backgroundColor = .systemGray6
        architectureImageView.layer.cornerRadius = 8
        architectureImageView.contentMode = .scaleAspectFit
        architectureImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(architectureImageView)
        
        // 描述
        descriptionLabel.text = """
        MVVM 架构模式的核心特点：
        
        🔄 数据绑定
        • View 通过数据绑定自动更新
        • ViewModel 状态变化自动反映到 UI
        • 减少手动 UI 更新代码
        
        🎯 职责分离
        • View: 纯 UI 展示和用户交互
        • ViewModel: 业务逻辑和状态管理
        • Model: 数据结构和数据访问
        
        🧪 易于测试
        • ViewModel 可独立测试
        • 不依赖 UI 框架
        • 支持单元测试和集成测试
        
        🔧 可维护性
        • 代码结构清晰
        • 模块化设计
        • 易于扩展和修改
        """
        descriptionLabel.font = .systemFont(ofSize: 16)
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(descriptionLabel)
        
        // 创建架构图
        createArchitectureDiagram()
        
        // 布局约束
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
            
            architectureImageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            architectureImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            architectureImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            architectureImageView.heightAnchor.constraint(equalToConstant: 300),
            
            descriptionLabel.topAnchor.constraint(equalTo: architectureImageView.bottomAnchor, constant: 20),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    private func createArchitectureDiagram() {
        // 创建架构图的文本表示
        let diagramText = """
        ┌─────────────────────────────────────┐
        │              View Layer             │
        │  ┌─────────────┐ ┌─────────────┐   │
        │  │   SwiftUI   │ │   UIKit     │   │
        │  │    Views    │ │   Views     │   │
        │  └─────────────┘ └─────────────┘   │
        └──────────────┬──────────────────────┘
                       │ 数据绑定 / 观察者模式
        ┌──────────────┴──────────────────────┐
        │           ViewModel Layer           │
        │  ┌─────────────────────────────────┐ │
        │  │     Business Logic & State      │ │
        │  │   • 数据处理和转换               │ │
        │  │   • 状态管理                    │ │
        │  │   • 用户交互处理                │ │
        │  └─────────────────────────────────┘ │
        └──────────────┬──────────────────────┘
                       │ 数据访问
        ┌──────────────┴──────────────────────┐
        │             Model Layer              │
        │  ┌─────────────────────────────────┐ │
        │  │     Data Models & Services      │ │
        │  │   • 数据结构定义                │ │
        │  │   • 数据持久化                  │ │
        │  │   • 网络请求                    │ │
        │  └─────────────────────────────────┘ │
        └─────────────────────────────────────┘
        """
        
        // 创建文本视图显示架构图
        let textView = UITextView()
        textView.text = diagramText
        textView.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        textView.backgroundColor = .systemGray6
        textView.isEditable = false
        textView.layer.cornerRadius = 8
        textView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(textView)
        
        // 更新约束
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            textView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            textView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            textView.heightAnchor.constraint(equalToConstant: 300)
        ])
    }
}

// MARK: - MVVM 代码示例控制器

/// MVVM 代码示例展示控制器
class MVVMCodeExampleViewController: UIViewController {
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let titleLabel = UILabel()
    private let codeTextView = UITextView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "MVVM 代码示例"
        view.backgroundColor = .systemBackground
        
        setupUI()
        loadCodeExamples()
    }
    
    private func setupUI() {
        // 滚动视图
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        // 标题
        titleLabel.text = "MVVM 代码实现示例"
        titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        
        // 代码文本视图
        codeTextView.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        codeTextView.backgroundColor = .systemGray6
        codeTextView.isEditable = false
        codeTextView.layer.cornerRadius = 8
        codeTextView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(codeTextView)
        
        // 布局约束
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
            
            codeTextView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            codeTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            codeTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            codeTextView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    private func loadCodeExamples() {
        let codeExample = """
        // MARK: - Model 层示例
        struct UserModel {
            let id: String
            var name: String
            var email: String
            var isOnline: Bool
        }
        
        // MARK: - ViewModel 层示例
        class UserListViewModel: ObservableObject {
            @Published var users: [UserModel] = []
            @Published var isLoading: Bool = false
            @Published var errorMessage: String?
            
            private let userService: UserServiceProtocol
            
            init(userService: UserServiceProtocol) {
                self.userService = userService
                loadUsers()
            }
            
            func loadUsers() {
                isLoading = true
                userService.fetchUsers { [weak self] users in
                    DispatchQueue.main.async {
                        self?.users = users
                        self?.isLoading = false
                    }
                }
            }
            
            func deleteUser(at index: Int) {
                let user = users[index]
                userService.deleteUser(id: user.id) { [weak self] success in
                    if success {
                        DispatchQueue.main.async {
                            self?.users.remove(at: index)
                        }
                    }
                }
            }
        }
        
        // MARK: - View 层示例 (SwiftUI)
        struct UserListView: View {
            @StateObject private var viewModel = UserListViewModel(
                userService: UserService()
            )
            
            var body: some View {
                NavigationView {
                    if viewModel.isLoading {
                        ProgressView("加载中...")
                    } else {
                        List {
                            ForEach(viewModel.users, id: \\.id) { user in
                                UserRowView(user: user)
                            }
                            .onDelete(perform: deleteUsers)
                        }
                    }
                }
                .alert("错误", isPresented: .constant(viewModel.errorMessage != nil)) {
                    Button("确定") {
                        viewModel.errorMessage = nil
                    }
                } message: {
                    Text(viewModel.errorMessage ?? "")
                }
            }
            
            private func deleteUsers(offsets: IndexSet) {
                for index in offsets {
                    viewModel.deleteUser(at: index)
                }
            }
        }
        
        // MARK: - 数据绑定示例
        struct UserRowView: View {
            let user: UserModel
            
            var body: some View {
                HStack {
                    VStack(alignment: .leading) {
                        Text(user.name)
                            .font(.headline)
                        Text(user.email)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Circle()
                        .fill(user.isOnline ? Color.green : Color.gray)
                        .frame(width: 10, height: 10)
                }
                .padding(.vertical, 4)
            }
        }
        
        // MARK: - 服务层示例
        protocol UserServiceProtocol {
            func fetchUsers(completion: @escaping ([UserModel]) -> Void)
            func deleteUser(id: String, completion: @escaping (Bool) -> Void)
        }
        
        class UserService: UserServiceProtocol {
            func fetchUsers(completion: @escaping ([UserModel]) -> Void) {
                // 模拟网络请求
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    let users = [
                        UserModel(id: "1", name: "张三", email: "zhang@example.com", isOnline: true),
                        UserModel(id: "2", name: "李四", email: "li@example.com", isOnline: false)
                    ]
                    completion(users)
                }
            }
            
            func deleteUser(id: String, completion: @escaping (Bool) -> Void) {
                // 模拟删除操作
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    completion(true)
                }
            }
        }
        
        // MARK: - MVVM 优势总结
        /*
        ✅ 职责分离清晰
        • Model: 数据结构和业务实体
        • View: UI 展示和用户交互
        • ViewModel: 业务逻辑和状态管理
        
        ✅ 数据绑定自动化
        • @Published 属性自动更新 UI
        • 减少手动 UI 更新代码
        • 提高开发效率
        
        ✅ 易于测试
        • ViewModel 可独立测试
        • 不依赖 UI 框架
        • 支持单元测试
        
        ✅ 可维护性强
        • 代码结构清晰
        • 模块化设计
        • 易于扩展和修改
        */
        """
        
        codeTextView.text = codeExample
    }
}
