#!/bin/bash

echo "🔧 开始修复Xcode编译错误..."
echo ""

# 清理Xcode派生数据（DerivedData）
echo "1️⃣ 清理Xcode缓存..."
rm -rf ~/Library/Developer/Xcode/DerivedData/*
echo "✅ 缓存已清理"
echo ""

# 查找并删除项目构建文件
echo "2️⃣ 清理项目构建文件..."
find /Users/rockcoder/IdeaProjects/ai-project/qiaoji -name "build" -type d -exec rm -rf {} + 2>/dev/null
find /Users/rockcoder/IdeaProjects/ai-project/qiaoji -name ".build" -type d -exec rm -rf {} + 2>/dev/null
echo "✅ 构建文件已清理"
echo ""

echo "✨ 清理完成！"
echo ""
echo "📝 接下来在Xcode中执行："
echo "   1. 按 Cmd + Shift + Option + K  （清理构建文件夹）"
echo "   2. 按 Cmd + B  （重新编译）"
echo "   3. 按 Cmd + R  （运行）"
echo ""
