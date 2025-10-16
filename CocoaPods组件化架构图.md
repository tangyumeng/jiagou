# CocoaPods 组件化架构图

## 📊 架构演进

### 阶段 1：单体应用（❌ 无模块化）

```
┌─────────────────────────────┐
│         MyApp               │
├─────────────────────────────┤
│  UserManager (单例)         │
│  ProductManager (单例)      │
│  OrderManager (单例)        │
│  ...                        │
│                             │
│  问题：                      │
│  ❌ 紧耦合                   │
│  ❌ 难以测试                 │
│  ❌ 难以维护                 │
└─────────────────────────────┘
```

---

### 阶段 2：URL-Based Router（✅ 页面解耦）

```
┌─────────────────────────────┐
│         MyApp               │
├─────────────────────────────┤
│                             │
│    ┌──────────────┐         │
│    │  URL Router  │         │
│    └──────────────┘         │
│           ↕                 │
│    URL 字符串匹配            │
│           ↕                 │
│  ┌──────┐  ┌──────┐        │
│  │ 用户页│  │ 商品页│  ...   │
│  └──────┘  └──────┘        │
│                             │
│  优点：                      │
│  ✅ 页面解耦                 │
│  ✅ 支持外部唤起             │
│                             │
│  限制：                      │
│  ❌ 只能页面跳转             │
│  ❌ 无法模块间服务调用       │
│  ❌ 业务逻辑仍然耦合         │
└─────────────────────────────┘
```

---

### 阶段 3：Protocol-Based Router（✅ 完全组件化）

```
┌──────────────────────────────────────────┐
│            App 主工程                     │
│    (集成所有模块，注册到 ModuleManager)    │
└──────────────────────────────────────────┘
                    ↓ 依赖
┌──────────────────────────────────────────┐
│      ModuleProtocols Pod（协议层）        │
│  ┌─────────────────────────────────┐    │
│  │  Core/                          │    │
│  │  - ModuleProtocol.swift         │    │
│  │  - ModuleManager.swift          │    │
│  │                                 │    │
│  │  Protocols/                     │    │
│  │  - UserModuleProtocol.swift     │    │
│  │  - ProductModuleProtocol.swift  │    │
│  │                                 │    │
│  │  Models/                        │    │
│  │  - User.swift                   │    │
│  │  - Product.swift                │    │
│  └─────────────────────────────────┘    │
└──────────────────────────────────────────┘
         ↓                    ↓
    ┌─────────┐          ┌─────────┐
    │UserModule│          │ProductModule│
    │  Pod    │          │  Pod    │
    └─────────┘          └─────────┘
         ↕                    ↕
    通过协议调用 ← ─ ─ → 通过协议调用
    UserModuleProtocol    ProductModuleProtocol
```

---

## 🔄 通信机制详解

### 1. 注册阶段（App 启动时）

```
App 主工程：
├── import UserModule
├── import ProductModule
└── 注册模块：
    ModuleManager.shared.register(UserModule.self)
    ModuleManager.shared.register(ProductModule.self)

ModuleManager 内部：
modules = [
    "UserModule": UserModule.Type,      // 实现了 UserModuleProtocol
    "ProductModule": ProductModule.Type  // 实现了 ProductModuleProtocol
]
```

---

### 2. 获取模块阶段（运行时）

```
ProductModule 中：
│
├─ import ModuleProtocols  // ✅ 只导入协议层
│
├─ 调用：
│   let userModule = ModuleManager.shared.module(UserModuleProtocol.self)
│
└─ ModuleManager 内部执行：
    │
    ├─ 遍历 modules
    │
    ├─ 检查：UserModule.Type 是否实现 UserModuleProtocol？
    │   ↓
    │   ✅ 是的
    │
    ├─ 创建实例：UserModule()
    │
    └─ 返回：UserModule 实例（类型为 UserModuleProtocol）
```

---

### 3. 调用服务阶段

```
ProductModule:
│
├─ let user = userModule.getCurrentUser()
│   ↓
│   调用的是 UserModuleProtocol 协议方法
│   ↓
│   实际执行的是 UserModule.getCurrentUser()
│   ↓
│   返回 User 对象
│
└─ print("用户：\(user.name)")
```

---

## 📋 依赖关系表

| Pod | 依赖 | Import 语句 |
|-----|------|------------|
| **ModuleProtocols** | 无 | - |
| **UserModule** | ModuleProtocols | `import ModuleProtocols` |
| **ProductModule** | ModuleProtocols | `import ModuleProtocols` |
| **App 主工程** | 所有 | `import UserModule`<br>`import ProductModule` |

---

## 🎯 关键代码对比

### ❌ 错误方式（产生依赖）

```swift
// ProductModule.podspec
s.dependency 'UserModule'  // ❌ 依赖具体模块

// ProductModule.swift
import UserModule  // ❌ 导入具体模块

let userModule = UserModule.shared  // ❌ 直接使用具体类
```

### ✅ 正确方式（完全解耦）

```swift
// ProductModule.podspec
s.dependency 'ModuleProtocols'  // ✅ 只依赖协议层

// ProductModule.swift
import ModuleProtocols  // ✅ 只导入协议层

// ✅ 通过协议类型获取模块
let userModule = ModuleManager.shared.module(UserModuleProtocol.self)
```

---

## 💡 核心理解

### 为什么不需要 import UserModule？

```
1. UserModuleProtocol 定义在 ModuleProtocols 中
   ↓
2. ProductModule 导入了 ModuleProtocols
   ↓
3. 所以 ProductModule 可以使用 UserModuleProtocol 类型
   ↓
4. ModuleManager.shared.module(UserModuleProtocol.self)
   ↓
5. ModuleManager 负责查找实现了该协议的模块
   ↓
6. 返回实现类的实例（UserModule），但类型是 UserModuleProtocol
   ↓
7. ProductModule 只知道协议，不知道具体实现
```

### 类比

```
现实世界：
- 你需要打车（服务需求）
- 你只需要知道"司机"的能力（协议）：开车、导航
- 你不需要知道具体是哪个司机（实现）
- 滴滴平台（ModuleManager）帮你找到合适的司机

代码世界：
- ProductModule 需要用户服务
- ProductModule 只需要知道 UserModuleProtocol（协议）
- ProductModule 不需要知道 UserModule（具体实现）
- ModuleManager 帮你找到实现了该协议的模块
```

---

## ✅ 总结

### 模块间通信方式

**在 CocoaPods 组件化架构中，ProductModule 和 UserModule 通过以下方式通信：**

1. **抽取协议层**（ModuleProtocols Pod）
2. **定义接口协议**（UserModuleProtocol, ProductModuleProtocol）
3. **模块实现协议**（UserModule 实现 UserModuleProtocol）
4. **通过协议调用**（`ModuleManager.shared.module(UserModuleProtocol.self)`）
5. **完全解耦**（互不依赖）

### 核心代码

```swift
// ProductModule 调用 UserModule
let userModule = ModuleManager.shared.module(UserModuleProtocol.self)
let user = userModule?.getCurrentUser()

// UserModule 调用 ProductModule  
let productModule = ModuleManager.shared.module(ProductModuleProtocol.self)
productModule?.syncCart()
```

### 核心价值

🎯 **完全解耦** - 两个 Pod 零依赖  
🎯 **类型安全** - 通过协议约束  
🎯 **独立开发** - 并行开发不互相影响  
🎯 **独立测试** - 可 Mock 可替换  

---

**这就是大厂使用的组件化通信方案！协议层是关键！🚀**

