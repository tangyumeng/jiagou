import Foundation
import UIKit

// MARK: - 自定义数据绑定机制

// MARK: - 绑定回调类型
typealias BindingCallback<T> = (T) -> Void

// MARK: - 可绑定属性
class Bindable<T> {
    private var _value: T
    private var callbacks: [BindingCallback<T>] = []
    
    var value: T {
        get { return _value }
        set {
            _value = newValue
            notifyCallbacks()
        }
    }
    
    init(_ value: T) {
        self._value = value
    }
    
    // 绑定回调
    func bind(_ callback: @escaping BindingCallback<T>) {
        callbacks.append(callback)
        // 立即执行一次回调
        callback(_value)
    }
    
    // 移除所有绑定
    func unbind() {
        callbacks.removeAll()
    }
    
    // 通知所有回调
    private func notifyCallbacks() {
        for callback in callbacks {
            callback(_value)
        }
    }
}

// MARK: - 双向绑定
class TwoWayBindable<T> {
    private var _value: T
    private var callbacks: [BindingCallback<T>] = []
    
    var value: T {
        get { return _value }
        set {
            _value = newValue
            notifyCallbacks()
        }
    }
    
    init(_ value: T) {
        self._value = value
    }
    
    // 绑定回调
    func bind(_ callback: @escaping BindingCallback<T>) {
        callbacks.append(callback)
        callback(_value)
    }
    
    // 设置值（不触发回调）
    func setValue(_ newValue: T, silent: Bool = false) {
        _value = newValue
        if !silent {
            notifyCallbacks()
        }
    }
    
    // 移除所有绑定
    func unbind() {
        callbacks.removeAll()
    }
    
    // 通知所有回调
    private func notifyCallbacks() {
        for callback in callbacks {
            callback(_value)
        }
    }
}

// MARK: - 数据绑定管理器
class BindingManager {
    private var bindings: [String: Any] = [:]
    
    static let shared = BindingManager()
    
    private init() {}
    
    // 创建绑定
    func createBinding<T>(for key: String, initialValue: T) -> Bindable<T> {
        let binding = Bindable(initialValue)
        bindings[key] = binding
        return binding
    }
    
    // 获取绑定
    func getBinding<T>(for key: String) -> Bindable<T>? {
        return bindings[key] as? Bindable<T>
    }
    
    // 移除绑定
    func removeBinding(for key: String) {
        bindings.removeValue(forKey: key)
    }
    
    // 清理所有绑定
    func clearAll() {
        bindings.removeAll()
    }
}

// MARK: - UI 控件扩展

// MARK: - UILabel 绑定扩展
extension UILabel {
    func bind<T>(to bindable: Bindable<T>, formatter: @escaping (T) -> String = { "\($0)" }) {
        bindable.bind { [weak self] value in
            DispatchQueue.main.async {
                self?.text = formatter(value)
            }
        }
    }
}

// MARK: - UITextField 双向绑定扩展
extension UITextField {
    func bind<T>(to bindable: TwoWayBindable<T>, 
                 formatter: @escaping (T) -> String = { "\($0)" },
                 parser: @escaping (String) -> T) {
        
        // 绑定到控件
        bindable.bind { [weak self] value in
            DispatchQueue.main.async {
                self?.text = formatter(value)
            }
        }
        
        // 控件变化绑定到数据
        self.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        // 存储解析器
        objc_setAssociatedObject(self, &AssociatedKeys.parser, parser, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        objc_setAssociatedObject(self, &AssociatedKeys.bindable, bindable, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    @objc private func textFieldDidChange() {
        guard let parser = objc_getAssociatedObject(self, &AssociatedKeys.parser) as? (String) -> Any,
              let bindable = objc_getAssociatedObject(self, &AssociatedKeys.bindable) as? TwoWayBindable<Any> else {
            return
        }
        
        if let text = self.text {
            let value = parser(text)
            bindable.setValue(value, silent: false)
        }
    }
}

private struct AssociatedKeys {
    static var parser = "parser"
    static var bindable = "bindable"
}

// MARK: - UIButton 绑定扩展
extension UIButton {
    func bind<T>(to bindable: Bindable<T>, 
                 titleFormatter: @escaping (T) -> String = { "\($0)" },
                 enabledFormatter: @escaping (T) -> Bool = { _ in true }) {
        
        bindable.bind { [weak self] value in
            DispatchQueue.main.async {
                self?.setTitle(titleFormatter(value), for: .normal)
                self?.isEnabled = enabledFormatter(value)
            }
        }
    }
}

// MARK: - UITableView 绑定扩展
extension UITableView {
    func bind<T>(to bindable: Bindable<[T]>, 
                 cellIdentifier: String,
                 configureCell: @escaping (UITableViewCell, T, IndexPath) -> Void) {
        
        bindable.bind { [weak self] items in
            DispatchQueue.main.async {
                self?.reloadData()
            }
        }
    }
}

// MARK: - UISwitch 双向绑定扩展
extension UISwitch {
    func bind(to bindable: TwoWayBindable<Bool>) {
        // 绑定到控件
        bindable.bind { [weak self] value in
            DispatchQueue.main.async {
                self?.isOn = value
            }
        }
        
        // 控件变化绑定到数据
        self.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
        
        // 存储绑定对象
        objc_setAssociatedObject(self, &SwitchAssociatedKeys.bindable, bindable, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    @objc private func switchValueChanged() {
        guard let bindable = objc_getAssociatedObject(self, &SwitchAssociatedKeys.bindable) as? TwoWayBindable<Bool> else {
            return
        }
        
        bindable.setValue(self.isOn, silent: false)
    }
}

private struct SwitchAssociatedKeys {
    static var bindable = "switchBindable"
}

// MARK: - UISegmentedControl 双向绑定扩展
extension UISegmentedControl {
    func bind<T: Equatable>(to bindable: TwoWayBindable<T>, 
                           options: [T],
                           titleFormatter: @escaping (T) -> String = { "\($0)" }) {
        
        // 设置选项
        removeAllSegments()
        for (index, option) in options.enumerated() {
            insertSegment(withTitle: titleFormatter(option), at: index, animated: false)
        }
        
        // 绑定到控件
        bindable.bind { [weak self] value in
            DispatchQueue.main.async {
                if let index = options.firstIndex(of: value) {
                    self?.selectedSegmentIndex = index
                }
            }
        }
        
        // 控件变化绑定到数据
        self.addTarget(self, action: #selector(segmentedControlValueChanged), for: .valueChanged)
        
        // 存储绑定对象和选项
        objc_setAssociatedObject(self, &SegmentedAssociatedKeys.bindable, bindable, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        objc_setAssociatedObject(self, &SegmentedAssociatedKeys.options, options, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    @objc private func segmentedControlValueChanged() {
        guard let bindable = objc_getAssociatedObject(self, &SegmentedAssociatedKeys.bindable) as? TwoWayBindable<Any>,
              let options = objc_getAssociatedObject(self, &SegmentedAssociatedKeys.options) as? [Any] else {
            return
        }
        
        let selectedIndex = self.selectedSegmentIndex
        if selectedIndex >= 0 && selectedIndex < options.count {
            let value = options[selectedIndex]
            bindable.setValue(value, silent: false)
        }
    }
}

private struct SegmentedAssociatedKeys {
    static var bindable = "segmentedBindable"
    static var options = "segmentedOptions"
}

// MARK: - 组合绑定
class CombinedBindable<T, U> {
    private let first: Bindable<T>
    private let second: Bindable<U>
    private var callbacks: [BindingCallback<(T, U)>] = []
    
    init(_ first: Bindable<T>, _ second: Bindable<U>) {
        self.first = first
        self.second = second
        
        // 监听两个绑定的变化
        first.bind { [weak self] _ in self?.notifyCombined() }
        second.bind { [weak self] _ in self?.notifyCombined() }
    }
    
    func bind(_ callback: @escaping BindingCallback<(T, U)>) {
        callbacks.append(callback)
        // 立即执行一次
        callback((first.value, second.value))
    }
    
    private func notifyCombined() {
        let combined = (first.value, second.value)
        for callback in callbacks {
            callback(combined)
        }
    }
}

// MARK: - 转换绑定
class TransformBindable<Source, Target> {
    private let source: Bindable<Source>
    private let transform: (Source) -> Target
    private var callbacks: [BindingCallback<Target>] = []
    
    init(_ source: Bindable<Source>, transform: @escaping (Source) -> Target) {
        self.source = source
        self.transform = transform
        
        source.bind { [weak self] _ in self?.notifyTransformed() }
    }
    
    func bind(_ callback: @escaping BindingCallback<Target>) {
        callbacks.append(callback)
        // 立即执行一次
        callback(transform(source.value))
    }
    
    private func notifyTransformed() {
        let transformed = transform(source.value)
        for callback in callbacks {
            callback(transformed)
        }
    }
}

// MARK: - 使用示例
/*
// 基本绑定
let name = Bindable("初始值")
nameLabel.bind(to: name)

// 双向绑定
let email = TwoWayBindable("")
emailTextField.bind(to: email, 
                   formatter: { $0 }, 
                   parser: { $0 })

// 组合绑定
let combined = CombinedBindable(name, email)
combined.bind { (name, email) in
    print("Name: \(name), Email: \(email)")
}

// 转换绑定
let isEnabled = TransformBindable(name) { !$0.isEmpty }
submitButton.bind(to: isEnabled, 
                  titleFormatter: { $0 ? "提交" : "请输入姓名" },
                  enabledFormatter: { $0 })
*/
