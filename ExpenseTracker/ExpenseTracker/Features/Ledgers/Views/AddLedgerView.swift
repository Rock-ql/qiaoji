//
//  AddLedgerView.swift
//  ExpenseTracker
//
//  Created by xiaolei on 2025/11/25.
//  添加账本表单
//

import SwiftUI
import SwiftData

/// 添加账本视图
/// 作者: xiaolei
/// 提供表单界面用于创建新账本
struct AddLedgerView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var icon = "book.fill"
    @State private var color = "4A90E2"
    @State private var ledgerDescription = ""
    @State private var isDefault = false
    @State private var showingIconPicker = false
    @State private var showingColorPicker = false

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
                    TextField("账本名称", text: $name)
                        .textInputAutocapitalization(.never)

                    TextField("描述（可选）", text: $ledgerDescription, axis: .vertical)
                        .lineLimit(3...6)
                        .textInputAutocapitalization(.never)
                }

                // 外观设置
                Section("外观设置") {
                    // 图标选择
                    HStack {
                        Text("图标")
                        Spacer()
                        Image(systemName: icon)
                            .foregroundColor(Color(hex: color) ?? .blue)
                            .frame(width: 30, height: 30)
                            .background(
                                Circle()
                                    .fill(Color(hex: color)?.opacity(0.2) ?? .blue.opacity(0.2))
                            )
                        Image(systemName: showingIconPicker ? "chevron.up" : "chevron.down")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation {
                            showingIconPicker.toggle()
                            if showingIconPicker {
                                showingColorPicker = false
                            }
                        }
                    }

                    if showingIconPicker {
                        LazyVGrid(columns: [
                            GridItem(.adaptive(minimum: 50))
                        ], spacing: 12) {
                            ForEach(icons, id: \.self) { iconName in
                                Image(systemName: iconName)
                                    .font(.title2)
                                    .foregroundColor(icon == iconName ? .white : .primary)
                                    .frame(width: 50, height: 50)
                                    .background(
                                        Circle()
                                            .fill(icon == iconName ? (Color(hex: color) ?? .blue) : Color(.systemGray6))
                                    )
                                    .onTapGesture {
                                        icon = iconName
                                        withAnimation {
                                            showingIconPicker = false
                                        }
                                    }
                            }
                        }
                        .padding(.vertical, 8)
                    }

                    // 颜色选择
                    HStack {
                        Text("颜色")
                        Spacer()
                        Circle()
                            .fill(Color(hex: color) ?? .blue)
                            .frame(width: 30, height: 30)
                        Image(systemName: showingColorPicker ? "chevron.up" : "chevron.down")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation {
                            showingColorPicker.toggle()
                            if showingColorPicker {
                                showingIconPicker = false
                            }
                        }
                    }

                    if showingColorPicker {
                        LazyVGrid(columns: [
                            GridItem(.adaptive(minimum: 50))
                        ], spacing: 12) {
                            ForEach(colors, id: \.self) { colorHex in
                                Circle()
                                    .fill(Color(hex: colorHex) ?? .gray)
                                    .frame(width: 50, height: 50)
                                    .overlay(
                                        Circle()
                                            .stroke(color == colorHex ? Color.primary : Color.clear, lineWidth: 3)
                                    )
                                    .scaleEffect(color == colorHex ? 1.1 : 1.0)
                                    .onTapGesture {
                                        color = colorHex
                                        withAnimation {
                                            showingColorPicker = false
                                        }
                                    }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }

                // 其他设置
                Section("其他设置") {
                    Toggle("设为默认账本", isOn: $isDefault)
                }
            }
            .navigationTitle("添加账本")
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
                    .disabled(name.isEmpty)
                }
            }
        }
    }

    /// 保存账本
    /// 作者: xiaolei
    private func saveLedger() {
        // 如果设为默认，先取消所有其他账本的默认状态
        if isDefault {
            let allLedgers = try? modelContext.fetch(FetchDescriptor<Ledger>())
            allLedgers?.forEach { $0.isDefault = false }
        }

        // 计算新账本的排序顺序（放在最后）
        let descriptor = FetchDescriptor<Ledger>()
        let existingLedgers = (try? modelContext.fetch(descriptor)) ?? []
        let maxSortOrder = existingLedgers.map { $0.sortOrder }.max() ?? -1

        // 创建新账本
        let newLedger = Ledger(
            name: name,
            icon: icon,
            color: color,
            description: ledgerDescription,
            isDefault: isDefault,
            isArchived: false,
            sortOrder: maxSortOrder + 1
        )

        modelContext.insert(newLedger)
        try? modelContext.save()

        dismiss()
    }
}
