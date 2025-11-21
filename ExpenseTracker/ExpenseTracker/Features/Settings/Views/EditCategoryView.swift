//
//  EditCategoryView.swift
//  ExpenseTracker
//
//  Created by xiaolei on 2025/11/13.
//  编辑分类界面
//

import SwiftUI
import SwiftData

/// 编辑分类视图
/// 作者: xiaolei
/// 用于编辑现有分类的信息
struct EditCategoryView: View {
    /// 关闭视图
    @Environment(\.dismiss) private var dismiss

    /// 访问数据库上下文
    @Environment(\.modelContext) private var modelContext

    /// 要编辑的分类
    let category: Category

    /// 分类名称
    @State private var name = ""

    /// 选中的图标
    @State private var selectedIcon = ""

    /// 选中的颜色
    @State private var selectedColor = ""

    /// 是否显示图标选择器
    @State private var showIconPicker = false

    /// 是否显示颜色选择器
    @State private var showColorPicker = false

    /// 是否显示删除确认对话框
    @State private var showDeleteAlert = false

    var body: some View {
        NavigationStack {
            Form {
                // 分类类型（只读）
                Section {
                    HStack {
                        Text("类型")
                        Spacer()
                        Text(category.type == .expense ? "支出" : "收入")
                            .foregroundColor(.secondary)
                    }
                } footer: {
                    Text("分类类型创建后不可更改")
                }

                // 分类名称
                Section {
                    TextField("请输入分类名称", text: $name)
                        .disabled(category.isSystem)
                } header: {
                    Text("分类名称")
                } footer: {
                    if category.isSystem {
                        Text("系统预设分类名称不可修改")
                    }
                }

                // 图标选择
                Section {
                    Button {
                        showIconPicker = true
                    } label: {
                        HStack {
                            Text("图标")
                                .foregroundColor(.primary)

                            Spacer()

                            // 当前选中的图标预览
                            Image(systemName: selectedIcon)
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 40, height: 40)
                                .background(
                                    Circle()
                                        .fill(Color(selectedColor))
                                )

                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                } header: {
                    Text("图标")
                }

                // 颜色选择
                Section {
                    Button {
                        showColorPicker = true
                    } label: {
                        HStack {
                            Text("颜色")
                                .foregroundColor(.primary)

                            Spacer()

                            // 当前选中的颜色预览
                            Circle()
                                .fill(Color(selectedColor))
                                .frame(width: 30, height: 30)

                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                } header: {
                    Text("颜色")
                }

                // 统计信息
                Section {
                    HStack {
                        Text("交易笔数")
                        Spacer()
                        Text("\(category.transactionCount) 笔")
                            .foregroundColor(.secondary)
                    }

                    if category.transactionCount > 0 {
                        HStack {
                            Text("总金额")
                            Spacer()
                            Text(category.formattedTotalAmount)
                                .foregroundColor(.secondary)
                        }
                    }
                } header: {
                    Text("统计信息")
                }

                // 删除按钮
                if !category.isSystem {
                    Section {
                        Button(role: .destructive) {
                            showDeleteAlert = true
                        } label: {
                            HStack {
                                Spacer()
                                Text("删除分类")
                                Spacer()
                            }
                        }
                        .disabled(category.transactionCount > 0)
                    } footer: {
                        if category.transactionCount > 0 {
                            Text("该分类下有交易记录，无法删除。请先处理这些交易。")
                        }
                    }
                }
            }
            .navigationTitle("编辑分类")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        saveChanges()
                    }
                    .disabled(!canSave)
                }
            }
            .sheet(isPresented: $showIconPicker) {
                IconPickerView(selectedIcon: $selectedIcon)
            }
            .sheet(isPresented: $showColorPicker) {
                ColorPickerView(selectedColor: $selectedColor)
            }
            .alert("确认删除", isPresented: $showDeleteAlert) {
                Button("取消", role: .cancel) {}
                Button("删除", role: .destructive) {
                    deleteCategory()
                }
            } message: {
                Text("确定要删除「\(category.name)」分类吗？此操作不可撤销。")
            }
            .onAppear {
                // 预填充数据
                name = category.name
                selectedIcon = category.icon
                selectedColor = category.color
            }
        }
    }

    /// 是否可以保存
    /// 作者: xiaolei
    private var canSave: Bool {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmedName.isEmpty &&
               (trimmedName != category.name ||
                selectedIcon != category.icon ||
                selectedColor != category.color)
    }

    /// 保存更改
    /// 作者: xiaolei
    private func saveChanges() {
        // 更新分类信息
        if !category.isSystem {
            category.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        category.icon = selectedIcon
        category.color = selectedColor

        // 保存到数据库
        try? modelContext.save()

        // 关闭界面
        dismiss()
    }

    /// 删除分类
    /// 作者: xiaolei
    private func deleteCategory() {
        modelContext.delete(category)
        try? modelContext.save()
        dismiss()
    }
}

// MARK: - 预览

#Preview {
    EditCategoryView(
        category: Category(
            name: "餐饮",
            icon: "fork.knife",
            color: "FF6B6B",
            type: .expense,
            isSystem: false
        )
    )
    .modelContainer(for: [Category.self])
}
