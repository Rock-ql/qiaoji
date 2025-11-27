//
//  ContentView.swift
//  ExpenseTracker
//
//  Created by xiaolei on 2025/11/12.
//  主视图 - 应用导航容器
//

import SwiftUI
import SwiftData

/// 添加交易的触发项
/// 作者: xiaolei
/// 用于 sheet(item:) 模式，确保每次打开时获取最新的账本
struct AddTransactionItem: Identifiable {
    let id = UUID()
    let ledger: Ledger?
}

/// 应用主视图
/// 作者: xiaolei
/// 使用TabView实现底部导航，包含：交易、统计、设置三个模块
struct ContentView: View {
    /// 当前选中的Tab
    @State private var selectedTab = 0

    /// 是否在交易详情页面（用于控制浮动按钮显示）
    @State private var isShowingTransactionDetail = false

    /// 当前选中的账本
    @State private var selectedLedger: Ledger?

    /// 添加交易的触发项（使用 item 模式确保获取最新账本）
    @State private var addTransactionItem: AddTransactionItem?

    /// 访问数据库上下文
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        ZStack(alignment: .bottom) {
            // 主TabView
            TabView(selection: $selectedTab) {
                // 交易列表
                TransactionListView(isShowingDetail: $isShowingTransactionDetail, selectedLedger: $selectedLedger)
                    .tabItem {
                        Label("交易", systemImage: "list.bullet")
                    }
                    .tag(0)

                // 数据统计
                StatisticsView()
                    .tabItem {
                        Label("统计", systemImage: "chart.pie.fill")
                    }
                    .tag(1)

                // 设置
                SettingsView()
                    .tabItem {
                        Label("设置", systemImage: "gearshape.fill")
                    }
                    .tag(2)
            }
            .accentColor(.blue)

            // 浮动添加按钮（仅在交易标签页且不在详情页时显示）
            // 作者: xiaolei
            if selectedTab == 0 && !isShowingTransactionDetail {
                FloatingAddButton {
                    // 使用 item 模式触发 sheet，确保每次都获取最新的账本
                    addTransactionItem = AddTransactionItem(ledger: selectedLedger)
                }
                .padding(.bottom, 60) // 留出TabBar的空间
            }
        }
        .sheet(item: $addTransactionItem) { item in
            AddTransactionView(defaultLedger: item.ledger)
        }
        .task {
            // 首次启动时初始化默认分类
            await setupDefaultCategoriesIfNeeded()
            // 首次启动时初始化默认账本
            await setupDefaultLedgerIfNeeded()
        }
    }

    /// 初始化默认分类（如果需要）
    /// 作者: xiaolei
    @MainActor
    private func setupDefaultCategoriesIfNeeded() async {
        // 检查是否已有分类数据
        let descriptor = FetchDescriptor<Category>()
        let existingCategories = try? modelContext.fetch(descriptor)

        guard existingCategories?.isEmpty ?? true else { return }

        // 创建默认支出分类（标记为系统分类）
        let expenseCategories = [
            Category(name: "餐饮", icon: "fork.knife", color: "FF6B6B", type: .expense, isSystem: true, sortOrder: 0),
            Category(name: "交通", icon: "car.fill", color: "4ECDC4", type: .expense, isSystem: true, sortOrder: 1),
            Category(name: "购物", icon: "cart.fill", color: "FFE66D", type: .expense, isSystem: true, sortOrder: 2),
            Category(name: "娱乐", icon: "gamecontroller.fill", color: "A8E6CF", type: .expense, isSystem: true, sortOrder: 3),
            Category(name: "医疗", icon: "cross.case.fill", color: "FF8B94", type: .expense, isSystem: true, sortOrder: 4),
            Category(name: "教育", icon: "book.fill", color: "C7CEEA", type: .expense, isSystem: true, sortOrder: 5),
            Category(name: "住房", icon: "house.fill", color: "B4A7D6", type: .expense, isSystem: true, sortOrder: 6),
            Category(name: "其他", icon: "ellipsis.circle.fill", color: "95A5A6", type: .expense, isSystem: true, sortOrder: 7)
        ]

        // 创建默认收入分类（标记为系统分类）
        let incomeCategories = [
            Category(name: "工资", icon: "dollarsign.circle.fill", color: "2ECC71", type: .income, isSystem: true, sortOrder: 8),
            Category(name: "奖金", icon: "gift.fill", color: "27AE60", type: .income, isSystem: true, sortOrder: 9),
            Category(name: "投资", icon: "chart.line.uptrend.xyaxis", color: "16A085", type: .income, isSystem: true, sortOrder: 10),
            Category(name: "其他收入", icon: "plus.circle.fill", color: "1ABC9C", type: .income, isSystem: true, sortOrder: 11)
        ]

        // 插入所有默认分类
        for category in expenseCategories + incomeCategories {
            modelContext.insert(category)
        }

        // 保存数据
        try? modelContext.save()
    }

    /// 初始化默认账本（如果需要）
    /// 作者: xiaolei
    @MainActor
    private func setupDefaultLedgerIfNeeded() async {
        // 检查是否已有账本数据
        let descriptor = FetchDescriptor<Ledger>()
        let existingLedgers = try? modelContext.fetch(descriptor)

        guard existingLedgers?.isEmpty ?? true else { return }

        // 创建默认账本
        let defaultLedger = Ledger(
            name: "日常账本",
            icon: "book.fill",
            color: "4A90E2",
            description: "日常收支记录",
            isDefault: true,
            isArchived: false,
            sortOrder: 0
        )

        modelContext.insert(defaultLedger)

        // 保存数据
        try? modelContext.save()
    }
}

/// 浮动添加按钮
/// 作者: xiaolei
struct FloatingAddButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(width: 60, height: 60)
                .background(
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.blue, .cyan],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
                )
        }
    }
}

// MARK: - 占位视图（待实现）

/// 交易列表视图占位
/// 作者: xiaolei
struct TransactionListView: View {
    @Query(sort: \Transaction.date, order: .reverse) var allTransactions: [Transaction]
    @Query(filter: #Predicate<Ledger> { !$0.isArchived }, sort: \Ledger.sortOrder)
    var ledgers: [Ledger]
    @Environment(\.modelContext) private var modelContext

    /// 是否在显示详情页（用于控制浮动按钮）
    /// 作者: xiaolei
    @Binding var isShowingDetail: Bool

    /// 当前选中的账本（直接使用外部 Binding，避免同步延迟）
    /// 作者: xiaolei
    @Binding var selectedLedger: Ledger?

    /// 根据选中账本筛选的交易
    /// 作者: xiaolei
    private var transactions: [Transaction] {
        guard let ledger = selectedLedger else {
            return allTransactions
        }
        return allTransactions.filter { $0.ledger?.id == ledger.id }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 账本选择器
                LedgerPickerView(selectedLedger: $selectedLedger, showAllOption: true)
                    .padding(.vertical, 8)

                // 交易列表内容
                Group {
                if transactions.isEmpty {
                    // 空状态视图
                    VStack(spacing: 20) {
                        Image(systemName: "tray.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)

                        Text("暂无交易记录")
                            .font(.title3)
                            .foregroundColor(.secondary)

                        Text("点击下方 + 按钮添加第一笔交易")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // 交易列表
                    List {
                        ForEach(groupedTransactions.keys.sorted(by: >), id: \.self) { date in
                            Section {
                                ForEach(groupedTransactions[date] ?? []) { transaction in
                                    NavigationLink(value: transaction) {
                                        TransactionRow(transaction: transaction)
                                    }
                                }
                                .onDelete { indexSet in
                                    deleteTransactions(at: indexSet, for: date)
                                }
                            } header: {
                                HStack {
                                    Text(formatSectionDate(date))
                                    Spacer()
                                    HStack(spacing: 8) {
                                        let incomeAmount = dailyIncomeTotal(for: date)
                                        let expenseAmount = dailyExpenseTotal(for: date)

                                        if incomeAmount > 0 {
                                            totalBadge(
                                                title: "收入",
                                                amount: incomeAmount,
                                                isIncome: true
                                            )
                                        }
                                        if expenseAmount > 0 {
                                            totalBadge(
                                                title: "支出",
                                                amount: expenseAmount,
                                                isIncome: false
                                            )
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
                }
            }
            .navigationTitle("交易记录")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            // TODO: 筛选功能
                        } label: {
                            Label("筛选", systemImage: "line.3.horizontal.decrease.circle")
                        }

                        Button {
                            // TODO: 导出功能
                        } label: {
                            Label("导出", systemImage: "square.and.arrow.up")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .navigationDestination(for: Transaction.self) { transaction in
                TransactionDetailView(transaction: transaction)
                    .onAppear {
                        isShowingDetail = true
                    }
                    .onDisappear {
                        isShowingDetail = false
                    }
            }
            .task {
                // 初始化默认选中的账本（如果当前没有选中任何账本）
                if selectedLedger == nil {
                    selectedLedger = ledgers.first(where: { $0.isDefault }) ?? ledgers.first
                }
            }
        }
    }

    /// 按日期分组的交易
    /// 作者: xiaolei
    private var groupedTransactions: [Date: [Transaction]] {
        Dictionary(grouping: transactions) { transaction in
            Calendar.current.startOfDay(for: transaction.date)
        }
    }

    /// 格式化分组标题日期
    /// 作者: xiaolei
    private func formatSectionDate(_ date: Date) -> String {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        if calendar.isDate(date, inSameDayAs: today) {
            return "今天"
        } else if calendar.isDate(date, inSameDayAs: calendar.date(byAdding: .day, value: -1, to: today)!) {
            return "昨天"
        } else {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "zh_CN")

            // 判断是否是本年
            let currentYear = calendar.component(.year, from: Date())
            let dateYear = calendar.component(.year, from: date)

            if currentYear == dateYear {
                // 本年：只显示月日和星期
                formatter.dateFormat = "M月d日 EEEE"
            } else {
                // 非本年：显示年月日和星期
                formatter.dateFormat = "yyyy年M月d日 EEEE"
            }

            return formatter.string(from: date)
        }
    }

    /// 删除交易
    /// 作者: xiaolei
    private func deleteTransactions(at offsets: IndexSet, for date: Date) {
        guard let transactions = groupedTransactions[date] else { return }

        offsets.forEach { index in
            modelContext.delete(transactions[index])
        }
    }

    /// 当日收入总额
    private func dailyIncomeTotal(for date: Date) -> Double {
        guard let transactions = groupedTransactions[date] else { return 0 }
        return transactions
            .filter { $0.type == .income }
            .reduce(0) { $0 + $1.amount }
    }

    /// 当日支出总额
    private func dailyExpenseTotal(for date: Date) -> Double {
        guard let transactions = groupedTransactions[date] else { return 0 }
        return transactions
            .filter { $0.type == .expense }
            .reduce(0) { $0 + $1.amount }
    }

    /// 汇总徽标视图
    @ViewBuilder
    private func totalBadge(title: String, amount: Double, isIncome: Bool) -> some View {
        let bgColor = isIncome ? Color.green.opacity(0.12) : Color.red.opacity(0.12)
        let textColor = isIncome ? Color.green : Color.red

        HStack(spacing: 4) {
            Text(title)
                .font(.footnote)
                .foregroundColor(.secondary)
            Text(formatAmount(amount, isIncome: isIncome))
                .font(.footnote.weight(.semibold))
                .foregroundColor(textColor)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(bgColor)
        .clipShape(Capsule())
    }

    /// 金额格式化（收入带 +，支出带 -）
    private func formatAmount(_ amount: Double, isIncome: Bool) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "CNY"
        formatter.currencySymbol = "¥"
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2

        let prefix = isIncome ? "+" : "-"
        let formatted = formatter.string(from: NSNumber(value: amount)) ?? "¥0.00"
        return amount == 0 ? "¥0.00" : "\(prefix)\(formatted)"
    }
}

/// 交易行视图
/// 作者: xiaolei
struct TransactionRow: View {
    let transaction: Transaction

    var body: some View {
        HStack(spacing: 12) {
            // 分类图标
            Image(systemName: transaction.categoryIcon)
                .font(.title3)
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(Color(transaction.category?.color ?? "95A5A6"))
                )

            // 交易信息
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.categoryName)
                    .font(.headline)

                if !transaction.note.isEmpty {
                    Text(transaction.note)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            // 金额
            Text(transaction.type == .income ? "+\(transaction.formattedAmount)" : "-\(transaction.formattedAmount)")
                .font(.headline)
                .foregroundColor(transaction.type == .income ? .green : .red)
        }
        .padding(.vertical, 4)
    }
}

// StatisticsView 已在 Features/Statistics/Views/StatisticsView.swift 中实现
// 作者: xiaolei

/// 预算视图占位
/// 作者: xiaolei
struct BudgetView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Image(systemName: "dollarsign.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.gray)

                Text("预算管理")
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .padding(.top)

                Text("即将推出")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .navigationTitle("预算管理")
        }
    }
}

/// 设置视图占位
/// 作者: xiaolei
struct SettingsView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("通用") {
                    NavigationLink {
                        CategoryManagementView()
                    } label: {
                        Label("分类管理", systemImage: "folder.fill")
                    }

                    NavigationLink {
                        LedgerListView()
                    } label: {
                        Label("账本管理", systemImage: "book.fill")
                    }

                    NavigationLink {
                        Text("账户管理")
                    } label: {
                        Label("账户管理", systemImage: "creditcard.fill")
                    }
                }

                Section("数据") {
                    Button {
                        // TODO: 导出数据
                    } label: {
                        Label("导出数据", systemImage: "square.and.arrow.up")
                    }

                    Button {
                        // TODO: 备份数据
                    } label: {
                        Label("iCloud备份", systemImage: "icloud.and.arrow.up")
                    }
                }

                Section("关于") {
                    HStack {
                        Text("版本")
                        Spacer()
                        Text("1.1.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("设置")
        }
    }
}

/// 添加交易视图
/// 作者: xiaolei
struct AddTransactionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @Query var categories: [Category]
    @Query(filter: #Predicate<Ledger> { !$0.isArchived }, sort: \Ledger.sortOrder)
    var ledgers: [Ledger]

    /// 外部传入的默认账本（来自交易列表当前选中的账本）
    /// 作者: xiaolei
    var defaultLedger: Ledger?

    @State private var amount: String = ""
    @State private var type: TransactionType = .expense
    @State private var selectedCategory: Category?
    @State private var selectedLedger: Ledger?
    @State private var date = Date()
    @State private var note = ""

    /// 当前输入模式
    /// 作者: xiaolei
    @State private var inputMode: InputMode = .none

    /// 分类网格列配置（两行显示）
    /// 作者: xiaolei
    private let categoryColumns = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8)
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 主内容区域
                ScrollView {
                    VStack(spacing: 20) {
                        // 1. 账本选择
                        VStack(alignment: .leading, spacing: 10) {
                            Text("账本")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 4)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(ledgers.sorted()) { ledger in
                                        Button(action: {
                                            selectedLedger = ledger
                                        }) {
                                            HStack(spacing: 6) {
                                                Image(systemName: ledger.icon)
                                                    .font(.subheadline)
                                                Text(ledger.name)
                                                    .font(.subheadline)
                                            }
                                            .fontWeight(selectedLedger?.id == ledger.id ? .semibold : .regular)
                                            .foregroundColor(selectedLedger?.id == ledger.id ? .white : .primary)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 10)
                                            .background(
                                                Capsule()
                                                    .fill(selectedLedger?.id == ledger.id ? Color(hex: ledger.color) ?? Color.blue : Color(.systemGray6))
                                            )
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)

                        // 2. 交易类型选择
                        VStack(alignment: .leading, spacing: 10) {
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

                        // 3. 分类选择（网格两行显示）
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("分类")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)

                                Spacer()

                                if selectedCategory == nil {
                                    Text("请选择")
                                        .font(.caption)
                                        .foregroundColor(.orange)
                                }
                            }
                            .padding(.horizontal, 4)

                            LazyVGrid(columns: categoryColumns, spacing: 12) {
                                ForEach(filteredCategories) { category in
                                    CategoryChip(
                                        category: category,
                                        isSelected: selectedCategory?.id == category.id
                                    ) {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            selectedCategory = category
                                            // 选择分类后显示数字键盘
                                            inputMode = .amount
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)

                        // 4. 金额和备注预览区域（键盘收起后显示）
                        if selectedCategory != nil && inputMode == .none {
                            transactionPreviewSection
                        }
                    }
                    .padding(.vertical)
                }

                // 底部输入面板（选择分类后且在输入模式时显示）
                if selectedCategory != nil && (inputMode == .amount || inputMode == .note) {
                    CustomNumericKeyboard(
                        amount: $amount,
                        date: $date,
                        note: $note,
                        inputMode: $inputMode,
                        onDone: {
                            // 点击对勾收起键盘，显示预览
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                inputMode = .none
                            }
                        }
                    )
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: inputMode)
            .navigationTitle("添加交易")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        tryToSave()
                    }
                    .disabled(!canSave)
                }

                // 系统键盘工具栏：显示"完成"按钮
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
            .task {
                // 初始化账本：优先使用外部传入的账本，否则使用默认账本
                if selectedLedger == nil {
                    if let passedLedger = defaultLedger {
                        selectedLedger = passedLedger
                    } else {
                        selectedLedger = ledgers.first(where: { $0.isDefault }) ?? ledgers.first
                    }
                }
            }
        }
        .interactiveDismissDisabled(inputMode == .note)
    }

    /// 交易预览区域（显示已填写的金额、日期、备注）
    /// 作者: xiaolei
    @ViewBuilder
    private var transactionPreviewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("交易信息")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.horizontal, 4)

            VStack(spacing: 0) {
                // 金额行
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        inputMode = .amount
                    }
                } label: {
                    HStack {
                        Label("金额", systemImage: "yensign.circle")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(amount.isEmpty ? "0.00" : "¥\(amount)")
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .foregroundColor(amount.isEmpty ? .secondary : (type == .expense ? .red : .green))
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                }
                .buttonStyle(.plain)

                Divider()
                    .padding(.leading, 16)

                // 日期行
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        inputMode = .amount
                    }
                } label: {
                    HStack {
                        Label("日期", systemImage: "calendar")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(formatDate(date))
                            .font(.subheadline)
                            .foregroundColor(.primary)
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                }
                .buttonStyle(.plain)

                Divider()
                    .padding(.leading, 16)

                // 备注行
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        inputMode = .note
                    }
                } label: {
                    HStack {
                        Label("备注", systemImage: "note.text")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(note.isEmpty ? "无" : note)
                            .font(.subheadline)
                            .foregroundColor(note.isEmpty ? .secondary : .primary)
                            .lineLimit(1)
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                }
                .buttonStyle(.plain)
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(.horizontal)
        .transition(.opacity.combined(with: .move(edge: .top)))
    }

    /// 格式化日期显示
    /// 作者: xiaolei
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        let calendar = Calendar.current

        if calendar.isDateInToday(date) {
            formatter.dateFormat = "今天 HH:mm"
        } else if calendar.isDateInYesterday(date) {
            formatter.dateFormat = "昨天 HH:mm"
        } else {
            formatter.dateFormat = "M月d日 HH:mm"
        }
        return formatter.string(from: date)
    }

    /// 尝试保存交易
    /// 作者: xiaolei
    private func tryToSave() {
        guard canSave else {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.warning)
            return
        }
        saveTransaction()
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

        let transaction = Transaction(
            amount: amountValue,
            type: type,
            date: date,
            note: note,
            category: selectedCategory,
            ledger: selectedLedger
        )

        modelContext.insert(transaction)
        try? modelContext.save()

        dismiss()
    }
}

// MARK: - 颜色扩展

extension Color {
    /// 从十六进制字符串创建颜色
    /// 作者: xiaolei
    /// - Parameter hex: 十六进制颜色字符串（如 "FF6B6B"）
    init(_ hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let r, g, b: Double
        switch hex.count {
        case 6: // RGB
            r = Double((int >> 16) & 0xFF) / 255
            g = Double((int >> 8) & 0xFF) / 255
            b = Double(int & 0xFF) / 255
        default:
            r = 0
            g = 0
            b = 0
        }

        self.init(red: r, green: g, blue: b)
    }
}

// MARK: - 预览

#Preview {
    ContentView()
        .modelContainer(for: [Transaction.self, Category.self, Budget.self, Account.self])
}
