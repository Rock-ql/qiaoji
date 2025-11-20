//
//  StatisticsService.swift
//  ExpenseTracker
//
//  Created by xiaolei on 2025/11/13.
//  统计功能的业务逻辑服务类
//

import Foundation
import SwiftData

/// 统计服务类
/// 作者: xiaolei
/// 提供数据查询、聚合、周期计算等功能
@Observable
class StatisticsService {
    /// 获取指定时间维度的周期选项列表
    /// 作者: xiaolei
    /// - Parameters:
    ///   - period: 时间维度（周/月/年）
    ///   - modelContext: SwiftData模型上下文
    /// - Returns: 周期选项数组
    static func getPeriodOptions(for period: TimePeriod, modelContext: ModelContext) -> [PeriodOption] {
        switch period {
        case .week:
            return getWeekOptions(modelContext: modelContext)
        case .month:
            return getMonthOptions(modelContext: modelContext)
        case .year:
            return getYearOptions(modelContext: modelContext)
        }
    }

    /// 获取周选项列表
    /// 作者: xiaolei
    /// 包含：本周、上周、以及所有有交易数据的历史周
    private static func getWeekOptions(modelContext: ModelContext) -> [PeriodOption] {
        var options: [PeriodOption] = []
        let calendar = Calendar.current
        let now = Date()

        // 本周
        let thisWeekStart = calendar.dateInterval(of: .weekOfYear, for: now)!.start
        let thisWeekEnd = calendar.date(byAdding: .day, value: 7, to: thisWeekStart)!
        options.append(PeriodOption(
            id: "thisWeek",
            displayName: "本周",
            startDate: thisWeekStart,
            endDate: thisWeekEnd,
            period: .week
        ))

        // 上周
        let lastWeekStart = calendar.date(byAdding: .weekOfYear, value: -1, to: thisWeekStart)!
        let lastWeekEnd = thisWeekStart
        options.append(PeriodOption(
            id: "lastWeek",
            displayName: "上周",
            startDate: lastWeekStart,
            endDate: lastWeekEnd,
            period: .week
        ))

        // 获取所有有交易数据的周
        let historicalWeeks = getHistoricalWeeks(modelContext: modelContext, excludingLast: 2)
        options.append(contentsOf: historicalWeeks)

        return options
    }

    /// 获取月选项列表
    /// 作者: xiaolei
    /// 包含：本月、上月、以及所有有交易数据的历史月
    private static func getMonthOptions(modelContext: ModelContext) -> [PeriodOption] {
        var options: [PeriodOption] = []
        let calendar = Calendar.current
        let now = Date()

        // 本月
        let thisMonthStart = calendar.dateInterval(of: .month, for: now)!.start
        let thisMonthEnd = calendar.date(byAdding: .month, value: 1, to: thisMonthStart)!
        options.append(PeriodOption(
            id: "thisMonth",
            displayName: "本月",
            startDate: thisMonthStart,
            endDate: thisMonthEnd,
            period: .month
        ))

        // 上月
        let lastMonthStart = calendar.date(byAdding: .month, value: -1, to: thisMonthStart)!
        let lastMonthEnd = thisMonthStart
        options.append(PeriodOption(
            id: "lastMonth",
            displayName: "上月",
            startDate: lastMonthStart,
            endDate: lastMonthEnd,
            period: .month
        ))

        // 获取所有有交易数据的月份
        let historicalMonths = getHistoricalMonths(modelContext: modelContext, excludingLast: 2)
        options.append(contentsOf: historicalMonths)

        return options
    }

    /// 获取年选项列表
    /// 作者: xiaolei
    /// 包含：今年、去年、以及所有有交易数据的历史年
    private static func getYearOptions(modelContext: ModelContext) -> [PeriodOption] {
        var options: [PeriodOption] = []
        let calendar = Calendar.current
        let now = Date()

        // 今年
        let thisYearStart = calendar.dateInterval(of: .year, for: now)!.start
        let thisYearEnd = calendar.date(byAdding: .year, value: 1, to: thisYearStart)!
        options.append(PeriodOption(
            id: "thisYear",
            displayName: "今年",
            startDate: thisYearStart,
            endDate: thisYearEnd,
            period: .year
        ))

        // 去年
        let lastYearStart = calendar.date(byAdding: .year, value: -1, to: thisYearStart)!
        let lastYearEnd = thisYearStart
        options.append(PeriodOption(
            id: "lastYear",
            displayName: "去年",
            startDate: lastYearStart,
            endDate: lastYearEnd,
            period: .year
        ))

        // 获取所有有交易数据的年份
        let historicalYears = getHistoricalYears(modelContext: modelContext, excludingLast: 2)
        options.append(contentsOf: historicalYears)

        return options
    }

    /// 获取历史周选项（有交易数据的周）
    /// 作者: xiaolei
    private static func getHistoricalWeeks(modelContext: ModelContext, excludingLast: Int) -> [PeriodOption] {
        var options: [PeriodOption] = []
        let calendar = Calendar.current
        let now = Date()

        // 获取所有交易的日期
        let descriptor = FetchDescriptor<Transaction>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )

        guard let transactions = try? modelContext.fetch(descriptor) else {
            return []
        }

        // 按周分组
        var weekSet = Set<Date>()
        for transaction in transactions {
            let weekStart = calendar.dateInterval(of: .weekOfYear, for: transaction.date)!.start
            weekSet.insert(weekStart)
        }

        // 转换为周期选项（排除最近的excludingLast周）
        let sortedWeeks = weekSet.sorted(by: >)
        let thisWeekStart = calendar.dateInterval(of: .weekOfYear, for: now)!.start

        for weekStart in sortedWeeks {
            // 跳过最近的几周（已经在本周、上周中显示）
            let weeksAgo = calendar.dateComponents([.weekOfYear], from: weekStart, to: thisWeekStart).weekOfYear ?? 0
            if weeksAgo < excludingLast {
                continue
            }

            let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart)!
            let year = calendar.component(.year, from: weekStart)
            let weekOfYear = calendar.component(.weekOfYear, from: weekStart)

            options.append(PeriodOption(
                id: "week_\(weekStart.timeIntervalSince1970)",
                displayName: "\(year)年第\(weekOfYear)周",
                startDate: weekStart,
                endDate: weekEnd,
                period: .week
            ))

            // 最多显示52周（一年）
            if options.count >= 52 {
                break
            }
        }

        return options
    }

    /// 获取历史月选项（有交易数据的月）
    /// 作者: xiaolei
    private static func getHistoricalMonths(modelContext: ModelContext, excludingLast: Int) -> [PeriodOption] {
        var options: [PeriodOption] = []
        let calendar = Calendar.current
        let now = Date()

        // 获取所有交易的日期
        let descriptor = FetchDescriptor<Transaction>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )

        guard let transactions = try? modelContext.fetch(descriptor) else {
            return []
        }

        // 按月分组
        var monthSet = Set<Date>()
        for transaction in transactions {
            let monthStart = calendar.dateInterval(of: .month, for: transaction.date)!.start
            monthSet.insert(monthStart)
        }

        // 转换为周期选项（排除最近的excludingLast月）
        let sortedMonths = monthSet.sorted(by: >)
        let thisMonthStart = calendar.dateInterval(of: .month, for: now)!.start

        for monthStart in sortedMonths {
            let monthsAgo = calendar.dateComponents([.month], from: monthStart, to: thisMonthStart).month ?? 0
            if monthsAgo < excludingLast {
                continue
            }

            let monthEnd = calendar.date(byAdding: .month, value: 1, to: monthStart)!
            let monthName = monthStart.formatted(.dateTime.year().month(.wide))

            options.append(PeriodOption(
                id: "month_\(monthStart.timeIntervalSince1970)",
                displayName: monthName,
                startDate: monthStart,
                endDate: monthEnd,
                period: .month
            ))

            // 最多显示24个月（两年）
            if options.count >= 24 {
                break
            }
        }

        return options
    }

    /// 获取历史年选项（有交易数据的年）
    /// 作者: xiaolei
    private static func getHistoricalYears(modelContext: ModelContext, excludingLast: Int) -> [PeriodOption] {
        var options: [PeriodOption] = []
        let calendar = Calendar.current
        let now = Date()

        // 获取所有交易的日期
        let descriptor = FetchDescriptor<Transaction>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )

        guard let transactions = try? modelContext.fetch(descriptor) else {
            return []
        }

        // 按年分组
        var yearSet = Set<Date>()
        for transaction in transactions {
            let yearStart = calendar.dateInterval(of: .year, for: transaction.date)!.start
            yearSet.insert(yearStart)
        }

        // 转换为周期选项（排除最近的excludingLast年）
        let sortedYears = yearSet.sorted(by: >)
        let thisYearStart = calendar.dateInterval(of: .year, for: now)!.start

        for yearStart in sortedYears {
            let yearsAgo = calendar.dateComponents([.year], from: yearStart, to: thisYearStart).year ?? 0
            if yearsAgo < excludingLast {
                continue
            }

            let yearEnd = calendar.date(byAdding: .year, value: 1, to: yearStart)!
            let year = calendar.component(.year, from: yearStart)

            options.append(PeriodOption(
                id: "year_\(yearStart.timeIntervalSince1970)",
                displayName: "\(year)年",
                startDate: yearStart,
                endDate: yearEnd,
                period: .year
            ))

            // 最多显示10年
            if options.count >= 10 {
                break
            }
        }

        return options
    }

    /// 计算指定周期的统计数据
    /// 作者: xiaolei
    /// - Parameters:
    ///   - periodOption: 周期选项
    ///   - modelContext: SwiftData模型上下文
    /// - Returns: 周期统计数据
    static func calculateStatistics(for periodOption: PeriodOption, modelContext: ModelContext) -> PeriodStatistics {
        // 查询指定时间范围内的所有交易
        // 捕获外部变量为局部常量，以便在Predicate中使用
        let startDate = periodOption.startDate
        let endDate = periodOption.endDate

        let predicate = #Predicate<Transaction> { transaction in
            transaction.date >= startDate && transaction.date < endDate
        }

        let descriptor = FetchDescriptor<Transaction>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )

        guard let transactions = try? modelContext.fetch(descriptor) else {
            return createEmptyStatistics(for: periodOption)
        }

        // 分离收入和支出
        let incomeTransactions = transactions.filter { $0.type == .income }
        let expenseTransactions = transactions.filter { $0.type == .expense }

        // 计算总额
        let totalIncome = incomeTransactions.reduce(0.0) { $0 + $1.amount }
        let totalExpense = expenseTransactions.reduce(0.0) { $0 + $1.amount }
        let balance = totalIncome - totalExpense

        // 按分类聚合
        let incomeCategories = aggregateByCategory(transactions: incomeTransactions, total: totalIncome)
        let expenseCategories = aggregateByCategory(transactions: expenseTransactions, total: totalExpense)

        return PeriodStatistics(
            period: periodOption,
            totalIncome: totalIncome,
            totalExpense: totalExpense,
            balance: balance,
            incomeCount: incomeTransactions.count,
            expenseCount: expenseTransactions.count,
            incomeCategories: incomeCategories,
            expenseCategories: expenseCategories
        )
    }

    /// 按分类聚合交易数据
    /// 作者: xiaolei
    /// - Parameters:
    ///   - transactions: 交易数组
    ///   - total: 总金额（用于计算百分比）
    /// - Returns: 分类统计数组
    private static func aggregateByCategory(transactions: [Transaction], total: Double) -> [CategoryStatistics] {
        // 按分类分组
        let grouped = Dictionary(grouping: transactions) { transaction -> UUID? in
            transaction.category?.id
        }

        // 计算每个分类的统计数据
        var statistics: [CategoryStatistics] = []

        for (categoryId, categoryTransactions) in grouped {
            let amount = categoryTransactions.reduce(0.0) { $0 + $1.amount }
            let percentage = total > 0 ? amount / total : 0

            // 获取分类信息（使用第一笔交易的分类信息）
            let firstTransaction = categoryTransactions.first!
            let category = firstTransaction.category

            statistics.append(CategoryStatistics(
                id: UUID(),
                categoryId: categoryId,
                categoryName: category?.name ?? "未分类",
                categoryIcon: category?.icon ?? "questionmark.circle",
                categoryColor: category?.color ?? "95A5A6",
                amount: amount,
                transactionCount: categoryTransactions.count,
                percentage: percentage
            ))
        }

        // 按金额降序排序
        return statistics.sorted { $0.amount > $1.amount }
    }

    /// 创建空统计数据
    /// 作者: xiaolei
    private static func createEmptyStatistics(for periodOption: PeriodOption) -> PeriodStatistics {
        return PeriodStatistics(
            period: periodOption,
            totalIncome: 0,
            totalExpense: 0,
            balance: 0,
            incomeCount: 0,
            expenseCount: 0,
            incomeCategories: [],
            expenseCategories: []
        )
    }
}
