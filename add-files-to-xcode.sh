#!/bin/bash

# 自动将新文件添加到 Xcode 项目的辅助脚本
# 作者: xiaolei

echo "🔧 准备将新文件添加到 Xcode 项目..."
echo ""

# 项目路径
PROJECT_PATH="/Users/rockcoder/Desktop/ExpenseTracker"
FILES_PATH="$PROJECT_PATH/ExpenseTracker 3/Features/Settings/Views"

# 检查路径是否存在
if [ ! -d "$FILES_PATH" ]; then
    echo "❌ 文件路径不存在: $FILES_PATH"
    exit 1
fi

# 检查文件是否存在
echo "✅ 检查文件..."
files=(
    "CategoryManagementView.swift"
    "CategoryListRow.swift"
    "AddCategoryView.swift"
    "EditCategoryView.swift"
    "IconPickerView.swift"
    "ColorPickerView.swift"
)

missing_files=0
for file in "${files[@]}"; do
    if [ -f "$FILES_PATH/$file" ]; then
        echo "   ✓ $file"
    else
        echo "   ✗ $file (缺失)"
        ((missing_files++))
    fi
done

if [ $missing_files -gt 0 ]; then
    echo ""
    echo "❌ 有 $missing_files 个文件缺失，请先同步文件"
    exit 1
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📂 文件位置: $FILES_PATH"
echo ""
echo "🎯 接下来的操作步骤："
echo ""
echo "1️⃣  我将为您打开 Finder（显示新文件）"
echo "2️⃣  我将为您打开 Xcode 项目"
echo "3️⃣  您需要："
echo "    • 在 Finder 中选中所有 6 个文件"
echo "    • 拖动到 Xcode 左侧的 Features/Settings 文件夹"
echo "    • 在弹出对话框中："
echo "      ✓ 勾选 'Copy items if needed'"
echo "      ✓ 选择 'Create groups'"
echo "      ✓ 勾选 Target: ExpenseTracker"
echo "      ✓ 点击 'Finish'"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
read -p "按回车键继续..."

# 打开 Finder 显示文件
echo ""
echo "📂 打开 Finder..."
open "$FILES_PATH"

# 等待 1 秒
sleep 1

# 打开 Xcode 项目
echo "📱 打开 Xcode 项目..."
open "$PROJECT_PATH/ExpenseTracker.xcodeproj"

echo ""
echo "✅ 已打开 Finder 和 Xcode"
echo ""
echo "💡 提示："
echo "   • 在 Finder 中按 ⌘A 选中所有文件"
echo "   • 拖动到 Xcode 的 Settings 文件夹"
echo "   • 添加后执行: Product → Clean Build Folder (⇧⌘K)"
echo "   • 然后重新构建: Product → Build (⌘B)"
echo ""
