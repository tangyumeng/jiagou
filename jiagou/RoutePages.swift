//
//  RoutePages.swift
//  jiagou
//
//  路由页面定义 - 所有通过路由跳转的页面
//

import UIKit

// MARK: - 用户详情页

class RouteUserDetailViewController: UIViewController, Routable {
    var userId: String?
    
    static func instantiate(with parameters: [String : Any]) -> Self? {
        let vc = Self()
        vc.userId = parameters["userId"] as? String
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "用户详情"
        view.backgroundColor = .systemBackground
        
        let label = UILabel()
        label.text = "用户 ID：\(userId ?? "未知")"
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

// MARK: - 设置页

class RouteSettingsViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "设置"
        view.backgroundColor = .systemBackground
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(dismissPage)
        )
        
        let label = UILabel()
        label.text = "设置页面\n（模态弹出）"
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    @objc private func dismissPage() {
        dismiss(animated: true)
    }
}

// MARK: - 商品详情页

class RouteProductViewController: UIViewController, Routable {
    var productId: String?
    var productName: String?
    var price: String?
    
    static func instantiate(with parameters: [String : Any]) -> Self? {
        let vc = Self()
        vc.productId = parameters["productId"] as? String
        vc.productName = parameters["name"] as? String
        vc.price = parameters["price"] as? String
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "商品详情"
        view.backgroundColor = .systemBackground
        
        let label = UILabel()
        label.text = """
        商品 ID：\(productId ?? "未知")
        商品名：\(productName ?? "未知")
        价格：¥\(price ?? "未知")
        """
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

// MARK: - 搜索页

class RouteSearchViewController: UIViewController, Routable {
    var keyword: String?
    var page: String?
    
    static func instantiate(with parameters: [String : Any]) -> Self? {
        let vc = Self()
        vc.keyword = parameters["keyword"] as? String
        vc.page = parameters["page"] as? String
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "搜索结果"
        view.backgroundColor = .systemBackground
        
        let label = UILabel()
        label.text = """
        关键词：\(keyword ?? "无")
        页码：\(page ?? "1")
        
        （Query 参数演示）
        """
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

// MARK: - VIP 页面

class RouteVIPViewController: UIViewController, Routable {
    var vipId: String?
    
    static func instantiate(with parameters: [String : Any]) -> Self? {
        let vc = Self()
        vc.vipId = parameters["vipId"] as? String
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "VIP 会员"
        view.backgroundColor = .systemBackground
        
        let label = UILabel()
        label.text = """
        VIP ID：\(vipId ?? "未知")
        
        🎉 恭喜！您已通过权限验证
        """
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}


