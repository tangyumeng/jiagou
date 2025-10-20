//
//  AppDelegate.swift
//  jiagou
//
//  Created by tangyumeng on 2025/10/10.
//

import UIKit
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // 1. 注册所有路由（URL-Based Router）
        registerAllRoutes()
        
        // 2. 注册所有模块（Protocol-Based Router）
        registerAllModules()
        
        // 3. 请求通知权限
        requestNotificationPermission()
        
        // 4. 处理从通知启动的情况
        handleLaunchFromNotification(launchOptions: launchOptions)
        
        return true
    }
    
    // MARK: - 注册路由
    private func registerAllRoutes() {
        let router = Router.shared
        
        // 注册用户详情页
        router.register("app://user/:userId", viewControllerType: RouteUserDetailViewController.self)
        
        // 注册设置页（模态）
        router.register("app://settings", action: .present) { _ in
            print("🔨 开始创建 RouteSettingsViewController")
            let vc = RouteSettingsViewController()
            print("✅ RouteSettingsViewController 创建成功")
            print("🔨 开始创建 UINavigationController")
            let navController = UINavigationController(rootViewController: vc)
            print("✅ UINavigationController 创建成功")
            return navController
        }
        
        // 注册商品详情
        router.register("app://product/:productId", viewControllerType: RouteProductViewController.self)
        
        // 注册搜索页
        router.register("app://search", viewControllerType: RouteSearchViewController.self)
        
        // 注册需要权限的页面
        router.register("app://vip/:vipId", viewControllerType: RouteVIPViewController.self)
        
        // 注册图片预览页（演示传递复杂对象）
        router.register("app://image-preview", viewControllerType: RouteImagePreviewViewController.self)
        router.register("app://image-preview/:imageId", viewControllerType: RouteImagePreviewViewController.self)
        
        print("✅ 应用启动时已注册所有路由")
    }
    
    // MARK: - 注册模块（Protocol-Based Router）
    
    private func registerAllModules() {
        let manager = ModuleManager.shared
        
        // 注册用户模块
        manager.register(UserModule.self)
        
        // 注册商品模块
        manager.register(ProductModule.self)
        
        print("✅ 应用启动时已注册所有模块")
    }
    
    // MARK: - 通知处理
    
    /// 请求通知权限
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("✅ 通知权限已授予")
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else if let error = error {
                print("❌ 通知权限被拒绝：\(error.localizedDescription)")
            }
        }
        
        // 设置通知代理
        UNUserNotificationCenter.current().delegate = self
    }
    
    /// 处理从通知启动（App 完全未运行时）
    private func handleLaunchFromNotification(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        
        // 场景：从远程推送通知启动
        if let remoteNotification = launchOptions?[.remoteNotification] as? [AnyHashable: Any] {
            print("🔔 从远程通知启动 App")
            handleNotificationPayload(remoteNotification, isLaunch: true)
        }
    }
    
    /// 处理通知负载（提取路由信息）
    private func handleNotificationPayload(_ userInfo: [AnyHashable: Any], isLaunch: Bool) {
        print("📦 通知内容：\(userInfo)")
        
        // 从通知中提取路由信息
        // 格式示例：{"route": "app://product/123", "title": "新商品上架"}
        guard let routeString = userInfo["route"] as? String else {
            print("⚠️ 通知中没有路由信息")
            return
        }
        
        print("🔗 提取到路由：\(routeString)")
        
        // 提取额外参数
        var parameters: [String: Any] = [:]
        if let params = userInfo["parameters"] as? [String: Any] {
            parameters = params
        }
        
        if isLaunch {
            // App 启动场景：设置待处理路由
            print("📌 App 正在启动，设置待处理路由")
            Router.shared.setPendingRoute(routeString, parameters: parameters)
        } else {
            // App 已运行场景：直接执行路由
            print("🚀 App 已运行，直接执行路由")
            Router.shared.open(routeString, parameters: parameters)
        }
    }
    
    /// 通过 URL Scheme 打开（外部唤起）
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        print("🔗 通过 URL Scheme 打开：\(url)")
        
        // 检查 UI 是否就绪
        if Router.shared.currentViewController() != nil {
            // UI 已就绪，直接执行
            return Router.shared.open(url)
        } else {
            // UI 未就绪，设置待处理路由
            Router.shared.setPendingRoute(url.absoluteString)
            return true
        }
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    /// 前台收到通知
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("🔔 前台收到通知：\(notification.request.content.userInfo)")
        
        // iOS 14+ 显示 banner
        if #available(iOS 14.0, *) {
            completionHandler([.banner, .sound, .badge])
        } else {
            completionHandler([.alert, .sound, .badge])
        }
    }
    
    /// 用户点击通知
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("🔔 用户点击了通知")
        
        let userInfo = response.notification.request.content.userInfo
        
        // 检查 App 是否刚启动（UI 未就绪）
        let isLaunch = Router.shared.currentViewController() == nil
        
        handleNotificationPayload(userInfo, isLaunch: isLaunch)
        
        completionHandler()
    }
}

