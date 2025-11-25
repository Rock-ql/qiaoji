//
//  LedgerService.swift
//  ExpenseTracker
//
//  Created by xiaolei on 2025/11/25.
//  账本功能的业务逻辑服务类
//

import Foundation
import SwiftData

/// 账本服务类
/// 作者: xiaolei
/// 提供账本CRUD、统计计算、趋势数据生成等功能
struct LedgerService {
    /// 获取默认账本
    /// 作者: xiaolei
    /// - Parameter modelContext: SwiftData模型上下文
    /// - Returns: 默认账本（如果存在）
    static func getDefaultLedger(modelContext: ModelContext) -> Ledger? {
        let descriptor = FetchDescriptor<Ledger>(
            predicate: #Predicate { $0.isDefault == true && $0.isArchived == false }
        )
        return try? modelContext.fetch(descriptor).first
    }

    /// 获取所有活跃账本（未归档）
    /// 作者: xiaolei
    /// - Parameter modelContext: SwiftData模型上下文
    /// - Returns: 活跃账本数组（按排序顺序）
    static func getActiveLedgers(modelContext: ModelContext) -> [Ledger] {
        let descriptor = FetchDescriptor<Ledger>(
            predicate: #Predicate { $0.isArchived == false }
        )
        let ledgers = (try? modelContext.fetch(descriptor)) ?? []
        return ledgers.sorted()  // 使用Ledger的Comparable实现排序
    }

    /// 设置默认账本
    /// 作者: xiaolei
    /// - Parameters:
    ///   - ledger: 要设置为默认的账本
    ///   - modelContext: SwiftData模型上下文
    static func setDefaultLedger(_ ledger: Ledger, modelContext: ModelContext) {
        // 1. 取消所有账本的默认状态
        let allLedgers = try? modelContext.fetch(FetchDescriptor<Ledger>())
        allLedgers?.forEach { $0.isDefault = false }

        // 2. 设置新的默认账本
        ledger.isDefault = true
        ledger.updatedAt = Date()

        // 3. 保存
        try? modelContext.save()
    }

    /// 计算账本统计数据（全量）
    /// 作者: xiaolei
    /// - Parameters:
    ///   - ledger: 要统计的账本
    ///   - modelContext: SwiftData模型上下文
    /// - Returns: 账本统计数据
    static func calculateLedgerStatistics(
        for ledger: Ledger,
        modelContext: ModelContext
    ) -> LedgerStatistics {
        // 查询该账本的所有交易
        let ledgerId = ledger.id
        let predicate = #Predicate<Transaction> { transaction in
            transaction.ledger?.id == ledgerId
        }
        let descriptor = FetchDescriptor<Transaction>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )

        guard let transactions = try? modelContext.fetch(descriptor) else {
            return LedgerStatistics(
                ledger: ledger,
                totalIncome: 0,
                totalExpense: 0,
                balance: 0,
                transactionCount: 0,
                incomeCategories: [],
                expenseCategories: []
            )
        }

        // 分离收入和支出
        let incomeTransactions = transactions.filter { $0.type == .income }
        let expenseTransactions = transactions.filter { $0.type == .expense }

        // 计算总额
        let totalIncome = incomeTransactions.reduce(0.0) { $0 + $1.amount }
        let totalExpense = expenseTransactions.reduce(0.0) { $0 + $1.amount }

        // 按分类聚合
        let incomeCategories = aggregateByCategory(incomeTransactions, total: totalIncome)
        let expenseCategories = aggregateByCategory(expenseTransactions, total: totalExpense)

        return LedgerStatistics(
            ledger: ledger,
            totalIncome: totalIncome,
            totalExpense: totalExpense,
            balance: totalIncome - totalExpense,
            transactionCount: transactions.count,
            incomeCategories: incomeCategories,
            expenseCategories: expenseCategories
        )
    }

    /// 计算账本趋势数据（自适应粒度）
    /// 作者: xiaolei
    /// - Parameters:
    ///   - ledger: 要统计的账本
    ///   - modelContext: SwiftData模型上下文
    /// - Returns: 趋势数据点数组
    static func calculateLedgerTrendData(
        for ledger: Ledger,
        modelContext: ModelContext
    ) -> [TrendDataPoint] {
        // 查询该账本的所有交易
        let ledgerId = ledger.id
        let predicate = #Predicate<Transaction> { transaction in
            transaction.ledger?.id == ledgerId
        }
        let descriptor = FetchDescriptor<Transaction>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.date)]
        )

        guard let transactions = try? modelContext.fetch(descriptor),
              !transactions.isEmpty else {
            return []
        }

        // 计算日期跨度
        guard let firstDate = transactions.first?.date,
              let lastDate = transactions.last?.date else {
            return []
        }

        let dayCount = Calendar.current.dateComponents([.day], from: firstDate, to: lastDate).day ?? 0

        // 根据跨度选择粒度
        if dayCount < 30 {
            // 按天
            return groupByDay(transactions)
        } else if dayCount < 365 {
            // 按周
            return groupByWeek(transactions)
        } else {
            // 按月
            return groupByMonth(transactions)
        }
    }

    // MARK: - 私有辅助方法

    /// 按分类聚合交易
    /// 作者: xiaolei
    private static func aggregateByCategory(_ transactions: [Transaction], total: Double) -> [CategoryStatistics] {
        let grouped = Dictionary(grouping: transactions) { $0.category?.id }

        var statistics: [CategoryStatistics] = []

        for (categoryId, categoryTransactions) in grouped {
            let amount = categoryTransactions.reduce(0.0) { $0 + $1.amount }
            let percentage = total > 0 ? amount / total : 0

            let firstTransaction = categoryTransactions.first!
            let stat = CategoryStatistics(
                id: UUID(),
                categoryId: categoryId,
                categoryName: firstTransaction.categoryName,
                categoryIcon: firstTransaction.categoryIcon,
                categoryColor: firstTransaction.category?.color ?? "95A5A6",
                amount: amount,
                transactionCount: categoryTransactions.count,
                percentage: percentage
            )
            statistics.append(stat)
        }

        // 按金额降序排列
        return statistics.sorted { $0.amount > $1.amount }
    }

    /// 按天分组
    /// 作者: xiaolei
    private static func groupByDay(_ transactions: [Transaction]) -> [TrendDataPoint] {
        guard let firstDate = transactions.first?.date,
              let lastDate = transactions.last?.date else {
            return []
        }

        let calendar = Calendar.current
        var dataPoints: [TrendDataPoint] = []
        var currentDate = calendar.startOfDay(for: firstDate)
        let finalDate = calendar.startOfDay(for: lastDate)

        while currentDate <= finalDate {
            let dayTransactions = transactions.filter {
                calendar.isDate($0.date, inSameDayAs: currentDate)
            }

            let income = dayTransactions.filter { $0.type == .income }.reduce(0.0) { $0 + $1.amount }
            let expense = dayTransactions.filter { $0.type == .expense }.reduce(0.0) { $0 + $1.amount }

            dataPoints.append(TrendDataPoint(date: currentDate, income: income, expense: expense))
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }

        return dataPoints
    }

    /// 按周分组
    /// 作者: xiaolei
    private static func groupByWeek(_ transactions: [Transaction]) -> [TrendDataPoint] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: transactions) { transaction in
            calendar.dateInterval(of: .weekOfYear, for: transaction.date)!.start
        }

        var dataPoints: [TrendDataPoint] = []

        for (weekStart, weekTransactions) in grouped.sorted(by: { $0.key < $1.key }) {
            let income = weekTransactions.filter { $0.type == .income }.reduce(0.0) { $0 + $1.amount }
            let expense = weekTransactions.filter { $0.type == .expense }.reduce(0.0) { $0 + $1.amount }

            dataPoints.append(TrendDataPoint(date: weekStart, income: income, expense: expense))
        }

        return dataPoints
    }

    /// 按月分组
    /// 作者: xiaolei
    private static func groupByMonth(_ transactions: [Transaction]) -> [TrendDataPoint] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: transactions) { transaction in
            calendar.dateInterval(of: .month, for: transaction.date)!.start
        }

        var dataPoints: [TrendDataPoint] = []

        for (monthStart, monthTransactions) in grouped.sorted(by: { $0.key < $1.key }) {
            let income = monthTransactions.filter { $0.type == .income }.reduce(0.0) { $0 + $1.amount }
            let expense = monthTransactions.filter { $0.type == .expense }.reduce(0.0) { $0 + $1.amount }

            dataPoints.append(TrendDataPoint(date: monthStart, income: income, expense: expense))
        }

        return dataPoints
    }
}
