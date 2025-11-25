//
//  LedgerPickerView.swift
//  ExpenseTracker
//
//  Created by xiaolei on 2025/11/25.
//  账本选择器组件
//

import SwiftUI
import SwiftData

/// 账本选择器视图
/// 作者: xiaolei
/// 用于统计页和交易列表顶部的账本切换
struct LedgerPickerView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<Ledger> { !$0.isArchived }, sort: \Ledger.sortOrder)
    private var ledgers: [Ledger]

    @Binding var selectedLedger: Ledger?
    let showAllOption: Bool

    init(selectedLedger: Binding<Ledger?>, showAllOption: Bool = true) {
        self._selectedLedger = selectedLedger
        self.showAllOption = showAllOption
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // "全部"选项
                if showAllOption {
                    Button(action: {
                        selectedLedger = nil
                    }) {
                        Text("全部")
                            .font(.subheadline)
                            .fontWeight(selectedLedger == nil ? .semibold : .regular)
                            .foregroundColor(selectedLedger == nil ? .white : .primary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(selectedLedger == nil ? Color.blue : Color(.systemGray6))
                            )
                    }
                }

                // 账本选项
                ForEach(ledgers) { ledger in
                    Button(action: {
                        selectedLedger = ledger
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: ledger.icon)
                                .font(.caption)
                            Text(ledger.name)
                                .font(.subheadline)
                        }
                        .fontWeight(selectedLedger?.id == ledger.id ? .semibold : .regular)
                        .foregroundColor(selectedLedger?.id == ledger.id ? .white : .primary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(selectedLedger?.id == ledger.id ? Color(ledger.color) : Color(.systemGray6))
                        )
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}
