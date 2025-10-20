//
//  RouterDemoViewController.swift
//  jiagou
//
//  Router 路由框架演示
//

import UIKit
import UserNotifications

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
    
    private let section4Label = UILabel()
    private let button7 = UIButton(type: .system)
    
    private let section5Label = UILabel()
    private let button8 = UIButton(type: .system)
    private let button9 = UIButton(type: .system)
    
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
        
        // Section 4: 通知路由
        setupSection4()
        
        // Section 5: 传递复杂对象
        setupSection5()
        
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
    
    private func setupSection4() {
        section4Label.text = "🔔 通知路由测试"
        section4Label.font = .boldSystemFont(ofSize: 16)
        section4Label.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(section4Label)
        
        button7.setTitle("发送测试通知（5秒后）", for: .normal)
        button7.addTarget(self, action: #selector(testNotification), for: .touchUpInside)
        button7.backgroundColor = .systemIndigo
        button7.setTitleColor(.white, for: .normal)
        button7.layer.cornerRadius = 8
        button7.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(button7)
    }
    
    private func setupSection5() {
        section5Label.text = "📦 传递复杂对象"
        section5Label.font = .boldSystemFont(ofSize: 16)
        section5Label.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(section5Label)
        
        button8.setTitle("方式1：parameters 字典", for: .normal)
        button8.addTarget(self, action: #selector(testParametersObject), for: .touchUpInside)
        button8.backgroundColor = .systemPurple
        button8.setTitleColor(.white, for: .normal)
        button8.layer.cornerRadius = 8
        button8.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(button8)
        
        button9.setTitle("方式2：全局缓存 + ID", for: .normal)
        button9.addTarget(self, action: #selector(testCacheObject), for: .touchUpInside)
        button9.backgroundColor = .systemPurple
        button9.setTitleColor(.white, for: .normal)
        button9.layer.cornerRadius = 8
        button9.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(button9)
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
            
            section4Label.topAnchor.constraint(equalTo: button6.bottomAnchor, constant: 20),
            section4Label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            button7.topAnchor.constraint(equalTo: section4Label.bottomAnchor, constant: 12),
            button7.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            button7.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            button7.heightAnchor.constraint(equalToConstant: 44),
            
            section5Label.topAnchor.constraint(equalTo: button7.bottomAnchor, constant: 20),
            section5Label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            button8.topAnchor.constraint(equalTo: section5Label.bottomAnchor, constant: 12),
            button8.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            button8.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            button8.heightAnchor.constraint(equalToConstant: 44),
            
            button9.topAnchor.constraint(equalTo: button8.bottomAnchor, constant: 12),
            button9.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            button9.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            button9.heightAnchor.constraint(equalToConstant: 44),
            
            clearLogButton.topAnchor.constraint(equalTo: button9.bottomAnchor, constant: 20),
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
    
    @objc private func testNotification() {
        log("📤 准备发送本地通知...")
        
        // 创建通知内容
        let content = UNMutableNotificationContent()
        content.title = "路由测试通知"
        content.body = "点击此通知将跳转到 VIP 页面"
        content.sound = .default
        content.badge = 1
        
        // 添加路由信息到通知负载
        content.userInfo = [
            "route": "app://vip/999",
            "parameters": [
                "from": "notification",
                "message": "通知路由测试成功！"
            ]
        ]
        
        // 5秒后触发
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        
        // 添加通知请求
        UNUserNotificationCenter.current().add(request) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.log("❌ 通知发送失败：\(error.localizedDescription)")
                } else {
                    self?.log("✅ 通知已调度（5秒后触发）")
                    self?.log("💡 提示：")
                    self?.log("  1. 前台：等待通知 banner 并点击")
                    self?.log("  2. 后台：按 Home 键，等待并点击通知")
                    self?.log("  3. 杀死 App：从多任务管理器杀死 App，等待并点击通知")
                }
            }
        }
    }
    
    @objc private func testParametersObject() {
        log("📤 测试传递 UIImage（方式1：parameters 字典）")
        
        // 创建测试图片
        let image = createTestImage(text: "Hello Router!", size: CGSize(width: 300, height: 200))
        
        log("📦 创建图片：\(Int(image.size.width))×\(Int(image.size.height))")
        log("📤 通过 parameters 直接传递 UIImage")
        
        // 方式1：通过 parameters 字典传递 UIImage
        let success = Router.shared.open(
            "app://image-preview",
            parameters: [
                "image": image,
                "title": "方式1：Parameters"
            ],
            from: self
        )
        
        log(success ? "✅ 跳转成功" : "❌ 跳转失败")
    }
    
    @objc private func testCacheObject() {
        log("📤 测试传递 UIImage（方式2：全局缓存）")
        
        // 创建测试图片
        let image = createTestImage(text: "Cache ID: 12345", size: CGSize(width: 300, height: 200))
        
        log("📦 创建图片：\(Int(image.size.width))×\(Int(image.size.height))")
        
        // 方式2：存储到全局缓存
        let imageId = RouteDataCache.shared.storeImage(image, ttl: 60)
        log("📦 存储到缓存：ID = \(imageId)")
        log("📤 通过 URL 传递 ID")
        
        // URL 中只传递 ID
        let success = Router.shared.open("app://image-preview/\(imageId)", from: self)
        
        log(success ? "✅ 跳转成功" : "❌ 跳转失败")
        log("💡 目标页面将从缓存中获取图片")
    }
    
    /// 创建测试图片
    private func createTestImage(text: String, size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            // 背景渐变
            let colors = [UIColor.systemBlue.cgColor, UIColor.systemPurple.cgColor]
            let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors as CFArray, locations: nil)!
            context.cgContext.drawLinearGradient(gradient, start: .zero, end: CGPoint(x: size.width, y: size.height), options: [])
            
            // 文字
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 24),
                .foregroundColor: UIColor.white,
                .paragraphStyle: paragraphStyle
            ]
            
            let textSize = text.size(withAttributes: attributes)
            let textRect = CGRect(
                x: (size.width - textSize.width) / 2,
                y: (size.height - textSize.height) / 2,
                width: textSize.width,
                height: textSize.height
            )
            
            text.draw(in: textRect, withAttributes: attributes)
        }
        
        return image
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

