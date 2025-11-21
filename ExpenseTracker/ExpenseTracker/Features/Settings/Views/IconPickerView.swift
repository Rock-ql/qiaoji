//
//  IconPickerView.swift
//  ExpenseTracker
//
//  Created by xiaolei on 2025/11/13.
//  图标选择器
//

import SwiftUI

/// 图标选择器视图
/// 作者: xiaolei
/// 提供SF Symbols图标选择功能
struct IconPickerView: View {
    /// 关闭视图
    @Environment(\.dismiss) private var dismiss

    /// 选中的图标绑定
    @Binding var selectedIcon: String

    /// 推荐的财务相关图标
    /// 作者: xiaolei
    private let recommendedIcons = [
        // 餐饮
        "fork.knife", "cup.and.saucer.fill", "wineglass.fill", "birthday.cake.fill",
        // 交通
        "car.fill", "bus.fill", "bicycle", "airplane", "fuelpump.fill",
        // 购物
        "cart.fill", "bag.fill", "basket.fill", "gift.fill",
        // 娱乐
        "gamecontroller.fill", "music.note", "film.fill", "tv.fill", "sportscourt.fill",
        // 医疗健康
        "cross.case.fill", "heart.fill", "pills.fill", "stethoscope",
        // 教育
        "book.fill", "graduationcap.fill", "pencil", "backpack.fill",
        // 住房
        "house.fill", "bed.double.fill", "lightbulb.fill", "lamp.desk.fill",
        // 金融
        "dollarsign.circle.fill", "yensign.circle.fill", "eurosign.circle.fill",
        "creditcard.fill", "banknote.fill", "wallet.pass.fill",
        // 工作
        "briefcase.fill", "desktopcomputer", "laptopcomputer", "phone.fill",
        // 其他
        "ellipsis.circle.fill", "star.fill", "flag.fill", "tag.fill",
        "bell.fill", "location.fill", "calendar", "clock.fill"
    ]

    /// 网格列配置
    private let columns = [
        GridItem(.adaptive(minimum: 60), spacing: 12)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(recommendedIcons, id: \.self) { icon in
                        IconCell(
                            icon: icon,
                            isSelected: icon == selectedIcon
                        ) {
                            selectedIcon = icon
                            dismiss()
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("选择图标")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
        }
    }
}

/// 图标单元格
/// 作者: xiaolei
struct IconCell: View {
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : .primary)
                    .frame(width: 50, height: 50)
                    .background(
                        Circle()
                            .fill(isSelected ? Color.blue : Color.gray.opacity(0.15))
                    )
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 预览

#Preview {
    IconPickerView(selectedIcon: .constant("fork.knife"))
}
