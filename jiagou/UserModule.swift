//
//  UserModule.swift
//  jiagou
//
//  用户模块 - 协议和实现
//

import UIKit

// MARK: - 用户模块协议

/// 用户模块协议
protocol UserModuleProtocol: PageModuleProtocol, ServiceModuleProtocol {
    
    // MARK: - 页面创建
    
    /// 创建用户详情页
    func createUserDetailPage(userId: String) -> UIViewController?
    
    /// 创建用户列表页
    func createUserListPage() -> UIViewController?
    
    /// 创建登录页
    func createLoginPage() -> UIViewController?
    
    // MARK: - 服务方法
    
    /// 获取当前用户信息
    func getCurrentUser() -> User?
    
    /// 登录
    func login(username: String, password: String, completion: @escaping (Bool, String?) -> Void)
    
    /// 登出
    func logout()
    
    /// 检查是否已登录
    func isLoggedIn() -> Bool
    
    /// 更新用户信息
    func updateUser(_ user: User) -> Bool
}

// MARK: - 用户模块实现

class UserModule: UserModuleProtocol {
    
    static let moduleName = "UserModule"
    
    // 当前用户（模拟）
    private var currentUser: User?
    
    required init() {
        print("📦 UserModule 已初始化")
    }
    
    // MARK: - PageModuleProtocol
    
    func createViewController(with parameters: [String : Any]) -> UIViewController? {
        // 根据参数决定创建哪个页面
        if let userId = parameters["userId"] as? String {
            return createUserDetailPage(userId: userId)
        } else if let isLogin = parameters["isLogin"] as? Bool, isLogin {
            return createLoginPage()
        } else {
            return createUserListPage()
        }
    }
    
    // MARK: - 页面创建
    
    func createUserDetailPage(userId: String) -> UIViewController? {
        let vc = ModuleUserDetailViewController()
        vc.userId = userId
        return vc
    }
    
    func createUserListPage() -> UIViewController? {
        return ModuleUserListViewController()
    }
    
    func createLoginPage() -> UIViewController? {
        return ModuleLoginViewController()
    }
    
    // MARK: - 服务方法
    
    func getCurrentUser() -> User? {
        return currentUser
    }
    
    func login(username: String, password: String, completion: @escaping (Bool, String?) -> Void) {
        print("🔐 登录：\(username)")
        
        // 模拟网络请求
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            if username.isEmpty || password.isEmpty {
                completion(false, "用户名或密码不能为空")
            } else {
                // 登录成功，保存用户信息
                self?.currentUser = User(
                    id: "123",
                    name: username,
                    avatar: "avatar.jpg",
                    email: "\(username)@example.com"
                )
                
                // 登录成功后，通知其他模块同步数据
                self?.notifyOtherModulesAfterLogin()
                
                completion(true, nil)
            }
        }
    }
    
    func logout() {
        print("🔓 登出")
        currentUser = nil
        
        // 登出后，通知其他模块清空数据
        notifyOtherModulesAfterLogout()
    }
    
    // MARK: - 跨模块通信
    
    /// 登录成功后通知其他模块
    private func notifyOtherModulesAfterLogin() {
        print("🔄 UserModule: 通知其他模块同步数据")
        
        // ✅ 通过协议类型调用 ProductModule（无需 import ProductModule）
        // 在 CocoaPods 组件化中，UserModule Pod 不依赖 ProductModule Pod
        // 只依赖 ModuleProtocols Pod，通过协议类型进行通信
        if let productModule = ModuleManager.shared.module(ProductModuleProtocol.self) {
            print("🔄 UserModule: 通知 ProductModule 同步购物车")
            productModule.syncCart()
        }
        
        // 可以通知更多模块（如果有）
        // if let orderModule = ModuleManager.shared.module(OrderModuleProtocol.self) {
        //     print("🔄 UserModule: 通知 OrderModule 同步订单")
        //     orderModule.syncOrders()
        // }
    }
    
    /// 登出后通知其他模块
    private func notifyOtherModulesAfterLogout() {
        print("🗑️ UserModule: 通知其他模块清空数据")
        
        // ✅ 通过协议类型调用 ProductModule
        if let productModule = ModuleManager.shared.module(ProductModuleProtocol.self) {
            print("🗑️ UserModule: 通知 ProductModule 清空购物车")
            productModule.clearCart()
        }
        
        // 可以通知更多模块
        // if let orderModule = ModuleManager.shared.module(OrderModuleProtocol.self) {
        //     orderModule.clearOrders()
        // }
    }
    
    func isLoggedIn() -> Bool {
        return currentUser != nil
    }
    
    func updateUser(_ user: User) -> Bool {
        print("📝 更新用户信息：\(user.name)")
        currentUser = user
        return true
    }
}

// MARK: - 用户详情页

class ModuleUserDetailViewController: UIViewController {
    
    var userId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "用户详情"
        view.backgroundColor = .systemBackground
        
        let label = UILabel()
        label.text = """
        用户详情页
        
        用户 ID：\(userId ?? "未知")
        
        ✅ 通过 Protocol Router 创建
        """
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
}

// MARK: - 用户列表页

class ModuleUserListViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "用户列表"
        view.backgroundColor = .systemBackground
        
        let label = UILabel()
        label.text = """
        用户列表页
        
        张三、李四、王五...
        
        ✅ 通过 Protocol Router 创建
        """
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
}

// MARK: - 登录页

class ModuleLoginViewController: UIViewController {
    
    private let usernameTextField = UITextField()
    private let passwordTextField = UITextField()
    private let loginButton = UIButton(type: .system)
    private let statusLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "登录"
        view.backgroundColor = .systemBackground
        
        setupUI()
    }
    
    private func setupUI() {
        // 用户名输入框
        usernameTextField.placeholder = "用户名"
        usernameTextField.borderStyle = .roundedRect
        usernameTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(usernameTextField)
        
        // 密码输入框
        passwordTextField.placeholder = "密码"
        passwordTextField.isSecureTextEntry = true
        passwordTextField.borderStyle = .roundedRect
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(passwordTextField)
        
        // 登录按钮
        loginButton.setTitle("登录", for: .normal)
        loginButton.backgroundColor = .systemBlue
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.layer.cornerRadius = 8
        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loginButton)
        
        // 状态标签
        statusLabel.text = "请输入用户名和密码"
        statusLabel.textAlignment = .center
        statusLabel.font = .systemFont(ofSize: 14)
        statusLabel.textColor = .secondaryLabel
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(statusLabel)
        
        NSLayoutConstraint.activate([
            usernameTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            usernameTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -80),
            usernameTextField.widthAnchor.constraint(equalToConstant: 280),
            usernameTextField.heightAnchor.constraint(equalToConstant: 44),
            
            passwordTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            passwordTextField.topAnchor.constraint(equalTo: usernameTextField.bottomAnchor, constant: 16),
            passwordTextField.widthAnchor.constraint(equalToConstant: 280),
            passwordTextField.heightAnchor.constraint(equalToConstant: 44),
            
            loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 24),
            loginButton.widthAnchor.constraint(equalToConstant: 280),
            loginButton.heightAnchor.constraint(equalToConstant: 44),
            
            statusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            statusLabel.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 16)
        ])
    }
    
    @objc private func loginTapped() {
        let username = usernameTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        
        statusLabel.text = "登录中..."
        statusLabel.textColor = .systemBlue
        
        // 调用用户模块服务
        if let userModule = ModuleManager.shared.module(UserModule.self) {
            userModule.login(username: username, password: password) { [weak self] success, error in
                if success {
                    self?.statusLabel.text = "✅ 登录成功"
                    self?.statusLabel.textColor = .systemGreen
                    
                    // 返回上一页
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self?.navigationController?.popViewController(animated: true)
                    }
                } else {
                    self?.statusLabel.text = "❌ \(error ?? "登录失败")"
                    self?.statusLabel.textColor = .systemRed
                }
            }
        }
    }
}

