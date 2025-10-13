# 如何运行 EventBus 演示

## ✅ 已完成的集成

EventBus 演示已经集成到现有的下载管理器项目中！

---

## 🚀 运行步骤

### 1. 打开项目
```bash
cd /Users/tangyumeng/Documents/ios-learn/jiagou
open jiagou.xcodeproj
```

### 2. 运行项目
```bash
⌘ + R (Command + R)
```

### 3. 打开 EventBus 演示
在下载管理器页面，点击右上角的 **"EventBus"** 按钮

```
┌─────────────────────────────────┐
│ < 多任务下载器    [EventBus] [+] │  ← 点击这里
├─────────────────────────────────┤
│  任务列表...                     │
│                                 │
└─────────────────────────────────┘
```

---

## 📱 界面布局

```
下载管理器页面：
┌─────────────────────────────────────┐
│ [清除已完成]  多任务下载器  [EventBus] [+] │
├─────────────────────────────────────┤
│  📄 file1.zip                        │
│  ▓▓▓▓▓░░░░░░░░░░ 45%                │
│  ⬇️ 1.2 MB/s                        │
│                                     │
│  📄 file2.pdf                        │
│  ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ 100%               │
│  ✅ 已完成                           │
└─────────────────────────────────────┘
           ↓ 点击 EventBus
┌─────────────────────────────────────┐
│ < EventBus 演示                      │
├─────────────────────────────────────┤
│  日志显示区域                         │
│  [10:30:45] ✅ EventBus 示例已启动    │
│  [10:30:45] 📝 已订阅所有事件         │
├─────────────────────────────────────┤
│  📦 下载事件                          │
│  [发布：下载完成事件]                 │
│  [发布：下载进度事件]                 │
│                                     │
│  🛒 订单事件                          │
│  [发布：订单创建事件]                 │
│  [发布：多个订单事件]                 │
│                                     │
│  🎨 主题事件                          │
│  [发布：主题切换事件]                 │
│                                     │
│  [清除日志]                          │
└─────────────────────────────────────┘
```

---

## 🎯 功能测试

### 1. 测试下载事件
- 点击 **"发布：下载完成事件"** 
- 观察日志输出：文件名、文件大小

### 2. 测试下载进度
- 点击 **"发布：下载进度事件"**
- 观察进度百分比变化

### 3. 测试订单事件
- 点击 **"发布：订单创建事件"**
- 观察订单信息：ID、商品、金额

### 4. 测试批量事件
- 点击 **"发布：多个订单事件"**
- 观察延迟发布效果（每隔 0.5 秒）

### 5. 测试主题切换
- 点击 **"发布：主题切换事件"**
- 观察界面颜色变化（深色/浅色）

---

## 📝 代码变更说明

### ViewController.swift 的变更

```swift
// 1. 添加了 EventBus 按钮
private lazy var eventBusButton: UIBarButtonItem = {
    return UIBarButtonItem(title: "EventBus", style: .plain, target: self, action: #selector(openEventBusDemo))
}()

// 2. 导航栏右侧改为按钮数组
navigationItem.rightBarButtonItems = [addButton, eventBusButton]

// 3. 添加了打开 EventBus 演示的方法
@objc private func openEventBusDemo() {
    let eventBusVC = EventBusExampleViewController()
    navigationController?.pushViewController(eventBusVC, animated: true)
}
```

### 新增文件

1. **EventBusExample.swift** - EventBus 完整演示代码
2. **EventBus使用说明.md** - 详细使用文档
3. **EventBus快速启动.md** - 快速启动指南

---

## 🔍 验证清单

运行前检查：
- [x] EventBusExample.swift 已添加到项目
- [x] ViewController.swift 已修改
- [x] 项目可以成功编译
- [x] 无编译错误

运行后检查：
- [ ] 下载管理器页面正常显示
- [ ] 右上角有 "EventBus" 按钮
- [ ] 点击按钮可以打开 EventBus 演示页面
- [ ] 演示页面显示日志区域和按钮
- [ ] 点击按钮有日志输出

---

## 💡 常见问题

### Q1: 找不到 EventBus 按钮？
**A:** 检查是否在 NavigationController 中，EventBus 按钮在导航栏右上角

### Q2: 点击按钮没反应？
**A:** 检查 EventBusExample.swift 是否已添加到项目 Target

### Q3: 编译错误？
**A:** 确保所有文件都已添加到正确的 Target，Clean Build Folder 后重新编译

### Q4: 找不到 EventBusExampleViewController？
**A:** 检查 EventBusExample.swift 是否在项目中，并且已勾选正确的 Target Membership

---

## 🎤 面试演示建议

### 演示流程（5分钟）

1. **介绍背景**（30秒）
   - "这是我实现的 EventBus 消息通信框架"
   - "用于解决模块间解耦通信问题"

2. **展示功能**（2分钟）
   - 点击"下载完成事件" → 展示类型安全的事件
   - 点击"多个订单事件" → 展示一对多通信
   - 点击"主题切换" → 展示实时响应

3. **讲解代码**（2分钟）
   - 打开 EventBus.swift → 讲解核心实现
   - 指出线程安全的处理
   - 指出内存管理（weak 引用）

4. **回答追问**（30秒）
   - EventBus vs NotificationCenter
   - 如何避免循环引用
   - 适用场景

---

## 📚 相关文档

- **EventBus.swift** - 核心实现（200行）
- **EventBusExample.swift** - 完整演示（500行）
- **EventBus使用说明.md** - 详细文档
- **EventBus快速启动.md** - 快速入门

---

## 🎉 总结

✅ **集成完成** - EventBus 演示已添加到项目  
✅ **一键启动** - 点击导航栏按钮即可打开  
✅ **功能完整** - 包含所有核心特性演示  
✅ **文档完善** - 提供详细的使用说明  

**立即运行项目，体验 EventBus 的强大功能！🚀**

---

## 🎯 下一步

### 可选扩展

1. **集成到下载管理器**
   ```swift
   // 在 DownloadManager 中发布事件
   EventBus.shared.post(DownloadCompletedEvent(...))
   ```

2. **添加更多事件**
   ```swift
   struct NetworkStatusEvent: Event { ... }
   struct UserLoginEvent: Event { ... }
   ```

3. **创建服务监听**
   ```swift
   class StatisticsService {
       init() {
           EventBus.shared.subscribe(...) { ... }
       }
   }
   ```

**现在就运行项目，开始你的 EventBus 之旅！💪**

