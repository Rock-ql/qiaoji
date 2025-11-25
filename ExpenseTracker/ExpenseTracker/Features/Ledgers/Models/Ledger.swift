//
//  Ledger.swift
//  ExpenseTracker
//
//  Created by xiaolei on 2025/11/25.
//  账本模型 - 用于场景化记账
//

import Foundation
import SwiftData

/// 账本模型
/// 作者: xiaolei
/// 用于场景化记账，如"旅行账本"、"装修账本"等
@Model
final class Ledger {
    /// 唯一标识符
    var id: UUID

    /// 账本名称
    var name: String

    /// SF Symbol 图标名称
    var icon: String

    /// 颜色（十六进制字符串，如"4A90E2"）
    var color: String

    /// 账本描述
    var ledgerDescription: String

    /// 是否为默认账本
    var isDefault: Bool

    /// 是否已归档
    var isArchived: Bool

    /// 排序顺序
    var sortOrder: Int

    /// 创建时间
    var createdAt: Date

    /// 更新时间
    var updatedAt: Date

    /// 关联的交易列表（一对多关系）
    @Relationship(inverse: \Transaction.ledger)
    var transactions: [Transaction]

    /// 初始化方法
    /// 作者: xiaolei
    init(
        name: String,
        icon: String,
        color: String,
        description: String = "",
        isDefault: Bool = false,
        isArchived: Bool = false,
        sortOrder: Int = 0
    ) {
        self.id = UUID()
        self.name = name
        self.icon = icon
        self.color = color
        self.ledgerDescription = description
        self.isDefault = isDefault
        self.isArchived = isArchived
        self.sortOrder = sortOrder
        self.createdAt = Date()
        self.updatedAt = Date()
        self.transactions = []
    }

    /// 总收入
    /// 作者: xiaolei
    var totalIncome: Double {
        transactions
            .filter { $0.type == .income }
            .reduce(0) { $0 + $1.amount }
    }

    /// 总支出
    /// 作者: xiaolei
    var totalExpense: Double {
        transactions
            .filter { $0.type == .expense }
            .reduce(0) { $0 + $1.amount }
    }

    /// 结余
    /// 作者: xiaolei
    var balance: Double {
        totalIncome - totalExpense
    }

    /// 交易笔数
    /// 作者: xiaolei
    var transactionCount: Int {
        transactions.count
    }

    /// 格式化的总收入
    /// 作者: xiaolei
    var formattedTotalIncome: String {
        formatCurrency(totalIncome)
    }

    /// 格式化的总支出
    /// 作者: xiaolei
    var formattedTotalExpense: String {
        formatCurrency(totalExpense)
    }

    /// 格式化的结余
    /// 作者: xiaolei
    var formattedBalance: String {
        formatCurrency(balance)
    }

    /// 格式化货币
    /// 作者: xiaolei
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "CNY"
        formatter.currencySymbol = "¥"
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: amount)) ?? "¥0.00"
    }
}

/// 使账本可比较和排序
/// 作者: xiaolei
extension Ledger: Comparable {
    static func < (lhs: Ledger, rhs: Ledger) -> Bool {
        // 默认账本排在最前面
        if lhs.isDefault != rhs.isDefault {
            return lhs.isDefault
        }
        // 其他按排序顺序升序排列
        return lhs.sortOrder < rhs.sortOrder
    }
}
