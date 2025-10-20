//
//  ModuleManagerDemoViewController.swift
//  jiagou
//
//  ModuleManager presentPage 演示
//

import UIKit

class ModuleManagerDemoViewController: UIViewController {
    
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "ModuleManager 演示"
        view.backgroundColor = .systemBackground
        
        setupUI()
    }
    
    private func setupUI() {
        // 设置 ScrollView
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        // 设置 StackView
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40)
        ])
        
        // 添加标题
        addSectionTitle("📤 presentPage 演示")
        
        // 添加演示按钮
        addDemoButton(title: "1️⃣ Present 用户列表", subtitle: "基础用法", action: #selector(demo1))
        addDemoButton(title: "2️⃣ Present 用户详情", subtitle: "传递参数", action: #selector(demo2))
        addDemoButton(title: "3️⃣ Present 商品列表", subtitle: "使用协议类型⭐", action: #selector(demo3))
        addDemoButton(title: "4️⃣ Present 登录页", subtitle: "自动获取源控制器", action: #selector(demo4))
        addDemoButton(title: "5️⃣ Present 商品详情", subtitle: "带完成回调", action: #selector(demo5))
        
        addSectionTitle("🔄 openPage 演示")
        
        addDemoButton(title: "6️⃣ Push 用户列表", subtitle: "导航栈 Push", action: #selector(demo6))
        addDemoButton(title: "7️⃣ Push 商品详情", subtitle: "带参数 Push", action: #selector(demo7))
        
        addSectionTitle("📊 调试工具")
        
        addDemoButton(title: "📋 查看已注册模块", subtitle: "打印模块列表", action: #selector(printModules))
    }
    
    private func addSectionTitle(_ title: String) {
        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .label
        stackView.addArrangedSubview(label)
        
        // 添加间距
        let spacer = UIView()
        spacer.heightAnchor.constraint(equalToConstant: 8).isActive = true
        stackView.addArrangedSubview(spacer)
    }
    
    private func addDemoButton(title: String, subtitle: String, action: Selector) {
        let container = UIView()
        container.backgroundColor = .secondarySystemBackground
        container.layer.cornerRadius = 12
        
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(button)
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        button.addSubview(titleLabel)
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.font = .systemFont(ofSize: 13, weight: .regular)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        button.addSubview(subtitleLabel)
        
        button.addTarget(self, action: action, for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: container.topAnchor),
            button.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            button.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            button.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            button.heightAnchor.constraint(greaterThanOrEqualToConstant: 70),
            
            titleLabel.topAnchor.constraint(equalTo: button.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -20),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            subtitleLabel.bottomAnchor.constraint(equalTo: button.bottomAnchor, constant: -16)
        ])
        
        stackView.addArrangedSubview(container)
    }
    
    // MARK: - 演示方法
    
    @objc private func demo1() {
        print("\n🎬 演示1：Present 用户列表")
        print("代码：ModuleManager.shared.presentPage(UserModule.self, parameters: [:])")
        
        let success = ModuleManager.shared.presentPage(
            UserModule.self,
            parameters: [:],
            from: self,
            animated: true
        )
        
        print(success ? "✅ 成功" : "❌ 失败")
    }
    
    @objc private func demo2() {
        print("\n🎬 演示2：Present 用户详情（带参数）")
        print("代码：ModuleManager.shared.presentPage(UserModule.self, parameters: [\"userId\": \"12345\"])")
        
        let success = ModuleManager.shared.presentPage(
            UserModule.self,
            parameters: ["userId": "12345"],
            from: self,
            animated: true,
            completion: {
                print("✅ 页面弹出动画完成")
            }
        )
        
        print(success ? "✅ 成功" : "❌ 失败")
    }
    
    @objc private func demo3() {
        print("\n🎬 演示3：Present 商品列表（协议类型）⭐")
        print("代码：ModuleManager.shared.presentPage(ProductModuleProtocol.self, ...)")
        print("💡 使用协议类型，实现解耦，无需 import ProductModule")
        
        let success = ModuleManager.shared.presentPage(
            ProductModuleProtocol.self,
            parameters: ["category": "手机"],
            from: self,
            animated: true
        )
        
        print(success ? "✅ 成功" : "❌ 失败")
    }
    
    @objc private func demo4() {
        print("\n🎬 演示4：Present 登录页（自动获取源）")
        print("代码：ModuleManager.shared.presentPage(UserModule.self, from: nil)")
        print("💡 from 参数为 nil，会自动获取当前显示的 ViewController")
        
        let success = ModuleManager.shared.presentPage(
            UserModule.self,
            parameters: ["isLogin": true],
            from: nil,  // 自动获取当前控制器
            animated: true
        )
        
        print(success ? "✅ 成功" : "❌ 失败")
    }
    
    @objc private func demo5() {
        print("\n🎬 演示5：Present 商品详情（带回调）")
        print("代码：ModuleManager.shared.presentPage(..., completion: { ... })")
        
        let success = ModuleManager.shared.presentPage(
            ProductModule.self,
            parameters: ["productId": "iPhone15"],
            from: self,
            animated: true,
            completion: { [weak self] in
                print("✅ 页面弹出完成")
                self?.trackEvent("ProductDetailPresented")
            }
        )
        
        print(success ? "✅ 成功" : "❌ 失败")
    }
    
    @objc private func demo6() {
        print("\n🎬 演示6：Push 用户列表")
        print("代码：ModuleManager.shared.openPage(UserModule.self)")
        
        let success = ModuleManager.shared.openPage(
            UserModule.self,
            parameters: [:],
            from: self,
            animated: true
        )
        
        print(success ? "✅ 成功" : "❌ 失败")
    }
    
    @objc private func demo7() {
        print("\n🎬 演示7：Push 商品详情（带参数）")
        print("代码：ModuleManager.shared.openPage(ProductModule.self, parameters: [\"productId\": \"999\"])")
        
        let success = ModuleManager.shared.openPage(
            ProductModule.self,
            parameters: ["productId": "999"],
            from: self,
            animated: true
        )
        
        print(success ? "✅ 成功" : "❌ 失败")
    }
    
    @objc private func printModules() {
        print("\n📋 已注册的模块：")
        ModuleManager.shared.printAllModules()
    }
    
    private func trackEvent(_ event: String) {
        print("📊 埋点：\(event)")
    }
}
