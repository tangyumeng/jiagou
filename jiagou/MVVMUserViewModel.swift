//
//  MVVMUserViewModel.swift
//  jiagou
//
//  MVVM 设计模式 - ViewModel 层
//  用户业务逻辑处理（使用自定义绑定）
//

import Foundation
import UIKit

// MARK: - 用户列表状态

/// 用户列表状态
enum UserListState {
    case loading
    case loaded([MVVMUserModel])
    case error(String)
    case empty
}

/// 用户操作状态
enum UserOperationState: Equatable {
    case idle
    case loading
    case success(String)
    case failure(String)
}

// MARK: - 用户列表 ViewModel

/// 用户列表 ViewModel（使用自定义绑定）
class MVVMUserListViewModel {
    
    // MARK: - 绑定属性
    let users = Bindable<[MVVMUserModel]>([])
    let isLoading = Bindable<Bool>(false)
    let errorMessage = Bindable<String?>(nil)
    let searchText = TwoWayBindable<String>("")
    let selectedFilter = TwoWayBindable<String>("全部")
    let sortType = TwoWayBindable<String>("创建时间")
    
    // MARK: - 私有属性
    private let userService: UserDataServiceProtocol
    private var allUsers: [MVVMUserModel] = []
    private var filteredUsers: [MVVMUserModel] = []
    
    // MARK: - 初始化
    init(userService: UserDataServiceProtocol = UserDataService()) {
        self.userService = userService
        setupBindings()
    }
    
    // MARK: - 绑定设置
    private func setupBindings() {
        // 搜索文本变化时重新过滤
        searchText.bind { [weak self] _ in
            self?.applyFilters()
        }
        
        // 过滤器变化时重新过滤
        selectedFilter.bind { [weak self] _ in
            self?.applyFilters()
        }
        
        // 排序类型变化时重新排序
        sortType.bind { [weak self] _ in
            self?.applySorting()
        }
    }
    
    // MARK: - 公共方法
    
    /// 加载用户列表
    func loadUsers() {
        isLoading.value = true
        errorMessage.value = nil
        
        userService.fetchUsers { [weak self] users in
            DispatchQueue.main.async {
                self?.isLoading.value = false
                self?.allUsers = users
                self?.applyFilters()
            }
        }
    }
    
    /// 刷新用户列表
    func refreshUsers() {
        loadUsers()
    }
    
    /// 搜索用户
    func searchUsers(query: String) {
        searchText.value = query
    }
    
    /// 过滤用户
    func filterUsers(by filter: String) {
        selectedFilter.value = filter
    }
    
    /// 排序用户
    func sortUsers(by sort: String) {
        sortType.value = sort
    }
    
    /// 删除用户
    func deleteUser(id: String) {
        guard let index = allUsers.firstIndex(where: { $0.id == id }) else { return }
        
        let user = allUsers[index]
        allUsers.remove(at: index)
        applyFilters()
        
        // 这里可以调用服务删除用户
        // userService.deleteUser(id: id) { success in
        //     if !success {
        //         // 恢复用户
        //         self.allUsers.insert(user, at: index)
        //         self.applyFilters()
        //     }
        // }
    }
    
    /// 切换用户在线状态
    func toggleUserOnlineStatus(id: String) {
        guard let index = allUsers.firstIndex(where: { $0.id == id }) else { return }
        
        var user = allUsers[index]
        user.isOnline.toggle()
        allUsers[index] = user
        applyFilters()
    }
    
    // MARK: - 私有方法
    
    /// 应用过滤条件
    private func applyFilters() {
        var result = allUsers
        
        // 应用搜索过滤
        let searchQuery = searchText.value.trimmingCharacters(in: .whitespacesAndNewlines)
        if !searchQuery.isEmpty {
            result = result.filter { user in
                user.name.localizedCaseInsensitiveContains(searchQuery) ||
                user.email.localizedCaseInsensitiveContains(searchQuery)
            }
        }
        
        // 应用状态过滤
        let filter = selectedFilter.value
        if filter == "仅在线" {
            result = result.filter { $0.isOnline }
        } else if filter == "仅离线" {
            result = result.filter { !$0.isOnline }
        }
        
        filteredUsers = result
        applySorting()
    }
    
    /// 应用排序
    private func applySorting() {
        let sort = sortType.value
        filteredUsers = filteredUsers.sorted { user1, user2 in
            switch sort {
            case "姓名":
                return user1.name.localizedCaseInsensitiveCompare(user2.name) == .orderedAscending
            case "邮箱":
                return user1.email.localizedCaseInsensitiveCompare(user2.email) == .orderedAscending
            case "登录时间":
                return user1.lastLoginTime > user2.lastLoginTime
            case "登录次数":
                return user1.loginCount > user2.loginCount
            case "在线状态":
                if user1.isOnline != user2.isOnline {
                    return user1.isOnline && !user2.isOnline
                }
                return user1.name.localizedCaseInsensitiveCompare(user2.name) == .orderedAscending
            default: // "创建时间"
                return user1.id.localizedCaseInsensitiveCompare(user2.id) == .orderedAscending
            }
        }
        
        users.value = filteredUsers
    }
}

// MARK: - 用户详情 ViewModel

/// 用户详情 ViewModel（使用自定义绑定）
class MVVMUserDetailViewModel {
    
    // MARK: - 绑定属性
    let user = Bindable<MVVMUserModel?>(nil)
    let isLoading = Bindable<Bool>(false)
    let operationState = Bindable<UserOperationState>(.idle)
    
    // 编辑相关绑定
    let name = TwoWayBindable<String>("")
    let email = TwoWayBindable<String>("")
    let isOnline = TwoWayBindable<Bool>(false)
    
    // MARK: - 私有属性
    private let userService: UserDataServiceProtocol
    private var currentUser: MVVMUserModel?
    
    // MARK: - 初始化
    init(userService: UserDataServiceProtocol = UserDataService()) {
        self.userService = userService
        setupBindings()
    }
    
    // MARK: - 绑定设置
    private func setupBindings() {
        // 用户数据变化时更新编辑字段
        user.bind { [weak self] user in
            if let user = user {
                self?.name.value = user.name
                self?.email.value = user.email
                self?.isOnline.value = user.isOnline
            }
        }
    }
    
    // MARK: - 公共方法
    
    /// 加载用户详情
    func loadUser(id: String) {
        isLoading.value = true
        operationState.value = .idle
        
        userService.fetchUser(id: id) { [weak self] user in
            DispatchQueue.main.async {
                self?.isLoading.value = false
                self?.currentUser = user
                self?.user.value = user
            }
        }
    }
    
    /// 更新用户信息
    func updateUser() {
        guard let currentUser = currentUser else { return }
        
        // 验证输入
        let nameText = name.value.trimmingCharacters(in: .whitespacesAndNewlines)
        let emailText = email.value.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if nameText.isEmpty {
            operationState.value = .failure("姓名不能为空")
            return
        }
        
        if !isValidEmail(emailText) {
            operationState.value = .failure("邮箱格式不正确")
            return
        }
        
        operationState.value = .loading
        
        var updatedUser = currentUser
        updatedUser.name = nameText
        updatedUser.email = emailText
        updatedUser.isOnline = isOnline.value
        
        userService.updateUser(updatedUser) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let message):
                    self?.currentUser = updatedUser
                    self?.user.value = updatedUser
                    self?.operationState.value = .success(message)
                case .failure(let error):
                    self?.operationState.value = .failure(error)
                }
            }
        }
    }
    
    /// 切换在线状态
    func toggleOnlineStatus() {
        isOnline.value.toggle()
    }
    
    // MARK: - 私有方法
    
    /// 验证邮箱格式
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}

// MARK: - 用户登录 ViewModel

/// 用户登录 ViewModel（使用自定义绑定）
class MVVMUserLoginViewModel {
    
    // MARK: - 绑定属性
    let email = TwoWayBindable<String>("")
    let password = TwoWayBindable<String>("")
    let isLoading = Bindable<Bool>(false)
    let operationState = Bindable<UserOperationState>(.idle)
    let isLoginEnabled = Bindable<Bool>(false)
    
    // MARK: - 私有属性
    private let userService: UserDataServiceProtocol
    
    // MARK: - 初始化
    init(userService: UserDataServiceProtocol = UserDataService()) {
        self.userService = userService
        setupBindings()
    }
    
    // MARK: - 绑定设置
    private func setupBindings() {
        // 监听邮箱和密码变化，更新登录按钮状态
        email.bind { [weak self] _ in
            self?.updateLoginButtonState()
        }
        
        password.bind { [weak self] _ in
            self?.updateLoginButtonState()
        }
    }
    
    private func updateLoginButtonState() {
        let emailText = email.value.trimmingCharacters(in: .whitespacesAndNewlines)
        let passwordText = password.value
        let isEmailValid = !emailText.isEmpty
        let isPasswordValid = passwordText.count >= 6
        isLoginEnabled.value = isEmailValid && isPasswordValid
    }
    
    // MARK: - 公共方法
    
    /// 执行登录
    func login() {
        let emailText = email.value.trimmingCharacters(in: .whitespacesAndNewlines)
        let passwordText = password.value
        
        // 验证输入
        if emailText.isEmpty {
            operationState.value = .failure("请输入邮箱")
            return
        }
        
        if passwordText.isEmpty {
            operationState.value = .failure("请输入密码")
            return
        }
        
        if !isValidEmail(emailText) {
            operationState.value = .failure("邮箱格式不正确")
            return
        }
        
        if passwordText.count < 6 {
            operationState.value = .failure("密码至少6位")
            return
        }
        
        isLoading.value = true
        operationState.value = .loading
        
        userService.loginUser(email: emailText, password: passwordText) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading.value = false
                switch result {
                case .success(let message):
                    self?.operationState.value = .success(message)
                case .failure(let error):
                    self?.operationState.value = .failure(error)
                }
            }
        }
    }
    
    /// 清除表单
    func clearForm() {
        email.value = ""
        password.value = ""
        operationState.value = .idle
    }
    
    // MARK: - 私有方法
    
    /// 验证邮箱格式
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}


