//
//  ColorPickerView.swift
//  ExpenseTracker
//
//  Created by xiaolei on 2025/11/13.
//  颜色选择器
//

import SwiftUI

/// 颜色选择器视图
/// 作者: xiaolei
/// 提供预设颜色选择功能
struct ColorPickerView: View {
    /// 关闭视图
    @Environment(\.dismiss) private var dismiss

    /// 选中的颜色绑定（十六进制字符串）
    @Binding var selectedColor: String

    /// 预设颜色列表（十六进制字符串）
    /// 作者: xiaolei
    private let presetColors = [
        // 红色系
        "FF6B6B", "EE5A6F", "FF8B94", "E74C3C", "C0392B",
        // 橙色系
        "FFE66D", "F39C12", "E67E22", "FF9F43", "FFA07A",
        // 黄色系
        "FFD93D", "F7DC6F", "F9CA24", "FFC312", "F8B400",
        // 绿色系
        "A8E6CF", "2ECC71", "27AE60", "16A085", "1ABC9C",
        // 青色系
        "4ECDC4", "48C9B0", "45B7D1", "3498DB", "2980B9",
        // 蓝色系
        "6C5CE7", "5F27CD", "3742FA", "2F3542", "57606F",
        // 紫色系
        "C7CEEA", "B4A7D6", "9B59B6", "8E44AD", "A29BFE",
        // 粉色系
        "FDA7DF", "E84393", "FD79A8", "F8A5C2", "EA8685",
        // 灰色系
        "95A5A6", "7F8C8D", "636E72", "2D3436", "34495E",
        // 棕色系
        "D4A574", "C39BD3", "A569BD", "7D5A50", "6C4A3E"
    ]

    /// 网格列配置
    private let columns = [
        GridItem(.adaptive(minimum: 50), spacing: 16)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(presetColors, id: \.self) { colorHex in
                        ColorCell(
                            colorHex: colorHex,
                            isSelected: colorHex == selectedColor
                        ) {
                            selectedColor = colorHex
                            dismiss()
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("选择颜色")
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

/// 颜色单元格
/// 作者: xiaolei
struct ColorCell: View {
    let colorHex: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Circle()
                .fill(Color(colorHex))
                .frame(width: 50, height: 50)
                .overlay(
                    Circle()
                        .strokeBorder(Color.white, lineWidth: 3)
                        .opacity(isSelected ? 1 : 0)
                )
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 预览

#Preview {
    ColorPickerView(selectedColor: .constant("FF6B6B"))
}
