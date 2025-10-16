# CocoaPods 组件化实战示例

## 📌 核心方案：协议层 + 中介者

### 问题：两个独立 Pod 怎么通信？

```
❌ 错误方案：
ProductModule Pod
    ↓ import UserModule  // 产生依赖
UserModule Pod

✅ 正确方案：
ProductModule Pod → ModuleProtocols Pod ← UserModule Pod
                         ↑
                    只依赖协议层
```

---

## 🏗️ 项目结构

### 1. CocoaPods 结构

```
MyApp/
├── Podfile
├── MyApp/                      # 主工程
│   └── AppDelegate.swift
│
├── Pods/                       # CocoaPods 管理
│   ├── ModuleProtocols/        # 协议层 Pod
│   ├── UserModule/             # 用户模块 Pod
│   └── ProductModule/          # 商品模块 Pod
│
└── LocalPods/                  # 本地开发的 Pods
    ├── ModuleProtocols/
    │   ├── ModuleProtocols.podspec
    │   └── ModuleProtocols/
    │       ├── Core/
    │       │   ├── ModuleProtocol.swift
    │       │   └── ModuleManager.swift
    │       ├── Protocols/
    │       │   ├── UserModuleProtocol.swift
    │       │   └── ProductModuleProtocol.swift
    │       └── Models/
    │           ├── User.swift
    │           └── Product.swift
    │
    ├── UserModule/
    │   ├── UserModule.podspec
    │   └── UserModule/
    │       ├── UserModule.swift
    │       ├── ViewControllers/
    │       │   ├── UserDetailViewController.swift
    │       │   └── LoginViewController.swift
    │       └── Services/
    │           └── UserNetworkService.swift
    │
    └── ProductModule/
        ├── ProductModule.podspec
        └── ProductModule/
            ├── ProductModule.swift
            ├── ViewControllers/
            │   ├── ProductDetailViewController.swift
            │   └── ProductListViewController.swift
            └── Services/
                └── ProductNetworkService.swift
```

---

## 📝 Podfile 配置

```ruby
platform :ios, '13.0'
use_frameworks!

target 'MyApp' do
  # 协议层（所有模块都依赖）
  pod 'ModuleProtocols', :path => './LocalPods/ModuleProtocols'
  
  # 业务模块（互不依赖，只依赖协议层）
  pod 'UserModule', :path => './LocalPods/UserModule'
  pod 'ProductModule', :path => './LocalPods/ProductModule'
  
  # 其他模块
  # pod 'OrderModule', :path => './LocalPods/OrderModule'
  # pod 'MineModule', :path => './LocalPods/MineModule'
end
```

---

## 💻 代码实现

### 1. ModuleProtocols Pod（协议层）

#### ModuleProtocols.podspec

```ruby
Pod::Spec.new do |s|
  s.name         = "ModuleProtocols"
  s.version      = "1.0.0"
  s.summary      = "模块协议层"
  s.description  = "定义所有模块的接口协议和数据模型"
  
  s.homepage     = "https://github.com/yourcompany/ModuleProtocols"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Your Name" => "your@email.com" }
  
  s.platform     = :ios, "13.0"
  s.source       = { :git => "https://github.com/yourcompany/ModuleProtocols.git", :tag => s.version }
  
  s.source_files = "ModuleProtocols/**/*.swift"
  s.swift_version = "5.0"
  
  # 不依赖任何业务模块
  # 可以依赖基础工具库
  # s.dependency 'Alamofire'  # 如果需要
end
```

#### UserModuleProtocol.swift

```swift
// ModuleProtocols/Protocols/UserModuleProtocol.swift

import UIKit

/// 用户模块协议
public protocol UserModuleProtocol: PageModuleProtocol, ServiceModuleProtocol {
    
    // MARK: - 页面创建
    
    /// 创建用户详情页
    func createUserDetailPage(userId: String) -> UIViewController?
    
    /// 创建登录页
    func createLoginPage() -> UIViewController?
    
    // MARK: - 服务方法
    
    /// 获取当前用户
    func getCurrentUser() -> User?
    
    /// 是否已登录
    func isLoggedIn() -> Bool
    
    /// 登录
    func login(username: String, password: String, completion: @escaping (Bool, String?) -> Void)
    
    /// 登出
    func logout()
    
    /// 获取用户信息（网络请求）
    func getUserInfo(userId: String, completion: @escaping (User?) -> Void)
}
```

#### ProductModuleProtocol.swift

```swift
// ModuleProtocols/Protocols/ProductModuleProtocol.swift

import UIKit

/// 商品模块协议
public protocol ProductModuleProtocol: PageModuleProtocol, ServiceModuleProtocol {
    
    // MARK: - 页面创建
    
    /// 创建商品详情页
    func createProductDetailPage(productId: String) -> UIViewController?
    
    /// 创建商品列表页
    func createProductListPage(category: String?) -> UIViewController?
    
    // MARK: - 服务方法
    
    /// 获取商品信息（网络请求）
    func getProduct(productId: String, completion: @escaping (Product?) -> Void)
    
    /// 获取商品列表（网络请求）
    func getProductList(category: String?, completion: @escaping ([Product]) -> Void)
    
    /// 添加到购物车（需要登录）
    func addToCart(productId: String, quantity: Int) -> Bool
    
    /// 同步购物车（登录后调用）
    func syncCart()
    
    /// 清空购物车（登出后调用）
    func clearCart()
}
```

---

### 2. UserModule Pod

#### UserModule.podspec

```ruby
Pod::Spec.new do |s|
  s.name         = "UserModule"
  s.version      = "1.0.0"
  s.summary      = "用户模块"
  
  s.homepage     = "https://github.com/yourcompany/UserModule"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Your Name" => "your@email.com" }
  
  s.platform     = :ios, "13.0"
  s.source       = { :git => "https://github.com/yourcompany/UserModule.git", :tag => s.version }
  
  s.source_files = "UserModule/**/*.swift"
  s.swift_version = "5.0"
  
  # ✅ 只依赖协议层
  s.dependency 'ModuleProtocols', '~> 1.0'
  
  # 可以依赖网络、存储等基础库
  # s.dependency 'Alamofire'
  # s.dependency 'Kingfisher'
end
```

#### UserModule.swift

```swift
// UserModule/UserModule.swift

import UIKit
import ModuleProtocols  // ✅ 只依赖协议层

/// 用户模块实现
public class UserModule: UserModuleProtocol {
    public static let moduleName = "UserModule"
    
    // 当前用户
    private var currentUser: User?
    
    public required init() {
        print("📦 UserModule 已初始化")
    }
    
    // MARK: - PageModuleProtocol
    
    public func createViewController(with parameters: [String : Any]) -> UIViewController? {
        if let userId = parameters["userId"] as? String {
            return createUserDetailPage(userId: userId)
        } else if let isLogin = parameters["isLogin"] as? Bool, isLogin {
            return createLoginPage()
        } else {
            return nil
        }
    }
    
    // MARK: - UserModuleProtocol 实现
    
    public func createUserDetailPage(userId: String) -> UIViewController? {
        let vc = UserDetailViewController()
        vc.userId = userId
        return vc
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
        print("🔐 UserModule: 登录 \(username)")
        
        // 模拟网络请求
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.currentUser = User(
                id: "123",
                name: username,
                avatar: nil,
                email: "\(username)@example.com"
            )
            
            print("✅ UserModule: 登录成功")
            
            // 登录成功后，通知其他模块同步数据
            self?.notifyOtherModulesAfterLogin()
            
            completion(true, nil)
        }
    }
    
    public func logout() {
        print("🔓 UserModule: 登出")
        currentUser = nil
        
        // 通知其他模块清空数据
        notifyOtherModulesAfterLogout()
    }
    
    public func getUserInfo(userId: String, completion: @escaping (User?) -> Void) {
        print("🌐 UserModule: 获取用户信息 \(userId)")
        
        // 网络请求
        // ...
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let user = User(id: userId, name: "张三", avatar: nil, email: "zhangsan@example.com")
            completion(user)
        }
    }
    
    // MARK: - 私有方法
    
    private func notifyOtherModulesAfterLogin() {
        // ✅ 通过协议调用 ProductModule，不需要 import ProductModule
        if let productModule = ModuleManager.shared.module(ProductModuleProtocol.self) {
            print("🔄 UserModule: 通知 ProductModule 同步购物车")
            productModule.syncCart()
        }
        
        // 可以通知更多模块
        // if let orderModule = ModuleManager.shared.module(OrderModuleProtocol.self) {
        //     orderModule.syncOrders()
        // }
    }
    
    private func notifyOtherModulesAfterLogout() {
        // ✅ 通过协议调用 ProductModule
        if let productModule = ModuleManager.shared.module(ProductModuleProtocol.self) {
            print("🗑️ UserModule: 通知 ProductModule 清空购物车")
            productModule.clearCart()
        }
    }
}
```

---

### 3. ProductModule Pod

#### ProductModule.podspec

```ruby
Pod::Spec.new do |s|
  s.name         = "ProductModule"
  s.version      = "1.0.0"
  s.summary      = "商品模块"
  
  s.homepage     = "https://github.com/yourcompany/ProductModule"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Your Name" => "your@email.com" }
  
  s.platform     = :ios, "13.0"
  s.source       = { :git => "https://github.com/yourcompany/ProductModule.git", :tag => s.version }
  
  s.source_files = "ProductModule/**/*.swift"
  s.swift_version = "5.0"
  
  # ✅ 只依赖协议层
  s.dependency 'ModuleProtocols', '~> 1.0'
  
  # 可以依赖网络、图片等基础库
  # s.dependency 'Alamofire'
  # s.dependency 'Kingfisher'
end
```

#### ProductModule.swift

```swift
// ProductModule/ProductModule.swift

import UIKit
import ModuleProtocols  // ✅ 只依赖协议层，不依赖 UserModule

/// 商品模块实现
public class ProductModule: ProductModuleProtocol {
    public static let moduleName = "ProductModule"
    
    // 购物车（本地存储）
    private var cart: [String: Int] = [:]
    
    public required init() {
        print("📦 ProductModule 已初始化")
    }
    
    // MARK: - PageModuleProtocol
    
    public func createViewController(with parameters: [String : Any]) -> UIViewController? {
        if let productId = parameters["productId"] as? String {
            return createProductDetailPage(productId: productId)
        } else {
            let category = parameters["category"] as? String
            return createProductListPage(category: category)
        }
    }
    
    // MARK: - ProductModuleProtocol 实现
    
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
        print("🌐 ProductModule: 获取商品 \(productId)")
        
        // 网络请求
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let product = Product(
                id: productId,
                name: "iPhone 15 Pro",
                price: 7999,
                imageUrl: "https://example.com/iphone.jpg",
                description: "A17 Pro 芯片，钛金属设计"
            )
            completion(product)
        }
    }
    
    public func getProductList(category: String?, completion: @escaping ([Product]) -> Void) {
        print("🌐 ProductModule: 获取商品列表")
        
        // 网络请求
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let products = [
                Product(id: "1", name: "iPhone 15", price: 5999),
                Product(id: "2", name: "iPad Pro", price: 6799),
                Product(id: "3", name: "MacBook Pro", price: 12999)
            ]
            completion(products)
        }
    }
    
    public func addToCart(productId: String, quantity: Int) -> Bool {
        // ✅ 核心：通过协议调用 UserModule，无需 import UserModule
        guard let userModule = ModuleManager.shared.module(UserModuleProtocol.self) else {
            print("❌ ProductModule: 无法获取 UserModule")
            return false
        }
        
        // 检查登录状态
        guard let user = userModule.getCurrentUser() else {
            print("❌ ProductModule: 用户未登录，无法添加购物车")
            return false
        }
        
        // 添加到购物车
        print("✅ ProductModule: 用户 \(user.name) 添加商品 \(productId) x\(quantity)")
        cart[productId] = (cart[productId] ?? 0) + quantity
        
        return true
    }
    
    public func syncCart() {
        // ✅ 通过协议调用 UserModule
        guard let userModule = ModuleManager.shared.module(UserModuleProtocol.self) else {
            return
        }
        
        if let user = userModule.getCurrentUser() {
            print("🔄 ProductModule: 为用户 \(user.name) 同步购物车")
            
            // 从服务器同步购物车数据
            // ...
        }
    }
    
    public func clearCart() {
        print("🗑️ ProductModule: 清空购物车")
        cart.removeAll()
    }
}
```

---

## 🔄 通信流程实例

### 实例 1：商品购买流程

```swift
// ProductModule/ProductDetailViewController.swift

import UIKit
import ModuleProtocols  // ✅ 只依赖协议层

public class ProductDetailViewController: UIViewController {
    public var productId: String?
    
    @IBAction func buyButtonTapped() {
        print("📱 ProductModule: 用户点击购买")
        
        // 步骤1：获取 UserModule（通过协议）
        guard let userModule = ModuleManager.shared.module(UserModuleProtocol.self) else {
            showAlert("系统错误")
            return
        }
        
        // 步骤2：检查登录状态
        if let user = userModule.getCurrentUser() {
            // 已登录
            print("✅ ProductModule: 用户已登录 - \(user.name)")
            confirmPurchase()
        } else {
            // 未登录，跳转登录页
            print("⚠️ ProductModule: 用户未登录，跳转登录页")
            
            // 步骤3：打开登录页（UserModule 提供）
            ModuleManager.shared.openPage(
                UserModuleProtocol.self,  // ✅ 使用协议类型
                parameters: ["isLogin": true],
                from: self
            )
        }
    }
    
    private func confirmPurchase() {
        // 步骤4：添加到购物车（ProductModule 服务）
        guard let productModule = ModuleManager.shared.module(ProductModuleProtocol.self) else {
            return
        }
        
        let success = productModule.addToCart(productId: productId ?? "", quantity: 1)
        
        showAlert(success ? "✅ 已添加到购物车" : "❌ 添加失败")
    }
}
```

### 实例 2：登录后同步数据

```swift
// UserModule/LoginViewController.swift

import UIKit
import ModuleProtocols  // ✅ 只依赖协议层

public class LoginViewController: UIViewController {
    
    @IBAction func loginButtonTapped() {
        let username = usernameTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        
        print("📱 UserModule: 用户尝试登录")
        
        // 步骤1：调用 UserModule 登录服务
        guard let userModule = ModuleManager.shared.module(UserModuleProtocol.self) else {
            return
        }
        
        userModule.login(username: username, password: password) { [weak self] success, error in
            if success {
                print("✅ UserModule: 登录成功")
                
                // 步骤2：登录成功后，通知其他模块同步数据
                self?.syncDataAfterLogin()
                
                // 步骤3：返回上一页
                self?.navigationController?.popViewController(animated: true)
            } else {
                print("❌ UserModule: 登录失败 - \(error ?? "")")
            }
        }
    }
    
    private func syncDataAfterLogin() {
        // 通过协议调用 ProductModule，同步购物车
        if let productModule = ModuleManager.shared.module(ProductModuleProtocol.self) {
            print("🔄 UserModule: 通知 ProductModule 同步购物车")
            productModule.syncCart()
        }
        
        // 可以通知更多模块
        // if let orderModule = ModuleManager.shared.module(OrderModuleProtocol.self) {
        //     orderModule.syncOrders()
        // }
    }
}
```

---

## 📊 依赖关系

### Podfile 依赖

```
App 主工程
├── ModuleProtocols  ✅
├── UserModule       ✅
└── ProductModule    ✅

UserModule Pod
└── ModuleProtocols  ✅（只依赖协议层）

ProductModule Pod
└── ModuleProtocols  ✅（只依赖协议层）
```

### Import 语句

```swift
// ✅ UserModule 中
import ModuleProtocols  // 只导入协议层

// ✅ ProductModule 中
import ModuleProtocols  // 只导入协议层

// ✅ App 主工程中
import ModuleProtocols
import UserModule      // 注册时需要
import ProductModule   // 注册时需要
```

---

## 🎯 关键技术点

### 1. 通过协议类型获取模块

```swift
// ❌ 错误方式（需要导入具体模块）
import UserModule
let userModule = ModuleManager.shared.module(UserModule.self)

// ✅ 正确方式（只需要协议）
import ModuleProtocols
let userModule = ModuleManager.shared.module(UserModuleProtocol.self)
```

### 2. ModuleManager 实现关键

```swift
// ModuleManager.swift

public func module<T: ModuleProtocol>(_ protocolType: T.Type) -> T? {
    // 遍历所有注册的模块
    for (_, moduleType) in modules {
        // 检查模块是否实现了该协议
        if let module = moduleType as? T.Type {
            // 返回协议类型的实例
            let instance = module.init()
            return instance
        }
    }
    return nil
}
```

### 3. 协议注册

```swift
// App 主工程 AppDelegate.swift

import UserModule
import ProductModule

func registerModules() {
    // 注册具体实现类
    ModuleManager.shared.register(UserModule.self)
    ModuleManager.shared.register(ProductModule.self)
}

// 其他模块中使用（不需要 import 具体模块）
let userModule = ModuleManager.shared.module(UserModuleProtocol.self)
```

---

## ✅ 总结

### 核心方案

**通过协议层（ModuleProtocols Pod）实现完全解耦**

```
1. 创建 ModuleProtocols Pod（协议层）
   - 定义所有模块协议
   - 定义数据模型
   - 包含 ModuleManager

2. 各业务模块 Pod
   - 只依赖 ModuleProtocols
   - 实现对应协议
   - 互不依赖

3. App 主工程
   - 依赖所有模块
   - 注册所有模块
   - 连接各组件
```

### 通信方式

```swift
// ProductModule 调用 UserModule

// ✅ 通过协议类型（无需导入 UserModule）
import ModuleProtocols

let userModule = ModuleManager.shared.module(UserModuleProtocol.self)
let user = userModule?.getCurrentUser()
```

### 依赖关系

```
UserModule Pod → ModuleProtocols Pod ✅
ProductModule Pod → ModuleProtocols Pod ✅
UserModule Pod ↔ ProductModule Pod ❌（零依赖）
```

---

**这就是大型项目组件化的标准方案！通过协议层实现模块间完全解耦！🚀**

