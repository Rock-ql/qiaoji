//
//  CategoryManagementView.swift
//  ExpenseTracker
//
//  Created by xiaolei on 2025/11/13.
//  分类管理主界面
//

import SwiftUI
import SwiftData

/// 分类管理视图
/// 作者: xiaolei
/// 功能：查看、添加、编辑、删除和排序分类
struct CategoryManagementView: View {
    /// 查询所有分类并按排序顺序展示
    @Query(sort: \Category.sortOrder) var categories: [Category]

    /// 访问数据库上下文
    @Environment(\.modelContext) private var modelContext

    /// 是否显示添加分类界面
    @State private var showAddCategory = false

    /// 选中要编辑的分类
    @State private var editingCategory: Category?

    /// 要删除的分类
    @State private var categoryToDelete: Category?

    /// 是否显示删除确认对话框
    @State private var showDeleteAlert = false

    var body: some View {
        List {
            // 支出分类组
            Section {
                ForEach(expenseCategories) { category in
                    CategoryListRow(category: category)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            editingCategory = category
                        }
                }
                .onDelete { indexSet in
                    handleDelete(at: indexSet, in: expenseCategories)
                }
                .onMove { source, destination in
                    moveCategory(from: source, to: destination, in: .expense)
                }
            } header: {
                HStack {
                    Image(systemName: "arrow.up.circle.fill")
                        .foregroundColor(.red)
                    Text("支出分类")
                }
            }

            // 收入分类组
            Section {
                ForEach(incomeCategories) { category in
                    CategoryListRow(category: category)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            editingCategory = category
                        }
                }
                .onDelete { indexSet in
                    handleDelete(at: indexSet, in: incomeCategories)
                }
                .onMove { source, destination in
                    moveCategory(from: source, to: destination, in: .income)
                }
            } header: {
                HStack {
                    Image(systemName: "arrow.down.circle.fill")
                        .foregroundColor(.green)
                    Text("收入分类")
                }
            }
        }
        .navigationTitle("分类管理")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showAddCategory = true
                } label: {
                    Image(systemName: "plus")
                }
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
        }
        .sheet(isPresented: $showAddCategory) {
            AddCategoryView()
        }
        .sheet(item: $editingCategory) { category in
            EditCategoryView(category: category)
        }
        .alert("无法删除分类", isPresented: $showDeleteAlert) {
            Button("确定", role: .cancel) {}
        } message: {
            if let category = categoryToDelete {
                if category.isSystem {
                    Text("系统预设分类不能删除")
                } else if category.transactionCount > 0 {
                    Text("该分类下有 \(category.transactionCount) 笔交易记录，请先处理这些交易后再删除。")
                }
            }
        }
    }

    /// 支出分类列表
    /// 作者: xiaolei
    private var expenseCategories: [Category] {
        categories.filter { $0.type == .expense }
    }

    /// 收入分类列表
    /// 作者: xiaolei
    private var incomeCategories: [Category] {
        categories.filter { $0.type == .income }
    }

    /// 处理删除操作
    /// 作者: xiaolei
    /// - Parameters:
    ///   - indexSet: 要删除的索引集合
    ///   - categoryList: 分类列表
    private func handleDelete(at indexSet: IndexSet, in categoryList: [Category]) {
        for index in indexSet {
            let category = categoryList[index]

            // 检查是否可以删除
            if category.isSystem {
                categoryToDelete = category
                showDeleteAlert = true
                return
            }

            if category.transactionCount > 0 {
                categoryToDelete = category
                showDeleteAlert = true
                return
            }

            // 执行删除
            modelContext.delete(category)
        }

        // 保存更改
        try? modelContext.save()
    }

    /// 移动分类（拖拽排序）
    /// 作者: xiaolei
    /// - Parameters:
    ///   - source: 源索引集合
    ///   - destination: 目标索引
    ///   - type: 分类类型
    private func moveCategory(from source: IndexSet, to destination: Int, in type: TransactionType) {
        let categoryList = type == .expense ? expenseCategories : incomeCategories
        var updatedList = categoryList
        updatedList.move(fromOffsets: source, toOffset: destination)

        // 更新所有分类的 sortOrder
        for (index, category) in updatedList.enumerated() {
            category.sortOrder = type == .expense ? index : (expenseCategories.count + index)
        }

        // 保存更改
        try? modelContext.save()
    }
}

// MARK: - 预览

#Preview {
    NavigationStack {
        CategoryManagementView()
            .modelContainer(for: [Category.self, Transaction.self])
    }
}
