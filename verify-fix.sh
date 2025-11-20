#!/bin/bash

# 验证代码修复是否正确
# 作者: xiaolei

echo "🔍 验证代码修复状态..."
echo ""

cd "$(dirname "$0")"

SOURCE_FILE="./ExpenseTracker/App/ContentView.swift"

if [ ! -f "$SOURCE_FILE" ]; then
    echo "❌ 源文件不存在"
    exit 1
fi

echo "✅ 正在检查..."
echo ""

# 检查 Color 扩展定义
echo "1️⃣ 检查 Color 扩展定义..."
if grep -q "init(_ hex: String)" "$SOURCE_FILE"; then
    echo "   ✅ Color 扩展定义正确"
else
    echo "   ❌ Color 扩展定义错误"
    echo "   应该是: init(_ hex: String)"
fi

echo ""

# 检查是否还有 Color(hex:) 调用
echo "2️⃣ 检查是否还有 Color(hex:) 调用..."
HEX_CALLS=$(grep -n "Color(hex:" "$SOURCE_FILE" 2>/dev/null)
if [ -z "$HEX_CALLS" ]; then
    echo "   ✅ 没有 Color(hex:) 调用"
else
    echo "   ❌ 发现 Color(hex:) 调用："
    echo "$HEX_CALLS"
fi

echo ""

# 检查 Color(_ 调用
echo "3️⃣ 检查 Color() 调用数量..."
COLOR_CALLS=$(grep -o "Color([^)]*\.color" "$SOURCE_FILE" | wc -l | tr -d ' ')
echo "   找到 $COLOR_CALLS 处 Color 调用"

echo ""

# 检查未定义的类型
echo "4️⃣ 检查未定义的类型引用..."
PRESET_REF=$(grep -n "PresetCategories" "$SOURCE_FILE" 2>/dev/null)
CATEGORY_MGT_REF=$(grep -n "CategoryManagementView" "$SOURCE_FILE" 2>/dev/null)

if [ -z "$PRESET_REF" ] && [ -z "$CATEGORY_MGT_REF" ]; then
    echo "   ✅ 没有未定义的类型引用"
else
    if [ ! -z "$PRESET_REF" ]; then
        echo "   ❌ 发现 PresetCategories 引用："
        echo "$PRESET_REF"
    fi
    if [ ! -z "$CATEGORY_MGT_REF" ]; then
        echo "   ❌ 发现 CategoryManagementView 引用:"
        echo "$CATEGORY_MGT_REF"
    fi
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 统计结果
ERRORS=0

if ! grep -q "init(_ hex: String)" "$SOURCE_FILE"; then
    ((ERRORS++))
fi

if grep -q "Color(hex:" "$SOURCE_FILE" 2>/dev/null; then
    ((ERRORS++))
fi

if [ ! -z "$PRESET_REF" ] || [ ! -z "$CATEGORY_MGT_REF" ]; then
    ((ERRORS++))
fi

if [ $ERRORS -eq 0 ]; then
    echo "✅ 所有检查通过！代码修复正确。"
    echo ""
    echo "如果 Xcode 仍显示错误，请："
    echo "1. 运行 ./clean-xcode.sh 清理缓存"
    echo "2. 或运行 ./sync-to-xcode.sh 同步到您的 Xcode 项目"
else
    echo "❌ 发现 $ERRORS 个问题"
    echo ""
    echo "请查看上面的详细信息"
fi

echo ""
