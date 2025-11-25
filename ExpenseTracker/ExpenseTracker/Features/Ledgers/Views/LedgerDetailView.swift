//
//  LedgerDetailView.swift
//  ExpenseTracker
//
//  Created by xiaolei on 2025/11/25.
//  账本详情页面
//

import SwiftUI
import SwiftData
import Charts

/// 账本详情视图
/// 作者: xiaolei
/// 展示账本的完整信息、统计数据、趋势图、饼状图和交易列表
struct LedgerDetailView: View {
    @Environment(\.modelContext) private var modelContext
    let ledger: Ledger

    @State private var statistics: LedgerStatistics?
    @State private var trendData: [TrendDataPoint] = []
    @State private var showingEditLedger = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 头部信息
                headerView

                // 汇总统计卡片
                if let statistics = statistics {
                    LedgerSummaryCard(statistics: statistics)
                        .padding(.horizontal)
                }

                // 趋势图
                if !trendData.isEmpty {
                    trendChartView
                        .padding(.horizontal)
                }

                // 饼状图
                if let statistics = statistics {
                    PieChartView(statistics: statistics)
                        .padding(.horizontal)
                }

                // 交易列表
                transactionListView
            }
            .padding(.vertical)
        }
        .navigationTitle(ledger.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    showingEditLedger = true
                }) {
                    Text("编辑")
                }
            }
        }
        .sheet(isPresented: $showingEditLedger) {
            EditLedgerView(ledger: ledger)
        }
        .task {
            loadStatistics()
        }
    }

    /// 头部信息视图
    /// 作者: xiaolei
    private var headerView: some View {
        HStack(spacing: 16) {
            // 图标
            Image(systemName: ledger.icon)
                .font(.system(size: 40))
                .foregroundColor(Color(hex: ledger.color) ?? .blue)
                .frame(width: 80, height: 80)
                .background(
                    Circle()
                        .fill(Color(hex: ledger.color)?.opacity(0.2) ?? .blue.opacity(0.2))
                )

            // 信息
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Text(ledger.name)
                        .font(.title2)
                        .fontWeight(.bold)

                    if ledger.isDefault {
                        Text("默认")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Capsule().fill(Color.blue))
                    }
                }

                if !ledger.ledgerDescription.isEmpty {
                    Text(ledger.ledgerDescription)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }

                Text("创建于 \(formatDate(ledger.createdAt))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding()
        .glassmorphism()
        .padding(.horizontal)
    }

    /// 趋势图视图
    /// 作者: xiaolei
    private var trendChartView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("收支趋势")
                .font(.headline)
                .foregroundColor(.primary)

            Chart {
                ForEach(trendData) { dataPoint in
                    LineMark(
                        x: .value("日期", dataPoint.date),
                        y: .value("收入", dataPoint.income)
                    )
                    .foregroundStyle(.green)
                    .interpolationMethod(.catmullRom)

                    LineMark(
                        x: .value("日期", dataPoint.date),
                        y: .value("支出", dataPoint.expense)
                    )
                    .foregroundStyle(.red)
                    .interpolationMethod(.catmullRom)
                }
            }
            .chartXAxis {
                AxisMarks(values: .automatic(desiredCount: 5))
            }
            .frame(height: 200)
        }
        .padding()
        .glassmorphism()
    }

    /// 交易列表视图
    /// 作者: xiaolei
    private var transactionListView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("交易记录")
                .font(.headline)
                .foregroundColor(.primary)
                .padding(.horizontal)

            if ledger.transactions.isEmpty {
                // 空状态
                VStack(spacing: 8) {
                    Image(systemName: "tray")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                    Text("暂无交易记录")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                // 交易列表（按日期分组）
                ForEach(groupedTransactions.keys.sorted(by: >), id: \.self) { date in
                    Section {
                        ForEach(groupedTransactions[date] ?? []) { transaction in
                            HStack(spacing: 12) {
                                // 分类图标
                                Image(systemName: transaction.categoryIcon)
                                    .font(.title3)
                                    .foregroundColor(Color(hex: transaction.category?.color ?? "95A5A6") ?? .gray)
                                    .frame(width: 40, height: 40)
                                    .background(
                                        Circle()
                                            .fill(Color(hex: transaction.category?.color ?? "95A5A6")?.opacity(0.2) ?? .gray.opacity(0.2))
                                    )

                                // 信息
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(transaction.categoryName)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.primary)

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
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(transaction.type == .income ? .green : .red)
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                        }
                    } header: {
                        HStack {
                            Text(formatSectionDate(date))
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                    }
                }
            }
        }
    }

    /// 按日期分组的交易
    /// 作者: xiaolei
    private var groupedTransactions: [Date: [Transaction]] {
        let calendar = Calendar.current
        let sortedTransactions = ledger.transactions.sorted { $0.date > $1.date }
        return Dictionary(grouping: sortedTransactions) { transaction in
            calendar.startOfDay(for: transaction.date)
        }
    }

    /// 加载统计数据
    /// 作者: xiaolei
    private func loadStatistics() {
        statistics = LedgerService.calculateLedgerStatistics(for: ledger, modelContext: modelContext)
        trendData = LedgerService.calculateLedgerTrendData(for: ledger, modelContext: modelContext)
    }

    /// 格式化日期
    /// 作者: xiaolei
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: date)
    }

    /// 格式化分组日期
    /// 作者: xiaolei
    private func formatSectionDate(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "今天"
        } else if calendar.isDateInYesterday(date) {
            return "昨天"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "M月d日 EEEE"
            formatter.locale = Locale(identifier: "zh_CN")
            return formatter.string(from: date)
        }
    }
}
