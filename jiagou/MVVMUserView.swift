//
//  MVVMUserView.swift
//  jiagou
//
//  MVVM 设计模式 - View 层
//  用户界面组件
//

import UIKit
import SwiftUI

// MARK: - 用户列表 Cell

/// 用户列表 Cell（MVVM View层）
class MVVMUserCell: UITableViewCell {
    
    // MARK: - UI 组件
    
    private let avatarImageView = UIImageView()
    private let nameLabel = UILabel()
    private let emailLabel = UILabel()
    private let statusLabel = UILabel()
    private let statusIndicator = UIView()
    private let loginInfoLabel = UILabel()
    
    // MARK: - 初始化
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - UI 设置
    
    private func setupUI() {
        // 头像
        avatarImageView.backgroundColor = .systemGray5
        avatarImageView.layer.cornerRadius = 25
        avatarImageView.clipsToBounds = true
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(avatarImageView)
        
        // 姓名
        nameLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        nameLabel.textColor = .label
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(nameLabel)
        
        // 邮箱
        emailLabel.font = .systemFont(ofSize: 14)
        emailLabel.textColor = .secondaryLabel
        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(emailLabel)
        
        // 状态指示器
        statusIndicator.layer.cornerRadius = 6
        statusIndicator.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(statusIndicator)
        
        // 状态标签
        statusLabel.font = .systemFont(ofSize: 12)
        statusLabel.textColor = .secondaryLabel
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(statusLabel)
        
        // 登录信息
        loginInfoLabel.font = .systemFont(ofSize: 12)
        loginInfoLabel.textColor = .tertiaryLabel
        loginInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(loginInfoLabel)
        
        // 布局约束
        NSLayoutConstraint.activate([
            // 头像
            avatarImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            avatarImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 50),
            avatarImageView.heightAnchor.constraint(equalToConstant: 50),
            
            // 姓名
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 12),
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: statusIndicator.leadingAnchor, constant: -8),
            
            // 邮箱
            emailLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            emailLabel.trailingAnchor.constraint(lessThanOrEqualTo: statusIndicator.leadingAnchor, constant: -8),
            
            // 状态指示器
            statusIndicator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            statusIndicator.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            statusIndicator.widthAnchor.constraint(equalToConstant: 12),
            statusIndicator.heightAnchor.constraint(equalToConstant: 12),
            
            // 状态标签
            statusLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            statusLabel.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 4),
            statusLabel.trailingAnchor.constraint(lessThanOrEqualTo: statusIndicator.leadingAnchor, constant: -8),
            
            // 登录信息
            loginInfoLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            loginInfoLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 2),
            loginInfoLabel.trailingAnchor.constraint(lessThanOrEqualTo: statusIndicator.leadingAnchor, constant: -8),
            loginInfoLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    
    // MARK: - 数据绑定
    
    /// 配置用户数据
    func configure(with user: MVVMUserModel) {
        nameLabel.text = user.displayName
        emailLabel.text = user.formattedEmail
        statusLabel.text = user.statusDescription
        loginInfoLabel.text = "\(user.formattedLastLoginTime) • \(user.loginCountDescription)"
        
        // 状态指示器颜色
        statusIndicator.backgroundColor = user.isOnline ? .systemGreen : .systemGray
        
        // 头像（这里使用默认头像，实际项目中可以加载网络图片）
        avatarImageView.image = UIImage(systemName: "person.circle.fill")
        avatarImageView.tintColor = .systemBlue
    }
}

// MARK: - 用户详情 View

/// 用户详情 View（SwiftUI）
struct MVVMUserDetailView: View {
    
    @StateObject private var viewModel: MVVMUserDetailViewModel
    
    init(user: MVVMUserModel) {
        self._viewModel = StateObject(wrappedValue: MVVMUserDetailViewModel(user: user))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 头像区域
                VStack(spacing: 12) {
                    Circle()
                        .fill(Color.blue.opacity(0.1))
                        .frame(width: 100, height: 100)
                        .overlay(
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.blue)
                        )
                    
                    Text(viewModel.user.displayName)
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text(viewModel.user.formattedEmail)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                
                // 用户信息卡片
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("用户信息")
                            .font(.headline)
                        Spacer()
                        Button(viewModel.isEditing ? "保存" : "编辑") {
                            if viewModel.isEditing {
                                viewModel.saveEditing()
                            } else {
                                viewModel.startEditing()
                            }
                        }
                        .foregroundColor(.blue)
                    }
                    
                    if viewModel.isEditing {
                        // 编辑模式
                        VStack(spacing: 12) {
                            TextField("姓名", text: $viewModel.editingName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            TextField("邮箱", text: $viewModel.editingEmail)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.emailAddress)
                            
                            TextField("头像URL", text: $viewModel.editingAvatar)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            Button("取消") {
                                viewModel.cancelEditing()
                            }
                            .foregroundColor(.red)
                        }
                    } else {
                        // 显示模式
                        VStack(alignment: .leading, spacing: 8) {
                            InfoRow(title: "用户ID", value: viewModel.user.id)
                            InfoRow(title: "姓名", value: viewModel.user.displayName)
                            InfoRow(title: "邮箱", value: viewModel.user.formattedEmail)
                            InfoRow(title: "状态", value: viewModel.user.statusDescription)
                            InfoRow(title: "最后登录", value: viewModel.user.formattedLastLoginTime)
                            InfoRow(title: "登录次数", value: viewModel.user.loginCountDescription)
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(radius: 2)
                
                // 操作按钮
                VStack(spacing: 12) {
                    Button(action: {
                        viewModel.toggleOnlineStatus()
                    }) {
                        HStack {
                            Image(systemName: viewModel.user.isOnline ? "wifi.slash" : "wifi")
                            Text(viewModel.user.isOnline ? "设为离线" : "设为在线")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.user.isOnline ? Color.orange : Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                }
                .padding()
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("用户详情")
        .alert("操作结果", isPresented: .constant(viewModel.operationState != .idle)) {
            Button("确定") {
                viewModel.clearOperationState()
            }
        } message: {
            if case .success(let message) = viewModel.operationState {
                Text(message)
            } else if case .error(let message) = viewModel.operationState {
                Text(message)
            }
        }
    }
}

// MARK: - 信息行组件

struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}

// MARK: - 用户登录 View

/// 用户登录 View（SwiftUI）
struct MVVMUserLoginView: View {
    
    @StateObject private var viewModel = MVVMUserLoginViewModel()
    
    var body: some View {
        VStack(spacing: 24) {
            // 标题
            VStack(spacing: 8) {
                Text("用户登录")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("请输入您的登录信息")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 40)
            
            // 登录表单
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("邮箱地址")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    TextField("请输入邮箱", text: $viewModel.email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("密码")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    SecureField("请输入密码", text: $viewModel.password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
            }
            .padding(.horizontal, 24)
            
            // 登录按钮
            Button(action: {
                viewModel.login()
            }) {
                HStack {
                    if case .loading = viewModel.operationState {
                        ProgressView()
                            .scaleEffect(0.8)
                            .foregroundColor(.white)
                    }
                    Text("登录")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(viewModel.isLoginEnabled ? Color.blue : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .disabled(!viewModel.isLoginEnabled || viewModel.operationState == .loading)
            .padding(.horizontal, 24)
            
            Spacer()
        }
        .alert("登录结果", isPresented: .constant(viewModel.operationState != .idle)) {
            Button("确定") {
                viewModel.clearOperationState()
            }
        } message: {
            if case .success(let message) = viewModel.operationState {
                Text(message)
            } else if case .error(let message) = viewModel.operationState {
                Text(message)
            }
        }
    }
}

// MARK: - 用户列表 View

/// 用户列表 View（SwiftUI）
struct MVVMUserListView: View {
    
    @StateObject private var viewModel = MVVMUserListViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                // 搜索和过滤栏
                VStack(spacing: 12) {
                    // 搜索框
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        TextField("搜索用户", text: $viewModel.searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    
                    // 过滤和排序
                    HStack {
                        // 在线用户过滤
                        Button(action: {
                            viewModel.toggleOnlineFilter()
                        }) {
                            HStack {
                                Image(systemName: viewModel.showOnlineOnly ? "checkmark.circle.fill" : "circle")
                                Text("仅在线")
                            }
                            .foregroundColor(viewModel.showOnlineOnly ? .blue : .secondary)
                        }
                        
                        Spacer()
                        
                        // 排序选择
                        Menu {
                            ForEach(MVVMUserListViewModel.SortType.allCases, id: \.self) { type in
                                Button(type.rawValue) {
                                    viewModel.setSortType(type)
                                }
                            }
                        } label: {
                            HStack {
                                Text("排序")
                                Image(systemName: "arrow.up.arrow.down")
                            }
                            .foregroundColor(.blue)
                        }
                    }
                }
                .padding(.horizontal)
                
                // 用户列表
                if viewModel.isLoading {
                    Spacer()
                    ProgressView("加载中...")
                    Spacer()
                } else if viewModel.hasError {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(.orange)
                        Text("加载失败")
                            .font(.headline)
                        Text(viewModel.errorMessage ?? "未知错误")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Button("重试") {
                            viewModel.refreshUsers()
                        }
                        .foregroundColor(.blue)
                    }
                    Spacer()
                } else if viewModel.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "person.3")
                            .font(.system(size: 50))
                            .foregroundColor(.secondary)
                        Text("暂无用户")
                            .font(.headline)
                        Text("没有找到符合条件的用户")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                } else {
                    List {
                        ForEach(Array(getCurrentUsers().enumerated()), id: \.element.id) { index, user in
                            NavigationLink(destination: MVVMUserDetailView(user: user)) {
                                UserRowView(user: user)
                            }
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                viewModel.deleteUser(at: index)
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("用户列表")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("刷新") {
                        viewModel.refreshUsers()
                    }
                }
            }
        }
        .alert("操作结果", isPresented: .constant(viewModel.operationState != .idle)) {
            Button("确定") {
                viewModel.clearOperationState()
            }
        } message: {
            if case .success(let message) = viewModel.operationState {
                Text(message)
            } else if case .error(let message) = viewModel.operationState {
                Text(message)
            }
        }
    }
    
    // MARK: - 辅助方法
    
    private func getCurrentUsers() -> [MVVMUserModel] {
        if case .loaded(let users) = viewModel.listState {
            return users
        }
        return []
    }
}

// MARK: - 用户行组件

struct UserRowView: View {
    let user: MVVMUserModel
    
    var body: some View {
        HStack(spacing: 12) {
            // 头像
            Circle()
                .fill(Color.blue.opacity(0.1))
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.blue)
                )
            
            // 用户信息
            VStack(alignment: .leading, spacing: 4) {
                Text(user.displayName)
                    .font(.headline)
                    .lineLimit(1)
                
                Text(user.formattedEmail)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                HStack {
                    Circle()
                        .fill(user.isOnline ? Color.green : Color.gray)
                        .frame(width: 8, height: 8)
                    
                    Text(user.statusDescription)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // 状态指示
            VStack(alignment: .trailing, spacing: 4) {
                Text(user.formattedLastLoginTime)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(user.loginCountDescription)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
