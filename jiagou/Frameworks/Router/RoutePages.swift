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
        Router.shared.open("app://dismiss")
//        dismiss(animated: true)
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

// MARK: - 图片预览页（演示传递复杂对象）

class RouteImagePreviewViewController: UIViewController, Routable {
    
    // 方式1：通过 parameters 字典接收 UIImage
    var image: UIImage?
    var imageTitle: String?
    
    // 方式2：通过缓存 ID 接收
    var imageId: String?
    
    static func instantiate(with parameters: [String : Any]) -> Self? {
        let vc = Self()
        
        // 优先从 parameters 获取 UIImage（应用内跳转）
        vc.image = parameters["image"] as? UIImage
        vc.imageTitle = parameters["title"] as? String
        
        // 如果没有，尝试从缓存获取（外部唤起或通知）
        if vc.image == nil, let imageId = parameters["imageId"] as? String {
            vc.imageId = imageId
            vc.image = RouteDataCache.shared.fetchImage(imageId)
            print("📦 从缓存获取图片：\(vc.image != nil ? "成功" : "失败")")
        }
        
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = imageTitle ?? "图片预览"
        view.backgroundColor = .systemBackground
        
        // 添加关闭按钮（如果是 present 方式）
        if presentingViewController != nil {
            navigationItem.leftBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .done,
                target: self,
                action: #selector(dismissPage)
            )
        }
        
        if let image = image {
            setupImageView(with: image)
        } else {
            setupPlaceholder()
        }
    }
    
    private func setupImageView(with image: UIImage) {
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        // 显示图片信息
        let infoLabel = UILabel()
        infoLabel.text = "图片尺寸：\(Int(image.size.width)) × \(Int(image.size.height))"
        infoLabel.font = .systemFont(ofSize: 14, weight: .medium)
        infoLabel.textColor = .white
        infoLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        infoLabel.textAlignment = .center
        infoLabel.layer.cornerRadius = 8
        infoLabel.clipsToBounds = true
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(infoLabel)
        
        NSLayoutConstraint.activate([
            infoLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            infoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            infoLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 200),
            infoLabel.heightAnchor.constraint(equalToConstant: 36)
        ])
    }
    
    private func setupPlaceholder() {
        let label = UILabel()
        label.text = "❌ 图片加载失败\n\n未找到图片数据"
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textColor = .secondaryLabel
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


