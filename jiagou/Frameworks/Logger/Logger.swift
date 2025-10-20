//
//  Logger.swift
//  jiagou
//
//  日志框架 - 多级别日志系统
//

import Foundation

// MARK: - 日志级别

/// 日志级别（优先级从低到高）
enum LogLevel: Int, Comparable {
    case verbose = 0  // 详细
    case debug = 1    // 调试
    case info = 2     // 信息
    case warning = 3  // 警告
    case error = 4    // 错误
    case fatal = 5    // 致命错误
    
    var symbol: String {
        switch self {
        case .verbose: return "💬"
        case .debug:   return "🐛"
        case .info:    return "ℹ️"
        case .warning: return "⚠️"
        case .error:   return "❌"
        case .fatal:   return "💀"
        }
    }
    
    var name: String {
        switch self {
        case .verbose: return "VERBOSE"
        case .debug:   return "DEBUG"
        case .info:    return "INFO"
        case .warning: return "WARNING"
        case .error:   return "ERROR"
        case .fatal:   return "FATAL"
        }
    }
    
    static func < (lhs: LogLevel, rhs: LogLevel) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

// MARK: - 日志消息

/// 日志消息
struct LogMessage {
    let level: LogLevel
    let message: String
    let file: String
    let function: String
    let line: Int
    let timestamp: Date
    let thread: Thread
    
    /// 格式化的文件名（只显示文件名，不显示完整路径）
    var fileName: String {
        return (file as NSString).lastPathComponent
    }
    
    /// 格式化的时间
    var formattedTimestamp: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return formatter.string(from: timestamp)
    }
    
    /// 线程信息
    var threadInfo: String {
        if thread.isMainThread {
            return "main"
        } else if let name = thread.name, !name.isEmpty {
            return name
        } else {
            return String(format: "%p", thread)
        }
    }
}

// MARK: - 日志格式化器

/// 日志格式化器协议
protocol LogFormatter {
    func format(_ message: LogMessage) -> String
}

/// 默认格式化器
class DefaultLogFormatter: LogFormatter {
    func format(_ message: LogMessage) -> String {
        return """
        [\(message.formattedTimestamp)] \
        [\(message.level.symbol) \(message.level.name)] \
        [\(message.threadInfo)] \
        [\(message.fileName):\(message.line) \(message.function)] \
        \(message.message)
        """
    }
}

/// 简单格式化器
class SimpleLogFormatter: LogFormatter {
    func format(_ message: LogMessage) -> String {
        return "\(message.level.symbol) [\(message.level.name)] \(message.message)"
    }
}

/// JSON 格式化器（用于上报到服务器）
class JSONLogFormatter: LogFormatter {
    func format(_ message: LogMessage) -> String {
        let dict: [String: Any] = [
            "level": message.level.name,
            "message": message.message,
            "file": message.fileName,
            "function": message.function,
            "line": message.line,
            "timestamp": message.timestamp.timeIntervalSince1970,
            "thread": message.threadInfo
        ]
        
        guard let data = try? JSONSerialization.data(withJSONObject: dict),
              let json = String(data: data, encoding: .utf8) else {
            return message.message
        }
        
        return json
    }
}

// MARK: - 日志目标

/// 日志输出目标协议
protocol LogDestination {
    var minLevel: LogLevel { get set }
    var formatter: LogFormatter { get set }
    func send(_ message: LogMessage)
}

/// 控制台输出
class ConsoleLogDestination: LogDestination {
    var minLevel: LogLevel = .verbose
    var formatter: LogFormatter = DefaultLogFormatter()
    
    func send(_ message: LogMessage) {
        guard message.level >= minLevel else { return }
        print(formatter.format(message))
    }
}

/// 文件输出
class FileLogDestination: LogDestination {
    var minLevel: LogLevel = .info
    var formatter: LogFormatter = DefaultLogFormatter()
    
    private let fileManager = FileManager.default
    private let logDirectory: URL
    private let maxFileSize: UInt64 = 5 * 1024 * 1024  // 5MB
    private let maxFileCount: Int = 10
    
    private lazy var currentLogFile: URL = {
        return logDirectory.appendingPathComponent("app_\(dateString()).log")
    }()
    
    private let queue = DispatchQueue(label: "com.jiagou.logger.file", qos: .background)
    
    init() {
        // 创建日志目录
        let paths = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        logDirectory = paths[0].appendingPathComponent("Logs")
        
        if !fileManager.fileExists(atPath: logDirectory.path) {
            try? fileManager.createDirectory(at: logDirectory, withIntermediateDirectories: true)
        }
        
        // 清理旧日志
        cleanOldLogs()
    }
    
    func send(_ message: LogMessage) {
        guard message.level >= minLevel else { return }
        
        queue.async { [weak self] in
            guard let self = self else { return }
            
            let logString = self.formatter.format(message) + "\n"
            
            guard let data = logString.data(using: .utf8) else { return }
            
            // 检查文件大小，超过限制则轮转
            if self.shouldRotateFile() {
                self.rotateLogFile()
            }
            
            // 写入文件
            if self.fileManager.fileExists(atPath: self.currentLogFile.path) {
                // 追加
                if let fileHandle = try? FileHandle(forWritingTo: self.currentLogFile) {
                    fileHandle.seekToEndOfFile()
                    fileHandle.write(data)
                    fileHandle.closeFile()
                }
            } else {
                // 创建新文件
                try? data.write(to: self.currentLogFile)
            }
        }
    }
    
    /// 检查是否需要轮转文件
    private func shouldRotateFile() -> Bool {
        guard let attributes = try? fileManager.attributesOfItem(atPath: currentLogFile.path),
              let fileSize = attributes[.size] as? UInt64 else {
            return false
        }
        
        return fileSize >= maxFileSize
    }
    
    /// 轮转日志文件
    private func rotateLogFile() {
        // 重命名当前文件
        let timestamp = Int(Date().timeIntervalSince1970)
        let newName = "app_\(dateString())_\(timestamp).log"
        let newPath = logDirectory.appendingPathComponent(newName)
        
        try? fileManager.moveItem(at: currentLogFile, to: newPath)
        
        // 更新当前文件路径
        currentLogFile = logDirectory.appendingPathComponent("app_\(dateString()).log")
        
        // 清理旧日志
        cleanOldLogs()
    }
    
    /// 清理旧日志
    private func cleanOldLogs() {
        guard let files = try? fileManager.contentsOfDirectory(at: logDirectory, includingPropertiesForKeys: [.creationDateKey], options: .skipsHiddenFiles) else {
            return
        }
        
        // 按创建时间排序
        let sortedFiles = files.sorted { file1, file2 in
            let date1 = (try? file1.resourceValues(forKeys: [.creationDateKey]))?.creationDate ?? Date.distantPast
            let date2 = (try? file2.resourceValues(forKeys: [.creationDateKey]))?.creationDate ?? Date.distantPast
            return date1 > date2  // 新的在前
        }
        
        // 删除超过数量限制的文件
        if sortedFiles.count > maxFileCount {
            for file in sortedFiles[maxFileCount...] {
                try? fileManager.removeItem(at: file)
            }
        }
    }
    
    /// 获取日期字符串
    private func dateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
    
    /// 获取所有日志文件
    func getAllLogFiles() -> [URL] {
        guard let files = try? fileManager.contentsOfDirectory(at: logDirectory, includingPropertiesForKeys: nil) else {
            return []
        }
        return files.filter { $0.pathExtension == "log" }
    }
    
    /// 清空所有日志
    func clearAllLogs() {
        let files = getAllLogFiles()
        files.forEach { try? fileManager.removeItem(at: $0) }
    }
}

/// 远程日志（上报到服务器）
class RemoteLogDestination: LogDestination {
    var minLevel: LogLevel = .error  // 只上报错误及以上级别
    var formatter: LogFormatter = JSONLogFormatter()
    
    private let serverURL: URL?
    private let queue = DispatchQueue(label: "com.jiagou.logger.remote", qos: .utility)
    private var buffer: [LogMessage] = []
    private let bufferSize: Int = 10  // 缓冲10条后批量上报
    
    init(serverURL: String) {
        self.serverURL = URL(string: serverURL)
    }
    
    func send(_ message: LogMessage) {
        guard message.level >= minLevel else { return }
        guard let serverURL = serverURL else { return }
        
        queue.async { [weak self] in
            guard let self = self else { return }
            
            self.buffer.append(message)
            
            // 缓冲区满，上报
            if self.buffer.count >= self.bufferSize {
                self.flushBuffer()
            }
        }
    }
    
    /// 立即上报所有缓冲的日志
    func flush() {
        queue.async { [weak self] in
            self?.flushBuffer()
        }
    }
    
    /// 上报缓冲区日志
    private func flushBuffer() {
        guard !buffer.isEmpty, let serverURL = serverURL else { return }
        
        // 转换为 JSON 数组
        let logs = buffer.map { formatter.format($0) }
        buffer.removeAll()
        
        // 发送到服务器
        var request = URLRequest(url: serverURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["logs": logs]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ 日志上报失败：\(error.localizedDescription)")
            }
        }.resume()
    }
}

// MARK: - 日志管理器

/// 日志管理器（单例）
class Logger {
    
    // MARK: - 单例
    static let shared = Logger()
    
    // MARK: - 属性
    
    private var destinations: [LogDestination] = []
    private let queue = DispatchQueue(label: "com.jiagou.logger", qos: .utility, attributes: .concurrent)
    
    // 全局日志级别（低于此级别的日志不会输出）
    var minLevel: LogLevel = .verbose
    
    // MARK: - 初始化
    private init() {
        // 默认添加控制台输出
        let console = ConsoleLogDestination()
        #if DEBUG
        console.minLevel = .verbose
        console.formatter = DefaultLogFormatter()
        #else
        console.minLevel = .info
        console.formatter = SimpleLogFormatter()
        #endif
        
        addDestination(console)
    }
    
    // MARK: - 目标管理
    
    /// 添加日志输出目标
    func addDestination(_ destination: LogDestination) {
        queue.async(flags: .barrier) { [weak self] in
            self?.destinations.append(destination)
        }
    }
    
    /// 移除所有目标
    func removeAllDestinations() {
        queue.async(flags: .barrier) { [weak self] in
            self?.destinations.removeAll()
        }
    }
    
    // MARK: - 日志输出
    
    /// 记录日志
    func log(
        _ level: LogLevel,
        _ message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        guard level >= minLevel else { return }
        
        let logMessage = LogMessage(
            level: level,
            message: message,
            file: file,
            function: function,
            line: line,
            timestamp: Date(),
            thread: Thread.current
        )
        
        queue.async { [weak self] in
            self?.destinations.forEach { $0.send(logMessage) }
        }
    }
    
    // MARK: - 便捷方法
    
    func verbose(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(.verbose, message, file: file, function: function, line: line)
    }
    
    func debug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(.debug, message, file: file, function: function, line: line)
    }
    
    func info(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(.info, message, file: file, function: function, line: line)
    }
    
    func warning(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(.warning, message, file: file, function: function, line: line)
    }
    
    func error(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(.error, message, file: file, function: function, line: line)
    }
    
    func fatal(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(.fatal, message, file: file, function: function, line: line)
    }
}

// MARK: - 全局函数（更简洁的调用方式）

func logVerbose(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
    Logger.shared.verbose(message, file: file, function: function, line: line)
}

func logDebug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
    Logger.shared.debug(message, file: file, function: function, line: line)
}

func logInfo(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
    Logger.shared.info(message, file: file, function: function, line: line)
}

func logWarning(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
    Logger.shared.warning(message, file: file, function: function, line: line)
}

func logError(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
    Logger.shared.error(message, file: file, function: function, line: line)
}

func logFatal(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
    Logger.shared.fatal(message, file: file, function: function, line: line)
}

