//
//  GlassmorphismModifier.swift
//  ExpenseTracker
//
//  Created by xiaolei on 2025/11/25.
//  玻璃拟态视觉效果修饰器
//

import SwiftUI

/// 玻璃拟态视觉效果修饰器
/// 作者: xiaolei
/// 提供毛玻璃、半透明、渐变边框等现代化视觉效果
struct GlassmorphismModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .opacity(0.8)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.3),
                                Color.white.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}

/// View 扩展，提供便捷的玻璃拟态修饰方法
/// 作者: xiaolei
extension View {
    /// 应用玻璃拟态效果
    /// - Returns: 应用效果后的视图
    func glassmorphism() -> some View {
        modifier(GlassmorphismModifier())
    }
}
