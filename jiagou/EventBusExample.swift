//
//  EventBusExample.swift
//  jiagou
//
//  EventBus 使用示例和演示
//

import UIKit

// MARK: - 自定义事件定义

/// 下载完成事件
struct DownloadCompletedEvent: Event {
    var name: String { "DownloadCompleted" }
    let fileName: String
    let fileSize: Int64
}

/// 下载进度事件
struct DownloadProgressEvent: Event {
    var name: String { "DownloadProgress" }
    let fileName: String
    let progress: Double
}

/// 订单创建事件
struct OrderCreatedEvent: Event {
    var name: String { "OrderCreated" }
    let orderId: String
    let amount: Double
    let productName: String
}

/// 主题切换事件
struct ThemeChangedEvent: Event {
    var name: String { "ThemeChanged" }
    let isDarkMode: Bool
}

// MARK: - EventBus 演示 ViewController

class EventBusExampleViewController: UIViewController {
    
    // MARK: - UI 组件
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let logTextView = UITextView()
    
    private let section1Label = UILabel()
    private let publishButton1 = UIButton(type: .system)
    private let publishButton2 = UIButton(type: .system)
    
    private let section2Label = UILabel()
    private let publishButton3 = UIButton(type: .system)
    private let publishButton4 = UIButton(type: .system)
    
    private let section3Label = UILabel()
    private let publishButton5 = UIButton(type: .system)
    
    private let clearLogButton = UIButton(type: .system)
    
    // MARK: - 生命周期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "EventBus 演示"
        view.backgroundColor = .systemBackground
        
        setupUI()
        setupEventBus()
        
        log("✅ EventBus 示例已启动")
        log("📝 已订阅所有事件，点击按钮发布事件")
    }
    
    deinit {
        // 取消所有订阅
        EventBus.shared.unsubscribeAll(observer: self)
        log("🗑️ 取消所有订阅")
    }
    
    // MARK: - 设置 UI
    
    private func setupUI() {
        // 滚动视图
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        // 日志显示区域
        logTextView.backgroundColor = .systemGray6
        logTextView.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        logTextView.isEditable = false
        logTextView.layer.cornerRadius = 8
        logTextView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(logTextView)
        
        // Section 1: 下载事件
        section1Label.text = "📦 下载事件"
        section1Label.font = .boldSystemFont(ofSize: 16)
        section1Label.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(section1Label)
        
        publishButton1.setTitle("发布：下载完成事件", for: .normal)
        publishButton1.addTarget(self, action: #selector(publishDownloadCompleted), for: .touchUpInside)
        publishButton1.backgroundColor = .systemBlue
        publishButton1.setTitleColor(.white, for: .normal)
        publishButton1.layer.cornerRadius = 8
        publishButton1.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(publishButton1)
        
        publishButton2.setTitle("发布：下载进度事件", for: .normal)
        publishButton2.addTarget(self, action: #selector(publishDownloadProgress), for: .touchUpInside)
        publishButton2.backgroundColor = .systemBlue
        publishButton2.setTitleColor(.white, for: .normal)
        publishButton2.layer.cornerRadius = 8
        publishButton2.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(publishButton2)
        
        // Section 2: 订单事件
        section2Label.text = "🛒 订单事件"
        section2Label.font = .boldSystemFont(ofSize: 16)
        section2Label.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(section2Label)
        
        publishButton3.setTitle("发布：订单创建事件", for: .normal)
        publishButton3.addTarget(self, action: #selector(publishOrderCreated), for: .touchUpInside)
        publishButton3.backgroundColor = .systemGreen
        publishButton3.setTitleColor(.white, for: .normal)
        publishButton3.layer.cornerRadius = 8
        publishButton3.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(publishButton3)
        
        publishButton4.setTitle("发布：多个订单事件", for: .normal)
        publishButton4.addTarget(self, action: #selector(publishMultipleOrders), for: .touchUpInside)
        publishButton4.backgroundColor = .systemGreen
        publishButton4.setTitleColor(.white, for: .normal)
        publishButton4.layer.cornerRadius = 8
        publishButton4.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(publishButton4)
        
        // Section 3: 主题事件
        section3Label.text = "🎨 主题事件"
        section3Label.font = .boldSystemFont(ofSize: 16)
        section3Label.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(section3Label)
        
        publishButton5.setTitle("发布：主题切换事件", for: .normal)
        publishButton5.addTarget(self, action: #selector(publishThemeChanged), for: .touchUpInside)
        publishButton5.backgroundColor = .systemPurple
        publishButton5.setTitleColor(.white, for: .normal)
        publishButton5.layer.cornerRadius = 8
        publishButton5.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(publishButton5)
        
        // 清除日志按钮
        clearLogButton.setTitle("清除日志", for: .normal)
        clearLogButton.addTarget(self, action: #selector(clearLog), for: .touchUpInside)
        clearLogButton.backgroundColor = .systemRed
        clearLogButton.setTitleColor(.white, for: .normal)
        clearLogButton.layer.cornerRadius = 8
        clearLogButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(clearLogButton)
        
        // 布局约束
        NSLayoutConstraint.activate([
            // ScrollView
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            // ContentView
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // 日志显示
            logTextView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            logTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            logTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            logTextView.heightAnchor.constraint(equalToConstant: 200),
            
            // Section 1
            section1Label.topAnchor.constraint(equalTo: logTextView.bottomAnchor, constant: 20),
            section1Label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            publishButton1.topAnchor.constraint(equalTo: section1Label.bottomAnchor, constant: 12),
            publishButton1.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            publishButton1.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            publishButton1.heightAnchor.constraint(equalToConstant: 44),
            
            publishButton2.topAnchor.constraint(equalTo: publishButton1.bottomAnchor, constant: 12),
            publishButton2.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            publishButton2.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            publishButton2.heightAnchor.constraint(equalToConstant: 44),
            
            // Section 2
            section2Label.topAnchor.constraint(equalTo: publishButton2.bottomAnchor, constant: 20),
            section2Label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            publishButton3.topAnchor.constraint(equalTo: section2Label.bottomAnchor, constant: 12),
            publishButton3.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            publishButton3.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            publishButton3.heightAnchor.constraint(equalToConstant: 44),
            
            publishButton4.topAnchor.constraint(equalTo: publishButton3.bottomAnchor, constant: 12),
            publishButton4.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            publishButton4.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            publishButton4.heightAnchor.constraint(equalToConstant: 44),
            
            // Section 3
            section3Label.topAnchor.constraint(equalTo: publishButton4.bottomAnchor, constant: 20),
            section3Label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            publishButton5.topAnchor.constraint(equalTo: section3Label.bottomAnchor, constant: 12),
            publishButton5.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            publishButton5.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            publishButton5.heightAnchor.constraint(equalToConstant: 44),
            
            // 清除按钮
            clearLogButton.topAnchor.constraint(equalTo: publishButton5.bottomAnchor, constant: 20),
            clearLogButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            clearLogButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            clearLogButton.heightAnchor.constraint(equalToConstant: 44),
            clearLogButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    // MARK: - 设置 EventBus
    
    private func setupEventBus() {
        // 方式1：使用字符串订阅
        EventBus.shared.subscribe("DownloadCompleted", observer: self) { [weak self] event in
            if let downloadEvent = event as? DownloadCompletedEvent {
                self?.log("📥 收到下载完成事件：\(downloadEvent.fileName)")
                self?.log("   文件大小：\(ByteCountFormatter.string(fromByteCount: downloadEvent.fileSize, countStyle: .file))")
            }
        }
        
        // 方式2：使用泛型订阅（类型安全，推荐）
        EventBus.shared.subscribe(DownloadProgressEvent.self, observer: self) { [weak self] event in
            self?.log("📊 下载进度：\(event.fileName) - \(Int(event.progress * 100))%")
        }
        
        // 订阅订单事件（在后台线程处理）
        EventBus.shared.subscribe(OrderCreatedEvent.self, observer: self, queue: .global(qos: .background)) { [weak self] event in
            // 模拟后台处理
            Thread.sleep(forTimeInterval: 0.5)
            
            // 切换到主线程更新 UI
            DispatchQueue.main.async {
                self?.log("🛒 订单已创建：ID=\(event.orderId)")
                self?.log("   商品：\(event.productName) | 金额：¥\(event.amount)")
            }
        }
        
        // 订阅主题切换事件
        EventBus.shared.subscribe(ThemeChangedEvent.self, observer: self) { [weak self] event in
            let mode = event.isDarkMode ? "深色模式" : "浅色模式"
            self?.log("🎨 主题已切换：\(mode)")
            
            // 模拟主题切换
            self?.updateTheme(isDarkMode: event.isDarkMode)
        }
        
        log("✅ 已订阅所有事件")
    }
    
    // MARK: - 发布事件
    
    @objc private func publishDownloadCompleted() {
        let event = DownloadCompletedEvent(
            fileName: "Xcode_15.dmg",
            fileSize: 10 * 1024 * 1024 * 1024  // 10GB
        )
        
        log("📤 发布：下载完成事件")
        EventBus.shared.post(event)
    }
    
    @objc private func publishDownloadProgress() {
        let progress = Double.random(in: 0...1)
        let event = DownloadProgressEvent(
            fileName: "Swift_Book.pdf",
            progress: progress
        )
        
        log("📤 发布：下载进度事件")
        EventBus.shared.post(event)
    }
    
    @objc private func publishOrderCreated() {
        let orderId = "ORD\(Int.random(in: 10000...99999))"
        let event = OrderCreatedEvent(
            orderId: orderId,
            amount: Double.random(in: 10...1000).rounded(),
            productName: ["iPhone 15", "MacBook Pro", "AirPods Pro", "Apple Watch"].randomElement()!
        )
        
        log("📤 发布：订单创建事件")
        EventBus.shared.post(event)
    }
    
    @objc private func publishMultipleOrders() {
        log("📤 发布：多个订单事件")
        
        for i in 1...3 {
            let orderId = "ORD\(Int.random(in: 10000...99999))"
            let event = OrderCreatedEvent(
                orderId: orderId,
                amount: Double.random(in: 10...1000).rounded(),
                productName: ["iPhone 15", "MacBook Pro", "AirPods Pro"].randomElement()!
            )
            
            // 延迟发布
            EventBus.shared.post(event, delay: TimeInterval(i) * 0.5)
        }
    }
    
    @objc private func publishThemeChanged() {
        let isDarkMode = Bool.random()
        let event = ThemeChangedEvent(isDarkMode: isDarkMode)
        
        log("📤 发布：主题切换事件")
        EventBus.shared.post(event)
    }
    
    // MARK: - 辅助方法
    
    private func log(_ message: String) {
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
        let logMessage = "[\(timestamp)] \(message)\n"
        
        DispatchQueue.main.async { [weak self] in
            self?.logTextView.text += logMessage
            
            // 自动滚动到底部
            let range = NSRange(location: self?.logTextView.text.count ?? 0, length: 0)
            self?.logTextView.scrollRangeToVisible(range)
        }
    }
    
    @objc private func clearLog() {
        logTextView.text = ""
        log("🗑️ 日志已清除")
    }
    
    private func updateTheme(isDarkMode: Bool) {
        UIView.animate(withDuration: 0.3) {
            self.view.backgroundColor = isDarkMode ? .black : .white
            self.logTextView.backgroundColor = isDarkMode ? .darkGray : .systemGray6
        }
    }
}

// MARK: - 模拟多个观察者

/// 订单统计服务（观察者1）
class OrderStatisticsService {
    
    init() {
        // 订阅订单事件
        EventBus.shared.subscribe(OrderCreatedEvent.self, observer: self) { event in
            print("📊 [统计服务] 记录订单：\(event.orderId), 金额：\(event.amount)")
            // 模拟统计逻辑
        }
    }
    
    deinit {
        EventBus.shared.unsubscribeAll(observer: self)
    }
}

/// 通知服务（观察者2）
class NotificationService {
    
    init() {
        // 订阅订单事件
        EventBus.shared.subscribe(OrderCreatedEvent.self, observer: self) { event in
            print("🔔 [通知服务] 发送通知：您的订单 \(event.orderId) 已创建")
            // 模拟推送通知
        }
        
        // 订阅下载事件
        EventBus.shared.subscribe(DownloadCompletedEvent.self, observer: self) { event in
            print("🔔 [通知服务] 下载完成：\(event.fileName)")
            // 模拟本地通知
        }
    }
    
    deinit {
        EventBus.shared.unsubscribeAll(observer: self)
    }
}

// MARK: - 使用方法

/*
 
 // 在 AppDelegate 或其他地方创建观察者服务
 let statisticsService = OrderStatisticsService()
 let notificationService = NotificationService()
 
 // 在 ViewController 中打开演示页面
 let exampleVC = EventBusExampleViewController()
 navigationController?.pushViewController(exampleVC, animated: true)
 
 // 点击按钮发布事件，观察日志输出
 
 */

// MARK: - EventBus 使用场景总结

/*
 
 ## 🎯 EventBus 适用场景
 
 ### 1. 跨模块通信
 - 订单模块 → 统计模块
 - 下载模块 → 通知模块
 - 登录模块 → 各个业务模块
 
 ### 2. 一对多通知
 - 一个事件，多个订阅者
 - 解耦事件发布者和订阅者
 
 ### 3. 替代 NotificationCenter
 - 类型安全（泛型）
 - 更清晰的事件定义
 - 自动管理订阅者生命周期
 
 ## ⚠️ 注意事项
 
 1. **避免过度使用**
    - 简单的页面间传值用代理或闭包
    - EventBus 适合跨层级、跨模块通信
 
 2. **内存管理**
    - observer 使用 weak 引用
    - deinit 中取消订阅
 
 3. **线程安全**
    - EventBus 内部已处理线程安全
    - 可指定回调队列（主线程/后台线程）
 
 4. **事件命名**
    - 使用清晰的事件名称
    - 定义为结构体，实现 Event 协议
    - 包含必要的数据
 
 */

