//
//  AppDelegate.swift
//  jiagou
//
//  Created by tangyumeng on 2025/10/10.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // 注册所有路由
        registerAllRoutes()
        
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
        
        print("✅ 应用启动时已注册所有路由")
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

