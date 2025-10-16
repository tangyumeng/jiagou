//
//  ProductModule.swift
//  jiagou
//
//  商品模块 - 协议和实现
//

import UIKit

// MARK: - 商品模块协议

/// 商品模块协议
protocol ProductModuleProtocol: PageModuleProtocol, ServiceModuleProtocol {
    
    // MARK: - 页面创建
    
    /// 创建商品详情页
    func createProductDetailPage(productId: String) -> UIViewController?
    
    /// 创建商品列表页
    func createProductListPage(category: String?) -> UIViewController?
    
    // MARK: - 服务方法
    
    /// 获取商品信息
    func getProduct(productId: String, completion: @escaping (Product?) -> Void)
    
    /// 获取商品列表
    func getProductList(category: String?, completion: @escaping ([Product]) -> Void)
    
    /// 添加到购物车
    func addToCart(productId: String, quantity: Int) -> Bool
    
    /// 收藏商品
    func favoriteProduct(productId: String) -> Bool
    
    /// 同步购物车（登录后调用）
    func syncCart()
    
    /// 清空购物车（登出后调用）
    func clearCart()
}

// MARK: - 商品模块实现

class ProductModule: ProductModuleProtocol {
    
    static let moduleName = "ProductModule"
    
    // 购物车（模拟）
    private var cart: [String: Int] = [:]
    
    // 收藏列表（模拟）
    private var favorites: Set<String> = []
    
    required init() {
        print("📦 ProductModule 已初始化")
    }
    
    // MARK: - PageModuleProtocol
    
    func createViewController(with parameters: [String : Any]) -> UIViewController? {
        if let productId = parameters["productId"] as? String {
            return createProductDetailPage(productId: productId)
        } else {
            let category = parameters["category"] as? String
            return createProductListPage(category: category)
        }
    }
    
    // MARK: - 页面创建
    
    func createProductDetailPage(productId: String) -> UIViewController? {
        let vc = ModuleProductDetailViewController()
        vc.productId = productId
        return vc
    }
    
    func createProductListPage(category: String?) -> UIViewController? {
        let vc = ModuleProductListViewController()
        vc.category = category
        return vc
    }
    
    // MARK: - 服务方法
    
    func getProduct(productId: String, completion: @escaping (Product?) -> Void) {
        print("📦 获取商品：\(productId)")
        
        // 模拟网络请求
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let product = Product(
                id: productId,
                name: "iPhone 15 Pro",
                price: 7999.0,
                imageUrl: "iphone.jpg",
                description: "A17 Pro 芯片，钛金属设计，超强性能"
            )
            completion(product)
        }
    }
    
    func getProductList(category: String?, completion: @escaping ([Product]) -> Void) {
        print("📦 获取商品列表：\(category ?? "全部")")
        
        // 模拟网络请求
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let products = [
                Product(id: "1", name: "iPhone 15", price: 5999, imageUrl: nil, description: nil),
                Product(id: "2", name: "iPad Pro", price: 6799, imageUrl: nil, description: nil),
                Product(id: "3", name: "MacBook Pro", price: 12999, imageUrl: nil, description: nil)
            ]
            completion(products)
        }
    }
    
    func addToCart(productId: String, quantity: Int) -> Bool {
        // ✅ 关键：通过协议类型获取 UserModule（无需 import UserModule）
        // 在 CocoaPods 组件化中，ProductModule Pod 不依赖 UserModule Pod
        // 只依赖 ModuleProtocols Pod，通过协议类型进行通信
        guard let userModule = ModuleManager.shared.module(UserModuleProtocol.self) else {
            print("❌ 无法获取 UserModule（可能未注册）")
            return false
        }
        
        // 检查登录状态（通过协议调用）
        guard let user = userModule.getCurrentUser() else {
            print("❌ 用户未登录，无法添加到购物车")
            return false
        }
        
        // 添加到购物车
        print("🛒 用户 \(user.name) 添加商品：\(productId) x\(quantity)")
        
        if let currentQuantity = cart[productId] {
            cart[productId] = currentQuantity + quantity
        } else {
            cart[productId] = quantity
        }
        
        return true
    }
    
    func favoriteProduct(productId: String) -> Bool {
        print("❤️ 收藏商品：\(productId)")
        favorites.insert(productId)
        return true
    }
    
    func syncCart() {
        print("🔄 同步购物车...")
        
        // ✅ 通过协议类型获取 UserModule（无需 import UserModule）
        guard let userModule = ModuleManager.shared.module(UserModuleProtocol.self) else {
            print("⚠️ 无法获取 UserModule，跳过同步")
            return
        }
        
        // 获取用户信息
        if let user = userModule.getCurrentUser() {
            print("✅ 为用户 \(user.name) 同步购物车")
            
            // 这里可以从服务器获取购物车数据
            // networkService.get(url: "/cart/\(user.id)") { ... }
        } else {
            print("⚠️ 用户未登录，无需同步购物车")
        }
    }
    
    func clearCart() {
        print("🗑️ 清空购物车")
        cart.removeAll()
    }
}

// MARK: - 商品详情页

class ModuleProductDetailViewController: UIViewController {
    
    var productId: String?
    private var product: Product?
    
    private let nameLabel = UILabel()
    private let priceLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let addToCartButton = UIButton(type: .system)
    private let favoriteButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "商品详情"
        view.backgroundColor = .systemBackground
        
        setupUI()
        loadProduct()
    }
    
    private func setupUI() {
        // 商品名称
        nameLabel.font = .systemFont(ofSize: 24, weight: .bold)
        nameLabel.textAlignment = .center
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)
        
        // 价格
        priceLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        priceLabel.textColor = .systemRed
        priceLabel.textAlignment = .center
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(priceLabel)
        
        // 描述
        descriptionLabel.font = .systemFont(ofSize: 16)
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .center
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(descriptionLabel)
        
        // 添加到购物车按钮
        addToCartButton.setTitle("加入购物车", for: .normal)
        addToCartButton.backgroundColor = .systemBlue
        addToCartButton.setTitleColor(.white, for: .normal)
        addToCartButton.layer.cornerRadius = 8
        addToCartButton.addTarget(self, action: #selector(addToCartTapped), for: .touchUpInside)
        addToCartButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(addToCartButton)
        
        // 收藏按钮
        favoriteButton.setTitle("❤️ 收藏", for: .normal)
        favoriteButton.backgroundColor = .systemPink
        favoriteButton.setTitleColor(.white, for: .normal)
        favoriteButton.layer.cornerRadius = 8
        favoriteButton.addTarget(self, action: #selector(favoriteTapped), for: .touchUpInside)
        favoriteButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(favoriteButton)
        
        NSLayoutConstraint.activate([
            nameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nameLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -100),
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            priceLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            priceLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 12),
            
            descriptionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 16),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            addToCartButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addToCartButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 40),
            addToCartButton.widthAnchor.constraint(equalToConstant: 280),
            addToCartButton.heightAnchor.constraint(equalToConstant: 44),
            
            favoriteButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            favoriteButton.topAnchor.constraint(equalTo: addToCartButton.bottomAnchor, constant: 12),
            favoriteButton.widthAnchor.constraint(equalToConstant: 280),
            favoriteButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func loadProduct() {
        guard let productId = productId else { return }
        
        // 调用商品模块服务
        if let productModule = ModuleManager.shared.module(ProductModule.self) {
            productModule.getProduct(productId: productId) { [weak self] product in
                self?.product = product
                self?.updateUI()
            }
        }
    }
    
    private func updateUI() {
        guard let product = product else { return }
        
        nameLabel.text = product.name
        priceLabel.text = "¥\(product.price)"
        descriptionLabel.text = product.description ?? "暂无描述"
    }
    
    @objc private func addToCartTapped() {
        guard let productId = productId else { return }
        
        if let productModule = ModuleManager.shared.module(ProductModule.self) {
            let success = productModule.addToCart(productId: productId, quantity: 1)
            
            let alert = UIAlertController(
                title: success ? "成功" : "失败",
                message: success ? "已添加到购物车" : "添加失败",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "确定", style: .default))
            present(alert, animated: true)
        }
    }
    
    @objc private func favoriteTapped() {
        guard let productId = productId else { return }
        
        if let productModule = ModuleManager.shared.module(ProductModule.self) {
            let success = productModule.favoriteProduct(productId: productId)
            
            let alert = UIAlertController(
                title: success ? "成功" : "失败",
                message: success ? "已收藏" : "收藏失败",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "确定", style: .default))
            present(alert, animated: true)
        }
    }
}

// MARK: - 商品列表页

class ModuleProductListViewController: UIViewController {
    
    var category: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "商品列表"
        view.backgroundColor = .systemBackground
        
        let label = UILabel()
        label.text = """
        商品列表页
        
        分类：\(category ?? "全部")
        
        iPhone 15、iPad Pro、MacBook...
        
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

