//
//  Router.swift
//  jiagou
//
//  路由框架 - 解决模块间页面跳转解耦问题
//

import UIKit

// MARK: - 路由协议

/// 可路由的协议（ViewController 需要遵循）
protocol Routable {
    /// 从路由参数初始化
    static func instantiate(with parameters: [String: Any]) -> Self?
}

/// 路由处理器协议
protocol RouteHandler {
    /// 是否可以处理该路由
    func canHandle(url: URL) -> Bool
    
    /// 处理路由
    func handle(url: URL, parameters: [String: Any], from source: UIViewController?) -> Bool
}

// MARK: - 路由请求

/// 路由请求
struct RouteRequest {
    let url: URL
    let parameters: [String: Any]
    let source: UIViewController?
    let animated: Bool
    let completion: (() -> Void)?
    
    init(
        url: URL,
        parameters: [String: Any] = [:],
        source: UIViewController? = nil,
        animated: Bool = true,
        completion: (() -> Void)? = nil
    ) {
        self.url = url
        self.parameters = parameters
        self.source = source
        self.animated = animated
        self.completion = completion
    }
}

// MARK: - 路由动作

/// 路由动作（push / present / replace）
enum RouteAction {
    case push           // 导航栏 push
    case present        // 模态弹出
    case replace        // 替换当前页面
    case custom(handler: (UIViewController, UIViewController, Bool) -> Void)  // 自定义
}

// MARK: - 路由错误

enum RouterError: Error {
    case urlNotFound            // URL 未注册
    case parametersMissing      // 参数缺失
    case instantiationFailed    // 实例化失败
    case noSourceViewController // 没有源 ViewController
    
    var localizedDescription: String {
        switch self {
        case .urlNotFound:
            return "URL 未注册"
        case .parametersMissing:
            return "参数缺失"
        case .instantiationFailed:
            return "实例化失败"
        case .noSourceViewController:
            return "没有源 ViewController"
        }
    }
}

// MARK: - 路由信息

/// 路由信息（注册时使用）
struct RouteInfo {
    let pattern: String                                              // URL 模式（支持占位符）
    let action: RouteAction                                          // 跳转方式
    let handler: ([String: Any]) -> UIViewController?                // 创建 ViewController 的闭包
    
    init(
        pattern: String,
        action: RouteAction = .push,
        handler: @escaping ([String: Any]) -> UIViewController?
    ) {
        self.pattern = pattern
        self.action = action
        self.handler = handler
    }
}

// MARK: - 路由管理器

/// 路由管理器（单例）
class Router {
    
    // MARK: - 单例
    static let shared = Router()
    
    // MARK: - 属性
    
    // 路由表 {pattern: RouteInfo}
    private var routes: [String: RouteInfo] = [:]
    
    // URL Scheme（自定义协议）
    private let scheme: String = "app"
    
    // 路由拦截器（中间件）
    private var interceptors: [(RouteRequest) -> Bool] = []
    
    // 待处理的路由（用于 App 启动时 UI 未就绪的情况）
    private var pendingURLString: String?
    private var pendingParameters: [String: Any]?
    
    // MARK: - 初始化
    private init() {
        registerBuiltInRoutes()
    }
    
    // MARK: - 注册路由
    
    /// 注册路由
    /// - Parameters:
    ///   - pattern: URL 模式，例如 "app://user/:userId"
    ///   - action: 跳转方式（push/present/replace）
    ///   - handler: 创建 ViewController 的闭包
    func register(
        _ pattern: String,
        action: RouteAction = .push,
        handler: @escaping ([String: Any]) -> UIViewController?
    ) {
        let routeInfo = RouteInfo(pattern: pattern, action: action, handler: handler)
        routes[pattern] = routeInfo
        print("📝 注册路由：\(pattern)")
    }
    
    /// 注册路由（使用 Routable 协议）
    func register<T: UIViewController & Routable>(
        _ pattern: String,
        viewControllerType: T.Type,
        action: RouteAction = .push
    ) {
        register(pattern, action: action) { parameters in
            return T.instantiate(with: parameters)
        }
    }
    
    /// 注销路由
    func unregister(_ pattern: String) {
        routes.removeValue(forKey: pattern)
        print("🗑️ 注销路由：\(pattern)")
    }
    
    /// 注册内置路由（例如返回、关闭等）
    private func registerBuiltInRoutes() {
        // 返回
        register("app://back") { _ in
            // 特殊处理，不需要创建 ViewController
            return nil
        }
        
        // 关闭模态
        register("app://dismiss") { _ in
            return nil
        }
    }
    
    // MARK: - 路由跳转
    
    /// 打开 URL
    /// - Parameters:
    ///   - urlString: URL 字符串
    ///   - parameters: 额外参数
    ///   - source: 源 ViewController（可选，默认使用当前）
    ///   - animated: 是否动画
    ///   - completion: 完成回调
    @discardableResult
    func open(
        _ urlString: String,
        parameters: [String: Any] = [:],
        from source: UIViewController? = nil,
        animated: Bool = true,
        completion: (() -> Void)? = nil
    ) -> Bool {
        guard let url = URL(string: urlString) else {
            print("❌ 无效的 URL：\(urlString)")
            return false
        }
        
        return open(url, parameters: parameters, from: source, animated: animated, completion: completion)
    }
    
    /// 打开 URL
    @discardableResult
    func open(
        _ url: URL,
        parameters: [String: Any] = [:],
        from source: UIViewController? = nil,
        animated: Bool = true,
        completion: (() -> Void)? = nil
    ) -> Bool {
        // 创建路由请求
        let request = RouteRequest(
            url: url,
            parameters: parameters,
            source: source,
            animated: animated,
            completion: completion
        )
        
        // 执行拦截器
        for interceptor in interceptors {
            if !interceptor(request) {
                print("⛔ 路由被拦截：\(url)")
                return false
            }
        }
        
        // 处理内置路由
        if handleBuiltInRoute(url: url, from: source, animated: animated) {
            completion?()
            return true
        }
        
        // 匹配路由
        guard let (routeInfo, pathParameters) = matchRoute(url: url) else {
            print("❌ 未找到匹配的路由：\(url)")
            print("📋 当前已注册 \(routes.count) 个路由")
            printAllRoutes()
            return false
        }
        
        print("✅ 路由匹配成功：\(routeInfo.pattern)")
        
        // 合并参数（URL 参数 + query 参数 + 额外参数）
        var allParameters = pathParameters
        if let queryParameters = url.queryParameters {
            allParameters.merge(queryParameters) { $1 }
        }
        allParameters.merge(parameters) { $1 }
        
        print("📝 参数：\(allParameters)")
        print("🔨 开始创建 ViewController...")
        
        // 创建目标 ViewController
        guard let destination = routeInfo.handler(allParameters) else {
            print("❌ 创建 ViewController 失败：\(url)")
            print("⚠️ handler 返回了 nil")
            return false
        }
        
        print("✅ ViewController 创建成功：\(type(of: destination))")
        
        // 执行跳转
        let sourceVC = source ?? currentViewController()
        perform(action: routeInfo.action, from: sourceVC, to: destination, animated: animated, completion: completion)
        
        return true
    }
    
    // MARK: - 路由匹配
    
    /// 匹配路由
    /// - Returns: (RouteInfo, 路径参数)
    private func matchRoute(url: URL) -> (RouteInfo, [String: Any])? {
        let urlPath = url.absoluteString
        
        for (pattern, routeInfo) in routes {
            // 解析 pattern
            guard let patternURL = URL(string: pattern) else { continue }
            let patternPath = patternURL.absoluteString
            
            // 匹配路径
            if let parameters = match(urlPath: urlPath, with: patternPath) {
                return (routeInfo, parameters)
            }
        }
        
        return nil
    }
    
    /// 匹配路径并提取参数
    /// - Parameters:
    ///   - urlPath: URL 路径，例如 "/user/123"
    ///   - patternPath: 模式路径，例如 "/user/:userId"
    /// - Returns: 提取的参数，例如 ["userId": "123"]
    private func match(urlPath: String, with patternPath: String) -> [String: Any]? {
        let urlComponents = urlPath.split(separator: "/").map(String.init)
        let patternComponents = patternPath.split(separator: "/").map(String.init)
        
        guard urlComponents.count == patternComponents.count else {
            return nil
        }
        
        var parameters: [String: Any] = [:]
        
        for (urlComponent, patternComponent) in zip(urlComponents, patternComponents) {
            if patternComponent.hasPrefix(":") {
                // 参数占位符
                let key = String(patternComponent.dropFirst())
                parameters[key] = urlComponent
            } else if urlComponent != patternComponent {
                // 不匹配
                return nil
            }
        }
        
        return parameters
    }
    
    private func match2(urlPath: String, with patternPath: String) -> [String:Any]? {
        let urlComponents = urlPath.split(separator: "/").map(String.init)
        let patternComponents = patternPath.split(separator: "/").map(String.init)
        
        guard urlComponents.count == patternComponents.count else {
            return nil
        }
        
        var parameters : [String: Any] = [:]
        for (urlComponent, patternComponent) in zip(urlComponents, patternComponents) {
            if patternComponent.hasPrefix(":") {
                let key = String(patternComponent.dropFirst())
                parameters[key] = urlComponent
            } else if urlComponent != patternComponent {
                return nil
            }
         }
        return parameters
    }
    
    // MARK: - 执行跳转
    
    /// 执行跳转动作
    private func perform(
        action: RouteAction,
        from source: UIViewController?,
        to destination: UIViewController,
        animated: Bool,
        completion: (() -> Void)?
    ) {
        guard let source = source else {
            print("❌ 没有源 ViewController")
            return
        }
        
        switch action {
        case .push:
            source.navigationController?.pushViewController(destination, animated: animated)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                completion?()
            }
            
        case .present:
            source.present(destination, animated: animated, completion: completion)
            
        case .replace:
            // 替换当前页面
            if let navigationController = source.navigationController {
                var viewControllers = navigationController.viewControllers
                if let index = viewControllers.firstIndex(of: source) {
                    viewControllers[index] = destination
                    navigationController.setViewControllers(viewControllers, animated: animated)
                }
            }
            completion?()
            
        case .custom(let handler):
            handler(source, destination, animated)
            completion?()
        }
    }
    
    // MARK: - 内置路由处理
    
    /// 处理内置路由（返回、关闭等）
    private func handleBuiltInRoute(url: URL, from source: UIViewController?, animated: Bool) -> Bool {
        let urlString = url.absoluteString
        
        if urlString == "app://back" {
            // 返回
            if let source = source ?? currentViewController() {
                source.navigationController?.popViewController(animated: animated)
            }
            return true
        }
        
        if urlString == "app://dismiss" {
            // 关闭模态
            if let source = source ?? currentViewController() {
                source.dismiss(animated: animated)
            }
            return true
        }
        
        return false
    }
    
    // MARK: - 工具方法
    
    /// 获取当前 ViewController
    func currentViewController() -> UIViewController? {
        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }),
              let rootViewController = window.rootViewController else {
            return nil
        }
        
        return findCurrentViewController(from: rootViewController)
    }
    
    /// 递归查找当前 ViewController
    private func findCurrentViewController(from viewController: UIViewController) -> UIViewController {
        if let presented = viewController.presentedViewController {
            return findCurrentViewController(from: presented)
        }
        
        if let navigationController = viewController as? UINavigationController {
            if let visible = navigationController.visibleViewController {
                return findCurrentViewController(from: visible)
            }
        }
        
        if let tabBarController = viewController as? UITabBarController {
            if let selected = tabBarController.selectedViewController {
                return findCurrentViewController(from: selected)
            }
        }
        
        return viewController
    }
    
    // MARK: - 拦截器（中间件）
    
    /// 添加拦截器
    /// - Parameter interceptor: 拦截器闭包，返回 false 表示拦截
    func addInterceptor(_ interceptor: @escaping (RouteRequest) -> Bool) {
        interceptors.append(interceptor)
    }
    
    /// 移除所有拦截器
    func removeAllInterceptors() {
        interceptors.removeAll()
    }
    
    // MARK: - 调试方法
    
    /// 打印所有已注册的路由（用于调试）
    func printAllRoutes() {
        print("📊 已注册的路由（共 \(routes.count) 个）：")
        for (pattern, routeInfo) in routes {
            let actionName: String
            switch routeInfo.action {
            case .push: actionName = "Push"
            case .present: actionName = "Present"
            case .replace: actionName = "Replace"
            case .custom: actionName = "Custom"
            }
            print("  - \(pattern) [\(actionName)]")
        }
    }
    
    // MARK: - 延迟路由（用于通知启动等场景）
    
    /// 设置待处理的路由（在 UI 未就绪时调用）
    /// 使用场景：App 从通知启动，但 Window 和 RootViewController 还未初始化
    /// - Parameters:
    ///   - urlString: 路由 URL
    ///   - parameters: 附加参数
    func setPendingRoute(_ urlString: String, parameters: [String: Any] = [:]) {
        if pendingURLString != nil {
            print("⚠️ 覆盖之前的待处理路由：\(pendingURLString!)")
        }
        print("📌 设置待处理路由：\(urlString)")
        pendingURLString = urlString
        pendingParameters = parameters
    }
    
    /// 执行待处理的路由（在 UI 就绪后调用）
    /// 通常在 RootViewController 的 viewDidAppear 中调用
    /// - Returns: 是否有路由被执行
    @discardableResult
    func executePendingRoute() -> Bool {
        guard let urlString = pendingURLString else {
            return false
        }
        
        print("🚀 执行待处理路由：\(urlString)")
        
        let parameters = pendingParameters ?? [:]
        
        // 清除待处理的路由
        pendingURLString = nil
        pendingParameters = nil
        
        // 延迟执行，确保 UI 完全就绪
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.open(urlString, parameters: parameters)
        }
        
        return true
    }
    
    /// 是否有待处理的路由
    var hasPendingRoute: Bool {
        return pendingURLString != nil
    }
    
    /// 清除待处理的路由
    func clearPendingRoute() {
        if pendingURLString != nil {
            print("🗑️ 清除待处理路由：\(pendingURLString!)")
        }
        pendingURLString = nil
        pendingParameters = nil
    }
}

// MARK: - URL 扩展

extension URL {
    /// 解析 query 参数
    var queryParameters: [String: Any]? {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems else {
            return nil
        }
        
        var parameters: [String: Any] = [:]
        for item in queryItems {
            parameters[item.name] = item.value
        }
        return parameters
    }
}

// MARK: - UIViewController 扩展

extension UIViewController {
    
    /// 通过路由打开页面
    @discardableResult
    func open(
        _ urlString: String,
        parameters: [String: Any] = [:],
        animated: Bool = true,
        completion: (() -> Void)? = nil
    ) -> Bool {
        return Router.shared.open(
            urlString,
            parameters: parameters,
            from: self,
            animated: animated,
            completion: completion
        )
    }
    
    /// 通过路由返回
    func routeBack(animated: Bool = true) {
        Router.shared.open("app://back", from: self, animated: animated)
    }
    
    /// 通过路由关闭
    func routeDismiss(animated: Bool = true) {
        Router.shared.open("app://dismiss", from: self, animated: animated)
    }
}

