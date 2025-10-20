//
//  HomeViewController.swift
//  jiagou
//
//  主页 - 展示所有架构知识点入口
//

import UIKit

// MARK: - 架构知识点模型
struct ArchitectureItem {
    let title: String           // 标题
    let subtitle: String        // 副标题
    let icon: String           // SF Symbol 图标名
    let color: UIColor         // 主题色
    let viewController: () -> UIViewController  // 创建 ViewController 的闭包
}

// MARK: - 主页 ViewController
class HomeViewController: UIViewController {
    
    // MARK: - UI 组件
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.delegate = self
        table.dataSource = self
        table.register(ArchitectureItemCell.self, forCellReuseIdentifier: "ArchitectureItemCell")
        table.rowHeight = 80
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    private let headerView = HomeHeaderView()
    
    // MARK: - 数据源
    private let architectureItems: [ArchitectureItem] = [
        ArchitectureItem(
            title: "下载管理器",
            subtitle: "并发控制 · 断点续传 · 后台下载 · 持久化",
            icon: "arrow.down.circle.fill",
            color: .systemBlue,
            viewController: { DownloadManagerDemoViewController() }
        ),
        ArchitectureItem(
            title: "图片加载框架",
            subtitle: "三级缓存 · NSCache · 防重复下载 · LRU策略",
            icon: "photo.fill",
            color: .systemPurple,
            viewController: { ImageLoaderDemoViewController() }
        ),
        ArchitectureItem(
            title: "路由框架",
            subtitle: "URL匹配 · 参数传递 · 拦截器 · 组件化",
            icon: "map.fill",
            color: .systemOrange,
            viewController: { RouterDemoViewController() }
        ),
        ArchitectureItem(
            title: "日志框架",
            subtitle: "多级别 · 多输出 · 文件轮转 · 远程上报",
            icon: "doc.text.fill",
            color: .systemGreen,
            viewController: { LoggerDemoViewController() }
        ),
        ArchitectureItem(
            title: "EventBus 消息通信",
            subtitle: "发布订阅 · 类型安全 · 解耦通信 · 线程安全",
            icon: "bubble.left.and.bubble.right.fill",
            color: .systemPink,
            viewController: { EventBusExampleViewController() }
        ),
        ArchitectureItem(
            title: "MVVM 架构",
            subtitle: "数据绑定 · 职责分离 · 易于测试",
            icon: "square.stack.3d.up.fill",
            color: .systemTeal,
            viewController: { MVVMDemoViewController() }
        ),
        ArchitectureItem(
            title: "MVP 架构",
            subtitle: "职责分离 · 易于测试 · 手动绑定",
            icon: "rectangle.stack.fill",
            color: .systemCyan,
            viewController: { MVPDemoViewController() }
        ),
        ArchitectureItem(
            title: "协议路由（模块化）",
            subtitle: "类型安全 · 模块通信 · 服务调用 · 大型项目",
            icon: "link.circle.fill",
            color: .systemIndigo,
            viewController: { ModuleDemoViewController() }
        )
    ]
    
    // MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // 执行待处理的路由（如果有）
        // 使用场景：App 从通知或 URL Scheme 启动时，UI 未就绪，路由被延迟
        if Router.shared.hasPendingRoute {
            print("🚀 HomeViewController 已就绪，执行待处理路由")
            Router.shared.executePendingRoute()
        }
    }
    
    // MARK: - UI 设置
    private func setupUI() {
        title = "iOS 架构设计"
        view.backgroundColor = .systemBackground
        
        // 设置 TableView
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // 设置头部视图
        headerView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 150)
        tableView.tableHeaderView = headerView
    }
}

// MARK: - UITableViewDataSource
extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return architectureItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ArchitectureItemCell", for: indexPath) as! ArchitectureItemCell
        let item = architectureItems[indexPath.row]
        cell.configure(with: item)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = architectureItems[indexPath.row]
        let viewController = item.viewController()
        navigationController?.pushViewController(viewController, animated: true)
    }
}

// MARK: - 自定义 Cell
class ArchitectureItemCell: UITableViewCell {
    
    // MARK: - UI 组件
    private let iconBackgroundView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let arrowImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "chevron.right")
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .tertiaryLabel
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // MARK: - 初始化
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI 设置
    private func setupUI() {
        contentView.addSubview(iconBackgroundView)
        iconBackgroundView.addSubview(iconImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(arrowImageView)
        
        NSLayoutConstraint.activate([
            // 图标背景
            iconBackgroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            iconBackgroundView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconBackgroundView.widthAnchor.constraint(equalToConstant: 56),
            iconBackgroundView.heightAnchor.constraint(equalToConstant: 56),
            
            // 图标
            iconImageView.centerXAnchor.constraint(equalTo: iconBackgroundView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconBackgroundView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 28),
            iconImageView.heightAnchor.constraint(equalToConstant: 28),
            
            // 标题
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: iconBackgroundView.trailingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: arrowImageView.leadingAnchor, constant: -8),
            
            // 副标题
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            // 箭头
            arrowImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            arrowImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            arrowImageView.widthAnchor.constraint(equalToConstant: 14),
            arrowImageView.heightAnchor.constraint(equalToConstant: 14)
        ])
    }
    
    // MARK: - 配置
    func configure(with item: ArchitectureItem) {
        titleLabel.text = item.title
        subtitleLabel.text = item.subtitle
        iconImageView.image = UIImage(systemName: item.icon)
        iconBackgroundView.backgroundColor = item.color
    }
}

// MARK: - 头部视图
class HomeHeaderView: UIView {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "iOS 架构设计"
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "7个热门框架 · 面试必备 · 实战演练"
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let statsLabel: UILabel = {
        let label = UILabel()
        label.text = "📦 下载 · 🖼️ 图片 · 🗺️ URL路由 · 📝 日志 · 📢 EventBus · 🏗️ MVVM · 🔗 协议路由"
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .tertiaryLabel
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(statsLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            statsLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 16),
            statsLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            statsLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20)
        ])
    }
}

// MARK: - 占位 ViewController（待实现的页面）

class ImageLoaderDemoViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "图片加载框架"
        view.backgroundColor = .systemBackground
        
        let label = UILabel()
        label.text = "图片加载框架演示\n\n功能：三级缓存、防重复下载\n\n敬请期待... 🎨"
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
    }
}

// RouterDemoViewController 已在 RouterDemoViewController.swift 中实现
// LoggerDemoViewController 已在 LoggerDemoViewController.swift 中实现
