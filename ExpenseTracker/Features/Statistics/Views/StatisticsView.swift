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
/// 提供按周/月/年维度查看收支统计的功能
struct StatisticsView: View {
    @Environment(\.modelContext) private var modelContext

    // 时间维度选择
    @State private var selectedPeriod: TimePeriod = .week
    @State private var selectedOption: PeriodOption?

    // 周期选项列表
    @State private var periodOptions: [PeriodOption] = []

    // 统计数据
    @State private var statistics: PeriodStatistics?

    // 当前显示的交易类型（收入/支出）
    @State private var selectedTransactionType: TransactionType = .expense

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 时间维度和周期选择器
                    PeriodSelectorView(
                        selectedPeriod: $selectedPeriod,
                        selectedOption: $selectedOption,
                        periodOptions: periodOptions
                    )
                    .padding(.top)

                    if let stats = statistics {
                        if stats.hasData {
                            // 汇总卡片
                            StatisticsSummaryCard(statistics: stats)

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
        }
        .onAppear {
            loadPeriodOptions()
        }
        .onChange(of: selectedPeriod) { oldValue, newValue in
            loadPeriodOptions()
        }
        .onChange(of: selectedOption) { oldValue, newValue in
            if newValue != nil {
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
                        CategoryStatisticsRow(categoryStats: categoryStats)
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
            return
        }

        statistics = StatisticsService.calculateStatistics(for: option, modelContext: modelContext)
    }
}

// MARK: - 预览
#Preview {
    StatisticsView()
        .modelContainer(for: [Transaction.self, Category.self], inMemory: true)
}
