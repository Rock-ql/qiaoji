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
                    .fill(categoryStats.color.opacity(0.2))
                    .frame(width: 44, height: 44)

                Image(systemName: categoryStats.categoryIcon)
                    .font(.system(size: 20))
                    .foregroundColor(categoryStats.color)
            }

            // 分类名称和笔数
            VStack(alignment: .leading, spacing: 4) {
                Text(categoryStats.categoryName)
                    .font(.body)
                    .fontWeight(.medium)

                Text("\(categoryStats.transactionCount)笔")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            // 金额和占比
            VStack(alignment: .trailing, spacing: 4) {
                Text(categoryStats.formattedAmount)
                    .font(.body)
                    .fontWeight(.semibold)

                Text(categoryStats.formattedPercentage)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // 箭头图标
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
        .padding(.horizontal)
        .background(Color(.systemBackground))
    }
}
