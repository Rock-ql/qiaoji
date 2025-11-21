//
//  StatisticsModels.swift
//  ExpenseTracker
//
//  Created by xiaolei on 2025/11/13.
//  统计功能相关的数据模型
//

import Foundation
import SwiftUI

// MARK: - 时间维度枚举
/// 统计时间维度
/// 作者: xiaolei
enum TimePeriod: String, CaseIterable, Identifiable {
    case week = "周"
    case month = "月"
    case year = "年"

    var id: String { rawValue }

    /// 获取显示名称
    var displayName: String { rawValue }
}

// MARK: - 周期选项
/// 具体的时间周期选项
/// 作者: xiaolei
struct PeriodOption: Identifiable, Hashable {
    let id: String
    let displayName: String
    let startDate: Date
    let endDate: Date
    let period: TimePeriod

    /// 便捷初始化方法
    /// 作者: xiaolei
    init(id: String, displayName: String, startDate: Date, endDate: Date, period: TimePeriod) {
        self.id = id
        self.displayName = displayName
        self.startDate = startDate
        self.endDate = endDate
        self.period = period
    }

    /// 判断是否为当前周期
    /// 作者: xiaolei
    var isCurrent: Bool {
        let now = Date()
        return now >= startDate && now < endDate
    }
}

// MARK: - 分类统计数据
/// 单个分类的统计数据
/// 作者: xiaolei
struct CategoryStatistics: Identifiable {
    let id: UUID
    let categoryId: UUID?
    let categoryName: String
    let categoryIcon: String
    let categoryColor: String
    let amount: Double
    let transactionCount: Int
    let percentage: Double

    /// 格式化的金额字符串
    /// 作者: xiaolei
    var formattedAmount: String {
        String(format: "¥%.2f", amount)
    }

    /// 格式化的百分比字符串
    /// 作者: xiaolei
    var formattedPercentage: String {
        String(format: "%.1f%%", percentage * 100)
    }

    /// 获取分类颜色
    /// 作者: xiaolei
    var color: Color {
        Color(hex: categoryColor) ?? .gray
    }
}

// MARK: - 周期统计汇总
/// 整个时间周期的统计汇总数据
/// 作者: xiaolei
struct PeriodStatistics {
    let period: PeriodOption
    let totalIncome: Double
    let totalExpense: Double
    let balance: Double
    let incomeCount: Int
    let expenseCount: Int
    let incomeCategories: [CategoryStatistics]
    let expenseCategories: [CategoryStatistics]

    /// 格式化的总收入
    /// 作者: xiaolei
    var formattedIncome: String {
        String(format: "¥%.2f", totalIncome)
    }

    /// 格式化的总支出
    /// 作者: xiaolei
    var formattedExpense: String {
        String(format: "¥%.2f", totalExpense)
    }

    /// 格式化的结余
    /// 作者: xiaolei
    var formattedBalance: String {
        String(format: "¥%.2f", balance)
    }

    /// 总交易笔数
    /// 作者: xiaolei
    var totalCount: Int {
        incomeCount + expenseCount
    }

    /// 是否有数据
    /// 作者: xiaolei
    var hasData: Bool {
        totalCount > 0
    }

    /// 已经过的天数（从周期开始到今天，包含首尾两天）
    /// 作者: xiaolei
    /// 例如：本周统计，今天周五，则返回5（周一到周五）
    var elapsedDays: Int {
        let calendar = Calendar.current
        let todayStart = calendar.startOfDay(for: Date())
        let periodStart = calendar.startOfDay(for: period.startDate)

        // 周期结束日是开区间，需要减1天得到闭区间的最后一天
        let periodEndExclusive = calendar.startOfDay(for: period.endDate)
        let periodEndInclusive = calendar.date(byAdding: .day, value: -1, to: periodEndExclusive) ?? periodEndExclusive

        // 取周期结束日和今天的较小值作为实际结束日
        let effectiveEnd = min(periodEndInclusive, todayStart)

        // 确保实际结束日不早于开始日
        guard effectiveEnd >= periodStart else { return 1 }

        // 计算天数差（+1 因为包含首尾两天）
        let days = calendar.dateComponents([.day], from: periodStart, to: effectiveEnd).day ?? 0
        return max(1, days + 1)
    }

    /// 平均每日支出
    /// 作者: xiaolei
    var expenseDailyAverage: Double {
        guard totalExpense > 0 else { return 0 }
        return totalExpense / Double(elapsedDays)
    }

    /// 格式化的平均每日支出
    /// 作者: xiaolei
    var formattedExpenseDailyAverage: String {
        String(format: "¥%.2f", expenseDailyAverage)
    }
}

// MARK: - Color扩展
/// Color扩展，支持十六进制颜色
/// 作者: xiaolei
extension Color {
    /// 从十六进制字符串创建颜色
    /// 作者: xiaolei
    /// - Parameter hex: 十六进制颜色字符串（如"FF6B6B"）
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else {
            return nil
        }

        let length = hexSanitized.count
        let r, g, b: Double

        if length == 6 {
            r = Double((rgb & 0xFF0000) >> 16) / 255.0
            g = Double((rgb & 0x00FF00) >> 8) / 255.0
            b = Double(rgb & 0x0000FF) / 255.0
        } else {
            return nil
        }

        self.init(red: r, green: g, blue: b)
    }
}
