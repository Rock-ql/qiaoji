//
//  CategoryTransactionListView.swift
//  ExpenseTracker
//
//  Created by xiaolei on 2025/11/20.
//  分类交易明细列表视图
//  从统计页面点击某个分类后，显示该分类在指定时间段内的所有交易明细
//

import SwiftUI
import SwiftData

/// 导航参数结构 - 用于从统计页面传递分类和时间信息
struct CategoryTransactionParams: Hashable {
    let categoryId: UUID?           // 分类ID（nil表示未分类）
    let categoryName: String        // 分类名称
    let categoryIcon: String        // 分类图标
    let categoryColor: String       // 分类颜色（十六进制）
    let startDate: Date            // 时间段开始日期
    let endDate: Date              // 时间段结束日期
    let transactionType: TransactionType  // 交易类型（收入/支出）
    let periodDisplayName: String   // 时间段显示名称，如"本周"、"2025年11月"
}

/// 分类交易明细列表视图
/// 作者: xiaolei
/// 显示指定分类在指定时间段内的所有交易，支持点击查看详情
struct CategoryTransactionListView: View {
    /// 导航参数
    let params: CategoryTransactionParams

    /// SwiftData环境
    @Environment(\.modelContext) private var modelContext

    /// 查询该分类的所有交易（使用SwiftData的@Query自动筛选）
    @Query private var transactions: [Transaction]

    /// 选中的交易（用于弹出编辑页面）
    @State private var selectedTransaction: Transaction?

    /// 是否显示交易详情/编辑页面
    @State private var showTransactionDetail = false

    /// 初始化视图
    /// - Parameter params: 分类和时间段参数
    init(params: CategoryTransactionParams) {
        self.params = params

        // 配置SwiftData查询：筛选指定分类、时间段、类型的交易，按日期倒序
        let categoryId = params.categoryId
        let startDate = params.startDate
        let endDate = params.endDate
        let type = params.transactionType

        // 调试信息：打印查询参数
        print("📊 CategoryTransactionListView 查询参数:")
        print("  - 分类: \(params.categoryName) (ID: \(categoryId?.uuidString ?? "nil"))")
        print("  - 时间范围: \(startDate) 到 \(endDate)")
        print("  - 交易类型: \(type)")

        // 根据是否有分类ID，构建不同的Predicate（避免三元运算符在Predicate中的问题）
        // 注意：SwiftData Predicate 不支持枚举类型直接比较，需要使用 rawValue
        let typeRawValue = type.rawValue
        let predicate: Predicate<Transaction>
        if let categoryId = categoryId {
            // 有分类ID：匹配指定分类的交易
            predicate = #Predicate<Transaction> { transaction in
                transaction.category?.id == categoryId &&
                transaction.date >= startDate && transaction.date < endDate &&
                transaction.type.rawValue == typeRawValue
            }
        } else {
            // 无分类ID：匹配未分类的交易
            predicate = #Predicate<Transaction> { transaction in
                transaction.category == nil &&
                transaction.date >= startDate && transaction.date < endDate &&
                transaction.type.rawValue == typeRawValue
            }
        }

        _transactions = Query(
            filter: predicate,
            sort: [SortDescriptor(\.date, order: .reverse)]
        )
    }

    var body: some View {
        List {
            // 头部统计卡片
            statisticsSummarySection

            // 交易列表
            if transactions.isEmpty {
                emptyStateSection
            } else {
                transactionListSection
            }
        }
        .onAppear {
            // 调试信息：打印查询结果
            print("📊 查询到的交易数量: \(transactions.count)")
            if !transactions.isEmpty {
                print("📊 交易详情:")
                for (index, transaction) in transactions.prefix(5).enumerated() {
                    print("  [\(index + 1)] \(transaction.amount) - \(transaction.category?.name ?? "无分类") - \(transaction.date)")
                }
            }
        }
        .navigationTitle("\(params.categoryName)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack(spacing: 2) {
                    Text(params.categoryName)
                        .font(.headline)
                    Text(params.periodDisplayName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .sheet(isPresented: $showTransactionDetail) {
            if let transaction = selectedTransaction {
                NavigationStack {
                    EditTransactionView(transaction: transaction)
                }
            }
        }
    }

    // MARK: - 视图组件

    /// 统计汇总卡片
    private var statisticsSummarySection: some View {
        Section {
            VStack(spacing: 12) {
                // 分类图标和名称
                HStack(spacing: 12) {
                    Image(systemName: params.categoryIcon)
                        .font(.system(size: 32))
                        .foregroundColor(Color(hex: params.categoryColor) ?? .gray)
                        .frame(width: 56, height: 56)
                        .background((Color(hex: params.categoryColor) ?? .gray).opacity(0.1))
                        .clipShape(Circle())

                    VStack(alignment: .leading, spacing: 4) {
                        Text(params.categoryName)
                            .font(.title3)
                            .fontWeight(.semibold)

                        Text(params.transactionType == .income ? "收入" : "支出")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    Spacer()
                }

                Divider()

                // 统计数据
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("总金额")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(totalAmount, format: .currency(code: "CNY"))
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(params.transactionType == .income ? .green : .red)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text("交易笔数")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(transactions.count) 笔")
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                }
            }
            .padding(.vertical, 8)
        }
    }

    /// 空状态提示
    private var emptyStateSection: some View {
        Section {
            VStack(spacing: 16) {
                Image(systemName: "tray")
                    .font(.system(size: 48))
                    .foregroundColor(.secondary)

                Text("暂无交易记录")
                    .font(.headline)
                    .foregroundColor(.secondary)

                Text("该分类在此时间段内没有交易")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 40)
        }
    }

    /// 交易列表
    private var transactionListSection: some View {
        Section {
            ForEach(groupedTransactions.keys.sorted(by: >), id: \.self) { date in
                // 日期分组标题
                Section(header: Text(date, style: .date)) {
                    ForEach(groupedTransactions[date] ?? []) { transaction in
                        TransactionRowView(transaction: transaction)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedTransaction = transaction
                                showTransactionDetail = true
                            }
                    }
                }
            }
        }
    }

    // MARK: - 计算属性

    /// 总金额
    private var totalAmount: Double {
        transactions.reduce(0) { $0 + $1.amount }
    }

    /// 按日期分组的交易（用于列表展示）
    private var groupedTransactions: [Date: [Transaction]] {
        Dictionary(grouping: transactions) { transaction in
            Calendar.current.startOfDay(for: transaction.date)
        }
    }
}

// MARK: - 交易行视图

/// 交易行视图 - 显示单笔交易的简要信息
private struct TransactionRowView: View {
    let transaction: Transaction

    var body: some View {
        HStack(spacing: 12) {
            // 左侧：分类图标
            if let category = transaction.category {
                Image(systemName: category.icon)
                    .font(.system(size: 20))
                    .foregroundColor(Color(hex: category.color) ?? .gray)
                    .frame(width: 40, height: 40)
                    .background((Color(hex: category.color) ?? .gray).opacity(0.1))
                    .clipShape(Circle())
            } else {
                Image(systemName: "questionmark")
                    .font(.system(size: 20))
                    .foregroundColor(.gray)
                    .frame(width: 40, height: 40)
                    .background(Color.gray.opacity(0.1))
                    .clipShape(Circle())
            }

            // 中间：日期和备注
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.date, format: .dateTime.month().day().hour().minute())
                    .font(.subheadline)
                    .fontWeight(.medium)

                if !transaction.note.isEmpty {
                    Text(transaction.note)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            // 右侧：金额和箭头
            HStack(spacing: 8) {
                Text(transaction.amount, format: .currency(code: "CNY"))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(transaction.type == .income ? .green : .red)

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - 预览

#Preview {
    NavigationStack {
        CategoryTransactionListView(
            params: CategoryTransactionParams(
                categoryId: UUID(),
                categoryName: "餐饮",
                categoryIcon: "fork.knife",
                categoryColor: "FF6B6B",
                startDate: Date().addingTimeInterval(-7*24*3600),
                endDate: Date(),
                transactionType: .expense,
                periodDisplayName: "本周"
            )
        )
    }
    .modelContainer(for: [Transaction.self, Category.self])
}
