//
//  LedgerCardView.swift
//  ExpenseTracker
//
//  Created by xiaolei on 2025/11/25.
//  账本卡片组件
//

import SwiftUI

/// 账本卡片视图
/// 作者: xiaolei
/// 用于账本列表展示，采用玻璃拟态风格
struct LedgerCardView: View {
    let ledger: Ledger

    /// 账本主题色
    private var themeColor: Color {
        Color(hex: ledger.color) ?? .blue
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // 顶部：图标和名称
            HStack(spacing: 10) {
                Image(systemName: ledger.icon)
                    .font(.title3)
                    .foregroundColor(themeColor)
                    .frame(width: 36, height: 36)
                    .background(
                        Circle()
                            .fill(themeColor.opacity(0.15))
                    )

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Text(ledger.name)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                            .lineLimit(1)

                        if ledger.isDefault {
                            Text("默认")
                                .font(.system(size: 9))
                                .foregroundColor(.white)
                                .padding(.horizontal, 4)
                                .padding(.vertical, 2)
                                .background(Capsule().fill(Color.blue))
                        }
                    }

                    Text("\(ledger.transactionCount)笔交易")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }

                Spacer()
            }

            Divider()

            // 统计信息
            HStack(spacing: 0) {
                // 收入
                VStack(alignment: .leading, spacing: 2) {
                    Text("收入")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(formatAmount(ledger.totalIncome))
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.green)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // 支出
                VStack(alignment: .trailing, spacing: 2) {
                    Text("支出")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(formatAmount(ledger.totalExpense))
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.red)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }

            // 结余
            HStack {
                Text("结余")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Spacer()
                Text(formatAmount(ledger.balance))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(ledger.balance >= 0 ? .green : .red)
            }
        }
        .padding(12)
        .frame(height: 150) // 固定高度确保卡片大小一致
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
    }

    /// 格式化金额（简洁显示）
    /// 作者: xiaolei
    private func formatAmount(_ amount: Double) -> String {
        if amount >= 10000 {
            return String(format: "¥%.1fw", amount / 10000)
        } else if amount >= 1000 {
            return String(format: "¥%.0f", amount)
        } else {
            return String(format: "¥%.2f", amount)
        }
    }
}
