//
//  MVVMUserModel.swift
//  jiagou
//
//  MVVM 设计模式 - Model 层
//  用户数据模型
//

import Foundation

// MARK: - 用户模型

/// 用户数据模型（MVVM Model层）
struct MVVMUserModel {
    let id: String
    var name: String
    var email: String
    var avatar: String?
    var isOnline: Bool
    var lastLoginTime: Date
    var loginCount: Int
    
    init(id: String, name: String, email: String, avatar: String? = nil) {
        self.id = id
        self.name = name
        self.email = email
        self.avatar = avatar
        self.isOnline = false
        self.lastLoginTime = Date()
        self.loginCount = 0
    }
}

// MARK: - 用户状态

/// 用户状态枚举
enum UserStatus {
    case online
    case offline
    case away
    case busy
    
    var displayName: String {
        switch self {
        case .online: return "在线"
        case .offline: return "离线"
        case .away: return "离开"
        case .busy: return "忙碌"
        }
    }
    
    var color: String {
        switch self {
        case .online: return "green"
        case .offline: return "gray"
        case .away: return "yellow"
        case .busy: return "red"
        }
    }
}

// MARK: - 用户操作结果

/// 用户操作结果
enum UserOperationResult {
    case success(String)
    case failure(String)
    
    var isSuccess: Bool {
        switch self {
        case .success: return true
        case .failure: return false
        }
    }
    
    var message: String {
        switch self {
        case .success(let msg): return msg
        case .failure(let msg): return msg
        }
    }
}

// MARK: - 用户数据服务协议

/// 用户数据服务协议（模拟网络请求）
protocol UserDataServiceProtocol {
    func fetchUsers(completion: @escaping ([MVVMUserModel]) -> Void)
    func fetchUser(id: String, completion: @escaping (MVVMUserModel?) -> Void)
    func updateUser(_ user: MVVMUserModel, completion: @escaping (UserOperationResult) -> Void)
    func deleteUser(id: String, completion: @escaping (UserOperationResult) -> Void)
    func loginUser(email: String, password: String, completion: @escaping (UserOperationResult) -> Void)
}

// MARK: - 用户数据服务实现

/// 用户数据服务实现（模拟网络请求）
class UserDataService: UserDataServiceProtocol {
    
    // 模拟用户数据
    private var users: [MVVMUserModel] = [
        MVVMUserModel(id: "1", name: "张三", email: "zhangsan@example.com", avatar: "avatar1.jpg"),
        MVVMUserModel(id: "2", name: "李四", email: "lisi@example.com", avatar: "avatar2.jpg"),
        MVVMUserModel(id: "3", name: "王五", email: "wangwu@example.com", avatar: "avatar3.jpg"),
        MVVMUserModel(id: "4", name: "赵六", email: "zhaoliu@example.com", avatar: "avatar4.jpg"),
        MVVMUserModel(id: "5", name: "钱七", email: "qianqi@example.com", avatar: "avatar5.jpg")
    ]
    
    func fetchUsers(completion: @escaping ([MVVMUserModel]) -> Void) {
        // 模拟网络延迟
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            completion(self?.users ?? [])
        }
    }
    
    func fetchUser(id: String, completion: @escaping (MVVMUserModel?) -> Void) {
        // 模拟网络延迟
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            let user = self?.users.first { $0.id == id }
            completion(user)
        }
    }
    
    func updateUser(_ user: MVVMUserModel, completion: @escaping (UserOperationResult) -> Void) {
        // 模拟网络延迟
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
            if let index = self?.users.firstIndex(where: { $0.id == user.id }) {
                self?.users[index] = user
                completion(.success("用户信息更新成功"))
            } else {
                completion(.failure("用户不存在"))
            }
        }
    }
    
    func deleteUser(id: String, completion: @escaping (UserOperationResult) -> Void) {
        // 模拟网络延迟
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
            if let index = self?.users.firstIndex(where: { $0.id == id }) {
                self?.users.remove(at: index)
                completion(.success("用户删除成功"))
            } else {
                completion(.failure("用户不存在"))
            }
        }
    }
    
    func loginUser(email: String, password: String, completion: @escaping (UserOperationResult) -> Void) {
        // 模拟网络延迟
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            // 简单的验证逻辑
            if email.isEmpty || password.isEmpty {
                completion(.failure("邮箱或密码不能为空"))
            } else if email.contains("@") && password.count >= 6 {
                completion(.success("登录成功"))
            } else {
                completion(.failure("邮箱格式错误或密码太短"))
            }
        }
    }
}

// MARK: - 用户数据扩展

extension MVVMUserModel {
    
    /// 格式化显示名称
    var displayName: String {
        return name.isEmpty ? "未知用户" : name
    }
    
    /// 格式化邮箱
    var formattedEmail: String {
        return email.isEmpty ? "未设置邮箱" : email
    }
    
    /// 格式化最后登录时间
    var formattedLastLoginTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter.string(from: lastLoginTime)
    }
    
    /// 用户状态描述
    var statusDescription: String {
        return isOnline ? "在线" : "离线"
    }
    
    /// 登录次数描述
    var loginCountDescription: String {
        return "登录 \(loginCount) 次"
    }
}

// MARK: - 用户数据验证

extension MVVMUserModel {
    
    /// 验证用户数据
    var isValid: Bool {
        return !id.isEmpty && !name.isEmpty && !email.isEmpty
    }
    
    /// 验证邮箱格式
    var isEmailValid: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    /// 获取验证错误信息
    var validationErrors: [String] {
        var errors: [String] = []
        
        if name.isEmpty {
            errors.append("用户名不能为空")
        }
        
        if email.isEmpty {
            errors.append("邮箱不能为空")
        } else if !isEmailValid {
            errors.append("邮箱格式不正确")
        }
        
        return errors
    }
}
