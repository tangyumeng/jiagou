//
//  DownloadTaskCell.swift
//  jiagou
//
//  Created by tangyumeng on 2025/10/10.
//

import UIKit

class DownloadTaskCell: UITableViewCell {
    
    // MARK: - UI组件
    private let fileNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let progressView: UIProgressView = {
        let progress = UIProgressView(progressViewStyle: .default)
        progress.translatesAutoresizingMaskIntoConstraints = false
        return progress
    }()
    
    private let percentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .label
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let speedLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .secondaryLabel
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - 属性
    var task: DownloadTask? {
        didSet {
            updateUI()
        }
    }
    
    var actionHandler: ((DownloadTask, DownloadTaskCell) -> Void)?
    
    // MARK: - 初始化
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - UI设置
    private func setupUI() {
        selectionStyle = .none
        
        contentView.addSubview(fileNameLabel)
        contentView.addSubview(statusLabel)
        contentView.addSubview(progressView)
        contentView.addSubview(percentLabel)
        contentView.addSubview(speedLabel)
        contentView.addSubview(actionButton)
        
        NSLayoutConstraint.activate([
            // 文件名
            fileNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            fileNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            fileNameLabel.trailingAnchor.constraint(equalTo: actionButton.leadingAnchor, constant: -8),
            
            // 状态标签
            statusLabel.topAnchor.constraint(equalTo: fileNameLabel.bottomAnchor, constant: 4),
            statusLabel.leadingAnchor.constraint(equalTo: fileNameLabel.leadingAnchor),
            statusLabel.widthAnchor.constraint(equalToConstant: 150),
            
            // 速度标签
            speedLabel.centerYAnchor.constraint(equalTo: statusLabel.centerYAnchor),
            speedLabel.trailingAnchor.constraint(equalTo: actionButton.leadingAnchor, constant: -8),
            speedLabel.widthAnchor.constraint(equalToConstant: 100),
            
            // 进度条
            progressView.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 8),
            progressView.leadingAnchor.constraint(equalTo: fileNameLabel.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: percentLabel.leadingAnchor, constant: -8),
            
            // 百分比标签
            percentLabel.centerYAnchor.constraint(equalTo: progressView.centerYAnchor),
            percentLabel.trailingAnchor.constraint(equalTo: actionButton.leadingAnchor, constant: -8),
            percentLabel.widthAnchor.constraint(equalToConstant: 50),
            
            // 操作按钮
            actionButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            actionButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            actionButton.widthAnchor.constraint(equalToConstant: 60),
            
            // 底部约束
            progressView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
        
        actionButton.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - UI更新
    private func updateUI() {
        guard let task = task else { return }
        
        fileNameLabel.text = task.fileName
        progressView.progress = Float(task.progress)
        percentLabel.text = String(format: "%.1f%%", task.progress * 100)
        
        switch task.state {
        case .waiting:
            statusLabel.text = "等待中"
            speedLabel.text = ""
            actionButton.setTitle("取消", for: .normal)
            actionButton.isEnabled = true
            
        case .downloading:
            statusLabel.text = "下载中 · \(task.formattedFileSize())"
            speedLabel.text = task.formattedSpeed()
            actionButton.setTitle("暂停", for: .normal)
            actionButton.isEnabled = true
            
        case .paused:
            statusLabel.text = "已暂停"
            speedLabel.text = ""
            actionButton.setTitle("继续", for: .normal)
            actionButton.isEnabled = true
            
        case .completed:
            statusLabel.text = "下载完成 · \(task.formattedFileSize())"
            speedLabel.text = ""
            percentLabel.text = "100%"
            actionButton.setTitle("完成", for: .normal)
            actionButton.isEnabled = false
            
        case .failed:
            statusLabel.text = "下载失败"
            speedLabel.text = ""
            actionButton.setTitle("重试", for: .normal)
            actionButton.isEnabled = true
            
        case .cancelled:
            statusLabel.text = "已取消"
            speedLabel.text = ""
            actionButton.setTitle("重新下载", for: .normal)
            actionButton.isEnabled = true
        }
    }
    
    // MARK: - 操作
    @objc private func actionButtonTapped() {
        guard let task = task else { return }
        actionHandler?(task, self)
    }
}

