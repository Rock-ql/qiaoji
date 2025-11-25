//
//  LedgerSummaryCard.swift
//  ExpenseTracker
//
//  Created by xiaolei on 2025/11/25.
//  账本汇总统计卡片
//

import SwiftUI

/// 账本汇总统计卡片视图
/// 作者: xiaolei
/// 用于账本详情页展示汇总统计数据，采用玻璃拟态风格
struct LedgerSummaryCard: View {
    let statistics: LedgerStatistics

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 标题
            Text("汇总统计")
                .font(.headline)
                .foregroundColor(.primary)

            // 统计数据网格
            VStack(spacing: 12) {
                // 第一行：总收入和总支出
                HStack(spacing: 12) {
                    statisticItem(
                        title: "总收入",
                        value: statistics.formattedTotalIncome,
                        color: .green
                    )

                    statisticItem(
                        title: "总支出",
                        value: statistics.formattedTotalExpense,
                        color: .red
                    )
                }

                // 第二行：结余和交易笔数
                HStack(spacing: 12) {
                    statisticItem(
                        title: "结余",
                        value: statistics.formattedBalance,
                        color: statistics.balance >= 0 ? .green : .red
                    )

                    statisticItem(
                        title: "交易笔数",
                        value: "\(statistics.transactionCount)笔",
                        color: .blue
                    )
                }
            }
        }
        .padding()
        .glassmorphism()
    }

    /// 统计项视图
    /// 作者: xiaolei
    /// - Parameters:
    ///   - title: 标题
    ///   - value: 数值
    ///   - color: 颜色
    /// - Returns: 统计项视图
    private func statisticItem(title: String, value: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)

            Text(value)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
        )
    }
}
