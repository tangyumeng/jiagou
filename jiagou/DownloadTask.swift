//
//  DownloadTask.swift
//  jiagou
//
//  Created by tangyumeng on 2025/10/10.
//

import Foundation

// MARK: - 下载状态枚举
enum DownloadState {
    case waiting        // 等待中
    case downloading    // 下载中
    case paused         // 已暂停
    case completed      // 已完成
    case failed         // 失败
    case cancelled      // 已取消
}

// MARK: - 下载任务模型
class DownloadTask {
    // 任务标识
    let id: String
    let url: URL
    let fileName: String
    
    // 下载状态
    var state: DownloadState = .waiting {
        didSet {
            notifyStateChanged()
        }
    }
    
    // 下载进度
    var progress: Double = 0.0 {
        didSet {
            notifyProgressChanged()
        }
    }
    
    var totalBytes: Int64 = 0
    var downloadedBytes: Int64 = 0
    
    // 下载速度（字节/秒）
    var speed: Double = 0.0
    
    // 错误信息
    var error: Error?
    
    // 保存路径
    var destinationPath: URL?
    
    // URLSession相关
    var downloadTask: URLSessionDownloadTask?
    var resumeData: Data?
    
    // 观察者回调
    var onProgressChanged: ((DownloadTask) -> Void)?
    var onStateChanged: ((DownloadTask) -> Void)?
    
    // 速度计算相关
    private var lastDownloadedBytes: Int64 = 0
    private var lastUpdateTime: Date = Date()
    
    init(url: URL, fileName: String? = nil) {
        self.id = UUID().uuidString
        self.url = url
        self.fileName = fileName ?? (url.lastPathComponent.isEmpty ? "download_\(Date().timeIntervalSince1970)" : url.lastPathComponent)
    }
    
    // 更新下载进度
    func updateProgress(downloadedBytes: Int64, totalBytes: Int64) {
        self.downloadedBytes = downloadedBytes
        self.totalBytes = totalBytes
        
        if totalBytes > 0 {
            self.progress = Double(downloadedBytes) / Double(totalBytes)
        }
        
        // 计算下载速度
        let now = Date()
        let timeInterval = now.timeIntervalSince(lastUpdateTime)
        if timeInterval >= 0.5 { // 每0.5秒更新一次速度
            let bytesIncrement = downloadedBytes - lastDownloadedBytes
            speed = Double(bytesIncrement) / timeInterval
            lastDownloadedBytes = downloadedBytes
            lastUpdateTime = now
        }
    }
    
    // 通知进度变化
    private func notifyProgressChanged() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.onProgressChanged?(self)
        }
    }
    
    // 通知状态变化
    private func notifyStateChanged() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.onStateChanged?(self)
        }
    }
    
    // 格式化文件大小
    func formattedFileSize() -> String {
        return ByteCountFormatter.string(fromByteCount: totalBytes, countStyle: .file)
    }
    
    // 格式化下载速度
    func formattedSpeed() -> String {
        if speed < 1024 {
            return String(format: "%.0f B/s", speed)
        } else if speed < 1024 * 1024 {
            return String(format: "%.2f KB/s", speed / 1024)
        } else {
            return String(format: "%.2f MB/s", speed / (1024 * 1024))
        }
    }
    
    // 获取状态描述
    func stateDescription() -> String {
        switch state {
        case .waiting:
            return "等待中"
        case .downloading:
            return "下载中"
        case .paused:
            return "已暂停"
        case .completed:
            return "已完成"
        case .failed:
            return "失败"
        case .cancelled:
            return "已取消"
        }
    }
}

