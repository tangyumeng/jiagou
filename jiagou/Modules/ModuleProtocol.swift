//
//  ModuleProtocol.swift
//  jiagou
//
//  模块协议定义 - Protocol-Based Router
//

import UIKit

// MARK: - 基础模块协议

/// 模块协议基类
protocol ModuleProtocol {
    /// 模块名称（用于标识和注册）
    static var moduleName: String { get }
    
    /// 模块初始化
    init()
}

// MARK: - 页面模块协议

/// 页面模块协议（可以创建 ViewController）
protocol PageModuleProtocol: ModuleProtocol {
    /// 创建 ViewController
    /// - Parameter parameters: 参数字典
    /// - Returns: ViewController实例
    func createViewController(with parameters: [String: Any]) -> UIViewController?
}

// MARK: - 服务模块协议

/// 服务模块协议（提供服务，不创建页面）
protocol ServiceModuleProtocol: ModuleProtocol {
    // 子类可以定义自己的服务方法
}

// MARK: - 数据模型

/// 用户模型
struct User {
    let id: String
    let name: String
    let avatar: String?
    let email: String?
}

/// 商品模型
struct Product {
    let id: String
    let name: String
    let price: Double
    let imageUrl: String?
    let description: String?
}

/// 订单模型
struct Order {
    let id: String
    let userId: String
    let productId: String
    let quantity: Int
    let totalPrice: Double
    let status: OrderStatus
    
    enum OrderStatus: String {
        case pending = "待支付"
        case paid = "已支付"
        case shipped = "已发货"
        case delivered = "已送达"
        case cancelled = "已取消"
    }
}

