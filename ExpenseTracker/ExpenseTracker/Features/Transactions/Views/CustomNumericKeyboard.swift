//
//  CustomNumericKeyboard.swift
//  ExpenseTracker
//
//  Created by xiaolei on 2025/11/13.
//  自定义数字键盘，用于输入金额，支持多笔金额累加/累减
//

import SwiftUI

/// 输入模式枚举
/// 作者: xiaolei
enum InputMode: Equatable {
    case amount    // 金额输入模式（显示数字键盘）
    case note      // 备注输入模式（显示系统键盘）
    case none      // 无输入模式
}

/// 自定义数字键盘
/// 作者: xiaolei
/// 提供数字输入、小数点、加减运算和删除等功能
struct CustomNumericKeyboard: View {
    /// 当前输入的金额文本
    @Binding var amount: String

    /// 交易日期
    @Binding var date: Date

    /// 备注
    @Binding var note: String

    /// 当前输入模式
    @Binding var inputMode: InputMode

    /// 累计金额（用于多笔金额计算）
    @State private var accumulatedAmount: Double = 0.0

    /// 当前输入的临时金额（用于显示）
    @State private var currentInput: String = ""

    /// 是否显示累计金额提示
    @State private var showAccumulatedHint: Bool = false

    /// 上一次的操作类型（加或减）
    @State private var lastOperation: OperationType? = nil

    /// 备注输入框焦点状态
    /// 作者: xiaolei
    @FocusState private var isNoteFocused: Bool

    /// 是否显示日期选择器弹窗
    /// 作者: xiaolei
    @State private var showDatePicker = false

    /// 完成回调
    var onDone: (() -> Void)?

    /// 操作类型枚举
    /// 作者: xiaolei
    enum OperationType {
        case add
        case subtract
    }

    /// 键盘布局数据
    /// 作者: xiaolei
    private let keyboardLayout: [[KeyboardKey]] = [
        [.number("7"), .number("8"), .number("9"), .action(.delete)],
        [.number("4"), .number("5"), .number("6"), .action(.add)],
        [.number("1"), .number("2"), .number("3"), .action(.subtract)],
        [.number("0"), .number("."), .number("00"), .action(.done)]
    ]

    /// 实时计算的累计金额（包含当前输入）
    /// 作者: xiaolei
    private var realTimeAccumulatedAmount: Double {
        guard let currentValue = Double(currentInput), currentValue > 0 else {
            return accumulatedAmount
        }

        guard let operation = lastOperation else {
            return accumulatedAmount
        }

        switch operation {
        case .add:
            return accumulatedAmount + currentValue
        case .subtract:
            return accumulatedAmount - currentValue
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // 拖动指示器
            Capsule()
                .fill(Color(.systemGray4))
                .frame(width: 36, height: 4)
                .padding(.top, 8)
                .padding(.bottom, 4)

            // 备注输入区域
            HStack(spacing: 12) {
                Image(systemName: "square.and.pencil")
                    .font(.system(size: 16))
                    .foregroundColor(inputMode == .note ? .blue : .secondary)

                TextField("添加备注", text: $note)
                    .textFieldStyle(.plain)
                    .font(.subheadline)
                    .focused($isNoteFocused)
                    .onTapGesture {
                        // 点击备注区域切换到备注输入模式
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            inputMode = .note
                        }
                    }

                if !note.isEmpty {
                    Button(action: {
                        note = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.systemGray6))
            )
            .padding(.horizontal, 16)
            .padding(.bottom, 8)

            // 金额显示区域
            HStack(alignment: .center, spacing: 8) {
                Text("¥")
                    .font(.system(size: 32, weight: .light))
                    .foregroundColor(.secondary)

                Text(currentInput.isEmpty ? "0" : currentInput)
                    .font(.system(size: 44, weight: .medium, design: .rounded))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .contentTransition(.numericText())

                Spacer()

                // 日期选择按钮
                Button(action: {
                    showDatePicker = true
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.system(size: 12))
                        Text(formatDateForButton(date))
                            .font(.system(size: 13, weight: .medium))
                    }
                    .foregroundColor(.blue)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color.blue.opacity(0.1))
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
            .contentShape(Rectangle())
            .onTapGesture {
                // 点击金额区域切换到金额输入模式
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    isNoteFocused = false
                    inputMode = .amount
                }
            }

            // 累计金额提示栏
            if showAccumulatedHint {
                HStack(spacing: 8) {
                    Image(systemName: lastOperation == .add ? "plus.circle.fill" : "minus.circle.fill")
                        .foregroundColor(lastOperation == .add ? .green : .orange)
                        .font(.system(size: 14))

                    Text("累计")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)

                    Text(formatCurrency(realTimeAccumulatedAmount))
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary)

                    Spacer()

                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            resetAccumulation()
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(Color(.systemGray3))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color(.systemGray6))
                .transition(.asymmetric(
                    insertion: .push(from: .top).combined(with: .opacity),
                    removal: .push(from: .bottom).combined(with: .opacity)
                ))
            }

            // 数字键盘（仅在金额输入模式显示）
            if inputMode == .amount {
                VStack(spacing: 1) {
                    ForEach(0..<keyboardLayout.count, id: \.self) { rowIndex in
                        HStack(spacing: 1) {
                            ForEach(0..<keyboardLayout[rowIndex].count, id: \.self) { colIndex in
                                KeyButton(
                                    key: keyboardLayout[rowIndex][colIndex],
                                    action: { handleKeyPress(keyboardLayout[rowIndex][colIndex]) }
                                )
                            }
                        }
                    }
                }
                .background(Color(.systemGray4))
                .transition(.asymmetric(
                    insertion: .move(edge: .bottom).combined(with: .opacity),
                    removal: .move(edge: .bottom).combined(with: .opacity)
                ))
            }
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: -4)
        .sheet(isPresented: $showDatePicker) {
            DatePickerSheet(date: $date)
        }
        .onAppear {
            // 初始化时，如果amount有值，显示在currentInput中
            if !amount.isEmpty && amount != "0" && amount != "0.00" {
                currentInput = amount
            }
        }
        .onChange(of: isNoteFocused) { _, focused in
            // 同步焦点状态和输入模式
            if focused {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    inputMode = .note
                }
            }
        }
        .onChange(of: inputMode) { _, newMode in
            // 输入模式变化时同步焦点
            if newMode == .note {
                isNoteFocused = true
            } else if newMode == .amount {
                isNoteFocused = false
            }
        }
    }

    /// 格式化日期按钮显示文本
    /// 作者: xiaolei
    /// - Parameter date: 要格式化的日期
    /// - Returns: 格式化后的文本（"今天"或具体日期）
    private func formatDateForButton(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "今天"
        } else if calendar.isDateInYesterday(date) {
            return "昨天"
        } else if calendar.isDateInTomorrow(date) {
            return "明天"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "M月d日"
            formatter.locale = Locale(identifier: "zh_CN")
            return formatter.string(from: date)
        }
    }

    /// 处理按键点击
    /// 作者: xiaolei
    /// - Parameter key: 点击的按键
    private func handleKeyPress(_ key: KeyboardKey) {
        switch key {
        case .number(let digit):
            handleNumberInput(digit)

        case .action(let action):
            handleAction(action)
        }
    }

    /// 处理数字输入
    /// 作者: xiaolei
    /// - Parameter digit: 输入的数字字符
    private func handleNumberInput(_ digit: String) {
        // 防止多个小数点
        if digit == "." && currentInput.contains(".") {
            return
        }

        // 防止以多个0开头
        if currentInput == "0" && digit != "." {
            currentInput = digit
            return
        }

        // 如果当前输入为空，直接赋值
        if currentInput.isEmpty {
            currentInput = digit
            return
        }

        // 限制小数点后最多两位
        if let dotIndex = currentInput.firstIndex(of: ".") {
            let decimalPart = currentInput[currentInput.index(after: dotIndex)...]
            if decimalPart.count >= 2 && digit != "." {
                return
            }
        }

        currentInput += digit
    }

    /// 处理功能按键
    /// 作者: xiaolei
    /// - Parameter action: 功能类型
    private func handleAction(_ action: KeyboardAction) {
        switch action {
        case .delete:
            // 删除最后一个字符
            if !currentInput.isEmpty {
                currentInput.removeLast()
            }

        case .add:
            // 累加当前金额
            if let currentAmount = Double(currentInput), currentAmount > 0 {
                if lastOperation == nil {
                    // 第一次点击加号：将当前输入作为基数
                    accumulatedAmount = currentAmount
                } else {
                    // 执行上一次的操作后，再设置新的基数
                    accumulatedAmount = realTimeAccumulatedAmount
                }
                lastOperation = .add
                currentInput = "" // 清空输入，让用户继续输入下一个数字
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    showAccumulatedHint = true
                }
            }

        case .subtract:
            // 累减当前金额
            if let currentAmount = Double(currentInput), currentAmount > 0 {
                if lastOperation == nil {
                    // 第一次点击减号：将当前输入作为基数
                    accumulatedAmount = currentAmount
                } else {
                    // 执行上一次的操作后，再设置新的基数
                    accumulatedAmount = realTimeAccumulatedAmount
                }
                lastOperation = .subtract
                currentInput = "" // 清空输入，让用户继续输入下一个数字
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    showAccumulatedHint = true
                }
            }

        case .done:
            // 完成输入：使用实时累计金额
            if showAccumulatedHint {
                amount = String(format: "%.2f", realTimeAccumulatedAmount)
            } else {
                // 没有累计，直接使用当前输入
                if !currentInput.isEmpty {
                    amount = currentInput
                }
            }
            onDone?()
        }
    }

    /// 重置累计金额
    /// 作者: xiaolei
    private func resetAccumulation() {
        accumulatedAmount = 0.0
        currentInput = ""
        lastOperation = nil
        showAccumulatedHint = false
    }

    /// 格式化货币显示
    /// 作者: xiaolei
    /// - Parameter value: 金额数值
    /// - Returns: 格式化后的货币字符串
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "CNY"
        formatter.currencySymbol = "¥"
        return formatter.string(from: NSNumber(value: value)) ?? "¥0.00"
    }
}

// MARK: - 键盘按键模型

/// 键盘按键类型
/// 作者: xiaolei
enum KeyboardKey {
    /// 数字按键
    case number(String)
    /// 功能按键
    case action(KeyboardAction)
}

/// 键盘功能类型
/// 作者: xiaolei
enum KeyboardAction {
    /// 删除
    case delete
    /// 累加
    case add
    /// 累减
    case subtract
    /// 完成
    case done
}

// MARK: - 按键按钮组件

/// 键盘按钮视图
/// 作者: xiaolei
struct KeyButton: View {
    let key: KeyboardKey
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: {
            // 触感反馈
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
            action()
        }) {
            ZStack {
                // 按钮背景
                Rectangle()
                    .fill(isPressed ? pressedColor : backgroundColor)

                // 按钮内容
                Group {
                    switch key {
                    case .number(let digit):
                        Text(digit)
                            .font(.system(size: 24, weight: .regular, design: .rounded))
                            .foregroundColor(.primary)

                    case .action(let actionType):
                        actionIcon(for: actionType)
                    }
                }
            }
        }
        .buttonStyle(KeyButtonStyle(isPressed: $isPressed))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .frame(height: 52)
    }

    /// 按键背景颜色
    /// 作者: xiaolei
    private var backgroundColor: Color {
        switch key {
        case .number:
            return Color(.systemBackground)
        case .action(let actionType):
            switch actionType {
            case .done:
                return Color.blue
            case .add, .subtract:
                return Color.orange.opacity(0.12)
            case .delete:
                return Color(.systemGray5)
            }
        }
    }

    /// 按键按下时的颜色
    private var pressedColor: Color {
        switch key {
        case .number:
            return Color(.systemGray4)
        case .action(let actionType):
            switch actionType {
            case .done:
                return Color.blue.opacity(0.8)
            case .add, .subtract:
                return Color.orange.opacity(0.25)
            case .delete:
                return Color(.systemGray4)
            }
        }
    }

    /// 功能按键图标
    /// 作者: xiaolei
    /// - Parameter action: 功能类型
    /// - Returns: 对应的图标视图
    @ViewBuilder
    private func actionIcon(for action: KeyboardAction) -> some View {
        switch action {
        case .delete:
            Image(systemName: "delete.left")
                .font(.system(size: 20))
                .foregroundColor(.primary)

        case .add:
            Image(systemName: "plus")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.orange)

        case .subtract:
            Image(systemName: "minus")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.orange)

        case .done:
            Image(systemName: "checkmark")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
        }
    }
}

/// 按键按钮样式
/// 作者: xiaolei
struct KeyButtonStyle: ButtonStyle {
    @Binding var isPressed: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { _, pressed in
                isPressed = pressed
            }
    }
}

// MARK: - 日期选择器弹窗

/// 日期选择器弹窗视图
/// 作者: xiaolei
struct DatePickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var date: Date

    var body: some View {
        NavigationStack {
            VStack {
                DatePicker(
                    "选择日期",
                    selection: $date,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                .environment(\.locale, Locale(identifier: "zh_CN"))
                .padding()

                Spacer()
            }
            .navigationTitle("选择日期")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("确定") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .presentationDetents([.height(350)])
    }
}

// MARK: - 预览

#Preview {
    VStack {
        Spacer()
        CustomNumericKeyboard(
            amount: .constant("123.45"),
            date: .constant(Date()),
            note: .constant(""),
            inputMode: .constant(.amount)
        )
    }
}
