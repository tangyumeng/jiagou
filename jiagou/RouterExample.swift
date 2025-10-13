//
//  RouterExample.swift
//  jiagou
//
//  路由框架使用示例
//

import UIKit

// MARK: - 示例：用户详情页面

class UserDetailViewController: UIViewController, Routable {
    
    var userId: String?
    var userName: String?
    
    // MARK: - Routable 协议
    
    static func instantiate(with parameters: [String: Any]) -> Self? {
        let vc = Self()
        vc.userId = parameters["userId"] as? String
        vc.userName = parameters["name"] as? String
        return vc
    }
    
    // MARK: - 生命周期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        title = "用户详情"
        
        setupUI()
    }
    
    private func setupUI() {
        let label = UILabel()
        label.text = "用户ID：\(userId ?? "未知")\n用户名：\(userName ?? "未知")"
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

// MARK: - 示例：商品详情页面

class ProductDetailViewController: UIViewController, Routable {
    
    var productId: String?
    var productName: String?
    var price: String?
    
    // MARK: - Routable 协议
    
    static func instantiate(with parameters: [String: Any]) -> Self? {
        let vc = Self()
        vc.productId = parameters["productId"] as? String
        vc.productName = parameters["name"] as? String
        vc.price = parameters["price"] as? String
        return vc
    }
    
    // MARK: - 生命周期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        title = "商品详情"
        
        setupUI()
    }
    
    private func setupUI() {
        let label = UILabel()
        label.text = """
        商品ID：\(productId ?? "未知")
        商品名：\(productName ?? "未知")
        价格：\(price ?? "未知")
        """
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

// MARK: - 示例：设置页面

class SettingsViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemGroupedBackground
        title = "设置"
        
        setupUI()
    }
    
    private func setupUI() {
        let label = UILabel()
        label.text = "设置页面"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

// MARK: - 路由注册（在 AppDelegate 中调用）

class RouterConfiguration {
    
    static func registerRoutes() {
        let router = Router.shared
        
        // 1. 使用 Routable 协议注册
        router.register(
            "app://user/:userId",
            viewControllerType: UserDetailViewController.self,
            action: .push
        )
        
        // 2. 使用闭包注册（支持更灵活的创建方式）
        router.register("app://product/:productId", action: .push) { parameters in
            return ProductDetailViewController.instantiate(with: parameters)
        }
        
        // 3. 注册模态弹出
        router.register("app://settings", action: .present) { _ in
            let vc = SettingsViewController()
            let nav = UINavigationController(rootViewController: vc)
            return nav
        }
        
        // 4. 注册自定义跳转方式
        router.register("app://web", action: .custom { source, destination, animated in
            // 自定义跳转逻辑
            destination.modalPresentationStyle = .fullScreen
            source.present(destination, animated: animated)
        }) { parameters in
            // 返回 WebViewController（示例）
            let vc = UIViewController()
            vc.title = parameters["url"] as? String ?? "网页"
            vc.view.backgroundColor = .white
            return vc
        }
        
        // 5. 添加拦截器（例如：登录验证）
        router.addInterceptor { request in
            // 检查是否需要登录
            if request.url.absoluteString.contains("/user/") {
                let isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
                if !isLoggedIn {
                    print("⛔ 需要登录，跳转到登录页面")
                    // 跳转到登录页
                    // Router.shared.open("app://login")
                    return false  // 拦截
                }
            }
            return true  // 通过
        }
        
        print("✅ 路由注册完成")
    }
}

// MARK: - 使用示例

/*
 
 // 在 AppDelegate 中注册路由
 func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
     RouterConfiguration.registerRoutes()
     return true
 }
 
 // 在任何 ViewController 中使用
 
 // 1. 基本使用
 Router.shared.open("app://user/123")
 
 // 2. 带额外参数
 Router.shared.open("app://user/123", parameters: ["name": "张三"])
 
 // 3. 带 query 参数
 Router.shared.open("app://product/456?name=iPhone&price=5999")
 
 // 4. 从指定 ViewController 跳转
 Router.shared.open("app://settings", from: self)
 
 // 5. 带完成回调
 Router.shared.open("app://user/123") {
     print("页面已打开")
 }
 
 // 6. UIViewController 扩展方法
 self.open("app://user/123")
 self.routeBack()  // 返回
 self.routeDismiss()  // 关闭模态
 
 // 7. 处理外部 URL（通用链接 / URL Scheme）
 func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
     return Router.shared.open(url)
 }
 
 */

