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
    @State private var groupedTransactions: [Date: [Transaction]] = [:]
    @State private var showingEditLedger = false

    // 折叠状态
    @State private var isTrendExpanded = false
    @State private var isPieChartExpanded = false
    @State private var isTransactionsExpanded = true

    // 加载状态
    @State private var isDataLoaded = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // 头部信息
                headerView

                // 汇总统计卡片（始终显示，轻量级）
                summaryCardView
                    .padding(.horizontal)

                // 趋势图（可折叠）
                collapsibleSection(
                    title: "收支趋势",
                    icon: "chart.line.uptrend.xyaxis",
                    isExpanded: $isTrendExpanded
                ) {
                    if isDataLoaded && !trendData.isEmpty {
                        trendChartView
                    } else if isDataLoaded {
                        emptyChartView(message: "暂无趋势数据")
                    } else {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                    }
                }
                .padding(.horizontal)

                // 饼状图（可折叠）
                collapsibleSection(
                    title: "分类占比",
                    icon: "chart.pie.fill",
                    isExpanded: $isPieChartExpanded
                ) {
                    if isDataLoaded, let statistics = statistics {
                        PieChartView(statistics: statistics)
                    } else if isDataLoaded {
                        emptyChartView(message: "暂无分类数据")
                    } else {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                    }
                }
                .padding(.horizontal)

                // 交易列表（可折叠）
                collapsibleSection(
                    title: "交易记录",
                    icon: "list.bullet.rectangle",
                    isExpanded: $isTransactionsExpanded
                ) {
                    transactionListContent
                }
                .padding(.horizontal)
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
            // 后台加载数据，不阻塞UI
            await loadStatisticsInBackground()
        }
    }

    /// 可折叠的区块
    /// 作者: xiaolei
    @ViewBuilder
    private func collapsibleSection<Content: View>(
        title: String,
        icon: String,
        isExpanded: Binding<Bool>,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(spacing: 0) {
            // 标题栏（可点击）
            Button {
                withAnimation(.easeInOut(duration: 0.25)) {
                    isExpanded.wrappedValue.toggle()
                }
            } label: {
                HStack {
                    Image(systemName: icon)
                        .foregroundColor(.blue)
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: isExpanded.wrappedValue ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemBackground))
            }
            .buttonStyle(.plain)

            // 内容区域
            if isExpanded.wrappedValue {
                content()
                    .padding(.horizontal)
                    .padding(.bottom)
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }

    /// 空图表视图
    /// 作者: xiaolei
    private func emptyChartView(message: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: "chart.bar.xaxis")
                .font(.title)
                .foregroundColor(.secondary)
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }

    /// 汇总卡片视图（轻量级，直接从ledger读取）
    /// 作者: xiaolei
    private var summaryCardView: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("总收入")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(ledger.formattedTotalIncome)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text("总支出")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(ledger.formattedTotalExpense)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.red)
                }
            }

            Divider()

            HStack {
                Text("结余")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Text(ledger.formattedBalance)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(ledger.balance >= 0 ? .green : .red)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
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
            // 标题和图例
            HStack {
                Text("收支趋势")
                    .font(.headline)
                    .foregroundColor(.primary)

                Spacer()

                // 图例
                HStack(spacing: 16) {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 8, height: 8)
                        Text("收入")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }

                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 8, height: 8)
                        Text("支出")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }

            Chart {
                // 收入折线 - 使用系列标识
                ForEach(trendData) { dataPoint in
                    LineMark(
                        x: .value("日期", dataPoint.date),
                        y: .value("金额", dataPoint.income),
                        series: .value("类型", "收入")
                    )
                    .foregroundStyle(Color.green)
                    .interpolationMethod(.catmullRom)
                    .symbol {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 6, height: 6)
                    }
                    .lineStyle(StrokeStyle(lineWidth: 2))
                }

                // 支出折线 - 使用系列标识
                ForEach(trendData) { dataPoint in
                    LineMark(
                        x: .value("日期", dataPoint.date),
                        y: .value("金额", dataPoint.expense),
                        series: .value("类型", "支出")
                    )
                    .foregroundStyle(Color.red)
                    .interpolationMethod(.catmullRom)
                    .symbol {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 6, height: 6)
                    }
                    .lineStyle(StrokeStyle(lineWidth: 2))
                }
            }
            .chartXAxis {
                AxisMarks(values: .automatic(desiredCount: 5)) { value in
                    if let date = value.as(Date.self) {
                        AxisValueLabel {
                            Text(formatChartDate(date))
                                .font(.caption2)
                        }
                        AxisGridLine()
                    }
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisValueLabel {
                        if let amount = value.as(Double.self) {
                            Text(formatChartAmount(amount))
                                .font(.caption2)
                        }
                    }
                    AxisGridLine()
                }
            }
            .frame(height: 200)
        }
        .padding()
        .glassmorphism()
    }

    /// 格式化图表日期
    /// 作者: xiaolei
    private func formatChartDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "M/d"
        return formatter.string(from: date)
    }

    /// 格式化图表金额
    /// 作者: xiaolei
    private func formatChartAmount(_ amount: Double) -> String {
        if amount >= 10000 {
            return String(format: "%.1fw", amount / 10000)
        } else if amount >= 1000 {
            return String(format: "%.1fk", amount / 1000)
        } else {
            return String(format: "%.0f", amount)
        }
    }

    /// 交易列表内容
    /// 作者: xiaolei
    @ViewBuilder
    private var transactionListContent: some View {
        if !isDataLoaded {
            ProgressView()
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
        } else if groupedTransactions.isEmpty {
            // 空状态
            VStack(spacing: 8) {
                Image(systemName: "tray")
                    .font(.title)
                    .foregroundColor(.secondary)
                Text("暂无交易记录")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
        } else {
            // 交易列表（按日期分组）
            VStack(spacing: 0) {
                ForEach(groupedTransactions.keys.sorted(by: >), id: \.self) { date in
                    VStack(alignment: .leading, spacing: 0) {
                        // 日期标题
                        Text(formatSectionDate(date))
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                            .padding(.vertical, 8)

                        // 该日期的交易
                        ForEach(groupedTransactions[date] ?? []) { transaction in
                            HStack(spacing: 12) {
                                // 分类图标
                                Image(systemName: transaction.categoryIcon)
                                    .font(.subheadline)
                                    .foregroundColor(Color(hex: transaction.category?.color ?? "95A5A6") ?? .gray)
                                    .frame(width: 32, height: 32)
                                    .background(
                                        Circle()
                                            .fill(Color(hex: transaction.category?.color ?? "95A5A6")?.opacity(0.2) ?? .gray.opacity(0.2))
                                    )

                                // 信息
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(transaction.categoryName)
                                        .font(.subheadline)
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
                                    .fontWeight(.medium)
                                    .foregroundColor(transaction.type == .income ? .green : .red)
                            }
                            .padding(.vertical, 6)
                        }
                    }
                }
            }
        }
    }

    /// 后台加载统计数据
    /// 作者: xiaolei
    @MainActor
    private func loadStatisticsInBackground() async {
        // 延迟一小段时间，让导航动画完成
        try? await Task.sleep(nanoseconds: 50_000_000) // 0.05秒

        // 计算分组交易（优先加载，因为交易列表默认展开）
        let calendar = Calendar.current
        let sortedTransactions = ledger.transactions.sorted { $0.date > $1.date }
        groupedTransactions = Dictionary(grouping: sortedTransactions) { transaction in
            calendar.startOfDay(for: transaction.date)
        }

        // 计算统计数据（图表数据，后台加载）
        statistics = LedgerService.calculateLedgerStatistics(for: ledger, modelContext: modelContext)
        trendData = LedgerService.calculateLedgerTrendData(for: ledger, modelContext: modelContext)

        isDataLoaded = true
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
