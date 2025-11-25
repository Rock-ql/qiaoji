//
//  Transaction.swift
//  ExpenseTracker
//
//  Created by xiaolei on 2025/11/12.
//  交易记录数据模型
//

import Foundation
import SwiftData

/// 交易记录模型
/// 作者: xiaolei
/// 存储单笔收入或支出记录
@Model
final class Transaction: Hashable {
    /// 唯一标识符
    var id: UUID

    /// 交易金额（正数）
    var amount: Double

    /// 交易类型（收入/支出）
    var type: TransactionType

    /// 交易日期
    var date: Date

    /// 备注信息
    var note: String

    /// 商户名称（可选）
    var merchant: String?

    /// 创建时间
    var createdAt: Date

    /// 更新时间
    var updatedAt: Date

    /// 关联的分类（多对一关系）
    @Relationship(deleteRule: .nullify)
    var category: Category?

    /// 关联的账户（多对一关系）
    @Relationship(deleteRule: .nullify)
    var account: Account?

    /// 关联的账本（多对一关系）
    /// 作者: xiaolei
    /// 为nil表示未归属任何账本（兼容旧数据）
    @Relationship(deleteRule: .nullify)
    var ledger: Ledger?

    /// 初始化交易记录
    /// - Parameters:
    ///   - amount: 交易金额
    ///   - type: 交易类型
    ///   - date: 交易日期
    ///   - note: 备注信息
    ///   - merchant: 商户名称
    ///   - category: 关联分类
    ///   - account: 关联账户
    ///   - ledger: 关联账本
    init(
        amount: Double,
        type: TransactionType,
        date: Date = Date(),
        note: String = "",
        merchant: String? = nil,
        category: Category? = nil,
        account: Account? = nil,
        ledger: Ledger? = nil
    ) {
        self.id = UUID()
        self.amount = amount
        self.type = type
        self.date = date
        self.note = note
        self.merchant = merchant
        self.category = category
        self.account = account
        self.ledger = ledger
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

// MARK: - Hashable 协议实现
extension Transaction {
    /// 哈希函数实现
    /// 作者: xiaolei
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    /// 相等性比较
    /// 作者: xiaolei
    static func == (lhs: Transaction, rhs: Transaction) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - 计算属性
extension Transaction {
    /// 格式化的金额字符串（带货币符号）
    /// 作者: xiaolei
    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "CNY"
        formatter.currencySymbol = "¥"
        return formatter.string(from: NSNumber(value: amount)) ?? "¥0.00"
    }

    /// 带符号的金额（收入为正，支出为负）
    /// 作者: xiaolei
    var signedAmount: Double {
        type == .income ? amount : -amount
    }

    /// 格式化的日期字符串
    /// 作者: xiaolei
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: date)
    }

    /// 格式化的时间字符串
    /// 作者: xiaolei
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }

    /// 分类名称（如果没有分类则返回"未分类"）
    /// 作者: xiaolei
    var categoryName: String {
        category?.name ?? "未分类"
    }

    /// 分类图标（如果没有分类则返回默认图标）
    /// 作者: xiaolei
    var categoryIcon: String {
        category?.icon ?? "questionmark.circle.fill"
    }
}

/// 交易类型枚举
/// 作者: xiaolei
enum TransactionType: String, Codable, CaseIterable {
    /// 收入
    case income = "收入"
    /// 支出
    case expense = "支出"

    /// 对应的SF Symbol图标
    var icon: String {
        switch self {
        case .income:
            return "arrow.down.circle.fill"
        case .expense:
            return "arrow.up.circle.fill"
        }
    }

    /// 对应的颜色名称
    var colorName: String {
        switch self {
        case .income:
            return "IncomeGreen"
        case .expense:
            return "ExpenseRed"
        }
    }
}
