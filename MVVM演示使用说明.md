# MVVM 设计模式演示使用说明

## 📱 功能概述

本项目包含完整的 MVVM (Model-View-ViewModel) 设计模式演示，展示了现代 iOS 开发的最佳实践，包括：

- ✅ 完整的 MVVM 三层架构实现
- ✅ SwiftUI + UIKit 混合开发
- ✅ 数据绑定和响应式编程
- ✅ 用户列表管理（搜索、排序、过滤）
- ✅ 用户详情编辑
- ✅ 用户登录演示
- ✅ 架构图和代码示例

---

## 🚀 快速启动

### 方式一：从主页进入

1. 运行项目
2. 在主页找到 **"MVVM 架构演示"** 按钮
3. 点击进入 MVVM 演示主界面

### 方式二：代码启动

在 `HomeViewController.swift` 中添加以下代码：

```swift
@objc private func showMVVMDemo() {
    let mvvmVC = MVVMDemoViewController()
    navigationController?.pushViewController(mvvmVC, animated: true)
}
```

---

## 📊 功能详解

### 1. 用户列表演示 (SwiftUI)

**入口**: 点击 "📱 用户列表演示 (SwiftUI)" 按钮

**功能特性**:
- ✅ 用户列表展示
- ✅ 搜索功能（按姓名或邮箱搜索）
- ✅ 过滤功能（只显示在线用户）
- ✅ 排序功能（按姓名、邮箱、登录时间、登录次数）
- ✅ 删除用户（滑动删除）
- ✅ 下拉刷新
- ✅ 加载状态显示
- ✅ 空状态显示
- ✅ 错误处理

**操作示例**:
```swift
// 1. 搜索用户
在搜索框输入 "张三" → 自动过滤显示结果

// 2. 过滤在线用户
点击 "仅在线" 按钮 → 只显示在线用户

// 3. 排序
点击 "排序" 菜单 → 选择排序方式

// 4. 删除用户
向左滑动用户行 → 点击删除
```

### 2. 用户详情演示 (SwiftUI)

**入口**: 在用户列表中点击任意用户

**功能特性**:
- ✅ 用户信息展示
- ✅ 编辑模式切换
- ✅ 实时数据验证
- ✅ 在线状态切换
- ✅ 操作结果提示

**操作示例**:
```swift
// 1. 编辑用户信息
点击 "编辑" 按钮 → 修改信息 → 点击 "保存"

// 2. 切换在线状态
点击 "设为在线/离线" 按钮 → 自动更新状态

// 3. 取消编辑
编辑模式下点击 "取消" → 恢复原始数据
```

### 3. 用户登录演示 (SwiftUI)

**入口**: 点击 "🔐 用户登录演示 (SwiftUI)" 按钮

**功能特性**:
- ✅ 登录表单
- ✅ 实时输入验证
- ✅ 登录按钮启用/禁用
- ✅ 异步登录处理
- ✅ 加载状态显示
- ✅ 错误提示

**操作示例**:
```swift
// 1. 输入正确的登录信息
邮箱: test@example.com
密码: 123456 (至少6位)
→ 登录按钮变为可用 → 点击登录

// 2. 输入错误的登录信息
邮箱: invalid
密码: 123
→ 显示错误提示
```

### 4. MVVM 架构图

**入口**: 点击 "🏗️ MVVM 架构图" 按钮

**内容**:
- MVVM 三层架构图
- 数据流向说明
- 职责分离说明
- 架构优势介绍

### 5. 代码示例说明

**入口**: 点击 "💻 代码示例说明" 按钮

**内容**:
- Model 层代码示例
- ViewModel 层代码示例
- View 层代码示例
- 数据绑定示例
- 服务层示例
- MVVM 优势总结

---

## 🏗️ 架构说明

### MVVM 三层架构

```
┌─────────────────────────────────────┐
│              View Layer             │
│  ┌─────────────┐ ┌─────────────┐   │
│  │   SwiftUI   │ │   UIKit     │   │
│  │    Views    │ │   Views     │   │
│  └─────────────┘ └─────────────┘   │
└──────────────┬──────────────────────┘
               │ 数据绑定 (@Published)
┌──────────────┴──────────────────────┐
│           ViewModel Layer           │
│  • MVVMUserListViewModel            │
│  • MVVMUserDetailViewModel          │
│  • MVVMUserLoginViewModel           │
└──────────────┬──────────────────────┘
               │ 数据访问
┌──────────────┴──────────────────────┐
│             Model Layer              │
│  • MVVMUserModel                    │
│  • UserDataService                  │
└─────────────────────────────────────┘
```

### 核心文件说明

| 文件名 | 作用 | 层次 |
|--------|------|------|
| `MVVMUserModel.swift` | 用户数据模型、数据验证、数据服务 | Model 层 |
| `MVVMUserViewModel.swift` | 业务逻辑、状态管理、数据处理 | ViewModel 层 |
| `MVVMUserView.swift` | UI 组件、数据绑定、用户交互 | View 层 |
| `MVVMDemoViewController.swift` | 演示入口、架构说明、代码示例 | 演示层 |

---

## 💡 核心特性

### 1. 数据绑定

使用 SwiftUI 的 `@Published` 和 `@StateObject` 实现自动 UI 更新：

```swift
// ViewModel 中定义
@Published var users: [MVVMUserModel] = []

// View 中绑定
@StateObject private var viewModel = MVVMUserListViewModel()

// 自动更新
List {
    ForEach(viewModel.users, id: \.id) { user in
        UserRowView(user: user)
    }
}
```

### 2. 状态管理

使用枚举管理复杂状态：

```swift
enum UserListState {
    case loading         // 加载中
    case loaded([MVVMUserModel])  // 已加载
    case error(String)   // 错误
    case empty           // 空列表
}
```

### 3. 响应式编程

使用 Combine 框架实现响应式逻辑：

```swift
$email.combineLatest($password)
    .map { email, password in
        !email.isEmpty && !password.isEmpty
    }
    .assign(to: &$isLoginEnabled)
```

### 4. 数据验证

Model 层提供数据验证方法：

```swift
extension MVVMUserModel {
    var isValid: Bool { ... }
    var isEmailValid: Bool { ... }
    var validationErrors: [String] { ... }
}
```

---

## 🎯 设计模式要点

### Model 层职责
- ✅ 定义数据结构
- ✅ 数据验证逻辑
- ✅ 数据格式化
- ✅ 数据服务接口
- ❌ 不包含 UI 逻辑
- ❌ 不包含业务逻辑

### ViewModel 层职责
- ✅ 业务逻辑处理
- ✅ 状态管理
- ✅ 数据转换
- ✅ 异步操作
- ✅ 与 Model 层通信
- ❌ 不包含 UI 代码
- ❌ 不直接操作 View

### View 层职责
- ✅ UI 展示
- ✅ 用户交互
- ✅ 数据绑定
- ✅ 布局和样式
- ❌ 不包含业务逻辑
- ❌ 不直接访问 Model

---

## 🔄 数据流向

### 用户操作流程

```
1. 用户点击按钮
   ↓
2. View 调用 ViewModel 方法
   viewModel.loadUsers()
   ↓
3. ViewModel 调用 Model 服务
   userDataService.fetchUsers()
   ↓
4. Model 执行网络请求
   URLSession.dataTask()
   ↓
5. 数据返回到 ViewModel
   completion(users)
   ↓
6. ViewModel 更新 @Published 属性
   self.users = users
   ↓
7. View 自动刷新
   List { ForEach(viewModel.users) }
```

---

## 🧪 测试建议

### ViewModel 单元测试

```swift
func testLoadUsers() {
    // 准备
    let mockService = MockUserDataService()
    let viewModel = MVVMUserListViewModel(userDataService: mockService)
    
    // 执行
    viewModel.loadUsers()
    
    // 验证
    XCTAssertTrue(viewModel.isLoading)
    
    // 等待异步完成
    let expectation = XCTestExpectation(description: "Load users")
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
        XCTAssertEqual(viewModel.userCount, 5)
        expectation.fulfill()
    }
    
    wait(for: [expectation], timeout: 2.0)
}
```

### Mock 服务实现

```swift
class MockUserDataService: UserDataServiceProtocol {
    var mockUsers: [MVVMUserModel] = []
    
    func fetchUsers(completion: @escaping ([MVVMUserModel]) -> Void) {
        completion(mockUsers)
    }
}
```

---

## 🛠️ 自定义和扩展

### 添加新的 ViewModel

1. 创建新的状态枚举
```swift
enum NewFeatureState {
    case idle
    case loading
    case success
}
```

2. 创建 ViewModel 类
```swift
class NewFeatureViewModel: ObservableObject {
    @Published var state: NewFeatureState = .idle
    
    func performAction() {
        state = .loading
        // 执行操作
        state = .success
    }
}
```

3. 在 View 中使用
```swift
struct NewFeatureView: View {
    @StateObject private var viewModel = NewFeatureViewModel()
    
    var body: some View {
        // UI 代码
    }
}
```

### 添加新的数据模型

1. 定义 Model
```swift
struct ProductModel {
    let id: String
    var name: String
    var price: Double
}
```

2. 创建服务协议
```swift
protocol ProductServiceProtocol {
    func fetchProducts(completion: @escaping ([ProductModel]) -> Void)
}
```

3. 实现服务
```swift
class ProductService: ProductServiceProtocol {
    func fetchProducts(completion: @escaping ([ProductModel]) -> Void) {
        // 实现逻辑
    }
}
```

---

## 📚 学习要点

### 1. 数据绑定
- 使用 `@Published` 标记需要自动更新的属性
- 使用 `@StateObject` 持有 ViewModel
- 使用 `@ObservedObject` 传递 ViewModel

### 2. 状态管理
- 使用枚举管理复杂状态
- 状态变化触发 UI 更新
- 统一的状态转换逻辑

### 3. 异步处理
- 所有网络请求在 ViewModel 中处理
- 使用 completion 回调返回结果
- 主线程更新 UI

### 4. 依赖注入
- ViewModel 通过初始化参数接收依赖
- 便于单元测试
- 提高代码灵活性

---

## ⚠️ 注意事项

### 1. 内存管理
- ViewModel 中使用 `[weak self]` 避免循环引用
- SwiftUI 的 `@StateObject` 会自动管理生命周期
- 及时清理不需要的订阅

### 2. 线程安全
- UI 更新必须在主线程
- 使用 `DispatchQueue.main.async` 切换线程
- 异步操作要处理取消情况

### 3. 性能优化
- 避免在 `@Published` 属性中执行耗时操作
- 合理使用计算属性
- 减少不必要的 UI 刷新

---

## 🎨 UI 演示截图说明

### 用户列表界面

```
┌──────────────────────────────────┐
│  用户列表                    [刷新] │
├──────────────────────────────────┤
│  🔍 搜索用户                      │
│  ☑️ 仅在线    排序 ▼              │
├──────────────────────────────────┤
│  👤 张三                      🟢 │
│     zhangsan@example.com         │
│     2025-10-16 18:30 • 登录5次   │
├──────────────────────────────────┤
│  👤 李四                      ⚪ │
│     lisi@example.com             │
│     2025-10-15 09:20 • 登录3次   │
└──────────────────────────────────┘
```

### 用户详情界面

```
┌──────────────────────────────────┐
│  < 用户详情                       │
├──────────────────────────────────┤
│        👤 张三                    │
│    zhangsan@example.com          │
├──────────────────────────────────┤
│  用户信息              [编辑]     │
│  用户ID:     123                 │
│  姓名:       张三                 │
│  邮箱:       zhangsan@...        │
│  状态:       在线                 │
│  最后登录:   2025-10-16 18:30    │
│  登录次数:   5次                  │
├──────────────────────────────────┤
│  [ 📶 设为离线 ]                 │
└──────────────────────────────────┘
```

### 用户登录界面

```
┌──────────────────────────────────┐
│  用户登录                         │
├──────────────────────────────────┤
│                                  │
│  邮箱地址                         │
│  ┌────────────────────────────┐  │
│  │ 请输入邮箱                  │  │
│  └────────────────────────────┘  │
│                                  │
│  密码                            │
│  ┌────────────────────────────┐  │
│  │ ••••••                     │  │
│  └────────────────────────────┘  │
│                                  │
│  ┌────────────────────────────┐  │
│  │         登录              │  │
│  └────────────────────────────┘  │
│                                  │
└──────────────────────────────────┘
```

---

## 📖 代码示例

### 完整的 MVVM 实现示例

#### Model 层

```swift
// 数据模型
struct UserModel {
    let id: String
    var name: String
    var email: String
}

// 数据服务协议
protocol UserServiceProtocol {
    func fetchUsers(completion: @escaping ([UserModel]) -> Void)
}

// 数据服务实现
class UserService: UserServiceProtocol {
    func fetchUsers(completion: @escaping ([UserModel]) -> Void) {
        // 网络请求逻辑
    }
}
```

#### ViewModel 层

```swift
class UserListViewModel: ObservableObject {
    // 发布属性（自动触发 UI 更新）
    @Published var users: [UserModel] = []
    @Published var isLoading: Bool = false
    
    private let userService: UserServiceProtocol
    
    init(userService: UserServiceProtocol) {
        self.userService = userService
        loadUsers()
    }
    
    func loadUsers() {
        isLoading = true
        userService.fetchUsers { [weak self] users in
            DispatchQueue.main.async {
                self?.users = users
                self?.isLoading = false
            }
        }
    }
}
```

#### View 层

```swift
struct UserListView: View {
    @StateObject private var viewModel = UserListViewModel(
        userService: UserService()
    )
    
    var body: some View {
        NavigationView {
            if viewModel.isLoading {
                ProgressView("加载中...")
            } else {
                List(viewModel.users, id: \.id) { user in
                    Text(user.name)
                }
            }
        }
        .navigationTitle("用户列表")
    }
}
```

---

## ✨ MVVM 优势

### 1. 职责分离清晰
- Model: 纯数据，无业务逻辑
- View: 纯 UI，无业务逻辑
- ViewModel: 纯业务逻辑，无 UI 依赖

### 2. 易于测试
- ViewModel 可独立测试
- 不依赖 UI 框架
- 支持 Mock 数据服务

### 3. 代码复用
- ViewModel 可在不同 View 中复用
- 业务逻辑集中管理
- 减少代码重复

### 4. 维护性强
- 代码结构清晰
- 模块化设计
- 易于扩展

---

## 🔍 常见问题

### Q1: 为什么使用 MVVM 而不是 MVC？

**A**: MVVM 相比 MVC 的优势：
- 更好的职责分离
- ViewModel 可测试性更强
- 数据绑定减少代码量
- 更适合 SwiftUI 开发

### Q2: @Published 和 @State 有什么区别？

**A**: 
- `@Published`: 用于 ViewModel，发布属性变化
- `@State`: 用于 View，管理本地状态
- `@StateObject`: 用于持有 ViewModel 实例
- `@ObservedObject`: 用于接收传入的 ViewModel

### Q3: 何时使用 SwiftUI，何时使用 UIKit？

**A**:
- SwiftUI: 新项目、简单界面、快速开发
- UIKit: 复杂动画、自定义控件、兼容旧版本
- 混合使用: 利用各自优势，互补不足

### Q4: 如何在 ViewModel 中处理异步操作？

**A**:
```swift
func loadData() {
    state = .loading
    
    service.fetchData { [weak self] result in
        DispatchQueue.main.async {
            switch result {
            case .success(let data):
                self?.data = data
                self?.state = .success
            case .failure(let error):
                self?.state = .error(error.localizedDescription)
            }
        }
    }
}
```

---

## 📝 总结

本 MVVM 演示展示了：

1. ✅ 完整的三层架构实现
2. ✅ 数据绑定和响应式编程
3. ✅ 状态管理最佳实践
4. ✅ SwiftUI + UIKit 混合开发
5. ✅ 依赖注入和可测试性
6. ✅ 错误处理和用户反馈

这是学习现代 iOS 开发的优秀示例，展示了 MVVM 设计模式在实际项目中的应用。

---

## 🚀 下一步

- 尝试修改用户信息
- 体验搜索和过滤功能
- 查看架构图和代码示例
- 理解数据流向
- 参考代码编写自己的 MVVM 模块

祝学习愉快！🎉

