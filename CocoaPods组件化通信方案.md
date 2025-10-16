# CocoaPods 组件化通信方案

## 📌 问题分析

### 现有问题

如果 ProductModule 和 UserModule 分别在两个 CocoaPods 中：

```ruby
# Podfile
pod 'UserModule'      # 用户模块
pod 'ProductModule'   # 商品模块
```

**方法一和方法二都需要引用对方：**

```swift
// ProductModule 中
import UserModule  // ❌ 产生依赖

if let userModule = ModuleManager.shared.module(UserModule.self) {
    // 需要知道 UserModule 类型
}
```

这违背了**组件化解耦**的初衷！

---

## 🎯 解决方案：三层架构

### 架构设计

```
┌─────────────────────────────────────┐
│          App 主工程                  │
│     (集成所有模块)                   │
└─────────────────────────────────────┘
              ↓ 依赖
┌─────────────────────────────────────┐
│      ModuleProtocols (协议层)        │
│      独立的 CocoaPods                │
│  - UserModuleProtocol               │
│  - ProductModuleProtocol            │
│  - OrderModuleProtocol              │
│  - 数据模型 (User, Product)         │
└─────────────────────────────────────┘
         ↓           ↓
    ┌────────┐  ┌────────┐
    │UserModule│  │ProductModule│
    │  Pod   │  │  Pod   │
    └────────┘  └────────┘
```

### 关键点

1. **ModuleProtocols Pod**（协议层）
   - 只包含协议定义
   - 只包含数据模型
   - 不包含任何实现
   - **所有模块都依赖它**

2. **UserModule Pod**
   - 依赖 ModuleProtocols
   - 实现 UserModuleProtocol
   - 不依赖其他业务模块

3. **ProductModule Pod**
   - 依赖 ModuleProtocols
   - 实现 ProductModuleProtocol
   - 不依赖其他业务模块
   - 通过协议调用其他模块

4. **App 主工程**
   - 依赖所有模块
   - 注册所有模块
   - 连接各个组件

---

## 💻 具体实现

### 1. 创建 ModuleProtocols Pod（协议层）

```ruby
# ModuleProtocols.podspec

Pod::Spec.new do |s|
  s.name         = "ModuleProtocols"
  s.version      = "1.0.0"
  s.summary      = "模块协议层 - 所有模块的接口定义"
  
  s.homepage     = "https://github.com/yourcompany/ModuleProtocols"
  s.license      = "MIT"
  s.author       = { "Your Company" => "contact@yourcompany.com" }
  
  s.platform     = :ios, "13.0"
  s.source       = { :git => "https://github.com/yourcompany/ModuleProtocols.git", :tag => s.version }
  
  s.source_files = "ModuleProtocols/**/*.swift"
  s.swift_version = "5.0"
  
  # 不依赖任何业务模块
end
```

#### 协议层文件结构

```
ModuleProtocols/
├── ModuleProtocols.podspec
└── ModuleProtocols/
    ├── Core/
    │   ├── ModuleProtocol.swift          # 基础协议
    │   └── ModuleManager.swift            # 模块管理器
    ├── Protocols/
    │   ├── UserModuleProtocol.swift       # 用户模块协议
    │   ├── ProductModuleProtocol.swift    # 商品模块协议
    │   └── OrderModuleProtocol.swift      # 订单模块协议
    └── Models/
        ├── User.swift                     # 用户数据模型
        ├── Product.swift                  # 商品数据模型
        └── Order.swift                    # 订单数据模型
```

#### 协议层代码示例

```swift
// ModuleProtocols/Core/ModuleProtocol.swift

import UIKit

/// 模块协议基类
public protocol ModuleProtocol {
    static var moduleName: String { get }
    init()
}

/// 页面模块协议
public protocol PageModuleProtocol: ModuleProtocol {
    func createViewController(with parameters: [String: Any]) -> UIViewController?
}

/// 服务模块协议
public protocol ServiceModuleProtocol: ModuleProtocol {
}
```

```swift
// ModuleProtocols/Protocols/UserModuleProtocol.swift

import UIKit

/// 用户模块协议
public protocol UserModuleProtocol: PageModuleProtocol, ServiceModuleProtocol {
    
    // MARK: - 页面创建
    func createUserDetailPage(userId: String) -> UIViewController?
    func createUserListPage() -> UIViewController?
    func createLoginPage() -> UIViewController?
    
    // MARK: - 服务方法
    func getCurrentUser() -> User?
    func isLoggedIn() -> Bool
    func login(username: String, password: String, completion: @escaping (Bool, String?) -> Void)
    func logout()
}
```

```swift
// ModuleProtocols/Protocols/ProductModuleProtocol.swift

import UIKit

/// 商品模块协议
public protocol ProductModuleProtocol: PageModuleProtocol, ServiceModuleProtocol {
    
    // MARK: - 页面创建
    func createProductDetailPage(productId: String) -> UIViewController?
    func createProductListPage(category: String?) -> UIViewController?
    
    // MARK: - 服务方法
    func getProduct(productId: String, completion: @escaping (Product?) -> Void)
    func getProductList(category: String?, completion: @escaping ([Product]) -> Void)
    func addToCart(productId: String, quantity: Int) -> Bool
    func syncCart()
}
```

```swift
// ModuleProtocols/Models/User.swift

import Foundation

/// 用户数据模型
public struct User {
    public let id: String
    public let name: String
    public let avatar: String?
    public let email: String?
    
    public init(id: String, name: String, avatar: String? = nil, email: String? = nil) {
        self.id = id
        self.name = name
        self.avatar = avatar
        self.email = email
    }
}
```

```swift
// ModuleProtocols/Models/Product.swift

import Foundation

/// 商品数据模型
public struct Product {
    public let id: String
    public let name: String
    public let price: Double
    public let imageUrl: String?
    public let description: String?
    
    public init(id: String, name: String, price: Double, imageUrl: String? = nil, description: String? = nil) {
        self.id = id
        self.name = name
        self.price = price
        self.imageUrl = imageUrl
        self.description = description
    }
}
```

```swift
// ModuleProtocols/Core/ModuleManager.swift

import UIKit

/// 模块管理器
public class ModuleManager {
    public static let shared = ModuleManager()
    
    private var modules: [String: ModuleProtocol.Type] = [:]
    private var instances: [String: ModuleProtocol] = [:]
    
    private init() {}
    
    // MARK: - 注册模块
    
    public func register<T: ModuleProtocol>(_ moduleType: T.Type) {
        modules[moduleType.moduleName] = moduleType
    }
    
    // MARK: - 获取模块（核心方法）
    
    /// 获取模块实例（返回协议类型）
    public func module<T: ModuleProtocol>(_ protocolType: T.Type) -> T? {
        // 通过协议类型查找模块
        for (_, moduleType) in modules {
            if let module = moduleType as? T.Type {
                let moduleName = moduleType.moduleName
                
                if let instance = instances[moduleName] as? T {
                    return instance
                }
                
                let instance = module.init()
                instances[moduleName] = instance
                return instance
            }
        }
        return nil
    }
    
    // MARK: - 页面跳转
    
    public func openPage<T: PageModuleProtocol>(
        _ protocolType: T.Type,
        parameters: [String: Any] = [:],
        from source: UIViewController? = nil,
        animated: Bool = true
    ) -> Bool {
        guard let module = self.module(protocolType) else {
            return false
        }
        
        guard let destination = module.createViewController(with: parameters) else {
            return false
        }
        
        guard let source = source else {
            return false
        }
        
        source.navigationController?.pushViewController(destination, animated: animated)
        return true
    }
}
```

---

### 2. 创建 UserModule Pod

```ruby
# UserModule.podspec

Pod::Spec.new do |s|
  s.name         = "UserModule"
  s.version      = "1.0.0"
  s.summary      = "用户模块"
  
  s.homepage     = "https://github.com/yourcompany/UserModule"
  s.license      = "MIT"
  s.author       = { "Your Company" => "contact@yourcompany.com" }
  
  s.platform     = :ios, "13.0"
  s.source       = { :git => "https://github.com/yourcompany/UserModule.git", :tag => s.version }
  
  s.source_files = "UserModule/**/*.swift"
  s.swift_version = "5.0"
  
  # 只依赖协议层，不依赖其他业务模块
  s.dependency 'ModuleProtocols'
end
```

#### UserModule 实现

```swift
// UserModule/UserModule.swift

import UIKit
import ModuleProtocols  // ✅ 只依赖协议层

/// 用户模块实现
public class UserModule: UserModuleProtocol {
    public static let moduleName = "UserModule"
    
    private var currentUser: User?
    
    public required init() {}
    
    // MARK: - PageModuleProtocol
    
    public func createViewController(with parameters: [String : Any]) -> UIViewController? {
        if let userId = parameters["userId"] as? String {
            return createUserDetailPage(userId: userId)
        } else if let isLogin = parameters["isLogin"] as? Bool, isLogin {
            return createLoginPage()
        } else {
            return createUserListPage()
        }
    }
    
    // MARK: - UserModuleProtocol
    
    public func createUserDetailPage(userId: String) -> UIViewController? {
        let vc = UserDetailViewController()
        vc.userId = userId
        return vc
    }
    
    public func createUserListPage() -> UIViewController? {
        return UserListViewController()
    }
    
    public func createLoginPage() -> UIViewController? {
        return LoginViewController()
    }
    
    public func getCurrentUser() -> User? {
        return currentUser
    }
    
    public func isLoggedIn() -> Bool {
        return currentUser != nil
    }
    
    public func login(username: String, password: String, completion: @escaping (Bool, String?) -> Void) {
        // 登录逻辑
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.currentUser = User(id: "123", name: username, avatar: nil, email: "\(username)@example.com")
            completion(true, nil)
        }
    }
    
    public func logout() {
        currentUser = nil
    }
}
```

---

### 3. 创建 ProductModule Pod

```ruby
# ProductModule.podspec

Pod::Spec.new do |s|
  s.name         = "ProductModule"
  s.version      = "1.0.0"
  s.summary      = "商品模块"
  
  s.homepage     = "https://github.com/yourcompany/ProductModule"
  s.license      = "MIT"
  s.author       = { "Your Company" => "contact@yourcompany.com" }
  
  s.platform     = :ios, "13.0"
  s.source       = { :git => "https://github.com/yourcompany/ProductModule.git", :tag => s.version }
  
  s.source_files = "ProductModule/**/*.swift"
  s.swift_version = "5.0"
  
  # 只依赖协议层，不依赖其他业务模块
  s.dependency 'ModuleProtocols'
end
```

#### ProductModule 实现（关键：通过协议调用）

```swift
// ProductModule/ProductModule.swift

import UIKit
import ModuleProtocols  // ✅ 只依赖协议层，不依赖 UserModule

/// 商品模块实现
public class ProductModule: ProductModuleProtocol {
    public static let moduleName = "ProductModule"
    
    private var cart: [String: Int] = [:]
    
    public required init() {}
    
    // MARK: - PageModuleProtocol
    
    public func createViewController(with parameters: [String : Any]) -> UIViewController? {
        if let productId = parameters["productId"] as? String {
            return createProductDetailPage(productId: productId)
        } else {
            let category = parameters["category"] as? String
            return createProductListPage(category: category)
        }
    }
    
    // MARK: - ProductModuleProtocol
    
    public func createProductDetailPage(productId: String) -> UIViewController? {
        let vc = ProductDetailViewController()
        vc.productId = productId
        return vc
    }
    
    public func createProductListPage(category: String?) -> UIViewController? {
        let vc = ProductListViewController()
        vc.category = category
        return vc
    }
    
    public func getProduct(productId: String, completion: @escaping (Product?) -> Void) {
        // 网络请求获取商品
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let product = Product(id: productId, name: "iPhone 15", price: 5999, imageUrl: nil, description: nil)
            completion(product)
        }
    }
    
    public func getProductList(category: String?, completion: @escaping ([Product]) -> Void) {
        // 网络请求获取商品列表
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let products = [
                Product(id: "1", name: "iPhone 15", price: 5999, imageUrl: nil, description: nil),
                Product(id: "2", name: "iPad Pro", price: 6799, imageUrl: nil, description: nil)
            ]
            completion(products)
        }
    }
    
    public func addToCart(productId: String, quantity: Int) -> Bool {
        // ✅ 关键：通过协议调用 UserModule，而不是直接依赖
        // 不需要 import UserModule
        
        guard let userModule = ModuleManager.shared.module(UserModuleProtocol.self) else {
            print("❌ 无法获取 UserModule")
            return false
        }
        
        // 检查登录状态
        guard let user = userModule.getCurrentUser() else {
            print("❌ 用户未登录")
            return false
        }
        
        // 添加到购物车
        print("✅ 用户 \(user.name) 添加商品 \(productId) x\(quantity)")
        cart[productId] = (cart[productId] ?? 0) + quantity
        return true
    }
    
    public func syncCart() {
        // ✅ 通过协议调用 UserModule
        guard let userModule = ModuleManager.shared.module(UserModuleProtocol.self) else {
            return
        }
        
        if let user = userModule.getCurrentUser() {
            print("🔄 为用户 \(user.name) 同步购物车")
            // 同步逻辑
        }
    }
}
```

---

### 4. App 主工程集成

```ruby
# Podfile

platform :ios, '13.0'
use_frameworks!

target 'MyApp' do
  # 协议层（所有模块都依赖）
  pod 'ModuleProtocols', :path => './ModuleProtocols'
  
  # 业务模块（互不依赖）
  pod 'UserModule', :path => './UserModule'
  pod 'ProductModule', :path => './ProductModule'
  pod 'OrderModule', :path => './OrderModule'
end
```

#### AppDelegate 注册模块

```swift
// AppDelegate.swift

import UIKit
import ModuleProtocols
import UserModule      // 只在主工程导入
import ProductModule   // 只在主工程导入

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // 注册所有模块
        registerModules()
        
        return true
    }
    
    private func registerModules() {
        let manager = ModuleManager.shared
        
        // 注册用户模块
        manager.register(UserModule.self)
        
        // 注册商品模块
        manager.register(ProductModule.self)
        
        // 注册订单模块
        // manager.register(OrderModule.self)
        
        print("✅ 所有模块已注册")
    }
}
```

---

## 🎯 使用示例

### ProductModule 中调用 UserModule（无需导入）

```swift
// ProductModule/ProductDetailViewController.swift

import UIKit
import ModuleProtocols  // ✅ 只依赖协议层

class ProductDetailViewController: UIViewController {
    var productId: String?
    
    @IBAction func buyButtonTapped() {
        // ✅ 通过协议类型获取模块，不需要 import UserModule
        guard let userModule = ModuleManager.shared.module(UserModuleProtocol.self) else {
            print("❌ 无法获取用户模块")
            return
        }
        
        // 检查登录状态
        if let user = userModule.getCurrentUser() {
            print("✅ 用户已登录：\(user.name)")
            processPurchase()
        } else {
            print("⚠️ 用户未登录，跳转登录页")
            
            // 打开登录页
            ModuleManager.shared.openPage(
                UserModuleProtocol.self,  // ✅ 使用协议类型
                parameters: ["isLogin": true],
                from: self
            )
        }
    }
    
    private func processPurchase() {
        guard let productModule = ModuleManager.shared.module(ProductModuleProtocol.self) else {
            return
        }
        
        let success = productModule.addToCart(productId: productId ?? "", quantity: 1)
        print(success ? "✅ 已添加到购物车" : "❌ 添加失败")
    }
}
```

---

## 📊 依赖关系图

### 传统方式（❌ 相互依赖）

```
ProductModule ←→ UserModule  // 互相依赖，紧耦合
```

### 协议层方式（✅ 完全解耦）

```
         App 主工程
            ↓
      ModuleProtocols
       ↙         ↘
UserModule    ProductModule

依赖关系：
- UserModule → ModuleProtocols ✅
- ProductModule → ModuleProtocols ✅
- UserModule ← → ProductModule ❌（无依赖）
```

---

## 🌟 核心优势

### 1. 完全解耦

```swift
// ProductModule 中
import ModuleProtocols  // ✅ 只依赖协议层

// 不需要
// import UserModule  // ❌ 不依赖具体模块
```

### 2. 独立开发

```
UserModule 团队：
- 只需要实现 UserModuleProtocol
- 不关心其他模块

ProductModule 团队：
- 只需要实现 ProductModuleProtocol
- 通过协议调用其他模块
```

### 3. 独立测试

```swift
// 测试 ProductModule 时，可以 Mock UserModule
class MockUserModule: UserModuleProtocol {
    static let moduleName = "MockUserModule"
    
    required init() {}
    
    func getCurrentUser() -> User? {
        return User(id: "test", name: "Test User")
    }
    
    // ... 其他方法
}

// 测试时注册 Mock 模块
ModuleManager.shared.register(MockUserModule.self)
```

### 4. 灵活替换

```swift
// 可以轻松替换模块实现
// 方式1：UserModule
manager.register(UserModule.self)

// 方式2：UserModuleV2（新版本）
manager.register(UserModuleV2.self)

// ProductModule 不需要任何修改
```

---

## 💡 最佳实践

### 1. 协议层保持轻量

```swift
// ✅ 协议层只包含
- 协议定义
- 数据模型（struct）
- 枚举类型

// ❌ 协议层不包含
- 具体实现
- 第三方库依赖
- UI 组件
```

### 2. 协议设计原则

```swift
// ✅ 好的协议设计
protocol UserModuleProtocol {
    func getCurrentUser() -> User?  // 返回数据模型
    func login(..., completion: @escaping (Bool, String?) -> Void)  // 异步回调
}

// ❌ 差的协议设计
protocol UserModuleProtocol {
    func getCurrentUserViewController() -> UIViewController  // 返回 UI
    var userManager: UserManager { get }  // 暴露内部实现
}
```

### 3. 版本管理

```ruby
# ModuleProtocols.podspec
s.version = "1.0.0"  # 协议层版本

# UserModule.podspec
s.version = "2.3.0"  # 模块实现版本
s.dependency 'ModuleProtocols', '~> 1.0'  # 兼容协议层 1.x
```

---

## ✅ 总结

### 核心思想

**通过协议层（ModuleProtocols）实现完全解耦**

### 架构层次

```
1. App 主工程（集成）
2. ModuleProtocols Pod（协议层）
3. 各业务模块 Pod（实现层）
```

### 通信方式

```swift
// ProductModule 中调用 UserModule

// ❌ 传统方式（产生依赖）
import UserModule
let userModule = ModuleManager.shared.module(UserModule.self)

// ✅ 协议层方式（完全解耦）
import ModuleProtocols
let userModule = ModuleManager.shared.module(UserModuleProtocol.self)
```

### 关键优势

✅ **完全解耦** - 模块间零依赖  
✅ **独立开发** - 团队并行开发  
✅ **独立测试** - 可 Mock 可替换  
✅ **灵活扩展** - 易于增加新模块  

---

**CocoaPods 组件化通信方案已完整说明！核心是抽取协议层作为中间层！🚀**

