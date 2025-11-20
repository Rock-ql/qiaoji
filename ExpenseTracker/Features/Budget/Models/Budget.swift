//
//  Budget.swift
//  ExpenseTracker
//
//  Created by xiaolei on 2025/11/12.
//  预算数据模型
//

import Foundation
import SwiftData

/// 预算模型
/// 作者: xiaolei
/// 用于设置和跟踪各分类的预算
@Model
final class Budget {
    /// 唯一标识符
    var id: UUID

    /// 预算金额
    var amount: Double

    /// 预算周期类型
    var period: BudgetPeriod

    /// 开始日期
    var startDate: Date

    /// 结束日期
    var endDate: Date

    /// 预警阈值（0.0-1.0，表示百分比）
    var alertThreshold: Double

    /// 是否启用预警
    var alertEnabled: Bool

    /// 创建时间
    var createdAt: Date

    /// 更新时间
    var updatedAt: Date

    /// 关联的分类（多对一关系）
    @Relationship(deleteRule: .nullify)
    var category: Category?

    /// 初始化预算
    /// - Parameters:
    ///   - amount: 预算金额
    ///   - period: 预算周期
    ///   - startDate: 开始日期
    ///   - alertThreshold: 预警阈值（默认0.8，即80%）
    ///   - alertEnabled: 是否启用预警
    ///   - category: 关联分类
    init(
        amount: Double,
        period: BudgetPeriod,
        startDate: Date = Date(),
        alertThreshold: Double = 0.8,
        alertEnabled: Bool = true,
        category: Category? = nil
    ) {
        self.id = UUID()
        self.amount = amount
        self.period = period
        self.startDate = startDate
        self.endDate = period.calculateEndDate(from: startDate)
        self.alertThreshold = alertThreshold
        self.alertEnabled = alertEnabled
        self.category = category
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

// MARK: - 计算属性
extension Budget {
    /// 当前已使用金额
    /// 作者: xiaolei
    /// 注意：需要从外部注入交易数据进行计算
    func currentUsage(transactions: [Transaction]) -> Double {
        guard let category = category else { return 0 }

        return transactions
            .filter { transaction in
                transaction.category?.id == category.id &&
                transaction.type == .expense &&
                transaction.date >= startDate &&
                transaction.date <= endDate
            }
            .reduce(0) { $0 + $1.amount }
    }

    /// 剩余预算金额
    /// 作者: xiaolei
    func remainingAmount(transactions: [Transaction]) -> Double {
        max(0, amount - currentUsage(transactions: transactions))
    }

    /// 预算使用百分比（0.0-1.0）
    /// 作者: xiaolei
    func usagePercentage(transactions: [Transaction]) -> Double {
        guard amount > 0 else { return 0 }
        return min(1.0, currentUsage(transactions: transactions) / amount)
    }

    /// 是否应该发出预警
    /// 作者: xiaolei
    func shouldAlert(transactions: [Transaction]) -> Bool {
        guard alertEnabled else { return false }
        return usagePercentage(transactions: transactions) >= alertThreshold
    }

    /// 是否已超支
    /// 作者: xiaolei
    func isExceeded(transactions: [Transaction]) -> Bool {
        currentUsage(transactions: transactions) > amount
    }

    /// 预算状态
    /// 作者: xiaolei
    func status(transactions: [Transaction]) -> BudgetStatus {
        let percentage = usagePercentage(transactions: transactions)

        if percentage >= 1.0 {
            return .exceeded
        } else if percentage >= alertThreshold {
            return .danger
        } else if percentage >= 0.5 {
            return .warning
        } else {
            return .safe
        }
    }

    /// 格式化的预算金额
    /// 作者: xiaolei
    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "CNY"
        formatter.currencySymbol = "¥"
        return formatter.string(from: NSNumber(value: amount)) ?? "¥0.00"
    }

    /// 格式化的剩余金额
    /// 作者: xiaolei
    func formattedRemainingAmount(transactions: [Transaction]) -> String {
        let remaining = remainingAmount(transactions: transactions)
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "CNY"
        formatter.currencySymbol = "¥"
        return formatter.string(from: NSNumber(value: remaining)) ?? "¥0.00"
    }

    /// 是否为当前有效预算
    /// 作者: xiaolei
    var isActive: Bool {
        let now = Date()
        return now >= startDate && now <= endDate
    }
}

/// 预算周期枚举
/// 作者: xiaolei
enum BudgetPeriod: String, Codable, CaseIterable {
    /// 每日
    case daily = "每日"
    /// 每周
    case weekly = "每周"
    /// 每月
    case monthly = "每月"
    /// 每年
    case yearly = "每年"

    /// 对应的SF Symbol图标
    var icon: String {
        switch self {
        case .daily:
            return "sun.max.fill"
        case .weekly:
            return "calendar.badge.clock"
        case .monthly:
            return "calendar"
        case .yearly:
            return "calendar.badge.plus"
        }
    }

    /// 根据开始日期计算结束日期
    /// 作者: xiaolei
    func calculateEndDate(from startDate: Date) -> Date {
        let calendar = Calendar.current
        var dateComponents = DateComponents()

        switch self {
        case .daily:
            dateComponents.day = 1
        case .weekly:
            dateComponents.weekOfYear = 1
        case .monthly:
            dateComponents.month = 1
        case .yearly:
            dateComponents.year = 1
        }

        return calendar.date(byAdding: dateComponents, to: startDate) ?? startDate
    }
}

/// 预算状态枚举
/// 作者: xiaolei
enum BudgetStatus: String, Codable {
    /// 安全（使用<50%）
    case safe = "安全"
    /// 警告（使用50%-预警阈值）
    case warning = "警告"
    /// 危险（使用≥预警阈值）
    case danger = "危险"
    /// 已超支（使用≥100%）
    case exceeded = "已超支"

    /// 对应的颜色名称
    var colorName: String {
        switch self {
        case .safe:
            return "BudgetSafeGreen"
        case .warning:
            return "BudgetWarningOrange"
        case .danger:
            return "BudgetDangerRed"
        case .exceeded:
            return "BudgetExceededDarkRed"
        }
    }

    /// 对应的SF Symbol图标
    var icon: String {
        switch self {
        case .safe:
            return "checkmark.circle.fill"
        case .warning:
            return "exclamationmark.triangle.fill"
        case .danger:
            return "exclamationmark.circle.fill"
        case .exceeded:
            return "xmark.octagon.fill"
        }
    }
}
