#!/bin/bash

# 同步修复后的代码到 Xcode 项目
# 作者: xiaolei

echo "🔍 正在搜索您的 Xcode 项目..."
echo ""

# 搜索可能的项目位置
PROJECT_PATHS=$(find ~/Documents ~/Desktop ~/Developer ~/Projects 2>/dev/null \
    -name "ExpenseTracker.xcodeproj" -o -name "ExpenseTracker" -type d \
    | grep -v "/Build/" | grep -v "/DerivedData/" | head -10)

if [ -z "$PROJECT_PATHS" ]; then
    echo "❌ 未找到 ExpenseTracker 项目"
    echo ""
    echo "请手动输入您的 Xcode 项目路径："
    read -p "项目路径: " USER_PROJECT_PATH

    if [ ! -d "$USER_PROJECT_PATH" ]; then
        echo "❌ 路径不存在: $USER_PROJECT_PATH"
        exit 1
    fi

    TARGET_DIR="$USER_PROJECT_PATH"
else
    echo "找到以下可能的项目："
    echo ""

    IFS=$'\n' read -d '' -r -a paths_array <<< "$PROJECT_PATHS"

    i=1
    for path in "${paths_array[@]}"; do
        echo "[$i] $path"
        ((i++))
    done

    echo ""
    read -p "请选择项目编号 [1]: " choice
    choice=${choice:-1}

    TARGET_DIR="${paths_array[$((choice-1))]}"

    if [[ "$TARGET_DIR" == *.xcodeproj ]]; then
        TARGET_DIR=$(dirname "$TARGET_DIR")
    fi
fi

echo ""
echo "📂 目标项目: $TARGET_DIR"
echo ""

# 查找 ContentView.swift 的位置
CONTENT_VIEW=$(find "$TARGET_DIR" -name "ContentView.swift" -not -path "*/DerivedData/*" | head -1)

if [ -z "$CONTENT_VIEW" ]; then
    echo "❌ 在项目中未找到 ContentView.swift"
    echo "请确认项目结构是否正确"
    exit 1
fi

echo "找到文件: $CONTENT_VIEW"
echo ""

# 创建备份
BACKUP_FILE="${CONTENT_VIEW}.backup.$(date +%Y%m%d_%H%M%S)"
echo "📦 创建备份: $BACKUP_FILE"
cp "$CONTENT_VIEW" "$BACKUP_FILE"

# 复制修复后的文件
SOURCE_FILE="/Users/rockcoder/IdeaProjects/ai-project/qiaoji/ExpenseTracker/App/ContentView.swift"

if [ ! -f "$SOURCE_FILE" ]; then
    echo "❌ 源文件不存在: $SOURCE_FILE"
    exit 1
fi

echo "📝 复制修复后的文件..."
cp "$SOURCE_FILE" "$CONTENT_VIEW"

echo ""
echo "✅ 同步完成！"
echo ""
echo "📋 后续步骤："
echo "1. 打开 Xcode"
echo "2. 重新加载项目（如果已打开，请关闭后重新打开）"
echo "3. Clean Build Folder (⇧⌘K)"
echo "4. Build (⌘B)"
echo ""
echo "💾 备份文件位置："
echo "   $BACKUP_FILE"
echo ""
