//
//  ExpenseTrackerApp.swift
//  ExpenseTracker
//
//  Created by xiaolei on 2025/11/12.
//  记账应用入口文件
//

import SwiftUI
import SwiftData
import UIKit

/// 键盘预加载器
/// 作者: xiaolei
/// 解决 iOS 系统键盘首次唤起延迟问题
final class KeyboardPreloader {
    static let shared = KeyboardPreloader()
    private var preloadWindow: UIWindow?
    private var hasPreloaded = false

    private init() {}

    /// 预加载系统键盘
    /// 通过创建隐藏的 TextField 并短暂激活键盘来实现预加载
    func preload() {
        guard !hasPreloaded else { return }
        hasPreloaded = true

        DispatchQueue.main.async { [weak self] in
            // 创建一个隐藏的窗口和文本框
            let textField = UITextField()
            textField.autocorrectionType = .no
            textField.spellCheckingType = .no

            let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
            window.windowLevel = .init(rawValue: -1000)
            window.alpha = 0.01
            window.rootViewController = UIViewController()
            window.rootViewController?.view.addSubview(textField)
            window.makeKeyAndVisible()

            self?.preloadWindow = window

            // 激活键盘
            textField.becomeFirstResponder()

            // 短暂延迟后收起键盘并清理
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                textField.resignFirstResponder()
                textField.removeFromSuperview()
                self?.preloadWindow?.isHidden = true
                self?.preloadWindow = nil
            }
        }
    }
}

/// 记账应用主入口
/// 作者: xiaolei
/// 配置SwiftData容器并启动应用
@main
struct ExpenseTrackerApp: App {
    /// SwiftData模型容器，管理数据持久化
    let container: ModelContainer

    init() {
        do {
            // 配置SwiftData容器，支持多个模型类型
            container = try ModelContainer(
                for: Transaction.self,
                    Category.self,
                    Budget.self,
                    Account.self,
                    Ledger.self,
                configurations: ModelConfiguration(
                    // 暂时禁用iCloud，使用本地数据库
                    cloudKitDatabase: .none
                )
            )
        } catch {
            fatalError("无法初始化ModelContainer: \(error.localizedDescription)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(container)
                .preferredColorScheme(nil) // 自动适配系统主题
                .onAppear {
                    // 预加载系统键盘，避免首次唤起延迟
                    KeyboardPreloader.shared.preload()
                }
        }
    }
}
