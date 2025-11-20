//
//  AddCategoryView.swift
//  ExpenseTracker
//
//  Created by xiaolei on 2025/11/13.
//  添加分类界面
//

import SwiftUI
import SwiftData

/// 添加分类视图
/// 作者: xiaolei
/// 用于创建新的收入或支出分类
struct AddCategoryView: View {
    /// 关闭视图
    @Environment(\.dismiss) private var dismiss

    /// 访问数据库上下文
    @Environment(\.modelContext) private var modelContext

    /// 查询现有分类（用于计算 sortOrder）
    @Query var categories: [Category]

    /// 分类名称
    @State private var name = ""

    /// 分类类型
    @State private var type: TransactionType = .expense

    /// 选中的图标
    @State private var selectedIcon = "circle.fill"

    /// 选中的颜色
    @State private var selectedColor = "4ECDC4"

    /// 是否显示图标选择器
    @State private var showIconPicker = false

    /// 是否显示颜色选择器
    @State private var showColorPicker = false

    var body: some View {
        NavigationStack {
            Form {
                // 分类类型选择
                Section {
                    Picker("类型", selection: $type) {
                        Text("支出").tag(TransactionType.expense)
                        Text("收入").tag(TransactionType.income)
                    }
                    .pickerStyle(.segmented)
                } header: {
                    Text("分类类型")
                }

                // 分类名称
                Section {
                    TextField("请输入分类名称", text: $name)
                } header: {
                    Text("分类名称")
                } footer: {
                    Text("建议使用简短易懂的名称，如：餐饮、交通等")
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
            }
            .navigationTitle("添加分类")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        saveCategory()
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
        }
    }

    /// 是否可以保存
    /// 作者: xiaolei
    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// 保存分类
    /// 作者: xiaolei
    private func saveCategory() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        // 计算新分类的 sortOrder
        let sameTypeCategories = categories.filter { $0.type == type }
        let maxSortOrder = sameTypeCategories.map { $0.sortOrder }.max() ?? -1
        let newSortOrder = maxSortOrder + 1

        // 创建新分类
        let newCategory = Category(
            name: trimmedName,
            icon: selectedIcon,
            color: selectedColor,
            type: type,
            isSystem: false,
            sortOrder: newSortOrder
        )

        // 保存到数据库
        modelContext.insert(newCategory)
        try? modelContext.save()

        // 关闭界面
        dismiss()
    }
}

// MARK: - 预览

#Preview {
    AddCategoryView()
        .modelContainer(for: [Category.self])
}
