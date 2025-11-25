//
//  EditLedgerView.swift
//  ExpenseTracker
//
//  Created by xiaolei on 2025/11/25.
//  编辑账本表单
//

import SwiftUI
import SwiftData

/// 编辑账本视图
/// 作者: xiaolei
/// 提供表单界面用于编辑已有账本，支持归档功能
struct EditLedgerView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Bindable var ledger: Ledger

    @State private var showingIconPicker = false
    @State private var showingColorPicker = false
    @State private var showingArchiveConfirmation = false

    // 常用图标
    private let icons = [
        "book.fill", "tray.fill", "cart.fill", "bag.fill",
        "house.fill", "car.fill", "airplane", "bicycle",
        "fork.knife", "cup.and.saucer.fill", "gift.fill", "heart.fill"
    ]

    // 常用颜色
    private let colors = [
        "4A90E2", "E74C3C", "2ECC71", "F39C12",
        "9B59B6", "1ABC9C", "E67E22", "95A5A6"
    ]

    var body: some View {
        NavigationStack {
            Form {
                // 基本信息
                Section("基本信息") {
                    TextField("账本名称", text: $ledger.name)
                        .textInputAutocapitalization(.never)

                    TextField("描述（可选）", text: $ledger.ledgerDescription, axis: .vertical)
                        .lineLimit(3...6)
                        .textInputAutocapitalization(.never)
                }

                // 外观设置
                Section("外观设置") {
                    // 图标选择
                    Button(action: {
                        showingIconPicker.toggle()
                    }) {
                        HStack {
                            Text("图标")
                                .foregroundColor(.primary)

                            Spacer()

                            Image(systemName: ledger.icon)
                                .foregroundColor(Color(hex: ledger.color) ?? .blue)
                                .frame(width: 30, height: 30)
                                .background(
                                    Circle()
                                        .fill(Color(hex: ledger.color)?.opacity(0.2) ?? .blue.opacity(0.2))
                                )
                        }
                    }

                    if showingIconPicker {
                        LazyVGrid(columns: [
                            GridItem(.adaptive(minimum: 50))
                        ], spacing: 12) {
                            ForEach(icons, id: \.self) { iconName in
                                Button(action: {
                                    ledger.icon = iconName
                                    showingIconPicker = false
                                }) {
                                    Image(systemName: iconName)
                                        .font(.title2)
                                        .foregroundColor(ledger.icon == iconName ? .white : .primary)
                                        .frame(width: 50, height: 50)
                                        .background(
                                            Circle()
                                                .fill(ledger.icon == iconName ? Color.blue : Color(.systemGray6))
                                        )
                                }
                            }
                        }
                        .padding(.vertical, 8)
                    }

                    // 颜色选择
                    Button(action: {
                        showingColorPicker.toggle()
                    }) {
                        HStack {
                            Text("颜色")
                                .foregroundColor(.primary)

                            Spacer()

                            Circle()
                                .fill(Color(hex: ledger.color) ?? .blue)
                                .frame(width: 30, height: 30)
                        }
                    }

                    if showingColorPicker {
                        LazyVGrid(columns: [
                            GridItem(.adaptive(minimum: 50))
                        ], spacing: 12) {
                            ForEach(colors, id: \.self) { colorHex in
                                Button(action: {
                                    ledger.color = colorHex
                                    showingColorPicker = false
                                }) {
                                    Circle()
                                        .fill(Color(hex: colorHex) ?? .gray)
                                        .frame(width: 50, height: 50)
                                        .overlay(
                                            Circle()
                                                .stroke(Color.white, lineWidth: ledger.color == colorHex ? 3 : 0)
                                        )
                                }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }

                // 其他设置
                Section("其他设置") {
                    Toggle("设为默认账本", isOn: $ledger.isDefault)
                        .onChange(of: ledger.isDefault) { oldValue, newValue in
                            if newValue {
                                // 取消其他账本的默认状态
                                let allLedgers = try? modelContext.fetch(FetchDescriptor<Ledger>())
                                allLedgers?.forEach { otherLedger in
                                    if otherLedger.id != ledger.id {
                                        otherLedger.isDefault = false
                                    }
                                }
                            }
                        }
                }

                // 危险操作
                Section {
                    Button(role: .destructive, action: {
                        showingArchiveConfirmation = true
                    }) {
                        Label("归档账本", systemImage: "archivebox")
                    }
                }
            }
            .navigationTitle("编辑账本")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        saveLedger()
                    }
                    .disabled(ledger.name.isEmpty)
                }
            }
            .alert("归档账本", isPresented: $showingArchiveConfirmation) {
                Button("取消", role: .cancel) { }
                Button("归档", role: .destructive) {
                    archiveLedger()
                }
            } message: {
                Text("归档后，此账本将不再显示在列表中，但历史数据会被保留。确定要归档吗？")
            }
        }
    }

    /// 保存账本
    /// 作者: xiaolei
    private func saveLedger() {
        ledger.updatedAt = Date()
        try? modelContext.save()
        dismiss()
    }

    /// 归档账本
    /// 作者: xiaolei
    private func archiveLedger() {
        ledger.isArchived = true
        ledger.updatedAt = Date()

        // 如果归档的是默认账本，需要重新指定默认账本
        if ledger.isDefault {
            let descriptor = FetchDescriptor<Ledger>(
                predicate: #Predicate { !$0.isArchived }
            )
            let activeLedgers = (try? modelContext.fetch(descriptor)) ?? []
            if let firstActive = activeLedgers.first(where: { $0.id != ledger.id }) {
                firstActive.isDefault = true
            }
        }

        try? modelContext.save()
        dismiss()
    }
}
