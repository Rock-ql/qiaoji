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

            // 周期选择器（横向滚动胶囊列表）
            if !periodOptions.isEmpty {
                ScrollViewReader { proxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(periodOptions) { option in
                                PeriodCapsule(
                                    option: option,
                                    isSelected: selectedOption?.id == option.id
                                ) {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        selectedOption = option
                                    }
                                }
                                .id(option.id)
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    .onAppear {
                        // 初始滚动到选中项
                        if let selected = selectedOption {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                withAnimation {
                                    proxy.scrollTo(selected.id, anchor: .center)
                                }
                            }
                        }
                    }
                    .onChange(of: selectedOption) { _, newValue in
                        // 选中项变化时滚动到对应位置
                        if let selected = newValue {
                            withAnimation {
                                proxy.scrollTo(selected.id, anchor: .center)
                            }
                        }
                    }
                }
            }
        }
    }
}

/// 周期胶囊标签
/// 作者: xiaolei
struct PeriodCapsule: View {
    let option: PeriodOption
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(option.displayName)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.blue : Color(.systemGray5))
                )
        }
        .buttonStyle(.plain)
    }
}
