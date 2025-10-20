//
//  ModuleDemoViewController.swift
//  jiagou
//
//  Protocol-Based Router 演示
//

import UIKit

class ModuleDemoViewController: UIViewController {
    
    // MARK: - UI组件
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let logTextView = UITextView()
    
    private let section1Label = UILabel()
    private let button1 = UIButton(type: .system)
    private let button2 = UIButton(type: .system)
    private let button3 = UIButton(type: .system)
    
    private let section2Label = UILabel()
    private let button4 = UIButton(type: .system)
    private let button5 = UIButton(type: .system)
    private let button6 = UIButton(type: .system)
    
    private let section3Label = UILabel()
    private let button7 = UIButton(type: .system)
    private let button8 = UIButton(type: .system)
    
    private let clearLogButton = UIButton(type: .system)
    
    // MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Protocol Router 演示"
        view.backgroundColor = .systemBackground
        
        setupUI()
        
        log("✅ Protocol Router 演示已启动")
        log("📦 已注册模块：UserModule, ProductModule")
        
        // 打印所有模块
        ModuleManager.shared.printAllModules()
    }
    
    // MARK: - UI设置
    private func setupUI() {
        // 滚动视图
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        // 日志显示
        logTextView.backgroundColor = .systemGray6
        logTextView.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        logTextView.isEditable = false
        logTextView.layer.cornerRadius = 8
        logTextView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(logTextView)
        
        // Section 1: 用户模块
        setupSection1()
        
        // Section 2: 商品模块
        setupSection2()
        
        // Section 3: 跨模块通信
        setupSection3()
        
        // 清除按钮
        clearLogButton.setTitle("清除日志", for: .normal)
        clearLogButton.addTarget(self, action: #selector(clearLog), for: .touchUpInside)
        clearLogButton.backgroundColor = .systemRed
        clearLogButton.setTitleColor(.white, for: .normal)
        clearLogButton.layer.cornerRadius = 8
        clearLogButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(clearLogButton)
        
        setupConstraints()
    }
    
    private func setupSection1() {
        section1Label.text = "👤 用户模块"
        section1Label.font = .boldSystemFont(ofSize: 16)
        section1Label.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(section1Label)
        
        button1.setTitle("打开用户详情页", for: .normal)
        button1.addTarget(self, action: #selector(openUserDetail), for: .touchUpInside)
        button1.backgroundColor = .systemBlue
        button1.setTitleColor(.white, for: .normal)
        button1.layer.cornerRadius = 8
        button1.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(button1)
        
        button2.setTitle("打开用户列表页", for: .normal)
        button2.addTarget(self, action: #selector(openUserList), for: .touchUpInside)
        button2.backgroundColor = .systemBlue
        button2.setTitleColor(.white, for: .normal)
        button2.layer.cornerRadius = 8
        button2.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(button2)
        
        button3.setTitle("调用登录服务", for: .normal)
        button3.addTarget(self, action: #selector(callLoginService), for: .touchUpInside)
        button3.backgroundColor = .systemBlue
        button3.setTitleColor(.white, for: .normal)
        button3.layer.cornerRadius = 8
        button3.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(button3)
    }
    
    private func setupSection2() {
        section2Label.text = "📦 商品模块"
        section2Label.font = .boldSystemFont(ofSize: 16)
        section2Label.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(section2Label)
        
        button4.setTitle("打开商品详情页", for: .normal)
        button4.addTarget(self, action: #selector(openProductDetail), for: .touchUpInside)
        button4.backgroundColor = .systemGreen
        button4.setTitleColor(.white, for: .normal)
        button4.layer.cornerRadius = 8
        button4.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(button4)
        
        button5.setTitle("打开商品列表页", for: .normal)
        button5.addTarget(self, action: #selector(openProductList), for: .touchUpInside)
        button5.backgroundColor = .systemGreen
        button5.setTitleColor(.white, for: .normal)
        button5.layer.cornerRadius = 8
        button5.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(button5)
        
        button6.setTitle("调用商品服务", for: .normal)
        button6.addTarget(self, action: #selector(callProductService), for: .touchUpInside)
        button6.backgroundColor = .systemGreen
        button6.setTitleColor(.white, for: .normal)
        button6.layer.cornerRadius = 8
        button6.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(button6)
    }
    
    private func setupSection3() {
        section3Label.text = "🔄 跨模块通信"
        section3Label.font = .boldSystemFont(ofSize: 16)
        section3Label.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(section3Label)
        
        button7.setTitle("登录后查看商品", for: .normal)
        button7.addTarget(self, action: #selector(loginAndViewProduct), for: .touchUpInside)
        button7.backgroundColor = .systemOrange
        button7.setTitleColor(.white, for: .normal)
        button7.layer.cornerRadius = 8
        button7.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(button7)
        
        button8.setTitle("获取用户并购买", for: .normal)
        button8.addTarget(self, action: #selector(getUserAndBuy), for: .touchUpInside)
        button8.backgroundColor = .systemOrange
        button8.setTitleColor(.white, for: .normal)
        button8.layer.cornerRadius = 8
        button8.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(button8)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            logTextView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            logTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            logTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            logTextView.heightAnchor.constraint(equalToConstant: 200),
            
            section1Label.topAnchor.constraint(equalTo: logTextView.bottomAnchor, constant: 20),
            section1Label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            button1.topAnchor.constraint(equalTo: section1Label.bottomAnchor, constant: 12),
            button1.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            button1.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            button1.heightAnchor.constraint(equalToConstant: 44),
            
            button2.topAnchor.constraint(equalTo: button1.bottomAnchor, constant: 12),
            button2.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            button2.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            button2.heightAnchor.constraint(equalToConstant: 44),
            
            button3.topAnchor.constraint(equalTo: button2.bottomAnchor, constant: 12),
            button3.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            button3.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            button3.heightAnchor.constraint(equalToConstant: 44),
            
            section2Label.topAnchor.constraint(equalTo: button3.bottomAnchor, constant: 20),
            section2Label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            button4.topAnchor.constraint(equalTo: section2Label.bottomAnchor, constant: 12),
            button4.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            button4.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            button4.heightAnchor.constraint(equalToConstant: 44),
            
            button5.topAnchor.constraint(equalTo: button4.bottomAnchor, constant: 12),
            button5.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            button5.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            button5.heightAnchor.constraint(equalToConstant: 44),
            
            button6.topAnchor.constraint(equalTo: button5.bottomAnchor, constant: 12),
            button6.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            button6.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            button6.heightAnchor.constraint(equalToConstant: 44),
            
            section3Label.topAnchor.constraint(equalTo: button6.bottomAnchor, constant: 20),
            section3Label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            button7.topAnchor.constraint(equalTo: section3Label.bottomAnchor, constant: 12),
            button7.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            button7.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            button7.heightAnchor.constraint(equalToConstant: 44),
            
            button8.topAnchor.constraint(equalTo: button7.bottomAnchor, constant: 12),
            button8.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            button8.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            button8.heightAnchor.constraint(equalToConstant: 44),
            
            clearLogButton.topAnchor.constraint(equalTo: button8.bottomAnchor, constant: 20),
            clearLogButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            clearLogButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            clearLogButton.heightAnchor.constraint(equalToConstant: 44),
            clearLogButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    // MARK: - 按钮响应 - 用户模块
    
    @objc private func openUserDetail() {
        log("📤 打开用户详情页（Protocol Router）")
        
        let success = ModuleManager.shared.openPage(
            UserModule.self,
            parameters: ["userId": "12345"],
            from: self
        )
        
        log(success ? "✅ 跳转成功" : "❌ 跳转失败")
    }
    
    @objc private func openUserList() {
        log("📤 打开用户列表页（Protocol Router）")
        
        let success = ModuleManager.shared.openPage(
            UserModule.self,
            parameters: [:],
            from: self
        )
        
        log(success ? "✅ 跳转成功" : "❌ 跳转失败")
    }
    
    @objc private func callLoginService() {
        log("📤 调用登录服务（UserModule）")
        
        if let userModule = ModuleManager.shared.module(UserModule.self) {
            userModule.login(username: "zhangsan", password: "123456") { [weak self] success, error in
                if success {
                    self?.log("✅ 登录成功")
                    if let user = userModule.getCurrentUser() {
                        self?.log("📝 当前用户：\(user.name)")
                    }
                } else {
                    self?.log("❌ 登录失败：\(error ?? "未知错误")")
                }
            }
        }
    }
    
    // MARK: - 按钮响应 - 商品模块
    
    @objc private func openProductDetail() {
        log("📤 打开商品详情页（Protocol Router）")
        
        let success = ModuleManager.shared.openPage(
            ProductModule.self,
            parameters: ["productId": "8888"],
            from: self
        )
        
        log(success ? "✅ 跳转成功" : "❌ 跳转失败")
    }
    
    @objc private func openProductList() {
        log("📤 打开商品列表页（Protocol Router）")
        
        let success = ModuleManager.shared.openPage(
            ProductModule.self,
            parameters: ["category": "电子产品"],
            from: self
        )
        
        log(success ? "✅ 跳转成功" : "❌ 跳转失败")
    }
    
    @objc private func callProductService() {
        log("📤 调用商品服务（ProductModule）")
        
        if let productModule = ModuleManager.shared.module(ProductModule.self) {
            productModule.getProduct(productId: "8888") { [weak self] product in
                if let product = product {
                    self?.log("✅ 获取商品成功")
                    self?.log("📝 商品：\(product.name)，价格：¥\(product.price)")
                } else {
                    self?.log("❌ 获取商品失败")
                }
            }
        }
    }
    
    // MARK: - 按钮响应 - 跨模块通信
    
    @objc private func loginAndViewProduct() {
        log("📤 场景：登录后查看商品（跨模块）")
        
        // 1. 先调用用户模块登录
        if let userModule = ModuleManager.shared.module(UserModule.self) {
            log("🔐 正在登录...")
            
            userModule.login(username: "zhangsan", password: "123456") { [weak self] success, _ in
                if success {
                    self?.log("✅ 登录成功")
                    
                    // 2. 登录成功后，跳转到商品详情页
                    self?.log("📦 打开商品详情页...")
                    
                    _ = ModuleManager.shared.openPage(
                        ProductModule.self,
                        parameters: ["productId": "8888"],
                        from: self
                    )
                } else {
                    self?.log("❌ 登录失败，无法查看商品")
                }
            }
        }
    }
    
    @objc private func getUserAndBuy() {
        log("📤 场景：获取用户信息并购买（跨模块）")
        
        // 1. 获取用户模块
        guard let userModule = ModuleManager.shared.module(UserModule.self) else {
            log("❌ 获取 UserModule 失败")
            return
        }
        
        // 2. 检查登录状态
        if let user = userModule.getCurrentUser() {
            log("✅ 当前用户：\(user.name)")
            
            // 3. 获取商品信息
            if let productModule = ModuleManager.shared.module(ProductModule.self) {
                productModule.getProduct(productId: "8888") { [weak self] product in
                    if let product = product {
                        self?.log("✅ 商品：\(product.name)，价格：¥\(product.price)")
                        
                        // 4. 添加到购物车
                        let success = productModule.addToCart(productId: "8888", quantity: 1)
                        self?.log(success ? "✅ 已添加到购物车" : "❌ 添加失败")
                    }
                }
            }
        } else {
            log("❌ 未登录，请先登录")
            log("📤 跳转到登录页...")
            
            _ = ModuleManager.shared.openPage(
                UserModule.self,
                parameters: ["isLogin": true],
                from: self
            )
        }
    }
    
    // MARK: - 辅助方法
    
    private func log(_ message: String) {
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
        let logMessage = "[\(timestamp)] \(message)\n"
        
        DispatchQueue.main.async { [weak self] in
            self?.logTextView.text += logMessage
            
            let range = NSRange(location: self?.logTextView.text.count ?? 0, length: 0)
            self?.logTextView.scrollRangeToVisible(range)
        }
    }
    
    @objc private func clearLog() {
        logTextView.text = ""
        log("🗑️ 日志已清除")
    }
}

