# ModuleManager 快速使用指南

## 🚀 如何访问演示

### 方法1：从主页进入（推荐）

1. 运行项目 (⌘R)
2. 在主页滚动到底部
3. 点击 **"ModuleManager 演示"** 卡片
4. 进入交互式演示页面

### 方法2：直接代码跳转

在任意 ViewController 中：

```swift
let demoVC = ModuleManagerDemoViewController()
navigationController?.pushViewController(demoVC, animated: true)
```

---

## 📱 演示页面功能

### 📤 presentPage 演示（5个）

| 按钮 | 功能 | 演示内容 |
|------|------|----------|
| 1️⃣ Present 用户列表 | 基础用法 | 最简单的弹出方式 |
| 2️⃣ Present 用户详情 | 传递参数 | 如何传递 userId 等参数 |
| 3️⃣ Present 商品列表 | 使用协议类型⭐ | 通过协议解耦，无需 import |
| 4️⃣ Present 登录页 | 自动获取源 | from: nil 自动获取当前控制器 |
| 5️⃣ Present 商品详情 | 带完成回调 | completion 回调的使用 |

### 🔄 openPage 演示（2个）

| 按钮 | 功能 | 演示内容 |
|------|------|----------|
| 6️⃣ Push 用户列表 | 导航栈 Push | Push 方式跳转 |
| 7️⃣ Push 商品详情 | 带参数 Push | Push + 参数传递 |

### 📊 调试工具（1个）

| 按钮 | 功能 | 输出内容 |
|------|------|----------|
| 📋 查看已注册模块 | 打印模块列表 | 显示所有已注册的模块及实例状态 |

---

## 🎯 每个演示的学习要点

### 演示1：Present 用户列表
**学习要点：** 最基础的用法
```swift
ModuleManager.shared.presentPage(
    UserModule.self,
    from: self
)
```
- ✅ 模态弹出
- ✅ 自动包装 NavigationController
- ✅ 需要手动 dismiss

---

### 演示2：Present 用户详情
**学习要点：** 参数传递
```swift
ModuleManager.shared.presentPage(
    UserModule.self,
    parameters: ["userId": "12345"],
    completion: {
        print("✅ 页面弹出完成")
    }
)
```
- ✅ 通过 parameters 传递数据
- ✅ completion 回调
- ✅ 模块内部根据参数创建不同页面

---

### 演示3：Present 商品列表 ⭐
**学习要点：** 使用协议类型（最重要）
```swift
ModuleManager.shared.presentPage(
    ProductModuleProtocol.self,  // 协议类型
    parameters: ["category": "手机"]
)
```
- ✅ **解耦**：无需 import ProductModule
- ✅ **类型安全**：编译时检查
- ✅ **适合组件化**：模块间通过协议通信

**为什么重要？**
- 在大型项目中，各个模块是独立的 Pod
- 模块A不应该依赖模块B的具体实现
- 只需要依赖协议定义（ModuleProtocols Pod）

---

### 演示4：Present 登录页
**学习要点：** 自动获取源控制器
```swift
ModuleManager.shared.presentPage(
    UserModule.self,
    parameters: ["isLogin": true],
    from: nil  // 自动获取
)
```
- ✅ from: nil 会自动查找当前显示的 ViewController
- ✅ 适合在工具类、Manager 中调用
- ✅ 不需要传递 self

---

### 演示5：Present 商品详情
**学习要点：** 完成回调的使用
```swift
ModuleManager.shared.presentPage(
    ProductModule.self,
    parameters: ["productId": "iPhone15"],
    completion: { [weak self] in
        print("✅ 页面弹出完成")
        self?.trackEvent("ProductDetailPresented")
    }
)
```
- ✅ 在页面弹出后执行额外操作
- ✅ 适合埋点、刷新数据等场景
- ✅ 注意使用 [weak self] 避免循环引用

---

### 演示6：Push 用户列表
**学习要点：** Push vs Present
```swift
ModuleManager.shared.openPage(
    UserModule.self,
    from: self
)
```
- ✅ Push 到导航栈
- ✅ 自动显示返回按钮
- ✅ 适合列表→详情等场景

---

### 演示7：Push 商品详情
**学习要点：** Push + 参数
```swift
ModuleManager.shared.openPage(
    ProductModule.self,
    parameters: ["productId": "999"]
)
```
- ✅ Push 方式传递参数
- ✅ 保持导航栈连续性

---

## 📊 查看已注册模块

点击 **"📋 查看已注册模块"** 按钮，控制台输出：

```
📊 已注册的模块（共 2 个）：
  - UserModule ✅
  - ProductModule ✅
```

- ✅ 表示已创建实例（单例）
- ⭕ 表示已注册但未创建实例

---

## 🎓 学习路径

### 初学者
1. 先看 **演示1** - 了解基础用法
2. 再看 **演示2** - 学习参数传递
3. 对比 **演示6** - 理解 Present vs Push

### 进阶
4. 重点学习 **演示3** ⭐ - 协议类型（最重要）
5. 学习 **演示4** - 自动获取源
6. 学习 **演示5** - 完成回调

### 实战
7. 查看控制台日志，理解执行流程
8. 修改参数，观察不同效果
9. 在自己的项目中应用

---

## 💡 实战技巧

### 1. 错误处理
```swift
let success = ModuleManager.shared.presentPage(...)
if !success {
    // 处理失败情况
    showAlert(title: "错误", message: "无法打开页面")
}
```

### 2. 协议类型优先
```swift
// ✅ 推荐：使用协议
ModuleManager.shared.presentPage(ProductModuleProtocol.self)

// ❌ 避免：直接依赖具体类
ModuleManager.shared.presentPage(ProductModule.self)
```

### 3. 查看日志
每次调用都会输出详细日志：
```
🎬 演示3：Present 商品列表（协议类型）⭐
代码：ModuleManager.shared.presentPage(ProductModuleProtocol.self, ...)
💡 使用协议类型，实现解耦，无需 import ProductModule
📤 弹出页面：ProductModuleProtocol
📦 创建模块实例：ProductModule
✅ Present 跳转成功
✅ 成功
```

---

## 🔍 调试技巧

### 问题：页面没有弹出

**检查清单：**
1. ✅ 模块是否已注册？
   ```swift
   ModuleManager.shared.printAllModules()
   ```

2. ✅ 是否有 NavigationController？
   ```swift
   print(navigationController)  // 不应该是 nil
   ```

3. ✅ 模块是否实现了 PageModuleProtocol？
   ```swift
   // 确保模块遵循 PageModuleProtocol
   class UserModule: UserModuleProtocol { ... }
   protocol UserModuleProtocol: PageModuleProtocol { ... }
   ```

---

## 📚 相关文档

- [ModuleManager演示示例.md](./ModuleManager演示示例.md) - 完整代码示例
- [presentPage快速参考.md](./presentPage快速参考.md) - 快速参考卡片
- [模块间通信完整方案.md](./模块间通信完整方案.md) - 架构设计
- [协议路由快速测试指南.md](./协议路由快速测试指南.md) - 测试指南

---

## 🎯 快速测试代码

### 在任意 ViewController 中测试

```swift
import UIKit

class TestViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 添加测试按钮
        let button = UIButton(type: .system)
        button.setTitle("测试 ModuleManager", for: .normal)
        button.frame = CGRect(x: 100, y: 200, width: 200, height: 44)
        button.addTarget(self, action: #selector(testModuleManager), for: .touchUpInside)
        view.addSubview(button)
    }
    
    @objc private func testModuleManager() {
        // 测试 presentPage
        ModuleManager.shared.presentPage(
            UserModuleProtocol.self,
            parameters: ["userId": "test123"],
            from: self,
            completion: {
                print("✅ 测试成功")
            }
        )
    }
}
```

---

## ✅ 总结

### 核心概念
1. **presentPage** - 模态弹出页面
2. **openPage** - Push 到导航栈
3. **协议类型** - 解耦模块依赖
4. **参数传递** - 通过 parameters 字典
5. **完成回调** - completion 闭包

### 最佳实践
- ✅ 优先使用协议类型
- ✅ 处理返回值（成功/失败）
- ✅ 使用 [weak self] 避免循环引用
- ✅ 查看控制台日志调试

### 适用场景
- ✅ 模块化大型项目
- ✅ 组件化架构（CocoaPods）
- ✅ 需要解耦的业务模块
- ✅ 动态页面跳转

---

**更新时间：** 2025年10月20日  
**版本：** v1.0  
**状态：** ✅ 已添加到主页，可直接访问
