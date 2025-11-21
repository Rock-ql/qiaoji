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

    /// 已经过的天数（包含起始日，结束日不超过当前时间）
    /// 作者: xiaolei
    var elapsedDays: Int {
        let calendar = Calendar.current
        let todayStart = calendar.startOfDay(for: Date())

        // 针对周统计，使用 ISO 周（周一为一周开始）确保天数符合用户认知
        if period.period == .week {
            var isoCal = Calendar(identifier: .iso8601)
            isoCal.firstWeekday = 2 // 周一

            // 获取该周的起始周一
            let comp = isoCal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: period.startDate)
            let isoStart = isoCal.date(from: comp) ?? calendar.startOfDay(for: period.startDate)
            // 该周的结束开区间（下周一）
            let isoEndExclusive = isoCal.date(byAdding: .day, value: 7, to: isoStart) ?? period.endDate

            let endInclusive = isoCal.date(byAdding: .day, value: -1, to: isoEndExclusive) ?? isoEndExclusive
            let logicalEnd = min(endInclusive, todayStart)

            guard logicalEnd >= isoStart else { return 1 }
            let days = isoCal.dateComponents([.day], from: isoStart, to: logicalEnd).day ?? 0
            return max(1, days + 1)
        }

        // 月/年沿用周期起止，但仍按开区间处理 endDate
        let start = calendar.startOfDay(for: period.startDate)
        let endExclusive = calendar.startOfDay(for: period.endDate)
        let endInclusive = calendar.date(byAdding: .day, value: -1, to: endExclusive) ?? endExclusive
        let logicalEnd = min(endInclusive, todayStart)

        guard logicalEnd >= start else { return 1 }
        let days = calendar.dateComponents([.day], from: start, to: logicalEnd).day ?? 0
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
