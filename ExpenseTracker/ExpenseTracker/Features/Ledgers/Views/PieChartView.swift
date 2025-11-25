//
//  PieChartView.swift
//  ExpenseTracker
//
//  Created by xiaolei on 2025/11/25.
//  分类占比饼状图组件
//

import SwiftUI
import Charts

/// 分类占比饼状图视图
/// 作者: xiaolei
/// 用于展示账本详情页的收入/支出分类占比
struct PieChartView: View {
    let statistics: LedgerStatistics
    @State private var selectedType: TransactionType = .expense

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 标题和类型切换
            HStack {
                Text("分类统计")
                    .font(.headline)
                    .foregroundColor(.primary)

                Spacer()

                Picker("类型", selection: $selectedType) {
                    Text("支出").tag(TransactionType.expense)
                    Text("收入").tag(TransactionType.income)
                }
                .pickerStyle(.segmented)
                .frame(width: 150)
            }

            // 饼状图
            if currentCategories.isEmpty {
                // 空状态
                VStack(spacing: 8) {
                    Image(systemName: "chart.pie")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                    Text("暂无数据")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 200)
            } else {
                // 饼状图
                Chart(currentCategories, id: \.id) { category in
                    SectorMark(
                        angle: .value("金额", category.amount),
                        innerRadius: .ratio(0.5),
                        angularInset: 1.5
                    )
                    .foregroundStyle(Color(hex: category.categoryColor) ?? Color.gray)
                    .annotation(position: .overlay) {
                        if category.percentage >= 0.1 {  // 只显示>=10%的百分比
                            Text(String(format: "%.0f%%", category.percentage * 100))
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        }
                    }
                }
                .frame(height: 200)

                // 图例
                legendView
            }
        }
        .padding()
        .glassmorphism()
    }

    /// 当前选中的分类数据
    /// 作者: xiaolei
    private var currentCategories: [CategoryStatistics] {
        selectedType == .income ? statistics.incomeCategories : statistics.expenseCategories
    }

    /// 图例视图
    /// 作者: xiaolei
    private var legendView: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(currentCategories.prefix(5), id: \.id) { category in
                HStack(spacing: 8) {
                    // 颜色标记
                    Circle()
                        .fill(Color(hex: category.categoryColor) ?? Color.gray)
                        .frame(width: 12, height: 12)

                    // 图标和名称
                    Image(systemName: category.categoryIcon)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text(category.categoryName)
                        .font(.caption)
                        .foregroundColor(.primary)

                    Spacer()

                    // 百分比
                    Text(String(format: "%.1f%%", category.percentage * 100))
                        .font(.caption)
                        .foregroundColor(.secondary)

                    // 金额
                    Text(formatCurrency(category.amount))
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                }
            }

            // 显示"查看更多"提示
            if currentCategories.count > 5 {
                Text("+ \(currentCategories.count - 5)个分类")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.top, 8)
    }

    /// 格式化货币
    /// 作者: xiaolei
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "CNY"
        formatter.currencySymbol = "¥"
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: amount)) ?? "¥0"
    }
}
