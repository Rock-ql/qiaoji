//
//  Category.swift
//  ExpenseTracker
//
//  Created by xiaolei on 2025/11/12.
//  分类数据模型
//

import Foundation
import SwiftData

/// 交易分类模型
/// 作者: xiaolei
/// 用于对交易进行分类管理
@Model
final class Category {
    /// 唯一标识符
    var id: UUID

    /// 分类名称
    var name: String

    /// SF Symbol图标名称
    var icon: String

    /// 颜色值（十六进制字符串，如"FF6B6B"）
    var color: String

    /// 分类类型（收入/支出）
    var type: TransactionType

    /// 是否为系统预设分类
    var isSystem: Bool

    /// 排序顺序
    var sortOrder: Int

    /// 创建时间
    var createdAt: Date

    /// 该分类下的所有交易（一对多反向关系）
    @Relationship(inverse: \Transaction.category)
    var transactions: [Transaction]

    /// 初始化分类
    /// - Parameters:
    ///   - name: 分类名称
    ///   - icon: SF Symbol图标名称
    ///   - color: 颜色十六进制值
    ///   - type: 分类类型
    ///   - isSystem: 是否为系统预设
    ///   - sortOrder: 排序顺序
    init(
        name: String,
        icon: String,
        color: String,
        type: TransactionType,
        isSystem: Bool = false,
        sortOrder: Int = 0
    ) {
        self.id = UUID()
        self.name = name
        self.icon = icon
        self.color = color
        self.type = type
        self.isSystem = isSystem
        self.sortOrder = sortOrder
        self.createdAt = Date()
        self.transactions = []
    }
}

// MARK: - 计算属性
extension Category {
    /// 该分类的总支出/收入金额
    /// 作者: xiaolei
    var totalAmount: Double {
        transactions.reduce(0) { $0 + $1.amount }
    }

    /// 该分类的交易笔数
    /// 作者: xiaolei
    var transactionCount: Int {
        transactions.count
    }

    /// 格式化的总金额
    /// 作者: xiaolei
    var formattedTotalAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "CNY"
        formatter.currencySymbol = "¥"
        return formatter.string(from: NSNumber(value: totalAmount)) ?? "¥0.00"
    }

    /// 是否可以删除（系统预设分类不可删除）
    /// 作者: xiaolei
    var canDelete: Bool {
        !isSystem
    }

    /// 在指定时间范围内的交易总额
    /// 作者: xiaolei
    /// - Parameters:
    ///   - startDate: 开始日期
    ///   - endDate: 结束日期
    /// - Returns: 时间范围内的总金额
    func totalAmount(from startDate: Date, to endDate: Date) -> Double {
        transactions
            .filter { $0.date >= startDate && $0.date <= endDate }
            .reduce(0) { $0 + $1.amount }
    }

    /// 在指定月份的交易总额
    /// 作者: xiaolei
    /// - Parameter date: 月份中的任意日期
    /// - Returns: 该月的总金额
    func totalAmountForMonth(_ date: Date) -> Double {
        let calendar = Calendar.current
        guard let startOfMonth = calendar.dateInterval(of: .month, for: date)?.start,
              let endOfMonth = calendar.dateInterval(of: .month, for: date)?.end else {
            return 0
        }
        return totalAmount(from: startOfMonth, to: endOfMonth)
    }
}

// MARK: - 比较和排序
extension Category: Comparable {
    /// 比较两个分类（按排序顺序）
    /// 作者: xiaolei
    static func < (lhs: Category, rhs: Category) -> Bool {
        lhs.sortOrder < rhs.sortOrder
    }
}
