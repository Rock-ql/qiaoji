//
//  TrendChartView.swift
//  ExpenseTracker
//
//  Created by xiaolei on 2025/11/21.
//  趋势折线图组件
//

import SwiftUI
import Charts

/// 趋势折线图视图
/// 作者: xiaolei
struct TrendChartView: View {
    let trendData: [TrendDataPoint]
    let period: TimePeriod

    /// 选中的数据点
    /// 作者: xiaolei
    @State private var selectedDate: Date?

    /// 选中的数据点信息
    /// 作者: xiaolei
    private var selectedDataPoint: TrendDataPoint? {
        guard let date = selectedDate else { return nil }
        return trendData.first { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 图表标题
            HStack(spacing: 6) {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundColor(.blue)
                Text("趋势")
                    .font(.headline)

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
            .padding(.horizontal, 16)
            .padding(.top, 16)

            // 折线图
            if trendData.isEmpty {
                // 空状态
                VStack(spacing: 12) {
                    Image(systemName: "chart.line.downtrend.xyaxis")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)

                    Text("暂无数据")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 200)
            } else {
                Chart {
                    // 收入折线
                    ForEach(trendData) { dataPoint in
                        LineMark(
                            x: .value("日期", dataPoint.date),
                            y: .value("收入", dataPoint.income)
                        )
                        .foregroundStyle(Color.green)
                        .symbol(Circle())
                        .interpolationMethod(.catmullRom)
                    }

                    // 支出折线
                    ForEach(trendData) { dataPoint in
                        LineMark(
                            x: .value("日期", dataPoint.date),
                            y: .value("支出", dataPoint.expense)
                        )
                        .foregroundStyle(Color.red)
                        .symbol(Circle())
                        .interpolationMethod(.catmullRom)
                    }

                    // 选中标记
                    if let selectedDataPoint = selectedDataPoint {
                        RuleMark(x: .value("选中日期", selectedDataPoint.date))
                            .foregroundStyle(Color.blue.opacity(0.3))
                            .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
                            .annotation(position: .top, spacing: 8) {
                                selectionAnnotation(for: selectedDataPoint)
                            }
                    }
                }
                .chartXSelection(value: $selectedDate)
                .chartXAxis {
                    AxisMarks(values: .automatic) { value in
                        if let date = value.as(Date.self) {
                            AxisValueLabel {
                                Text(formatXAxisLabel(date))
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
                                Text(formatYAxisLabel(amount))
                                    .font(.caption2)
                            }
                        }
                        AxisGridLine()
                    }
                }
                .frame(height: 200)
                .padding(.horizontal, 12)
                .padding(.bottom, 12)
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        .padding(.horizontal, 16)
    }

    /// 格式化X轴标签
    /// 作者: xiaolei
    private func formatXAxisLabel(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")

        switch period {
        case .week:
            // 周：显示星期（周一、周二...）
            formatter.dateFormat = "EEEE"
            let weekday = formatter.string(from: date)
            return weekday.replacingOccurrences(of: "星期", with: "周")
        case .month:
            // 月：显示日期（1日、5日、10日...）
            let day = Calendar.current.component(.day, from: date)
            // 每5天显示一个标签
            return day % 5 == 1 ? "\(day)日" : ""
        case .year:
            // 年：显示月份（1月、2月...）
            formatter.dateFormat = "M月"
            return formatter.string(from: date)
        }
    }

    /// 格式化Y轴标签（金额）
    /// 作者: xiaolei
    private func formatYAxisLabel(_ amount: Double) -> String {
        if amount >= 10000 {
            return String(format: "%.1fw", amount / 10000)
        } else if amount >= 1000 {
            return String(format: "%.1fk", amount / 1000)
        } else {
            return String(format: "%.0f", amount)
        }
    }

    /// 选中数据点的注释视图
    /// 作者: xiaolei
    @ViewBuilder
    private func selectionAnnotation(for dataPoint: TrendDataPoint) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            // 日期
            Text(dataPoint.formattedDate(for: period))
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.primary)

            // 收入
            HStack(spacing: 4) {
                Circle()
                    .fill(Color.green)
                    .frame(width: 6, height: 6)
                Text("收入：")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text(String(format: "¥%.2f", dataPoint.income))
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.green)
            }

            // 支出
            HStack(spacing: 4) {
                Circle()
                    .fill(Color.red)
                    .frame(width: 6, height: 6)
                Text("支出：")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text(String(format: "¥%.2f", dataPoint.expense))
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.red)
            }

            // 结余
            Divider()

            HStack(spacing: 4) {
                Text("结余：")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                let balance = dataPoint.income - dataPoint.expense
                Text(String(format: "¥%.2f", balance))
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(balance >= 0 ? .blue : .orange)
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
    }
}
