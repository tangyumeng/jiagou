# 目录结构

本项目代码已按功能模块重新组织，共33个Swift文件分布在以下目录中：

## 📂 目录说明

### Core/ (3个文件)
应用核心 - 启动和主页
- `AppDelegate.swift`
- `SceneDelegate.swift`
- `Home/HomeViewController.swift`

### Architecture/ (10个文件)
架构模式示例
- **MVVM/** - Model-View-ViewModel架构
- **MVP/** - Model-View-Presenter架构

### Frameworks/ (15个文件)
可复用的基础框架
- **Router/** - URL路由系统 (4个文件)
- **EventBus/** - 事件总线 (2个文件)
- **Logger/** - 日志框架 (2个文件)
- **DownloadManager/** - 下载管理器 (5个文件)
- **ImageLoader/** - 图片加载框架 (2个文件)

### Modules/ (5个文件)
业务模块
- 模块化管理和通信

### Resources/
资源文件
- `Assets.xcassets/` - 图片资源
- `Base.lproj/` - 本地化
- `Info.plist` - 配置

## 🔧 Xcode配置更新

**重要：** 文件移动后需要在Xcode中更新引用！

1. 打开项目：`open jiagou.xcodeproj`
2. 删除红色的文件引用
3. 右键 `jiagou` 组 → Add Files to "jiagou"
4. 选择新目录，勾选 "Create groups"
5. 更新 Info.plist 路径为 `jiagou/Resources/Info.plist`
6. Clean Build (⇧⌘K) → Build (⌘B)

详细说明请查看项目根目录的 `目录结构说明.md`
