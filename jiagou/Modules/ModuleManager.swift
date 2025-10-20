//
//  ModuleManager.swift
//  jiagou
//
//  模块管理器（中介者） - Protocol-Based Router
//

import UIKit

/// 模块管理器（Mediator 中介者模式）
class ModuleManager {
    
    // MARK: - 单例
    static let shared = ModuleManager()
    
    // MARK: - 属性
    
    /// 注册的模块类型
    private var modules: [String: ModuleProtocol.Type] = [:]
    
    /// 模块实例缓存（单例模式）
    private var instances: [String: ModuleProtocol] = [:]
    
    /// 线程安全队列
    private let queue = DispatchQueue(label: "com.jiagou.modulemanager", attributes: .concurrent)
    
    // MARK: - 初始化
    private init() {
        print("📦 ModuleManager 已初始化")
    }
    
    // MARK: - 注册模块
    
    /// 注册模块
    /// - Parameter moduleType: 模块类型（必须遵循 ModuleProtocol）
    func register<T: ModuleProtocol>(_ moduleType: T.Type) {
        let moduleName = moduleType.moduleName
        
        queue.async(flags: .barrier) { [weak self] in
            self?.modules[moduleName] = moduleType
            print("✅ 注册模块：\(moduleName)")
        }
    }
    
    /// 批量注册模块
    /// - Parameter moduleTypes: 模块类型数组
    func registerModules(_ moduleTypes: [ModuleProtocol.Type]) {
        for moduleType in moduleTypes {
            let moduleName = moduleType.moduleName  // ✅ 直接访问，不需要 type(of:)
            queue.async(flags: .barrier) { [weak self] in
                self?.modules[moduleName] = moduleType
                print("✅ 注册模块：\(moduleName)")
            }
        }
    }
    
    // MARK: - 获取模块
    
    /// 获取模块实例（单例，线程安全）
    /// - Parameter type: 模块类型或协议类型（例如 `UserModule.self` 或 `UserModuleProtocol.self`）
    /// - Returns: 模块实例，找不到则返回 nil
    /// 
    /// 使用示例：
    /// ```
    /// // 方式1：通过具体类型（在主工程中使用）
    /// let userModule = ModuleManager.shared.module(UserModule.self)
    /// 
    /// // 方式2：通过协议类型（在其他模块中使用，推荐⭐）
    /// let userModule = ModuleManager.shared.module(UserModuleProtocol.self)
    /// ```
    func module<T>(_ type: T.Type) -> T? {
        var result: T?
        
        queue.sync { [weak self] in
            guard let self = self else { return }
            
            // 遍历所有已注册的模块
            for (moduleName, moduleType) in self.modules {
                // 若注册的模块类型可转换为目标协议/类型
                if (moduleType as Any) is T.Type {
                    // 命中模块后，优先从缓存取实例
                    if let cached = self.instances[moduleName] as? T {
                        result = cached
                        return
                    }
                    
                    // 未命中缓存则创建实例（通过 ModuleProtocol.Type 构造）
                    let newInstance = moduleType.init()
                    self.instances[moduleName] = newInstance
                    result = newInstance as? T
                    print("📦 创建模块实例：\(moduleName)")
                    return
                }
            }
            
            // 未找到匹配的模块
            print("❌ 未找到实现 \(type) 协议的模块")
        }
        
        return result
    }
    
    // MARK: - 页面跳转
    
    /// 打开页面（Push）
    /// - Parameters:
    ///   - moduleType: 模块类型或协议类型（例如 `ProductModule.self` 或 `ProductModuleProtocol.self`）
    ///   - parameters: 参数字典
    ///   - source: 源 ViewController
    ///   - animated: 是否动画
    /// - Returns: 是否成功
    @discardableResult
    func openPage<T>(
        _ moduleType: T.Type,
        parameters: [String: Any] = [:],
        from source: UIViewController? = nil,
        animated: Bool = true
    ) -> Bool {
        
        print("📤 打开页面：\(moduleType)")
        print("📝 参数：\(parameters)")
        
        // 获取模块实例
        guard let module = self.module(moduleType) as? PageModuleProtocol else {
            print("❌ 获取模块失败或模块不是 PageModuleProtocol")
            return false
        }
        
        // 创建 ViewController
        guard let destination = module.createViewController(with: parameters) else {
            print("❌ 创建页面失败")
            return false
        }
        
        // 执行跳转
        let sourceVC = source ?? Router.shared.currentViewController()
        guard let sourceVC = sourceVC else {
            print("❌ 没有源 ViewController")
            return false
        }
        
        if let navigationController = sourceVC.navigationController {
            navigationController.pushViewController(destination, animated: animated)
            print("✅ Push 跳转成功")
        } else {
            print("❌ 没有 NavigationController")
            return false
        }
        
        return true
    }
    
    /// 打开页面（Present）
    /// - Parameters:
    ///   - moduleType: 模块类型或协议类型（例如 `ProductModule.self` 或 `ProductModuleProtocol.self`）
    ///   - parameters: 参数字典
    ///   - source: 源 ViewController
    ///   - animated: 是否动画
    ///   - completion: 完成回调
    /// - Returns: 是否成功
    @discardableResult
    func presentPage<T>(
        _ moduleType: T.Type,
        parameters: [String: Any] = [:],
        from source: UIViewController? = nil,
        animated: Bool = true,
        completion: (() -> Void)? = nil
    ) -> Bool {
        
        print("📤 弹出页面：\(moduleType)")
        
        guard let module = self.module(moduleType) as? PageModuleProtocol else {
            print("❌ 获取模块失败或模块不是 PageModuleProtocol")
            return false
        }
        
        guard let destination = module.createViewController(with: parameters) else {
            return false
        }
        
        let sourceVC = source ?? Router.shared.currentViewController()
        guard let sourceVC = sourceVC else {
            return false
        }
        
        // 包装在 NavigationController 中
        let navController = UINavigationController(rootViewController: destination)
        sourceVC.present(navController, animated: animated, completion: completion)
        
        print("✅ Present 跳转成功")
        return true
    }
    
    // MARK: - 调试
    
    /// 打印所有已注册的模块
    func printAllModules() {
        queue.sync { [weak self] in
            guard let self = self else { return }
            print("📊 已注册的模块（共 \(self.modules.count) 个）：")
            for (name, _) in self.modules {
                let hasInstance = self.instances[name] != nil
                print("  - \(name) \(hasInstance ? "✅" : "⭕")")
            }
        }
    }
    
    /// 清除所有实例缓存
    func clearInstances() {
        queue.async(flags: .barrier) { [weak self] in
            self?.instances.removeAll()
            print("🗑️ 清除所有模块实例缓存")
        }
    }
}

