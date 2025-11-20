//
//  CategoryListRow.swift
//  ExpenseTracker
//
//  Created by xiaolei on 2025/11/13.
//  分类列表行组件
//

import SwiftUI

/// 分类列表行视图
/// 作者: xiaolei
/// 用于在分类管理界面展示单个分类信息
struct CategoryListRow: View {
    /// 要展示的分类
    let category: Category

    var body: some View {
        HStack(spacing: 16) {
            // 分类图标
            Image(systemName: category.icon)
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 50, height: 50)
                .background(
                    Circle()
                        .fill(Color(category.color))
                )

            // 分类信息
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(category.name)
                        .font(.headline)

                    // 系统分类标识
                    if category.isSystem {
                        Image(systemName: "lock.fill")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                HStack(spacing: 12) {
                    // 交易笔数
                    Label("\(category.transactionCount) 笔", systemImage: "list.bullet")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    // 总金额
                    if category.transactionCount > 0 {
                        Text(category.formattedTotalAmount)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }

            Spacer()

            // 箭头指示器
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }
}

// MARK: - 预览

#Preview("支出分类") {
    List {
        CategoryListRow(
            category: Category(
                name: "餐饮",
                icon: "fork.knife",
                color: "FF6B6B",
                type: .expense,
                isSystem: true
            )
        )

        CategoryListRow(
            category: Category(
                name: "交通",
                icon: "car.fill",
                color: "4ECDC4",
                type: .expense,
                isSystem: false
            )
        )
    }
}

#Preview("收入分类") {
    List {
        CategoryListRow(
            category: Category(
                name: "工资",
                icon: "dollarsign.circle.fill",
                color: "2ECC71",
                type: .income,
                isSystem: true
            )
        )
    }
}
