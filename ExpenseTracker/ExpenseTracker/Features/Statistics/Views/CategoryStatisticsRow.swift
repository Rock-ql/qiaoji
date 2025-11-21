//
//  CategoryStatisticsRow.swift
//  ExpenseTracker
//
//  Created by xiaolei on 2025/11/13.
//  单个分类的统计行视图
//

import SwiftUI

/// 分类统计行视图
/// 作者: xiaolei
/// 显示单个分类的图标、名称、金额和占比信息
struct CategoryStatisticsRow: View {
    let categoryStats: CategoryStatistics

    var body: some View {
        HStack(spacing: 12) {
            // 分类图标
            ZStack {
                Circle()
                    .fill(categoryStats.color.opacity(0.15))
                    .frame(width: 44, height: 44)

                Image(systemName: categoryStats.categoryIcon)
                    .font(.system(size: 20))
                    .foregroundColor(categoryStats.color)
            }

            VStack(alignment: .leading, spacing: 8) {
                // 标题行：名称 + 笔数 + 金额 + 箭头
                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(categoryStats.categoryName)
                            .font(.body)
                            .fontWeight(.medium)

                        Text("\(categoryStats.transactionCount)笔")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Text(categoryStats.formattedAmount)
                        .font(.body)
                        .fontWeight(.semibold)

                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                // 占比线条
                HStack(spacing: 8) {
                    ProgressView(value: categoryStats.percentage)
                        .progressViewStyle(.linear)
                        .tint(categoryStats.color)
                        .frame(height: 6)
                        .animation(.easeInOut(duration: 0.25), value: categoryStats.percentage)

                    Text(categoryStats.formattedPercentage)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(width: 48, alignment: .trailing)
                }
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal)
        .background(Color(.systemBackground))
    }
}
