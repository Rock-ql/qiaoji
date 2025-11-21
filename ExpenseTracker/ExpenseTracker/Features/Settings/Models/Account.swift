//
//  Account.swift
//  ExpenseTracker
//
//  Created by xiaolei on 2025/11/12.
//  账户数据模型
//

import Foundation
import SwiftData

/// 账户模型
/// 作者: xiaolei
/// 用于管理不同的资金账户（现金、银行卡、信用卡等）
@Model
final class Account {
    /// 唯一标识符
    var id: UUID

    /// 账户名称
    var name: String

    /// 账户类型
    var type: AccountType

    /// 初始余额
    var initialBalance: Double

    /// SF Symbol图标名称
    var icon: String

    /// 颜色值（十六进制字符串）
    var color: String

    /// 是否为默认账户
    var isDefault: Bool

    /// 排序顺序
    var sortOrder: Int

    /// 创建时间
    var createdAt: Date

    /// 更新时间
    var updatedAt: Date

    /// 该账户下的所有交易（一对多反向关系）
    @Relationship(inverse: \Transaction.account)
    var transactions: [Transaction]

    /// 初始化账户
    /// - Parameters:
    ///   - name: 账户名称
    ///   - type: 账户类型
    ///   - initialBalance: 初始余额
    ///   - icon: SF Symbol图标名称
    ///   - color: 颜色十六进制值
    ///   - isDefault: 是否为默认账户
    ///   - sortOrder: 排序顺序
    init(
        name: String,
        type: AccountType,
        initialBalance: Double = 0,
        icon: String,
        color: String,
        isDefault: Bool = false,
        sortOrder: Int = 0
    ) {
        self.id = UUID()
        self.name = name
        self.type = type
        self.initialBalance = initialBalance
        self.icon = icon
        self.color = color
        self.isDefault = isDefault
        self.sortOrder = sortOrder
        self.createdAt = Date()
        self.updatedAt = Date()
        self.transactions = []
    }
}

// MARK: - 计算属性
extension Account {
    /// 当前余额（初始余额 + 所有交易的净额）
    /// 作者: xiaolei
    var currentBalance: Double {
        let transactionsSum = transactions.reduce(0) { result, transaction in
            result + transaction.signedAmount
        }
        return initialBalance + transactionsSum
    }

    /// 总收入金额
    /// 作者: xiaolei
    var totalIncome: Double {
        transactions
            .filter { $0.type == .income }
            .reduce(0) { $0 + $1.amount }
    }

    /// 总支出金额
    /// 作者: xiaolei
    var totalExpense: Double {
        transactions
            .filter { $0.type == .expense }
            .reduce(0) { $0 + $1.amount }
    }

    /// 交易笔数
    /// 作者: xiaolei
    var transactionCount: Int {
        transactions.count
    }

    /// 格式化的当前余额
    /// 作者: xiaolei
    var formattedBalance: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "CNY"
        formatter.currencySymbol = "¥"
        return formatter.string(from: NSNumber(value: currentBalance)) ?? "¥0.00"
    }

    /// 格式化的初始余额
    /// 作者: xiaolei
    var formattedInitialBalance: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "CNY"
        formatter.currencySymbol = "¥"
        return formatter.string(from: NSNumber(value: initialBalance)) ?? "¥0.00"
    }

    /// 指定时间范围内的余额变化
    /// 作者: xiaolei
    /// - Parameters:
    ///   - startDate: 开始日期
    ///   - endDate: 结束日期
    /// - Returns: 余额变化金额（正数表示增加，负数表示减少）
    func balanceChange(from startDate: Date, to endDate: Date) -> Double {
        transactions
            .filter { $0.date >= startDate && $0.date <= endDate }
            .reduce(0) { $0 + $1.signedAmount }
    }

    /// 指定月份的余额变化
    /// 作者: xiaolei
    /// - Parameter date: 月份中的任意日期
    /// - Returns: 该月的余额变化金额
    func balanceChangeForMonth(_ date: Date) -> Double {
        let calendar = Calendar.current
        guard let startOfMonth = calendar.dateInterval(of: .month, for: date)?.start,
              let endOfMonth = calendar.dateInterval(of: .month, for: date)?.end else {
            return 0
        }
        return balanceChange(from: startOfMonth, to: endOfMonth)
    }
}

// MARK: - 比较和排序
extension Account: Comparable {
    /// 比较两个账户（默认账户优先，其次按排序顺序）
    /// 作者: xiaolei
    static func < (lhs: Account, rhs: Account) -> Bool {
        if lhs.isDefault != rhs.isDefault {
            return lhs.isDefault
        }
        return lhs.sortOrder < rhs.sortOrder
    }
}

/// 账户类型枚举
/// 作者: xiaolei
enum AccountType: String, Codable, CaseIterable {
    /// 现金
    case cash = "现金"
    /// 储蓄卡
    case debitCard = "储蓄卡"
    /// 信用卡
    case creditCard = "信用卡"
    /// 支付宝
    case alipay = "支付宝"
    /// 微信
    case wechat = "微信"
    /// 其他
    case other = "其他"

    /// 对应的SF Symbol图标
    var icon: String {
        switch self {
        case .cash:
            return "banknote.fill"
        case .debitCard:
            return "creditcard.fill"
        case .creditCard:
            return "creditcard.and.123"
        case .alipay:
            return "a.circle.fill"
        case .wechat:
            return "w.circle.fill"
        case .other:
            return "folder.fill"
        }
    }

    /// 默认颜色
    var defaultColor: String {
        switch self {
        case .cash:
            return "48C774" // 绿色
        case .debitCard:
            return "3298DC" // 蓝色
        case .creditCard:
            return "F14668" // 红色
        case .alipay:
            return "1296DB" // 支付宝蓝
        case .wechat:
            return "09BB07" // 微信绿
        case .other:
            return "B5B5B5" // 灰色
        }
    }
}
