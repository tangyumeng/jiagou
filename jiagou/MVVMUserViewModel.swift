//
//  MVVMUserViewModel.swift
//  jiagou
//
//  MVVM 设计模式 - ViewModel 层
//  用户业务逻辑处理
//

import Foundation
import UIKit
import Combine

// MARK: - 用户列表状态

/// 用户列表状态
enum UserListState {
    case loading
    case loaded([MVVMUserModel])
    case error(String)
    case empty
}

// MARK: - 用户操作状态

/// 用户操作状态
enum UserOperationState: Equatable {
    case idle
    case loading
    case success(String)
    case error(String)
}

// MARK: - 用户列表 ViewModel

/// 用户列表 ViewModel（MVVM ViewModel层）
class MVVMUserListViewModel: ObservableObject {
    
    // MARK: - 属性
    
    /// 用户数据服务
    private let userDataService: UserDataServiceProtocol
    
    /// 用户列表状态
    @Published var listState: UserListState = .loading
    
    /// 操作状态
    @Published var operationState: UserOperationState = .idle
    
    /// 搜索关键词
    @Published var searchText: String = "" {
        didSet {
            filterUsers()
        }
    }
    
    /// 排序方式
    @Published var sortType: SortType = .name
    
    /// 是否显示在线用户
    @Published var showOnlineOnly: Bool = false
    
    /// 原始用户数据
    private var originalUsers: [MVVMUserModel] = []
    
    /// 过滤后的用户数据
    private var filteredUsers: [MVVMUserModel] = []
    
    // MARK: - 排序类型
    
    enum SortType: String, CaseIterable {
        case name = "按姓名"
        case email = "按邮箱"
        case loginTime = "按登录时间"
        case loginCount = "按登录次数"
        
        var sortKey: (MVVMUserModel) -> String {
            switch self {
            case .name: return { $0.name }
            case .email: return { $0.email }
            case .loginTime: return { $0.formattedLastLoginTime }
            case .loginCount: return { String($0.loginCount) }
            }
        }
    }
    
    // MARK: - 初始化
    
    init(userDataService: UserDataServiceProtocol = UserDataService()) {
        self.userDataService = userDataService
        loadUsers()
    }
    
    // MARK: - 公共方法
    
    /// 加载用户列表
    func loadUsers() {
        listState = .loading
        
        userDataService.fetchUsers { [weak self] users in
            DispatchQueue.main.async {
                self?.originalUsers = users
                self?.filterUsers()
            }
        }
    }
    
    /// 刷新用户列表
    func refreshUsers() {
        loadUsers()
    }
    
    /// 删除用户
    func deleteUser(at index: Int) {
        guard let user = getCurrentUser(at: index) else { return }
        
        operationState = .loading
        
        userDataService.deleteUser(id: user.id) { [weak self] result in
            DispatchQueue.main.async {
                if result.isSuccess {
                    self?.originalUsers.removeAll { $0.id == user.id }
                    self?.filterUsers()
                    self?.operationState = .success(result.message)
                } else {
                    self?.operationState = .error(result.message)
                }
            }
        }
    }
    
    /// 更新用户信息
    func updateUser(_ user: MVVMUserModel) {
        operationState = .loading
        
        userDataService.updateUser(user) { [weak self] result in
            DispatchQueue.main.async {
                if result.isSuccess {
                    if let index = self?.originalUsers.firstIndex(where: { $0.id == user.id }) {
                        self?.originalUsers[index] = user
                        self?.filterUsers()
                    }
                    self?.operationState = .success(result.message)
                } else {
                    self?.operationState = .error(result.message)
                }
            }
        }
    }
    
    /// 切换用户在线状态
    func toggleUserOnlineStatus(at index: Int) {
        guard var user = getCurrentUser(at: index) else { return }
        
        user.isOnline.toggle()
        user.lastLoginTime = Date()
        user.loginCount += 1
        
        updateUser(user)
    }
    
    /// 清空操作状态
    func clearOperationState() {
        operationState = .idle
    }
    
    /// 设置排序方式
    func setSortType(_ type: SortType) {
        sortType = type
        filterUsers()
    }
    
    /// 切换在线用户过滤
    func toggleOnlineFilter() {
        showOnlineOnly.toggle()
        filterUsers()
    }
    
    // MARK: - 私有方法
    
    /// 过滤用户
    private func filterUsers() {
        var users = originalUsers
        
        // 搜索过滤
        if !searchText.isEmpty {
            users = users.filter { user in
                user.name.localizedCaseInsensitiveContains(searchText) ||
                user.email.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // 在线用户过滤
        if showOnlineOnly {
            users = users.filter { $0.isOnline }
        }
        
        // 排序
        users.sort { user1, user2 in
            let key1 = sortType.sortKey(user1)
            let key2 = sortType.sortKey(user2)
            return key1.localizedCaseInsensitiveCompare(key2) == .orderedAscending
        }
        
        filteredUsers = users
        
        // 更新状态
        if users.isEmpty {
            if originalUsers.isEmpty {
                listState = .empty
            } else {
                listState = .loaded([])
            }
        } else {
            listState = .loaded(users)
        }
    }
    
    /// 获取当前用户（考虑过滤和排序）
    private func getCurrentUser(at index: Int) -> MVVMUserModel? {
        guard case .loaded(let users) = listState,
              index >= 0 && index < users.count else {
            return nil
        }
        return users[index]
    }
}

// MARK: - 用户详情 ViewModel

/// 用户详情 ViewModel
class MVVMUserDetailViewModel: ObservableObject {
    
    // MARK: - 属性
    
    private let userDataService: UserDataServiceProtocol
    
    @Published var user: MVVMUserModel
    @Published var operationState: UserOperationState = .idle
    @Published var isEditing: Bool = false
    
    // 编辑时的临时数据
    @Published var editingName: String = ""
    @Published var editingEmail: String = ""
    @Published var editingAvatar: String = ""
    
    // MARK: - 初始化
    
    init(user: MVVMUserModel, userDataService: UserDataServiceProtocol = UserDataService()) {
        self.user = user
        self.userDataService = userDataService
        setupEditingData()
    }
    
    // MARK: - 公共方法
    
    /// 开始编辑
    func startEditing() {
        isEditing = true
        setupEditingData()
    }
    
    /// 取消编辑
    func cancelEditing() {
        isEditing = false
        setupEditingData()
    }
    
    /// 保存编辑
    func saveEditing() {
        // 验证数据
        let tempUser = MVVMUserModel(
            id: user.id,
            name: editingName,
            email: editingEmail,
            avatar: editingAvatar.isEmpty ? nil : editingAvatar
        )
        
        let errors = tempUser.validationErrors
        if !errors.isEmpty {
            operationState = .error(errors.joined(separator: ", "))
            return
        }
        
        operationState = .loading
        
        userDataService.updateUser(tempUser) { [weak self] result in
            DispatchQueue.main.async {
                if result.isSuccess {
                    self?.user = tempUser
                    self?.isEditing = false
                    self?.operationState = .success(result.message)
                } else {
                    self?.operationState = .error(result.message)
                }
            }
        }
    }
    
    /// 切换在线状态
    func toggleOnlineStatus() {
        var updatedUser = user
        updatedUser.isOnline.toggle()
        updatedUser.lastLoginTime = Date()
        updatedUser.loginCount += 1
        
        operationState = .loading
        
        userDataService.updateUser(updatedUser) { [weak self] result in
            DispatchQueue.main.async {
                if result.isSuccess {
                    self?.user = updatedUser
                    self?.operationState = .success(result.message)
                } else {
                    self?.operationState = .error(result.message)
                }
            }
        }
    }
    
    /// 清空操作状态
    func clearOperationState() {
        operationState = .idle
    }
    
    // MARK: - 私有方法
    
    /// 设置编辑数据
    private func setupEditingData() {
        editingName = user.name
        editingEmail = user.email
        editingAvatar = user.avatar ?? ""
    }
}

// MARK: - 用户登录 ViewModel

/// 用户登录 ViewModel
class MVVMUserLoginViewModel: ObservableObject {
    
    // MARK: - 属性
    
    private let userDataService: UserDataServiceProtocol
    
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var operationState: UserOperationState = .idle
    @Published var isLoginEnabled: Bool = false
    
    // MARK: - 初始化
    
    init(userDataService: UserDataServiceProtocol = UserDataService()) {
        self.userDataService = userDataService
        
        // 监听输入变化
        $email.combineLatest($password)
            .map { email, password in
                !email.isEmpty && !password.isEmpty
            }
            .assign(to: &$isLoginEnabled)
    }
    
    // MARK: - 公共方法
    
    /// 执行登录
    func login() {
        guard isLoginEnabled else { return }
        
        operationState = .loading
        
        userDataService.loginUser(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                if result.isSuccess {
                    self?.operationState = .success(result.message)
                } else {
                    self?.operationState = .error(result.message)
                }
            }
        }
    }
    
    /// 清空操作状态
    func clearOperationState() {
        operationState = .idle
    }
    
    /// 重置表单
    func resetForm() {
        email = ""
        password = ""
        operationState = .idle
    }
}

// MARK: - ViewModel 扩展

extension MVVMUserListViewModel {
    
    /// 获取用户数量
    var userCount: Int {
        if case .loaded(let users) = listState {
            return users.count
        }
        return 0
    }
    
    /// 获取在线用户数量
    var onlineUserCount: Int {
        if case .loaded(let users) = listState {
            return users.filter { $0.isOnline }.count
        }
        return 0
    }
    
    /// 是否正在加载
    var isLoading: Bool {
        if case .loading = listState {
            return true
        }
        return false
    }
    
    /// 是否有错误
    var hasError: Bool {
        if case .error = listState {
            return true
        }
        return false
    }
    
    /// 错误信息
    var errorMessage: String? {
        if case .error(let message) = listState {
            return message
        }
        return nil
    }
    
    /// 是否为空列表
    var isEmpty: Bool {
        if case .empty = listState {
            return true
        }
        return false
    }
}
