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
    @State private var isLoading = true

    /// 当前输入模式
    /// 作者: xiaolei
    @State private var inputMode: InputMode = .amount

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // 主内容区域
                    mainContentView

                    // 底部输入面板
                    CustomNumericKeyboard(
                        amount: $amount,
                        date: $date,
                        note: $note,
                        inputMode: $inputMode,
                        onDone: {
                            if canSave {
                                saveTransaction()
                            } else {
                                // 未满足保存条件时给出反馈
                                let generator = UINotificationFeedbackGenerator()
                                generator.notificationOccurred(.warning)
                            }
                        }
                    )
                }
            }
            .navigationTitle("编辑交易")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                toolbarContent
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
                initializeFormData()
            }
        }
        .interactiveDismissDisabled(inputMode == .note)
    }

    /// 主内容视图
    /// 作者: xiaolei
    @ViewBuilder
    private var mainContentView: some View {
        ScrollView {
            VStack(spacing: 16) {
                // 交易类型选择
                typePickerSection

                // 金额显示卡片
                amountSection

                // 分类选择
                categorySection

                // 删除按钮
                deleteSection
            }
            .padding(.vertical)
        }
        .scrollDismissesKeyboard(.interactively)
        .onTapGesture {
            if inputMode == .note {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    inputMode = .amount
                }
            }
        }
    }

    /// 类型选择区域
    /// 作者: xiaolei
    @ViewBuilder
    private var typePickerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("类型")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.horizontal, 4)

            Picker("类型", selection: $type) {
                Text("支出").tag(TransactionType.expense)
                Text("收入").tag(TransactionType.income)
            }
            .pickerStyle(.segmented)
        }
        .padding(.horizontal)
    }

    /// 金额显示区域
    /// 作者: xiaolei
    @ViewBuilder
    private var amountSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("金额")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.horizontal, 4)

            HStack {
                Text("¥")
                    .font(.system(size: 28, weight: .light))
                    .foregroundColor(.secondary)

                Text(amount.isEmpty ? "0.00" : amount)
                    .font(.system(size: 32, weight: .semibold, design: .rounded))
                    .foregroundColor(amount.isEmpty ? .secondary : (type == .expense ? .red : .green))
                    .contentTransition(.numericText())

                Spacer()

                if inputMode == .amount {
                    Image(systemName: "keyboard")
                        .font(.system(size: 14))
                        .foregroundColor(.blue)
                        .padding(6)
                        .background(Color.blue.opacity(0.1))
                        .clipShape(Circle())
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
            )
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    inputMode = .amount
                }
            }
        }
        .padding(.horizontal)
    }

    /// 分类选择区域
    /// 作者: xiaolei
    @ViewBuilder
    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("分类")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.horizontal, 4)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(filteredCategories) { category in
                        CategoryChip(
                            category: category,
                            isSelected: selectedCategory?.id == category.id
                        ) {
                            selectedCategory = category
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
        }
        .padding(.horizontal)
    }

    /// 删除按钮区域
    /// 作者: xiaolei
    @ViewBuilder
    private var deleteSection: some View {
        Button(role: .destructive) {
            showDeleteAlert = true
        } label: {
            HStack {
                Spacer()
                Image(systemName: "trash")
                Text("删除交易")
                Spacer()
            }
            .foregroundColor(.red)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.red.opacity(0.1))
            )
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }

    /// 工具栏内容
    /// 作者: xiaolei
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
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

        ToolbarItemGroup(placement: .keyboard) {
            Spacer()
            Button("完成") {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    inputMode = .amount
                }
            }
            .fontWeight(.semibold)
        }
    }

    /// 初始化表单数据
    /// 作者: xiaolei
    private func initializeFormData() {
        amount = String(format: "%.2f", transaction.amount)
        type = transaction.type
        selectedCategory = transaction.category
        date = transaction.date
        note = transaction.note
        isLoading = false
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
