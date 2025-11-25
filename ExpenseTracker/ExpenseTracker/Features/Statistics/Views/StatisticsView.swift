//
//  StatisticsView.swift
//  ExpenseTracker
//
//  Created by xiaolei on 2025/11/13.
//  统计功能主页面
//

import SwiftUI
import SwiftData

/// 统计主视图
/// 作者: xiaolei
/// 提供按周/月/年维度查看收支统计的功能，支持按账本筛选
struct StatisticsView: View {
    @Environment(\.modelContext) private var modelContext

    // 账本选择
    @State private var selectedLedger: Ledger?

    // 时间维度选择
    @State private var selectedPeriod: TimePeriod = .week
    @State private var selectedOption: PeriodOption?

    // 周期选项列表
    @State private var periodOptions: [PeriodOption] = []

    // 统计数据
    @State private var statistics: PeriodStatistics?

    // 当前显示的交易类型（收入/支出）
    @State private var selectedTransactionType: TransactionType = .expense

    // 显示模式（汇总/趋势）
    @State private var displayMode: DisplayMode = .summary

    // 趋势数据
    @State private var trendData: [TrendDataPoint] = []

    // 监听所有交易数据的变化，用于触发统计自动刷新
    @Query private var allTransactions: [Transaction]

    /// 显示模式枚举
    /// 作者: xiaolei
    enum DisplayMode: String, CaseIterable {
        case summary = "汇总"
        case trend = "趋势"
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 账本选择器
                    LedgerPickerView(selectedLedger: $selectedLedger, showAllOption: true)
                        .padding(.top, 8)

                    // 时间维度和周期选择器
                    PeriodSelectorView(
                        selectedPeriod: $selectedPeriod,
                        selectedOption: $selectedOption,
                        periodOptions: periodOptions
                    )

                    if let stats = statistics {
                        if stats.hasData {
                            // 显示模式切换（汇总/趋势）
                            Picker("显示模式", selection: $displayMode) {
                                ForEach(DisplayMode.allCases, id: \.self) { mode in
                                    Text(mode.rawValue).tag(mode)
                                }
                            }
                            .pickerStyle(.segmented)
                            .padding(.horizontal)

                            // 根据模式显示不同的视图
                            if displayMode == .summary {
                                // 汇总卡片
                                StatisticsSummaryCard(statistics: stats)
                            } else {
                                // 趋势图
                                TrendChartView(trendData: trendData, period: selectedPeriod)
                            }

                            // 类型切换（收入/支出）
                            Picker("类型", selection: $selectedTransactionType) {
                                Text("支出").tag(TransactionType.expense)
                                Text("收入").tag(TransactionType.income)
                            }
                            .pickerStyle(.segmented)
                            .padding(.horizontal)

                            // 分类统计列表
                            categoryStatisticsList(for: stats)
                        } else {
                            // 空数据提示
                            emptyStateView
                        }
                    } else {
                        // 加载中
                        ProgressView()
                            .padding()
                    }
                }
                .padding(.bottom, 20)
            }
            .navigationTitle("统计")
            .navigationBarTitleDisplayMode(.large)
            .background(Color(.systemGroupedBackground))
            // 配置导航目标：点击分类统计行后导航到交易明细列表
            .navigationDestination(for: CategoryTransactionParams.self) { params in
                CategoryTransactionListView(params: params)
            }
        }
        .onAppear {
            loadPeriodOptions()
        }
        .onChange(of: selectedPeriod) { oldValue, newValue in
            loadPeriodOptions()
        }
        .onChange(of: selectedLedger) { oldValue, newValue in
            // 账本切换时重新计算统计
            if selectedOption != nil {
                calculateStatistics()
            }
        }
        .onChange(of: selectedOption) { oldValue, newValue in
            if newValue != nil {
                calculateStatistics()
            }
        }
        // 监听交易数据变化，当添加/删除/编辑交易后自动刷新统计
        .onChange(of: allTransactions.count) { oldValue, newValue in
            // 当交易数量发生变化时，重新计算统计数据
            if selectedOption != nil {
                calculateStatistics()
            }
        }
        // 监听交易内容变化（金额/时间等），即使笔数不变也自动刷新
        .onChange(of: transactionsSignature) { _, _ in
            if selectedOption != nil {
                calculateStatistics()
            }
        }
    }

    /// 分类统计列表视图
    /// 作者: xiaolei
    @ViewBuilder
    private func categoryStatisticsList(for stats: PeriodStatistics) -> some View {
        let categories = selectedTransactionType == .expense ? stats.expenseCategories : stats.incomeCategories

        VStack(alignment: .leading, spacing: 12) {
            // 标题
            HStack {
                Image(systemName: "list.bullet")
                    .foregroundColor(.blue)
                Text("分类明细")
                    .font(.headline)
                Spacer()
                Text("\(categories.count)个分类")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)

            // 分类列表
            if categories.isEmpty {
                Text("暂无\(selectedTransactionType == .expense ? "支出" : "收入")数据")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                VStack(spacing: 1) {
                    ForEach(categories) { categoryStats in
                        // 使用NavigationLink包装分类统计行，支持点击导航到明细
                        NavigationLink(value: createNavigationParams(for: categoryStats)) {
                            CategoryStatisticsRow(categoryStats: categoryStats)
                        }
                        .buttonStyle(PlainButtonStyle())

                        if categoryStats.id != categories.last?.id {
                            Divider()
                                .padding(.leading, 68)
                        }
                    }
                }
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                .padding(.horizontal)
            }
        }
    }

    /// 空数据状态视图
    /// 作者: xiaolei
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 60))
                .foregroundColor(.gray)

            Text("暂无数据")
                .font(.title3)
                .fontWeight(.medium)

            Text("该时间段内没有交易记录")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.top, 100)
    }

    /// 加载周期选项列表
    /// 作者: xiaolei
    private func loadPeriodOptions() {
        periodOptions = StatisticsService.getPeriodOptions(for: selectedPeriod, modelContext: modelContext)

        // 自动选择第一个选项（本周/本月/今年）
        if let firstOption = periodOptions.first {
            selectedOption = firstOption
        }
    }

    /// 计算统计数据
    /// 作者: xiaolei
    private func calculateStatistics() {
        guard let option = selectedOption else {
            statistics = nil
            trendData = []
            return
        }

        // 计算汇总统计数据
        statistics = StatisticsService.calculateStatistics(for: option, modelContext: modelContext)

        // 计算趋势数据
        trendData = StatisticsService.calculateTrendData(for: option, modelContext: modelContext)
    }

    /// 创建导航参数
    /// 作者: xiaolei
    /// 将分类统计数据转换为导航参数，用于跳转到交易明细列表
    private func createNavigationParams(for categoryStats: CategoryStatistics) -> CategoryTransactionParams {
        guard let selectedOption = selectedOption else {
            fatalError("selectedOption不能为空")
        }

        return CategoryTransactionParams(
            categoryId: categoryStats.categoryId,
            categoryName: categoryStats.categoryName,
            categoryIcon: categoryStats.categoryIcon,
            categoryColor: categoryStats.categoryColor,
            startDate: selectedOption.startDate,
            endDate: selectedOption.endDate,
            transactionType: selectedTransactionType,
            periodDisplayName: selectedOption.displayName
        )
    }

    /// 交易变更签名：用于监听金额、日期等字段的变化
    private var transactionsSignature: String {
        allTransactions
            .map { "\($0.id.uuidString)|\($0.amount)|\($0.date.timeIntervalSince1970)" }
            .joined(separator: ";")
    }
}

// MARK: - 预览
#Preview {
    StatisticsView()
        .modelContainer(for: [Transaction.self, Category.self], inMemory: true)
}
