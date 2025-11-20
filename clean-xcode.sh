#!/bin/bash

# Xcode 项目清理脚本
# 作者: xiaolei
# 用于清理 Xcode 构建缓存和派生数据

echo "🧹 开始清理 Xcode 项目..."

# 清理 DerivedData
echo "正在清理 DerivedData..."
rm -rf ~/Library/Developer/Xcode/DerivedData/*

# 清理项目构建目录
echo "正在清理项目构建目录..."
cd "$(dirname "$0")"
if [ -d "build" ]; then
    rm -rf build
fi

# 清理 .DS_Store 文件
echo "正在清理 .DS_Store 文件..."
find . -name ".DS_Store" -delete

# 清理 Xcode 缓存
echo "正在清理 Xcode 缓存..."
rm -rf ~/Library/Caches/com.apple.dt.Xcode

echo "✅ 清理完成！"
echo ""
echo "请在 Xcode 中执行以下操作："
echo "1. Product → Clean Build Folder (⇧⌘K)"
echo "2. 重新构建项目 (⌘B)"
echo ""
