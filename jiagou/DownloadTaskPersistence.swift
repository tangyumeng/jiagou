//
//  DownloadTaskPersistence.swift
//  jiagou
//
//  持久化管理器 - 负责保存和恢复下载任务
//

import Foundation

// MARK: - 可序列化的下载状态
enum SerializableDownloadState: String, Codable {
    case waiting
    case downloading
    case paused
    case completed
    case failed
    case cancelled
    
    // 转换为 DownloadState
    func toDownloadState() -> DownloadState {
        switch self {
        case .waiting: return .waiting
        case .downloading: return .downloading
        case .paused: return .paused
        case .completed: return .completed
        case .failed: return .failed
        case .cancelled: return .cancelled
        }
    }
    
    // 从 DownloadState 创建
    init(from state: DownloadState) {
        switch state {
        case .waiting: self = .waiting
        case .downloading: self = .downloading
        case .paused: self = .paused
        case .completed: self = .completed
        case .failed: self = .failed
        case .cancelled: self = .cancelled
        }
    }
}

// MARK: - 可序列化的任务数据
struct DownloadTaskData: Codable {
    let id: String
    let url: String
    let fileName: String
    var state: SerializableDownloadState
    var progress: Double
    var totalBytes: Int64
    var downloadedBytes: Int64
    var destinationPath: String?
    var resumeData: Data?
    var errorDescription: String?
    
    // 创建时间（用于排序）
    let createdAt: TimeInterval
    
    // 从 DownloadTask 创建
    init(from task: DownloadTask) {
        self.id = task.id
        self.url = task.url.absoluteString
        self.fileName = task.fileName
        self.state = SerializableDownloadState(from: task.state)
        self.progress = task.progress
        self.totalBytes = task.totalBytes
        self.downloadedBytes = task.downloadedBytes
        self.destinationPath = task.destinationPath?.path
        self.resumeData = task.resumeData
        self.errorDescription = task.error?.localizedDescription
        self.createdAt = Date().timeIntervalSince1970
    }
}

// MARK: - 持久化管理器
class DownloadTaskPersistence {
    
    // 单例
    static let shared = DownloadTaskPersistence()
    
    // 存储key
    private let tasksKey = "com.jiagou.download.tasks"
    private let maxStoredTasks = 100  // 最多存储100个任务
    
    // UserDefaults
    private let userDefaults = UserDefaults.standard
    
    // 文件管理器
    private let fileManager = FileManager.default
    
    // 存储路径（用于大数据量时使用文件存储）
    private lazy var storageDirectory: URL = {
        let paths = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        let storageDir = documentsDirectory.appendingPathComponent("DownloadTasks")
        
        if !fileManager.fileExists(atPath: storageDir.path) {
            try? fileManager.createDirectory(at: storageDir, withIntermediateDirectories: true)
        }
        
        return storageDir
    }()
    
    private init() {}
    
    // MARK: - 公共方法
    
    /// 保存所有任务
    func saveTasks(_ tasks: [DownloadTask]) {
        // 只保存未完成和已暂停的任务（不保存已完成、已取消、失败的）
        let tasksToSave = tasks.filter { task in
            task.state == .waiting || task.state == .downloading || task.state == .paused
        }
        
        // 转换为可序列化的数据
        let taskDataArray = tasksToSave.map { DownloadTaskData(from: $0) }
        
        // 限制数量
        let limitedTasks = Array(taskDataArray.prefix(maxStoredTasks))
        
        do {
            // 使用 JSONEncoder 编码
            let encoder = JSONEncoder()
            let data = try encoder.encode(limitedTasks)
            
            // 保存到 UserDefaults
            userDefaults.set(data, forKey: tasksKey)
            userDefaults.synchronize()
            
            print("✅ 持久化：已保存 \(limitedTasks.count) 个任务")
        } catch {
            print("❌ 持久化失败：\(error.localizedDescription)")
        }
    }
    
    /// 保存单个任务
    func saveTask(_ task: DownloadTask) {
        var tasks = loadTasks()
        
        // 如果任务已存在，更新；否则添加
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = DownloadTaskData(from: task)
        } else {
            tasks.append(DownloadTaskData(from: task))
        }
        
        // 保存
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(tasks)
            userDefaults.set(data, forKey: tasksKey)
            userDefaults.synchronize()
        } catch {
            print("❌ 保存任务失败：\(error.localizedDescription)")
        }
    }
    
    /// 加载所有任务
    func loadTasks() -> [DownloadTaskData] {
        guard let data = userDefaults.data(forKey: tasksKey) else {
            print("ℹ️ 没有找到已保存的任务")
            return []
        }
        
        do {
            let decoder = JSONDecoder()
            let taskDataArray = try decoder.decode([DownloadTaskData].self, from: data)
            print("✅ 加载了 \(taskDataArray.count) 个任务")
            return taskDataArray
        } catch {
            print("❌ 加载任务失败：\(error.localizedDescription)")
            return []
        }
    }
    
    /// 删除指定任务
    func removeTask(withId id: String) {
        var tasks = loadTasks()
        tasks.removeAll { $0.id == id }
        
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(tasks)
            userDefaults.set(data, forKey: tasksKey)
            userDefaults.synchronize()
        } catch {
            print("❌ 删除任务失败：\(error.localizedDescription)")
        }
    }
    
    /// 清空所有任务
    func clearAllTasks() {
        userDefaults.removeObject(forKey: tasksKey)
        userDefaults.synchronize()
        print("✅ 已清空所有持久化任务")
    }
    
    /// 清理已完成的任务
    func clearCompletedTasks() {
        let tasks = loadTasks()
        let activeTasks = tasks.filter { $0.state != .completed && $0.state != .cancelled && $0.state != .failed }
        
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(activeTasks)
            userDefaults.set(data, forKey: tasksKey)
            userDefaults.synchronize()
            print("✅ 已清理已完成的任务")
        } catch {
            print("❌ 清理任务失败：\(error.localizedDescription)")
        }
    }
    
    // MARK: - 高级功能：文件存储（用于大数据量）
    
    /// 保存到文件（当任务数量较多时使用）
    func saveTasksToFile(_ tasks: [DownloadTask]) {
        let taskDataArray = tasks.map { DownloadTaskData(from: $0) }
        let filePath = storageDirectory.appendingPathComponent("tasks.json")
        
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(taskDataArray)
            try data.write(to: filePath)
            print("✅ 已保存任务到文件：\(filePath.path)")
        } catch {
            print("❌ 保存到文件失败：\(error.localizedDescription)")
        }
    }
    
    /// 从文件加载
    func loadTasksFromFile() -> [DownloadTaskData] {
        let filePath = storageDirectory.appendingPathComponent("tasks.json")
        
        guard fileManager.fileExists(atPath: filePath.path) else {
            return []
        }
        
        do {
            let data = try Data(contentsOf: filePath)
            let decoder = JSONDecoder()
            let taskDataArray = try decoder.decode([DownloadTaskData].self, from: data)
            return taskDataArray
        } catch {
            print("❌ 从文件加载失败：\(error.localizedDescription)")
            return []
        }
    }
}

// MARK: - DownloadTask 扩展：持久化支持
extension DownloadTask {
    
    /// 从持久化数据恢复任务
    convenience init(from data: DownloadTaskData) {
        guard let url = URL(string: data.url) else {
            fatalError("无效的URL：\(data.url)")
        }
        
        self.init(url: url, fileName: data.fileName)
        
        // 恢复属性
        self.state = data.state.toDownloadState()
        self.progress = data.progress
        self.totalBytes = data.totalBytes
        self.downloadedBytes = data.downloadedBytes
        self.resumeData = data.resumeData
        
        if let pathString = data.destinationPath {
            self.destinationPath = URL(fileURLWithPath: pathString)
        }
        
        // 注意：downloadTask 和回调需要由 DownloadManager 重新设置
    }
    
    /// 保存当前任务
    func save() {
        DownloadTaskPersistence.shared.saveTask(self)
    }
}

