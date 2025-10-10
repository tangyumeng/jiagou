//
//  DownloadManager.swift
//  jiagou
//
//  Created by tangyumeng on 2025/10/10.
//

import Foundation

// MARK: - 下载管理器协议
protocol DownloadManagerDelegate: AnyObject {
    func downloadManager(_ manager: DownloadManager, didUpdateTask task: DownloadTask)
    func downloadManager(_ manager: DownloadManager, didCompleteTask task: DownloadTask)
    func downloadManager(_ manager: DownloadManager, didFailTask task: DownloadTask, withError error: Error)
}

// MARK: - 下载管理器
class DownloadManager: NSObject {
    
    // MARK: - 单例
    static let shared = DownloadManager()
    
    // MARK: - 属性
    private var session: URLSession!
    private var tasks: [String: DownloadTask] = [:]
    private let maxConcurrentDownloads = 3  // 最大并发下载数
    private var activeDownloadCount = 0
    private let taskQueue = DispatchQueue(label: "com.jiagou.downloadmanager", attributes: .concurrent)
    private let fileManager = FileManager.default
    
    // 代理
    weak var delegate: DownloadManagerDelegate?
    
    // 下载目录
    private lazy var downloadDirectory: URL = {
        let paths = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        let downloadDir = documentsDirectory.appendingPathComponent("Downloads")
        
        // 创建下载目录
        if !fileManager.fileExists(atPath: downloadDir.path) {
            try? fileManager.createDirectory(at: downloadDir, withIntermediateDirectories: true)
        }
        
        return downloadDir
    }()
    
    // MARK: - 初始化
    private override init() {
        super.init()
        
        let config = URLSessionConfiguration.background(withIdentifier: "com.jiagou.downloadmanager.background")
        config.isDiscretionary = false
        config.sessionSendsLaunchEvents = true
        
        session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }
    
    // MARK: - 公共方法
    
    /// 添加下载任务
    func addTask(url: URL, fileName: String? = nil) -> DownloadTask {
        let task = DownloadTask(url: url, fileName: fileName)
        task.destinationPath = downloadDirectory.appendingPathComponent(task.fileName)
        
        taskQueue.async(flags: .barrier) { [weak self] in
            self?.tasks[task.id] = task
        }
        
        startNextTaskIfPossible()
        return task
    }
    
    /// 获取所有任务
    func getAllTasks() -> [DownloadTask] {
        var result: [DownloadTask] = []
        taskQueue.sync {
            result = Array(tasks.values)
        }
        return result
    }
    
    /// 获取指定任务
    func getTask(byId id: String) -> DownloadTask? {
        var result: DownloadTask?
        taskQueue.sync {
            result = tasks[id]
        }
        return result
    }
    
    /// 开始下载
    func startDownload(taskId: String) {
        guard let task = getTask(byId: taskId) else { return }
        
        switch task.state {
        case .waiting, .failed, .cancelled:
            startTask(task)
        case .paused:
            resumeTask(task)
        default:
            break
        }
    }
    
    /// 暂停下载
    func pauseDownload(taskId: String) {
        guard let task = getTask(byId: taskId) else { return }
        guard task.state == .downloading else { return }
        
        task.downloadTask?.cancel(byProducingResumeData: { [weak self, weak task] resumeData in
            guard let self = self, let task = task else { return }
            task.resumeData = resumeData
            task.state = .paused
            self.activeDownloadCount -= 1
            self.startNextTaskIfPossible()
        })
    }
    
    /// 取消下载
    func cancelDownload(taskId: String) {
        guard let task = getTask(byId: taskId) else { return }
        
        task.downloadTask?.cancel()
        task.downloadTask = nil
        task.resumeData = nil
        task.state = .cancelled
        
        if task.state == .downloading {
            activeDownloadCount -= 1
            startNextTaskIfPossible()
        }
    }
    
    /// 删除任务
    func removeTask(taskId: String) {
        guard let task = getTask(byId: taskId) else { return }
        
        // 先取消下载
        cancelDownload(taskId: taskId)
        
        // 删除文件
        if let path = task.destinationPath {
            try? fileManager.removeItem(at: path)
        }
        
        // 从任务列表移除
        taskQueue.async(flags: .barrier) { [weak self] in
            self?.tasks.removeValue(forKey: taskId)
        }
    }
    
    /// 清除所有已完成的任务
    func clearCompletedTasks() {
        taskQueue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            let completedTaskIds = self.tasks.filter { $0.value.state == .completed }.map { $0.key }
            completedTaskIds.forEach { self.tasks.removeValue(forKey: $0) }
        }
    }
    
    // MARK: - 私有方法
    
    /// 开始任务
    private func startTask(_ task: DownloadTask) {
        guard activeDownloadCount < maxConcurrentDownloads else {
            task.state = .waiting
            return
        }
        
        let downloadTask = session.downloadTask(with: task.url)
        task.downloadTask = downloadTask
        task.state = .downloading
        activeDownloadCount += 1
        downloadTask.resume()
    }
    
    /// 恢复任务
    private func resumeTask(_ task: DownloadTask) {
        guard activeDownloadCount < maxConcurrentDownloads else {
            task.state = .waiting
            return
        }
        
        if let resumeData = task.resumeData {
            let downloadTask = session.downloadTask(withResumeData: resumeData)
            task.downloadTask = downloadTask
            task.state = .downloading
            activeDownloadCount += 1
            downloadTask.resume()
        } else {
            startTask(task)
        }
    }
    
    /// 启动下一个等待中的任务
    private func startNextTaskIfPossible() {
        guard activeDownloadCount < maxConcurrentDownloads else { return }
        
        var waitingTask: DownloadTask?
        taskQueue.sync {
            waitingTask = tasks.values.first { $0.state == .waiting }
        }
        
        if let task = waitingTask {
            startTask(task)
        }
    }
    
    /// 根据URLSessionTask查找DownloadTask
    private func findTask(for downloadTask: URLSessionDownloadTask) -> DownloadTask? {
        var result: DownloadTask?
        taskQueue.sync {
            result = tasks.values.first { $0.downloadTask == downloadTask }
        }
        return result
    }
}

// MARK: - URLSessionDownloadDelegate
extension DownloadManager: URLSessionDownloadDelegate {
    
    // 下载完成
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let task = findTask(for: downloadTask) else { return }
        
        // 移动文件到目标位置
        if let destinationPath = task.destinationPath {
            do {
                // 如果文件已存在，先删除
                if fileManager.fileExists(atPath: destinationPath.path) {
                    try fileManager.removeItem(at: destinationPath)
                }
                
                try fileManager.moveItem(at: location, to: destinationPath)
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    task.state = .completed
                    task.progress = 1.0
                    self.activeDownloadCount -= 1
                    self.delegate?.downloadManager(self, didCompleteTask: task)
                    self.startNextTaskIfPossible()
                }
            } catch {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    task.error = error
                    task.state = .failed
                    self.activeDownloadCount -= 1
                    self.delegate?.downloadManager(self, didFailTask: task, withError: error)
                    self.startNextTaskIfPossible()
                }
            }
        }
    }
    
    // 下载进度更新
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        guard let task = findTask(for: downloadTask) else { return }
        
        task.updateProgress(downloadedBytes: totalBytesWritten, totalBytes: totalBytesExpectedToWrite)
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.delegate?.downloadManager(self, didUpdateTask: task)
        }
    }
    
    // 恢复下载
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
        guard let task = findTask(for: downloadTask) else { return }
        task.updateProgress(downloadedBytes: fileOffset, totalBytes: expectedTotalBytes)
    }
}

// MARK: - URLSessionTaskDelegate
extension DownloadManager: URLSessionTaskDelegate {
    
    // 任务完成（包括成功和失败）
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let downloadTask = task as? URLSessionDownloadTask,
              let downloadTaskObj = findTask(for: downloadTask) else { return }
        
        if let error = error {
            // 检查是否是用户取消
            let nsError = error as NSError
            if nsError.code == NSURLErrorCancelled {
                return  // 用户取消，不做处理
            }
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                downloadTaskObj.error = error
                downloadTaskObj.state = .failed
                self.activeDownloadCount -= 1
                self.delegate?.downloadManager(self, didFailTask: downloadTaskObj, withError: error)
                self.startNextTaskIfPossible()
            }
        }
    }
}

