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

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 顶部：图标和名称
            HStack {
                Image(systemName: ledger.icon)
                    .font(.title2)
                    .foregroundColor(Color(ledger.color))
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(Color(ledger.color).opacity(0.2))
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text(ledger.name)
                        .font(.headline)
                        .foregroundColor(.primary)

                    if ledger.isDefault {
                        Text("默认")
                            .font(.caption2)
                            .foregroundColor(.blue)
                    }
                }

                Spacer()
            }

            // 统计信息
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("收支")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(ledger.formattedBalance)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(ledger.balance >= 0 ? .green : .red)
                }

                HStack {
                    Text("笔数")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(ledger.transactionCount)笔")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .glassmorphism()
    }
}
