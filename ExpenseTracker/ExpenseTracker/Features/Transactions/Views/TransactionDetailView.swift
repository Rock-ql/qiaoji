import SwiftUI
import SwiftData

/// 交易详情视图（只读模式）
/// 作者: xiaolei
struct TransactionDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let transaction: Transaction

    @State private var showEditSheet = false
    @State private var showDeleteAlert = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // 金额卡片
                    amountCard

                    // 详情信息
                    detailsSection

                    // 操作按钮
                    actionButtons
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("交易详情")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("关闭") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showEditSheet) {
                EditTransactionView(transaction: transaction)
            }
            .alert("确认删除", isPresented: $showDeleteAlert) {
                Button("取消", role: .cancel) { }
                Button("删除", role: .destructive) {
                    deleteTransaction()
                }
            } message: {
                Text("确定要删除这笔交易吗？此操作无法撤销。")
            }
        }
    }

    /// 金额卡片
    /// 作者: xiaolei
    @ViewBuilder
    private var amountCard: some View {
        VStack(spacing: 16) {
            // 分类图标
            Image(systemName: transaction.categoryIcon)
                .font(.system(size: 50))
                .foregroundColor(.white)
                .frame(width: 100, height: 100)
                .background(
                    Circle()
                        .fill(Color(transaction.category?.color ?? "95A5A6"))
                )

            // 分类名称
            Text(transaction.categoryName)
                .font(.title2)
                .fontWeight(.semibold)

            // 金额
            Text(transaction.type == .income ? "+\(transaction.formattedAmount)" : "-\(transaction.formattedAmount)")
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(transaction.type == .income ? .green : .red)

            // 交易类型标签
            Text(transaction.type == .income ? "收入" : "支出")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(transaction.type == .income ? Color.green : Color.red)
                )
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
        )
    }

    /// 详情信息
    /// 作者: xiaolei
    @ViewBuilder
    private var detailsSection: some View {
        VStack(spacing: 0) {
            // 日期时间
            DetailRow(
                icon: "calendar",
                title: "日期时间",
                value: formatFullDate(transaction.date)
            )

            Divider()
                .padding(.leading, 52)

            // 账本
            if let ledger = transaction.ledger {
                DetailRow(
                    icon: "book.fill",
                    title: "账本",
                    value: ledger.name,
                    iconColor: Color(hex: ledger.color) ?? .blue
                )

                Divider()
                    .padding(.leading, 52)
            }

            // 备注
            if !transaction.note.isEmpty {
                DetailRow(
                    icon: "note.text",
                    title: "备注",
                    value: transaction.note
                )
            } else {
                DetailRow(
                    icon: "note.text",
                    title: "备注",
                    value: "无"
                )
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
        )
    }

    /// 操作按钮
    /// 作者: xiaolei
    @ViewBuilder
    private var actionButtons: some View {
        VStack(spacing: 12) {
            // 编辑按钮
            Button(action: {
                showEditSheet = true
            }) {
                HStack {
                    Image(systemName: "pencil")
                    Text("编辑")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    LinearGradient(
                        colors: [.blue, .cyan],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
            }

            // 删除按钮
            Button(role: .destructive, action: {
                showDeleteAlert = true
            }) {
                HStack {
                    Image(systemName: "trash")
                    Text("删除")
                }
                .font(.headline)
                .foregroundColor(.red)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.red, lineWidth: 2)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.red.opacity(0.1))
                        )
                )
            }
        }
        .padding(.top, 8)
    }

    /// 删除交易
    /// 作者: xiaolei
    private func deleteTransaction() {
        modelContext.delete(transaction)
        try? modelContext.save()
        dismiss()
    }

    /// 格式化完整日期
    /// 作者: xiaolei
    /// - Parameter date: 日期
    /// - Returns: 格式化的日期字符串（年月日时分秒 星期几）
    private func formatFullDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "yyyy年M月d日 HH:mm:ss EEEE"
        return formatter.string(from: date)
    }
}

/// 详情行视图
/// 作者: xiaolei
struct DetailRow: View {
    let icon: String
    let title: String
    let value: String
    var iconColor: Color = .blue

    var body: some View {
        HStack(spacing: 16) {
            // 图标
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(iconColor)
                .frame(width: 36, height: 36)

            // 标题和值
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text(value)
                    .font(.body)
                    .foregroundColor(.primary)
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

