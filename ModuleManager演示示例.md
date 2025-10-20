# ModuleManager 使用演示

## 📚 presentPage 方法详解

`presentPage` 用于以模态方式（Present）打开一个页面模块。

### 方法签名

```swift
func presentPage<T: PageModuleProtocol>(
    _ moduleType: T.Type,           // 模块类型（协议或具体类）
    parameters: [String: Any] = [:], // 传递的参数
    from source: UIViewController? = nil,  // 源控制器（nil则自动获取）
    animated: Bool = true,           // 是否动画
    completion: (() -> Void)? = nil  // 完成回调
) -> Bool  // 返回是否成功
```

---

## 🎯 使用示例

### 示例 1：基础用法 - 弹出用户列表

```swift
import UIKit

class DemoViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "演示页面"
        view.backgroundColor = .systemBackground
        
        // 添加按钮
        let button = UIButton(type: .system)
        button.setTitle("打开用户列表（Present）", for: .normal)
        button.addTarget(self, action: #selector(openUserList), for: .touchUpInside)
        button.frame = CGRect(x: 100, y: 200, width: 200, height: 44)
        view.addSubview(button)
    }
    
    @objc private func openUserList() {
        // ✅ 方式1：通过具体类型
        let success = ModuleManager.shared.presentPage(
            UserModule.self,
            parameters: [:],
            from: self,
            animated: true
        )
        
        if success {
            print("✅ 页面已弹出")
        } else {
            print("❌ 弹出失败")
        }
    }
}
```

---

### 示例 2：传递参数 - 弹出用户详情

```swift
@objc private func openUserDetail() {
    // 传递用户ID参数
    let success = ModuleManager.shared.presentPage(
        UserModule.self,
        parameters: ["userId": "12345"],
        from: self,
        animated: true,
        completion: {
            print("✅ 页面弹出动画完成")
        }
    )
    
    if !success {
        // 失败处理
        showAlert(title: "错误", message: "无法打开用户详情")
    }
}
```

---

### 示例 3：使用协议类型（推荐⭐）

```swift
@objc private func openProductList() {
    // ✅ 方式2：通过协议类型（解耦，无需 import 具体模块）
    let success = ModuleManager.shared.presentPage(
        ProductModuleProtocol.self,  // 使用协议类型
        parameters: ["category": "手机"],
        from: self,
        animated: true
    )
    
    print(success ? "✅ 商品列表已弹出" : "❌ 弹出失败")
}
```

---

### 示例 4：不指定源控制器（自动获取）

```swift
@objc private func openLoginPage() {
    // from 参数为 nil，会自动获取当前显示的 ViewController
    let success = ModuleManager.shared.presentPage(
        UserModule.self,
        parameters: ["isLogin": true],  // 标记为登录页
        from: nil,  // 自动获取当前控制器
        animated: true
    )
    
    if success {
        print("✅ 登录页已弹出")
    }
}
```

---

### 示例 5：完整的交互示例

```swift
class ProductListViewController: UIViewController {
    
    @objc private func showProductDetail(productId: String) {
        // 弹出商品详情，带完成回调
        ModuleManager.shared.presentPage(
            ProductModule.self,
            parameters: ["productId": productId],
            from: self,
            animated: true,
            completion: { [weak self] in
                // 页面弹出后的回调
                print("✅ 商品详情已显示")
                
                // 可以在这里做一些额外操作
                self?.trackPageView(page: "ProductDetail")
            }
        )
    }
    
    private func trackPageView(page: String) {
        print("📊 埋点：页面浏览 - \(page)")
    }
}
```

---

### 示例 6：错误处理

```swift
@objc private func openUserProfile() {
    let success = ModuleManager.shared.presentPage(
        UserModule.self,
        parameters: ["userId": "999"],
        from: self,
        animated: true
    )
    
    if !success {
        // 失败原因可能：
        // 1. 模块未注册
        // 2. 创建 ViewController 失败
        // 3. 没有源 ViewController
        
        let alert = UIAlertController(
            title: "提示",
            message: "无法打开用户资料，请稍后重试",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
}
```

---

## 🔄 与 openPage 的区别

### openPage（Push 方式）

```swift
// Push 到导航栈
ModuleManager.shared.openPage(
    UserModule.self,
    parameters: ["userId": "123"],
    from: self,
    animated: true
)
// 结果：页面被 push 到导航栈，可以通过返回按钮返回
```

### presentPage（Present 方式）

```swift
// 模态弹出
ModuleManager.shared.presentPage(
    UserModule.self,
    parameters: ["userId": "123"],
    from: self,
    animated: true
)
// 结果：页面以模态方式弹出，自动包装在 NavigationController 中
// 需要手动关闭（dismiss）
```

---

## 🎨 完整演示控制器

```swift
import UIKit

class ModuleManagerDemoViewController: UIViewController {
    
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "ModuleManager 演示"
        view.backgroundColor = .systemBackground
        
        setupUI()
    }
    
    private func setupUI() {
        // 设置 ScrollView
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        // 设置 StackView
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40)
        ])
        
        // 添加演示按钮
        addDemoButton(title: "1️⃣ Present 用户列表", action: #selector(demo1))
        addDemoButton(title: "2️⃣ Present 用户详情（带参数）", action: #selector(demo2))
        addDemoButton(title: "3️⃣ Present 商品列表（协议类型）", action: #selector(demo3))
        addDemoButton(title: "4️⃣ Present 登录页（自动获取源）", action: #selector(demo4))
        addDemoButton(title: "5️⃣ Present 商品详情（带回调）", action: #selector(demo5))
    }
    
    private func addDemoButton(title: String, action: Selector) {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 12
        button.contentEdgeInsets = UIEdgeInsets(top: 16, left: 20, bottom: 16, right: 20)
        button.addTarget(self, action: action, for: .touchUpInside)
        stackView.addArrangedSubview(button)
    }
    
    // MARK: - 演示方法
    
    @objc private func demo1() {
        print("\n🎬 演示1：Present 用户列表")
        
        let success = ModuleManager.shared.presentPage(
            UserModule.self,
            parameters: [:],
            from: self,
            animated: true
        )
        
        print(success ? "✅ 成功" : "❌ 失败")
    }
    
    @objc private func demo2() {
        print("\n🎬 演示2：Present 用户详情（带参数）")
        
        let success = ModuleManager.shared.presentPage(
            UserModule.self,
            parameters: ["userId": "12345"],
            from: self,
            animated: true,
            completion: {
                print("✅ 页面弹出动画完成")
            }
        )
        
        print(success ? "✅ 成功" : "❌ 失败")
    }
    
    @objc private func demo3() {
        print("\n🎬 演示3：Present 商品列表（协议类型）")
        
        // ⭐ 使用协议类型，实现解耦
        let success = ModuleManager.shared.presentPage(
            ProductModuleProtocol.self,
            parameters: ["category": "手机"],
            from: self,
            animated: true
        )
        
        print(success ? "✅ 成功" : "❌ 失败")
    }
    
    @objc private func demo4() {
        print("\n🎬 演示4：Present 登录页（自动获取源）")
        
        let success = ModuleManager.shared.presentPage(
            UserModule.self,
            parameters: ["isLogin": true],
            from: nil,  // 自动获取当前控制器
            animated: true
        )
        
        print(success ? "✅ 成功" : "❌ 失败")
    }
    
    @objc private func demo5() {
        print("\n🎬 演示5：Present 商品详情（带回调）")
        
        let success = ModuleManager.shared.presentPage(
            ProductModule.self,
            parameters: ["productId": "iPhone15"],
            from: self,
            animated: true,
            completion: { [weak self] in
                print("✅ 页面弹出完成")
                self?.trackEvent("ProductDetailPresented")
            }
        )
        
        print(success ? "✅ 成功" : "❌ 失败")
    }
    
    private func trackEvent(_ event: String) {
        print("📊 埋点：\(event)")
    }
}
```

---

## 🔍 内部实现逻辑

```swift
func presentPage<T: PageModuleProtocol>(
    _ moduleType: T.Type,
    parameters: [String: Any] = [:],
    from source: UIViewController? = nil,
    animated: Bool = true,
    completion: (() -> Void)? = nil
) -> Bool {
    
    print("📤 弹出页面：\(moduleType.moduleName)")
    
    // 1️⃣ 获取模块实例
    guard let module = self.module(moduleType) else {
        print("❌ 获取模块失败")
        return false
    }
    
    // 2️⃣ 创建 ViewController
    guard let destination = module.createViewController(with: parameters) else {
        print("❌ 创建页面失败")
        return false
    }
    
    // 3️⃣ 获取源 ViewController
    let sourceVC = source ?? Router.shared.currentViewController()
    guard let sourceVC = sourceVC else {
        print("❌ 没有源 ViewController")
        return false
    }
    
    // 4️⃣ 包装在 NavigationController 中
    let navController = UINavigationController(rootViewController: destination)
    
    // 5️⃣ 执行 Present
    sourceVC.present(navController, animated: animated, completion: completion)
    
    print("✅ Present 跳转成功")
    return true
}
```

---

## 📋 使用场景

### 适合 presentPage 的场景：
- ✅ 登录/注册页面
- ✅ 设置页面
- ✅ 图片/视频预览
- ✅ 表单填写页面
- ✅ 独立的功能模块（不需要导航栈）

### 适合 openPage 的场景：
- ✅ 列表 → 详情
- ✅ 需要返回按钮的页面
- ✅ 多层级导航
- ✅ 需要保持导航栈的场景

---

## 🎯 最佳实践

### 1. 使用协议类型（推荐）

```swift
// ✅ 好：使用协议类型，解耦
ModuleManager.shared.presentPage(
    UserModuleProtocol.self,
    parameters: ["userId": "123"]
)

// ❌ 避免：直接依赖具体类（除非在主工程中）
ModuleManager.shared.presentPage(
    UserModule.self,
    parameters: ["userId": "123"]
)
```

### 2. 错误处理

```swift
let success = ModuleManager.shared.presentPage(...)
if !success {
    // 处理失败情况
    showErrorAlert()
}
```

### 3. 使用完成回调

```swift
ModuleManager.shared.presentPage(
    UserModule.self,
    parameters: [:],
    completion: {
        // 页面弹出后执行
        self.refreshData()
    }
)
```

---

## 🚀 快速测试

在任意 ViewController 中添加：

```swift
override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    // 延迟1秒后自动弹出用户列表
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
        ModuleManager.shared.presentPage(
            UserModule.self,
            parameters: [:],
            from: self,
            animated: true
        )
    }
}
```

---

## 📚 相关文档

- [ModuleManager 完整文档](./模块间通信完整方案.md)
- [协议路由快速测试指南](./协议路由快速测试指南.md)
- [模块化架构设计](./CocoaPods组件化架构图.md)

---

**更新时间：** 2025年10月20日  
**版本：** v1.0
