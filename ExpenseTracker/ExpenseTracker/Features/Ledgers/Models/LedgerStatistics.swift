//
//  LedgerStatistics.swift
//  ExpenseTracker
//
//  Created by xiaolei on 2025/11/25.
//  账本统计数据模型
//

import Foundation

/// 账本统计数据
/// 作者: xiaolei
/// 存储账本的全量统计信息
struct LedgerStatistics {
    /// 账本引用
    let ledger: Ledger

    /// 总收入
    let totalIncome: Double

    /// 总支出
    let totalExpense: Double

    /// 结余
    let balance: Double

    /// 交易笔数
    let transactionCount: Int

    /// 收入分类统计
    let incomeCategories: [CategoryStatistics]

    /// 支出分类统计
    let expenseCategories: [CategoryStatistics]

    /// 是否有数据
    /// 作者: xiaolei
    var hasData: Bool {
        transactionCount > 0
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
