# Router 路由框架演示

## ✅ 演示已完成

Router 路由框架演示已经创建，包含完整的交互式演示和示例页面！

---

## 📱 演示界面

```
┌────────────────────────────────────┐
│ < Router 路由演示                  │
├────────────────────────────────────┤
│  日志显示区域                       │
│  [10:30:45] ✅ Router 演示已启动    │
│  [10:30:45] 📝 路由已注册完成       │
├────────────────────────────────────┤
│  📦 基础路由                        │
│  [Push：用户详情页]                 │
│  [Present：设置页面]                │
│                                    │
│  🚀 高级功能                        │
│  [带参数：商品详情]                 │
│  [Query参数：搜索]                  │
│                                    │
│  🔒 拦截器演示                      │
│  [测试拦截器（会拦截）]             │
│  [移除拦截器（可通过）]             │
│                                    │
│  [清除日志]                         │
└────────────────────────────────────┘
```

---

## 🎯 演示功能

### 1. 📦 基础路由

#### Push 跳转
```
点击 [Push：用户详情页]

执行路由：app://user/12345
  ↓
URL 匹配：app://user/:userId
  ↓
提取参数：userId = 12345
  ↓
创建 ViewController
  ↓
Push 跳转 →  用户详情页
```

#### Present 模态弹出
```
点击 [Present：设置页面]

执行路由：app://settings
  ↓
匹配路由，action = .present
  ↓
创建 NavigationController
  ↓
Present 弹出 →  设置页面
```

---

### 2. 🚀 高级功能

#### 路径参数 + Query 参数
```
点击 [带参数：商品详情]

URL：app://product/8888?name=iPhone&price=5999
  ↓
匹配模式：app://product/:productId
  ↓
提取参数：
  - productId = 8888 (路径参数)
  - name = iPhone (Query参数)
  - price = 5999 (Query参数)
  ↓
商品详情页显示所有参数
```

#### Query 参数解析
```
点击 [Query参数：搜索]

URL：app://search?keyword=Swift&page=1
  ↓
解析参数：
  - keyword = Swift
  - page = 1
  ↓
搜索页面显示搜索结果
```

---

### 3. 🔒 拦截器演示

#### 添加拦截器
```
点击 [测试拦截器（会拦截）]

步骤：
1. 添加拦截器（拦截 VIP 页面）
2. 尝试打开 app://vip/888
3. 被拦截，跳转失败

日志输出：
[10:00] 📤 添加拦截器：拦截 VIP 页面
[10:00] 📤 尝试打开：app://vip/888
[10:00] ⛔ 拦截器触发：需要VIP权限
[10:00] ❌ 被拦截了
```

#### 移除拦截器
```
点击 [移除拦截器（可通过）]

步骤：
1. 移除所有拦截器
2. 再次尝试打开 app://vip/888
3. 成功跳转

日志输出：
[10:00] 📤 移除所有拦截器
[10:00] 📤 尝试打开：app://vip/888
[10:00] ✅ 跳转成功（无拦截）
```

---

## 💻 已注册的路由

### 路由表
```swift
1. app://user/:userId
   - 用户详情页
   - Push 跳转
   - 参数：userId

2. app://settings
   - 设置页面
   - Present 模态弹出
   - 无参数

3. app://product/:productId
   - 商品详情页
   - Push 跳转
   - 参数：productId, name, price (Query)

4. app://search
   - 搜索页面
   - Push 跳转
   - 参数：keyword, page (Query)

5. app://vip/:vipId
   - VIP 会员页
   - Push 跳转
   - 参数：vipId
   - 用于演示拦截器
```

---

## 🔍 核心技术演示

### 1. URL 模式匹配

```
URL Pattern：app://user/:userId
Real URL：   app://user/12345

匹配过程：
1. 分割路径：[user, :userId] vs [user, 12345]
2. 逐个比对：
   - user == user ✅
   - :userId 是占位符，提取 userId=12345 ✅
3. 匹配成功，返回参数 {"userId": "12345"}
```

### 2. 参数合并

```
URL：app://product/8888?name=iPhone&price=5999

提取到的参数：
1. 路径参数：{"productId": "8888"}
2. Query参数：{"name": "iPhone", "price": "5999"}
3. 代码参数：{} (本例为空)

合并后：
{"productId": "8888", "name": "iPhone", "price": "5999"}
```

### 3. 拦截器机制

```swift
Router.shared.addInterceptor { request in
    // 检查 URL
    if request.url.absoluteString.contains("vip") {
        print("需要 VIP 权限")
        return false  // 拦截
    }
    return true  // 通过
}

// 应用场景：
- 登录验证
- 权限检查
- 埋点统计
- 参数校验
```

---

## 🎤 面试要点

### Q1: 为什么需要路由？

**A: 解决模块间解耦问题**

```
传统方式：
import UserModule
let vc = UserDetailViewController()
vc.userId = "123"
navigationController?.push(vc)
❌ 模块紧耦合

路由方式：
Router.shared.open("app://user/123")
✅ 通过 URL 解耦
✅ 模块间零依赖
✅ 支持外部唤起
```

### Q2: URL-Based vs Protocol-Based？

**A: 各有优势，通常结合使用**

| 特性 | URL-Based | Protocol-Based |
|------|-----------|----------------|
| 类型安全 | ❌ | ✅ |
| 外部唤起 | ✅ | ❌ |
| 编译检查 | ❌ | ✅ |
| 灵活性 | ✅ | ❌ |
| 配置化 | ✅ | ❌ |

### Q3: 拦截器有什么用？

**A: 统一处理横切关注点**

```
应用场景：
1. 登录验证 - 未登录跳转登录页
2. 权限检查 - 无权限显示提示
3. 埋点统计 - 统一记录页面跳转
4. 参数校验 - 验证参数有效性

优势：
✅ 集中管理
✅ 避免重复代码
✅ 易于维护
```

### Q4: 如何处理参数传递？

**A: 三种参数来源，自动合并**

```swift
// 1. 路径参数
app://user/:userId → userId=123

// 2. Query 参数
?name=张三&age=25 → name=张三, age=25

// 3. 代码参数
parameters: ["vip": true]

// 自动合并（后者覆盖前者）
{"userId": "123", "name": "张三", "age": 25, "vip": true}
```

---

## 🚀 运行步骤

### 1. 打开项目
```bash
open jiagou.xcodeproj
```

### 2. 运行（⌘ + R）

### 3. 导航到 Router 演示
```
主页 → 点击"路由框架"卡片 → 进入演示页面
```

### 4. 测试功能
- 点击各个按钮
- 观察页面跳转
- 查看日志输出
- 体验拦截器

---

## 📊 测试场景

### 场景1：基础跳转
```
点击 [Push：用户详情页]
→ Push 到用户详情页
→ 显示 "用户 ID：12345"
→ 点击返回按钮
→ 回到演示页面
```

### 场景2：模态弹出
```
点击 [Present：设置页面]
→ 模态弹出设置页
→ 点击"完成"按钮
→ 关闭模态，回到演示页面
```

### 场景3：参数传递
```
点击 [带参数：商品详情]
→ Push 到商品详情页
→ 显示商品 ID、名称、价格
→ 验证参数正确传递
```

### 场景4：Query 参数
```
点击 [Query参数：搜索]
→ Push 到搜索页
→ 显示关键词和页码
→ 验证 Query 参数解析
```

### 场景5：拦截器
```
点击 [测试拦截器]
→ 添加拦截器
→ 尝试打开 VIP 页面
→ 被拦截，跳转失败
→ 查看日志：⛔ 拦截器触发

点击 [移除拦截器]
→ 移除拦截器
→ 再次打开 VIP 页面
→ 成功跳转
→ 查看日志：✅ 跳转成功
```

---

## 💡 代码亮点

### 1. 完整的演示系统
```swift
// 演示主页
class RouterDemoViewController

// 示例页面
- RouteUserDetailViewController (用户详情)
- RouteSettingsViewController (设置)
- RouteProductViewController (商品)
- RouteSearchViewController (搜索)
- RouteVIPViewController (VIP)
```

### 2. Routable 协议
```swift
protocol Routable {
    static func instantiate(with parameters: [String: Any]) -> Self?
}

// 实现示例
class RouteUserDetailViewController: UIViewController, Routable {
    static func instantiate(with parameters: [String: Any]) -> Self? {
        let vc = Self()
        vc.userId = parameters["userId"] as? String
        return vc
    }
}
```

### 3. 实时日志
```swift
// 所有路由操作都有日志
[10:30:45] 📤 打开：app://user/12345
[10:30:45] ✅ 跳转成功

[10:30:50] 📤 打开：app://vip/888
[10:30:50] ⛔ 拦截器触发：需要VIP权限
[10:30:50] ❌ 被拦截了
```

---

## 🎯 学习要点

### 1. URL 模式设计
```swift
// ✅ 良好的设计
app://user/:userId
app://product/:productId/detail
app://shop/category/:categoryId

// ❌ 不好的设计
app://showUser?id=123
app://page1
```

### 2. 参数传递方式
```swift
// 方式1：路径参数（推荐）
app://user/:userId → /user/123

// 方式2：Query 参数（可选信息）
app://search?keyword=iPhone&page=1

// 方式3：代码参数（复杂对象）
Router.open("app://user/123", parameters: ["user": userObject])
```

### 3. 跳转方式选择
```swift
// Push - 页面栈
.push → 导航栏 push

// Present - 模态弹出
.present → 模态显示

// Replace - 替换
.replace → 替换当前页

// Custom - 自定义
.custom { source, dest, animated in
    // 自定义跳转逻辑
}
```

---

## 📚 使用示例

### 示例1：注册路由
```swift
// AppDelegate.swift
func application(...) -> Bool {
    registerRoutes()
    return true
}

func registerRoutes() {
    // 方式1：使用 Routable 协议
    Router.shared.register(
        "app://user/:userId",
        viewControllerType: UserDetailViewController.self
    )
    
    // 方式2：使用闭包
    Router.shared.register("app://settings", action: .present) { _ in
        let vc = SettingsViewController()
        return UINavigationController(rootViewController: vc)
    }
}
```

### 示例2：打开页面
```swift
// 基础使用
Router.shared.open("app://user/123")

// 带参数
Router.shared.open("app://product/456?name=iPhone")

// 带回调
Router.shared.open("app://user/123") {
    print("页面已打开")
}

// UIViewController 扩展
self.open("app://user/123")
```

### 示例3：拦截器
```swift
// 登录验证拦截器
Router.shared.addInterceptor { request in
    if request.url.path.contains("/user/") {
        let isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
        if !isLoggedIn {
            Router.shared.open("app://login")
            return false  // 拦截
        }
    }
    return true  // 通过
}

// 埋点统计拦截器
Router.shared.addInterceptor { request in
    Analytics.track("page_view", url: request.url)
    return true
}
```

---

## 🎤 面试演示建议

### 演示流程（5分钟）

**第1分钟：介绍背景**
```
"这是我实现的 URL-Based 路由框架"
"用于解决模块间页面跳转的解耦问题"
"支持 URL 匹配、参数传递、拦截器等功能"
```

**第2分钟：基础演示**
```
点击 [Push：用户详情页]
→ "URL 是 app://user/12345"
→ "匹配模式 app://user/:userId"
→ "自动提取参数 userId=12345"
→ 进入页面
```

**第3分钟：高级功能**
```
点击 [带参数：商品详情]
→ "URL 包含路径参数和 Query 参数"
→ "自动合并参数"
→ 进入页面，展示所有参数
```

**第4分钟：拦截器**
```
点击 [测试拦截器]
→ "添加了权限验证拦截器"
→ "尝试打开 VIP 页面被拦截"
→ 查看日志

点击 [移除拦截器]
→ "移除拦截器后成功跳转"
```

**第5分钟：总结**
```
"路由框架的核心价值：解耦"
"支持外部 URL 唤起"
"统一的跳转入口和拦截控制"
```

---

## 🔍 核心代码讲解

### URL 匹配算法
```swift
// 输入
urlPath = "/user/123"
patternPath = "/user/:userId"

// 处理
let urlComponents = ["user", "123"]
let patternComponents = ["user", ":userId"]

// 匹配
for (urlComp, patternComp) in zip(...) {
    if patternComp.hasPrefix(":") {
        // 提取参数
        parameters["userId"] = "123"
    } else if urlComp != patternComp {
        // 不匹配
        return nil
    }
}

// 结果
{"userId": "123"}
```

### 拦截器链
```swift
// 注册多个拦截器
Router.shared.addInterceptor(interceptor1)
Router.shared.addInterceptor(interceptor2)

// 执行顺序（任一返回 false 则终止）
interceptor1 → true → 继续
interceptor2 → false → 终止，不跳转
```

---

## 📦 文件清单

### 核心代码
- ✅ `Router.swift` - 路由框架核心
- ✅ `RouterExample.swift` - 基础示例
- ✅ `RouterDemoViewController.swift` - 完整演示（新增）

### 示例页面
- ✅ `RouteUserDetailViewController` - 用户详情
- ✅ `RouteSettingsViewController` - 设置
- ✅ `RouteProductViewController` - 商品
- ✅ `RouteSearchViewController` - 搜索
- ✅ `RouteVIPViewController` - VIP

### 文档
- ✅ `路由框架说明.md` - 详细文档
- ✅ `Router演示说明.md` - 本文档

---

## 🚀 扩展方向

### 可添加的演示

1. **Replace 跳转**
   ```swift
   Router.shared.register("app://replace", action: .replace) { _ in
       return ReplaceViewController()
   }
   ```

2. **自定义转场动画**
   ```swift
   Router.shared.register("app://fancy", action: .custom { source, dest, animated in
       // 自定义转场动画
       dest.modalPresentationStyle = .custom
       source.present(dest, animated: animated)
   })
   ```

3. **路由回调**
   ```swift
   Router.shared.open("app://edit") {
       print("编辑页面已打开")
   }
   ```

4. **外部 URL 处理**
   ```swift
   // AppDelegate
   func application(_ app: UIApplication, open url: URL) -> Bool {
       // myapp://user/123
       return Router.shared.open(url)
   }
   ```

---

## ✅ 完成清单

- [x] 创建 RouterDemoViewController
- [x] 创建 5 个示例页面
- [x] 实现日志显示
- [x] 添加 6 个测试按钮
- [x] 注册所有路由
- [x] 演示拦截器功能
- [x] 更新 HomeViewController
- [x] 创建说明文档
- [x] 无编译错误

---

## 💡 总结

### 实现的功能
✅ **完整的演示系统** - 交互式按钮 + 实时日志  
✅ **URL 匹配演示** - 路径参数提取  
✅ **参数传递演示** - Query 参数解析  
✅ **拦截器演示** - 添加/移除拦截器  
✅ **多种跳转方式** - Push / Present  
✅ **5 个示例页面** - 完整的路由生态  

### 技术亮点
⭐ URL 模式匹配算法  
⭐ 参数自动提取和合并  
⭐ 拦截器链式执行  
⭐ Routable 协议解耦  
⭐ 实时日志展示  

### 面试价值
🎯 展示路由架构设计能力  
🎯 理解组件化方案  
🎯 掌握解耦技术  
🎯 实践设计模式  

---

**Router 演示已完成，立即运行体验！🗺️**

**从主页点击"路由框架"即可进入！🚀**


