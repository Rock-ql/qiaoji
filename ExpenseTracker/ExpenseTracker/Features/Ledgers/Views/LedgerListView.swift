//
//  LedgerListView.swift
//  ExpenseTracker
//
//  Created by xiaolei on 2025/11/25.
//  账本列表页面
//

import SwiftUI
import SwiftData

/// 账本列表视图
/// 作者: xiaolei
/// 使用2列网格布局展示所有账本，支持添加、编辑、归档功能
struct LedgerListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<Ledger> { !$0.isArchived }, sort: \Ledger.sortOrder)
    private var ledgers: [Ledger]

    @State private var showingAddLedger = false
    @State private var selectedLedger: Ledger?

    // 网格布局配置
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        ZStack {
            if ledgers.isEmpty {
                // 空状态
                emptyStateView
            } else {
                // 账本网格列表
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(ledgers) { ledger in
                            Button {
                                selectedLedger = ledger
                            } label: {
                                LedgerCardView(ledger: ledger)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding()
                }
            }

            // 浮动添加按钮
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        showingAddLedger = true
                    }) {
                        Image(systemName: "plus")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(
                                Circle()
                                    .fill(Color.blue)
                                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                            )
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("账本管理")
        .navigationDestination(isPresented: Binding(
            get: { selectedLedger != nil },
            set: { if !$0 { selectedLedger = nil } }
        )) {
            if let ledger = selectedLedger {
                LedgerDetailView(ledger: ledger)
            }
        }
        .sheet(isPresented: $showingAddLedger) {
            AddLedgerView()
        }
    }

    /// 空状态视图
    /// 作者: xiaolei
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "book.closed")
                .font(.system(size: 60))
                .foregroundColor(.secondary)

            Text("还没有账本")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)

            Text("点击右下角的 + 按钮创建第一个账本")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}
