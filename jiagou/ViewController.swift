//
//  ViewController.swift
//  jiagou
//
//  Created by tangyumeng on 2025/10/10.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: - UI组件
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.delegate = self
        table.dataSource = self
        table.register(DownloadTaskCell.self, forCellReuseIdentifier: "DownloadTaskCell")
        table.rowHeight = 100
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    private lazy var addButton: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addDownloadTask))
    }()
    
    private lazy var clearButton: UIBarButtonItem = {
        return UIBarButtonItem(title: "清除已完成", style: .plain, target: self, action: #selector(clearCompleted))
    }()
    
    private lazy var eventBusButton: UIBarButtonItem = {
        return UIBarButtonItem(title: "EventBus", style: .plain, target: self, action: #selector(openEventBusDemo))
    }()
    
    // MARK: - 属性
    private let downloadManager = DownloadManager.shared
    private var tasks: [DownloadTask] = []
    
    // 测试下载URL列表
    private let testURLs = [
        "https://speed.hetzner.de/100MB.bin",
        "https://speed.hetzner.de/1GB.bin",
        "https://ash-speed.hetzner.com/100MB.bin",
        "https://download.blender.org/demo/movies/BBB/bbb_sunflower_1080p_30fps_normal.mp4",
        "https://sample-videos.com/video321/mp4/720/big_buck_bunny_720p_1mb.mp4"
    ]
    
    // MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupDownloadManager()
        loadTasks()
    }
    
    // MARK: - UI设置
    private func setupUI() {
        title = "多任务下载器"
        view.backgroundColor = .systemBackground
        
        // 设置导航栏按钮
        navigationItem.rightBarButtonItems = [addButton, eventBusButton]
        navigationItem.leftBarButtonItem = clearButton
        
        // 添加tableView
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupDownloadManager() {
        downloadManager.delegate = self
    }
    
    // MARK: - 数据加载
    private func loadTasks() {
        tasks = downloadManager.getAllTasks()
        
        // 为每个任务设置观察者
        tasks.forEach { task in
            setupTaskObservers(task)
        }
        
        tableView.reloadData()
    }
    
    private func setupTaskObservers(_ task: DownloadTask) {
        // 进度变化回调
        task.onProgressChanged = { [weak self] _ in
            self?.updateTaskCell(task)
        }
        
        // 状态变化回调
        task.onStateChanged = { [weak self] _ in
            self?.updateTaskCell(task)
        }
    }
    
    private func updateTaskCell(_ task: DownloadTask) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        let indexPath = IndexPath(row: index, section: 0)
        
        DispatchQueue.main.async { [weak self] in
            if let cell = self?.tableView.cellForRow(at: indexPath) as? DownloadTaskCell {
                cell.task = task
            }
        }
    }
    
    // MARK: - 操作
    @objc private func addDownloadTask() {
        let alert = UIAlertController(title: "添加下载任务", message: "选择一个测试文件或输入自定义URL", preferredStyle: .actionSheet)
        
        // 添加测试URL选项
        for (index, url) in testURLs.enumerated() {
            let fileName = URL(string: url)?.lastPathComponent ?? "文件\(index + 1)"
            alert.addAction(UIAlertAction(title: "测试文件 \(index + 1): \(fileName)", style: .default) { [weak self] _ in
                self?.createDownloadTask(urlString: url)
            })
        }
        
        // 添加自定义URL选项
        alert.addAction(UIAlertAction(title: "输入自定义URL", style: .default) { [weak self] _ in
            self?.showCustomURLInput()
        })
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        
        // iPad适配
        if let popover = alert.popoverPresentationController {
            popover.barButtonItem = addButton
        }
        
        present(alert, animated: true)
    }
    
    private func showCustomURLInput() {
        let alert = UIAlertController(title: "输入下载URL", message: nil, preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "https://example.com/file.zip"
            textField.keyboardType = .URL
        }
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "添加", style: .default) { [weak self, weak alert] _ in
            guard let urlString = alert?.textFields?.first?.text, !urlString.isEmpty else {
                return
            }
            self?.createDownloadTask(urlString: urlString)
        })
        
        present(alert, animated: true)
    }
    
    private func createDownloadTask(urlString: String) {
        guard let url = URL(string: urlString) else {
            showError(message: "无效的URL")
            return
        }
        
        let task = downloadManager.addTask(url: url)
        setupTaskObservers(task)
        tasks.insert(task, at: 0)
        
        tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        
        // 自动开始下载
        downloadManager.startDownload(taskId: task.id)
    }
    
    @objc private func clearCompleted() {
        let completedIndices = tasks.enumerated()
            .filter { $0.element.state == .completed }
            .map { $0.offset }
        
        guard !completedIndices.isEmpty else {
            showError(message: "没有已完成的任务")
            return
        }
        
        // 从后往前删除，避免索引变化
        for index in completedIndices.reversed() {
            let task = tasks[index]
            downloadManager.removeTask(taskId: task.id)
            tasks.remove(at: index)
        }
        
        let indexPaths = completedIndices.map { IndexPath(row: $0, section: 0) }
        tableView.deleteRows(at: indexPaths, with: .fade)
    }
    
    @objc private func openEventBusDemo() {
        let eventBusVC = EventBusExampleViewController()
        navigationController?.pushViewController(eventBusVC, animated: true)
    }
    
    private func handleTaskAction(_ task: DownloadTask) {
        switch task.state {
        case .waiting, .failed, .cancelled:
            downloadManager.startDownload(taskId: task.id)
            
        case .downloading:
            downloadManager.pauseDownload(taskId: task.id)
            
        case .paused:
            downloadManager.startDownload(taskId: task.id)
            
        case .completed:
            break
        }
    }
    
    private func showError(message: String) {
        let alert = UIAlertController(title: "错误", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DownloadTaskCell", for: indexPath) as! DownloadTaskCell
        let task = tasks[indexPath.row]
        cell.task = task
        cell.actionHandler = { [weak self] task, _ in
            self?.handleTaskAction(task)
        }
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let task = tasks[indexPath.row]
        
        let deleteAction = UIContextualAction(style: .destructive, title: "删除") { [weak self] _, _, completion in
            guard let self = self else {
                completion(false)
                return
            }
            
            self.downloadManager.removeTask(taskId: task.id)
            self.tasks.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
            completion(true)
        }
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

// MARK: - DownloadManagerDelegate
extension ViewController: DownloadManagerDelegate {
    func downloadManager(_ manager: DownloadManager, didUpdateTask task: DownloadTask) {
        // 由task的观察者回调处理
    }
    
    func downloadManager(_ manager: DownloadManager, didCompleteTask task: DownloadTask) {
        DispatchQueue.main.async { [weak self] in
            let alert = UIAlertController(
                title: "下载完成",
                message: "\(task.fileName) 下载完成",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "确定", style: .default))
            self?.present(alert, animated: true)
        }
    }
    
    func downloadManager(_ manager: DownloadManager, didFailTask task: DownloadTask, withError error: Error) {
        DispatchQueue.main.async { [weak self] in
            let alert = UIAlertController(
                title: "下载失败",
                message: "\(task.fileName) 下载失败: \(error.localizedDescription)",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "确定", style: .default))
            self?.present(alert, animated: true)
        }
    }
}

