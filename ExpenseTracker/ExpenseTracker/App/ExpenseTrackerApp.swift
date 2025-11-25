//
//  ExpenseTrackerApp.swift
//  ExpenseTracker
//
//  Created by xiaolei on 2025/11/12.
//  记账应用入口文件
//

import SwiftUI
import SwiftData

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
        }
    }
}
