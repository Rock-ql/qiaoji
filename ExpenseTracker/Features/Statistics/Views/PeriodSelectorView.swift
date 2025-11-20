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

            // 周期选择器（本周、上周、具体周等）
            if !periodOptions.isEmpty {
                Menu {
                    ForEach(periodOptions) { option in
                        Button {
                            selectedOption = option
                        } label: {
                            HStack {
                                Text(option.displayName)
                                if option.isCurrent {
                                    Image(systemName: "clock")
                                }
                            }
                        }
                    }
                } label: {
                    HStack {
                        Text(selectedOption?.displayName ?? "选择周期")
                            .font(.headline)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .font(.caption)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
            }
        }
    }
}
