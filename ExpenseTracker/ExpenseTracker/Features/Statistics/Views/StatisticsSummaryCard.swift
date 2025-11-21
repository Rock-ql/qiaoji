//
//  StatisticsSummaryCard.swift
//  ExpenseTracker
//
//  Created by xiaolei on 2025/11/13.
//  统计汇总卡片组件
//

import SwiftUI

/// 统计汇总卡片视图
/// 作者: xiaolei
/// 显示总收入、总支出和结余信息
struct StatisticsSummaryCard: View {
    let statistics: PeriodStatistics

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 标题
            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundColor(.blue)
                Text("汇总")
                    .font(.headline)
                Spacer()
                Text("\(statistics.totalCount)笔")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // 统计数据
            VStack(spacing: 12) {
                // 收入
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.down.circle.fill")
                            .foregroundColor(.green)
                        Text("收入")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Text(statistics.formattedIncome)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                }

                // 支出
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.up.circle.fill")
                            .foregroundColor(.red)
                        Text("支出")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Text(statistics.formattedExpense)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.red)
                }

                // 平均（按日）
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: "calendar.badge.clock")
                            .foregroundColor(.purple)
                        Text("平均/日")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Text(statistics.formattedExpenseDailyAverage)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.purple)
                }

                Divider()

                // 结余
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: "equal.circle.fill")
                            .foregroundColor(statistics.balance >= 0 ? .blue : .orange)
                        Text("结余")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Text(statistics.formattedBalance)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(statistics.balance >= 0 ? .blue : .orange)
                }
            }
        }
        .frame(height: 220)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
}
