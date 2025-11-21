//
//  PeriodSelectorView.swift
//  ExpenseTracker
//
//  Created by xiaolei on 2025/11/13.
//  时间维度和周期选择器组件
//

import SwiftUI
import SwiftData

/// 时间维度和周期选择器视图
/// 作者: xiaolei
struct PeriodSelectorView: View {
    @Binding var selectedPeriod: TimePeriod
    @Binding var selectedOption: PeriodOption?
    let periodOptions: [PeriodOption]

    /// 当前选中项的索引
    /// 作者: xiaolei
    private var currentIndex: Int {
        guard let selected = selectedOption else { return 0 }
        return periodOptions.firstIndex(where: { $0.id == selected.id }) ?? 0
    }

    /// 是否可以向前（更早的周期）
    /// 作者: xiaolei
    private var canGoBack: Bool {
        currentIndex < periodOptions.count - 1
    }

    /// 是否可以向后（更晚的周期）
    /// 作者: xiaolei
    private var canGoForward: Bool {
        currentIndex > 0
    }

    var body: some View {
        VStack(spacing: 12) {
            // 时间维度选择器（周/月/年）
            Picker("时间维度", selection: $selectedPeriod) {
                ForEach(TimePeriod.allCases) { period in
                    Text(period.displayName).tag(period)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            // 周期选择器（支持左右滑动）
            if !periodOptions.isEmpty {
                HStack(spacing: 0) {
                    // 向前按钮（更早的周期）
                    Button {
                        goToPreviousPeriod()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(canGoBack ? .blue : .gray.opacity(0.3))
                            .frame(width: 44, height: 44)
                    }
                    .disabled(!canGoBack)

                    Spacer()

                    // 当前周期显示
                    Text(selectedOption?.displayName ?? "选择周期")
                        .font(.headline)
                        .foregroundColor(.blue)

                    Spacer()

                    // 向后按钮（更晚的周期）
                    Button {
                        goToNextPeriod()
                    } label: {
                        Image(systemName: "chevron.right")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(canGoForward ? .blue : .gray.opacity(0.3))
                            .frame(width: 44, height: 44)
                    }
                    .disabled(!canGoForward)
                }
                .padding(.horizontal, 8)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 30)
                        .onEnded { value in
                            // 左滑 = 向后（更晚的周期）
                            if value.translation.width < -30 && canGoForward {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    goToNextPeriod()
                                }
                            }
                            // 右滑 = 向前（更早的周期）
                            else if value.translation.width > 30 && canGoBack {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    goToPreviousPeriod()
                                }
                            }
                        }
                )
            }
        }
    }

    /// 切换到上一个周期（更早）
    /// 作者: xiaolei
    private func goToPreviousPeriod() {
        guard canGoBack else { return }
        selectedOption = periodOptions[currentIndex + 1]
    }

    /// 切换到下一个周期（更晚）
    /// 作者: xiaolei
    private func goToNextPeriod() {
        guard canGoForward else { return }
        selectedOption = periodOptions[currentIndex - 1]
    }
}
