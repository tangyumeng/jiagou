//
//  LoggerDemoViewController.swift
//  jiagou
//
//  日志框架演示控制器
//

import UIKit

/// 日志框架演示控制器
class LoggerDemoViewController: UIViewController {
    
    // MARK: - UI 组件
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let titleLabel = UILabel()
    private let logTextView = UITextView()
    
    // 日志级别按钮
    private let verboseButton = UIButton(type: .system)
    private let debugButton = UIButton(type: .system)
    private let infoButton = UIButton(type: .system)
    private let warningButton = UIButton(type: .system)
    private let errorButton = UIButton(type: .system)
    private let fatalButton = UIButton(type: .system)
    
    // 功能按钮
    private let clearButton = UIButton(type: .system)
    private let saveToFileButton = UIButton(type: .system)
    
    private var logMessages: [String] = []
    
    // MARK: - 生命周期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "日志框架演示"
        view.backgroundColor = .systemBackground
        
        setupUI()
        setupActions()
        
        Logger.shared.addDestination(FileLogDestination())
        
        // 记录初始化日志
        logInfo("日志框架演示已启动")
    }
    
    // MARK: - UI 设置
    
    private func setupUI() {
        // 滚动视图
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        // 标题
        titleLabel.text = "日志框架功能演示"
        titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        
        // 日志显示区域
        logTextView.backgroundColor = .systemGray6
        logTextView.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        logTextView.isEditable = false
        logTextView.layer.cornerRadius = 8
        logTextView.text = "点击下方按钮记录不同级别的日志\n\n"
        logTextView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(logTextView)
        
        // 设置按钮
        setupButtons()
        
        // 布局约束
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            logTextView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            logTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            logTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            logTextView.heightAnchor.constraint(equalToConstant: 250),
            
            verboseButton.topAnchor.constraint(equalTo: logTextView.bottomAnchor, constant: 20),
            verboseButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            verboseButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            verboseButton.heightAnchor.constraint(equalToConstant: 44),
            
            debugButton.topAnchor.constraint(equalTo: verboseButton.bottomAnchor, constant: 12),
            debugButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            debugButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            debugButton.heightAnchor.constraint(equalToConstant: 44),
            
            infoButton.topAnchor.constraint(equalTo: debugButton.bottomAnchor, constant: 12),
            infoButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            infoButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            infoButton.heightAnchor.constraint(equalToConstant: 44),
            
            warningButton.topAnchor.constraint(equalTo: infoButton.bottomAnchor, constant: 12),
            warningButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            warningButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            warningButton.heightAnchor.constraint(equalToConstant: 44),
            
            errorButton.topAnchor.constraint(equalTo: warningButton.bottomAnchor, constant: 12),
            errorButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            errorButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            errorButton.heightAnchor.constraint(equalToConstant: 44),
            
            fatalButton.topAnchor.constraint(equalTo: errorButton.bottomAnchor, constant: 12),
            fatalButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            fatalButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            fatalButton.heightAnchor.constraint(equalToConstant: 44),
            
            clearButton.topAnchor.constraint(equalTo: fatalButton.bottomAnchor, constant: 20),
            clearButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            clearButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            clearButton.heightAnchor.constraint(equalToConstant: 44),
            
            saveToFileButton.topAnchor.constraint(equalTo: clearButton.bottomAnchor, constant: 12),
            saveToFileButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            saveToFileButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            saveToFileButton.heightAnchor.constraint(equalToConstant: 44),
            saveToFileButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    private func setupButtons() {
        // Verbose 按钮
        verboseButton.setTitle("💬 记录 VERBOSE 日志", for: .normal)
        verboseButton.backgroundColor = .systemGray
        verboseButton.setTitleColor(.white, for: .normal)
        verboseButton.layer.cornerRadius = 8
        verboseButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(verboseButton)
        
        // Debug 按钮
        debugButton.setTitle("🐛 记录 DEBUG 日志", for: .normal)
        debugButton.backgroundColor = .systemBlue
        debugButton.setTitleColor(.white, for: .normal)
        debugButton.layer.cornerRadius = 8
        debugButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(debugButton)
        
        // Info 按钮
        infoButton.setTitle("ℹ️ 记录 INFO 日志", for: .normal)
        infoButton.backgroundColor = .systemGreen
        infoButton.setTitleColor(.white, for: .normal)
        infoButton.layer.cornerRadius = 8
        infoButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(infoButton)
        
        // Warning 按钮
        warningButton.setTitle("⚠️ 记录 WARNING 日志", for: .normal)
        warningButton.backgroundColor = .systemYellow
        warningButton.setTitleColor(.white, for: .normal)
        warningButton.layer.cornerRadius = 8
        warningButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(warningButton)
        
        // Error 按钮
        errorButton.setTitle("❌ 记录 ERROR 日志", for: .normal)
        errorButton.backgroundColor = .systemRed
        errorButton.setTitleColor(.white, for: .normal)
        errorButton.layer.cornerRadius = 8
        errorButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(errorButton)
        
        // Fatal 按钮
        fatalButton.setTitle("💀 记录 FATAL 日志", for: .normal)
        fatalButton.backgroundColor = .systemPurple
        fatalButton.setTitleColor(.white, for: .normal)
        fatalButton.layer.cornerRadius = 8
        fatalButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(fatalButton)
        
        // 清除按钮
        clearButton.setTitle("🗑️ 清除日志", for: .normal)
        clearButton.backgroundColor = .systemGray4
        clearButton.setTitleColor(.label, for: .normal)
        clearButton.layer.cornerRadius = 8
        clearButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(clearButton)
        
        // 保存到文件按钮
        saveToFileButton.setTitle("💾 保存到文件", for: .normal)
        saveToFileButton.backgroundColor = .systemIndigo
        saveToFileButton.setTitleColor(.white, for: .normal)
        saveToFileButton.layer.cornerRadius = 8
        saveToFileButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(saveToFileButton)
    }
    
    private func setupActions() {
        verboseButton.addTarget(self, action: #selector(logVerboseTapped), for: .touchUpInside)
        debugButton.addTarget(self, action: #selector(logDebugTapped), for: .touchUpInside)
        infoButton.addTarget(self, action: #selector(logInfoTapped), for: .touchUpInside)
        warningButton.addTarget(self, action: #selector(logWarningTapped), for: .touchUpInside)
        errorButton.addTarget(self, action: #selector(logErrorTapped), for: .touchUpInside)
        fatalButton.addTarget(self, action: #selector(logFatalTapped), for: .touchUpInside)
        clearButton.addTarget(self, action: #selector(clearLogTapped), for: .touchUpInside)
        saveToFileButton.addTarget(self, action: #selector(saveToFileTapped), for: .touchUpInside)
    }
    
    // MARK: - 按钮动作
    
    @objc private func logVerboseTapped() {
        logVerbose("这是一条详细日志 (VERBOSE)")
        appendToTextView("💬 [VERBOSE] 这是一条详细日志")
    }
    
    @objc private func logDebugTapped() {
        logDebug("这是一条调试日志 (DEBUG)")
        appendToTextView("🐛 [DEBUG] 这是一条调试日志")
    }
    
    @objc private func logInfoTapped() {
        logInfo("这是一条信息日志 (INFO)")
        appendToTextView("ℹ️ [INFO] 这是一条信息日志")
    }
    
    @objc private func logWarningTapped() {
        logWarning("这是一条警告日志 (WARNING)")
        appendToTextView("⚠️ [WARNING] 这是一条警告日志")
    }
    
    @objc private func logErrorTapped() {
        logError("这是一条错误日志 (ERROR)")
        appendToTextView("❌ [ERROR] 这是一条错误日志")
    }
    
    @objc private func logFatalTapped() {
        logFatal("这是一条致命错误日志 (FATAL)")
        appendToTextView("💀 [FATAL] 这是一条致命错误日志")
    }
    
    @objc private func clearLogTapped() {
        logTextView.text = "日志已清除\n\n"
        logMessages.removeAll()
        logInfo("日志显示已清除")
    }
    
    @objc private func saveToFileTapped() {
        // 添加文件日志输出目标
        let fileDestination = FileLogDestination()
        Logger.shared.addDestination(fileDestination)
        
        logInfo("已启用文件日志，日志将保存到 Documents/Logs 目录")
        appendToTextView("💾 [INFO] 文件日志已启用")
        
        // 显示提示
        let alert = UIAlertController(
            title: "文件日志已启用",
            message: "后续日志将同时保存到文件\n路径：Documents/Logs/",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - 辅助方法
    
    private func appendToTextView(_ message: String) {
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
        let logMessage = "[\(timestamp)] \(message)\n"
        
        logMessages.append(logMessage)
        logTextView.text += logMessage
        
        // 自动滚动到底部
        let range = NSRange(location: logTextView.text.count, length: 0)
        logTextView.scrollRangeToVisible(range)
    }
}

