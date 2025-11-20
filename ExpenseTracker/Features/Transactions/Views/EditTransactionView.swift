import SwiftUI
import SwiftData

/// 编辑交易视图
/// 作者: xiaolei
struct EditTransactionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @Query var categories: [Category]

    let transaction: Transaction

    @State private var amount: String = ""
    @State private var type: TransactionType = .expense
    @State private var selectedCategory: Category?
    @State private var date = Date()
    @State private var note = ""
    @State private var showDeleteAlert = false

    /// 是否显示自定义数字键盘
    /// 作者: xiaolei
    @State private var showCustomKeyboard = false

    /// 输入框焦点管理
    /// 作者: xiaolei
    @FocusState private var focusedField: Field?

    /// 输入框类型枚举
    /// 作者: xiaolei
    enum Field {
        case note    // 备注输入框
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            NavigationStack {
                Form {
                // 交易类型选择
                Section {
                    Picker("类型", selection: $type) {
                        Text("支出").tag(TransactionType.expense)
                        Text("收入").tag(TransactionType.income)
                    }
                    .pickerStyle(.segmented)
                }

                // 金额输入
                Section {
                    Button(action: {
                        // 点击显示自定义键盘
                        focusedField = nil // 关闭系统键盘
                        withAnimation {
                            showCustomKeyboard = true
                        }
                    }) {
                        HStack {
                            Text("¥")
                                .font(.title2)
                                .foregroundColor(.secondary)

                            Text(amount.isEmpty ? "0.00" : amount)
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(amount.isEmpty ? .secondary : .primary)

                            Spacer()
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                } header: {
                    Text("金额")
                }

                // 分类选择
                Section {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(filteredCategories) { category in
                                CategoryChip(
                                    category: category,
                                    isSelected: selectedCategory?.id == category.id
                                ) {
                                    selectedCategory = category
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                } header: {
                    Text("分类")
                }

                // 删除按钮
                Section {
                    Button(role: .destructive) {
                        showDeleteAlert = true
                    } label: {
                        HStack {
                            Spacer()
                            Text("删除交易")
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("编辑交易")
            .navigationBarTitleDisplayMode(.inline)
            .background(
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        // 点击表单空白区域关闭键盘
                        focusedField = nil
                    }
            )
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        saveTransaction()
                    }
                    .disabled(!canSave)
                }

                // 键盘工具栏：显示"完成"按钮
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("完成") {
                        focusedField = nil
                    }
                    .fontWeight(.semibold)
                }
            }
            .alert("确认删除", isPresented: $showDeleteAlert) {
                Button("取消", role: .cancel) { }
                Button("删除", role: .destructive) {
                    deleteTransaction()
                }
            } message: {
                Text("确定要删除这笔交易吗？此操作无法撤销。")
            }
            .onAppear {
                // 初始化表单数据
                amount = String(format: "%.2f", transaction.amount)
                type = transaction.type
                selectedCategory = transaction.category
                date = transaction.date
                note = transaction.note
            }
            }

            // 自定义数字键盘
            if showCustomKeyboard {
                VStack(spacing: 0) {
                    Spacer()

                    CustomNumericKeyboard(
                        amount: $amount,
                        date: $date,
                        note: $note,
                        onDismiss: {
                            withAnimation {
                                showCustomKeyboard = false
                            }
                        }
                    )
                    .transition(.move(edge: .bottom))
                }
                .background(
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation {
                                showCustomKeyboard = false
                            }
                        }
                )
            }
        }
    }

    /// 筛选后的分类（根据交易类型）
    /// 作者: xiaolei
    private var filteredCategories: [Category] {
        categories.filter { $0.type == type }.sorted()
    }

    /// 是否可以保存
    /// 作者: xiaolei
    private var canSave: Bool {
        guard let amountValue = Double(amount), amountValue > 0 else {
            return false
        }
        return selectedCategory != nil
    }

    /// 保存交易
    /// 作者: xiaolei
    private func saveTransaction() {
        guard let amountValue = Double(amount) else { return }

        // 更新交易信息
        transaction.amount = amountValue
        transaction.type = type
        transaction.date = date
        transaction.note = note
        transaction.category = selectedCategory

        try? modelContext.save()

        dismiss()
    }

    /// 删除交易
    /// 作者: xiaolei
    private func deleteTransaction() {
        modelContext.delete(transaction)
        try? modelContext.save()

        dismiss()
    }
}

/// 分类选择器芯片
/// 作者: xiaolei
struct CategoryChip: View {
    let category: Category
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                // 图标
                Image(systemName: category.icon)
                    .font(.title3)
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .background(
                        Circle()
                            .fill(Color(category.color))
                    )
                    .overlay(
                        Circle()
                            .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 3)
                    )

                // 名称
                Text(category.name)
                    .font(.caption)
                    .foregroundColor(.primary)
                    .lineLimit(1)
            }
            .frame(width: 60)
        }
        .buttonStyle(.plain)
    }
}
