# presentPage 快速参考卡片

## 🚀 一行代码弹出页面

```swift
ModuleManager.shared.presentPage(UserModule.self)
```

---

## 📋 完整参数

```swift
ModuleManager.shared.presentPage(
    UserModule.self,              // 模块类型
    parameters: ["userId": "123"], // 参数
    from: self,                    // 源控制器
    animated: true,                // 动画
    completion: { print("完成") }  // 回调
)
```

---

## 💡 5个常用场景

### 1️⃣ 基础弹出
```swift
ModuleManager.shared.presentPage(UserModule.self)
```

### 2️⃣ 传递参数
```swift
ModuleManager.shared.presentPage(
    UserModule.self,
    parameters: ["userId": "12345"]
)
```

### 3️⃣ 使用协议（推荐⭐）
```swift
ModuleManager.shared.presentPage(
    ProductModuleProtocol.self,
    parameters: ["category": "手机"]
)
```

### 4️⃣ 自动获取源
```swift
ModuleManager.shared.presentPage(
    UserModule.self,
    from: nil  // 自动获取
)
```

### 5️⃣ 带完成回调
```swift
ModuleManager.shared.presentPage(
    ProductModule.self,
    completion: {
        print("页面已弹出")
    }
)
```

---

## 🔄 Present vs Push

| 特性 | presentPage | openPage |
|------|-------------|----------|
| 方式 | 模态弹出 | 导航栈Push |
| 返回 | 需手动dismiss | 自动返回按钮 |
| 导航栏 | 自动包装 | 使用现有 |
| 场景 | 登录、设置 | 列表→详情 |

---

## ✅ 返回值处理

```swift
let success = ModuleManager.shared.presentPage(...)

if success {
    print("✅ 成功")
} else {
    print("❌ 失败")
    // 可能原因：
    // - 模块未注册
    // - 创建失败
    // - 无源控制器
}
```

---

## 🎯 最佳实践

✅ **推荐**
```swift
// 使用协议类型
ModuleManager.shared.presentPage(
    UserModuleProtocol.self
)
```

❌ **避免**
```swift
// 直接依赖具体类
import UserModule
ModuleManager.shared.presentPage(
    UserModule.self
)
```

---

## 📱 快速测试

在任意 ViewController 中：

```swift
override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    // 1秒后自动弹出
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
        ModuleManager.shared.presentPage(
            UserModule.self,
            from: self
        )
    }
}
```

---

## 🔍 调试技巧

### 查看已注册模块
```swift
ModuleManager.shared.printAllModules()
```

### 输出示例
```
📊 已注册的模块（共 2 个）：
  - UserModule ✅
  - ProductModule ✅
```

---

## 📚 相关文档

- [完整演示](./ModuleManager演示示例.md)
- [模块通信方案](./模块间通信完整方案.md)
- [协议路由指南](./协议路由快速测试指南.md)
