//
//  RouterDemoViewController.swift
//  jiagou
//
//  Router 路由框架演示
//

import UIKit

// MARK: - Router 演示主页

class RouterDemoViewController: UIViewController {
    
    // MARK: - UI 组件
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let logTextView = UITextView()
    
    private let section1Label = UILabel()
    private let button1 = UIButton(type: .system)
    private let button2 = UIButton(type: .system)
    
    private let section2Label = UILabel()
    private let button3 = UIButton(type: .system)
    private let button4 = UIButton(type: .system)
    
    private let section3Label = UILabel()
    private let button5 = UIButton(type: .system)
    private let button6 = UIButton(type: .system)
    
    private let clearLogButton = UIButton(type: .system)
    
    // MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Router 路由演示"
        view.backgroundColor = .systemBackground
        
        setupUI()
        
        log("✅ Router 演示已启动")
        log("📝 路由已在应用启动时注册")
        
        // 调试：打印所有已注册的路由
        Router.shared.printAllRoutes()
    }
    
    // MARK: - UI 设置
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
        
        // Section 1: 基础路由
        setupSection1()
        
        // Section 2: 高级功能
        setupSection2()
        
        // Section 3: 拦截器
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
        section1Label.text = "📦 基础路由"
        section1Label.font = .boldSystemFont(ofSize: 16)
        section1Label.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(section1Label)
        
        button1.setTitle("Push：用户详情页", for: .normal)
        button1.addTarget(self, action: #selector(openUserDetail), for: .touchUpInside)
        button1.backgroundColor = .systemBlue
        button1.setTitleColor(.white, for: .normal)
        button1.layer.cornerRadius = 8
        button1.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(button1)
        
        button2.setTitle("Present：设置页面", for: .normal)
        button2.addTarget(self, action: #selector(openSettings), for: .touchUpInside)
        button2.backgroundColor = .systemBlue
        button2.setTitleColor(.white, for: .normal)
        button2.layer.cornerRadius = 8
        button2.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(button2)
    }
    
    private func setupSection2() {
        section2Label.text = "🚀 高级功能"
        section2Label.font = .boldSystemFont(ofSize: 16)
        section2Label.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(section2Label)
        
        button3.setTitle("带参数：商品详情", for: .normal)
        button3.addTarget(self, action: #selector(openProduct), for: .touchUpInside)
        button3.backgroundColor = .systemGreen
        button3.setTitleColor(.white, for: .normal)
        button3.layer.cornerRadius = 8
        button3.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(button3)
        
        button4.setTitle("Query参数：搜索", for: .normal)
        button4.addTarget(self, action: #selector(openSearch), for: .touchUpInside)
        button4.backgroundColor = .systemGreen
        button4.setTitleColor(.white, for: .normal)
        button4.layer.cornerRadius = 8
        button4.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(button4)
    }
    
    private func setupSection3() {
        section3Label.text = "🔒 拦截器演示"
        section3Label.font = .boldSystemFont(ofSize: 16)
        section3Label.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(section3Label)
        
        button5.setTitle("测试拦截器（会拦截）", for: .normal)
        button5.addTarget(self, action: #selector(testInterceptor), for: .touchUpInside)
        button5.backgroundColor = .systemOrange
        button5.setTitleColor(.white, for: .normal)
        button5.layer.cornerRadius = 8
        button5.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(button5)
        
        button6.setTitle("移除拦截器（可通过）", for: .normal)
        button6.addTarget(self, action: #selector(removeInterceptor), for: .touchUpInside)
        button6.backgroundColor = .systemOrange
        button6.setTitleColor(.white, for: .normal)
        button6.layer.cornerRadius = 8
        button6.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(button6)
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
            
            section2Label.topAnchor.constraint(equalTo: button2.bottomAnchor, constant: 20),
            section2Label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            button3.topAnchor.constraint(equalTo: section2Label.bottomAnchor, constant: 12),
            button3.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            button3.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            button3.heightAnchor.constraint(equalToConstant: 44),
            
            button4.topAnchor.constraint(equalTo: button3.bottomAnchor, constant: 12),
            button4.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            button4.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            button4.heightAnchor.constraint(equalToConstant: 44),
            
            section3Label.topAnchor.constraint(equalTo: button4.bottomAnchor, constant: 20),
            section3Label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            button5.topAnchor.constraint(equalTo: section3Label.bottomAnchor, constant: 12),
            button5.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            button5.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            button5.heightAnchor.constraint(equalToConstant: 44),
            
            button6.topAnchor.constraint(equalTo: button5.bottomAnchor, constant: 12),
            button6.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            button6.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            button6.heightAnchor.constraint(equalToConstant: 44),
            
            clearLogButton.topAnchor.constraint(equalTo: button6.bottomAnchor, constant: 20),
            clearLogButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            clearLogButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            clearLogButton.heightAnchor.constraint(equalToConstant: 44),
            clearLogButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    // MARK: - 按钮响应
    @objc private func openUserDetail() {
        
//        let success = Router.shared.open("app://back", from: self)
//        log(success ? "✅ 跳转成功" : "❌ 跳转失败")
        log("📤 打开：app://user/12345")
        let success = Router.shared.open("app://user/12345", from: self)
        log(success ? "✅ 跳转成功" : "❌ 跳转失败")
    }
    
    @objc private func openSettings() {
        log("📤 打开：app://settings (Present)")
        let success = Router.shared.open("app://settings", from: self)
        log(success ? "✅ 跳转成功" : "❌ 跳转失败")
    }
    
    @objc private func openProduct() {
        let productId = Int.random(in: 1000...9999)
        let url = "app://product/\(productId)?name=iPhone&price=5999"
        log("📤 打开：\(url)")
        let success = Router.shared.open(url, from: self)
        log(success ? "✅ 跳转成功" : "❌ 跳转失败")
    }
    
    @objc private func openSearch() {
        log("📤 打开：app://search?keyword=Swift&page=1")
        let success = Router.shared.open("app://search?keyword=Swift&page=1", from: self)
        log(success ? "✅ 跳转成功" : "❌ 跳转失败")
    }
    
    @objc private func testInterceptor() {
        log("📤 添加拦截器：拦截 VIP 页面")
        
        // 添加拦截器
        Router.shared.addInterceptor { [weak self] request in
            if request.url.absoluteString.contains("vip") {
                self?.log("⛔ 拦截器触发：需要VIP权限")
                return false
            }
            return true
        }
        
        log("📤 尝试打开：app://vip/888")
        let success = Router.shared.open("app://vip/888", from: self)
        log(success ? "✅ 跳转成功" : "❌ 被拦截了")
    }
    
    @objc private func removeInterceptor() {
        log("📤 移除所有拦截器")
        Router.shared.removeAllInterceptors()
        
        log("📤 尝试打开：app://vip/888")
        let success = Router.shared.open("app://vip/888", from: self)
        log(success ? "✅ 跳转成功（无拦截）" : "❌ 跳转失败")
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

// MARK: - 示例页面已移至 RoutePages.swift
// 所有路由页面定义都在独立文件中，便于 AppDelegate 访问

