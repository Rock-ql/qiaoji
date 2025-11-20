#!/bin/bash

echo "🔨 准备重新构建Xcode项目..."
echo ""

# 1. 尝试关闭Xcode
echo "1️⃣  关闭Xcode..."
osascript -e 'tell application "Xcode" to quit' 2>/dev/null
sleep 3

# 2. 重新打开项目
echo "2️⃣  打开Xcode项目..."
open "/Users/rockcoder/Desktop/ExpenseTracker/ExpenseTracker.xcodeproj"
sleep 5

# 3. 清理构建
echo "3️⃣  执行Clean Build Folder..."
osascript << 'EOF'
tell application "System Events"
    tell process "Xcode"
        set frontmost to true
        delay 2
        keystroke "k" using {command down, shift down}
    end tell
end tell
EOF

sleep 5

# 4. 开始构建
echo "4️⃣  开始构建..."
osascript << 'EOF'
tell application "System Events"
    tell process "Xcode"
        keystroke "b" using command down
    end tell
end tell
EOF

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ 构建命令已发送！"
echo ""
echo "📌 请在Xcode中查看构建结果"
echo "   • 如果成功：Build Succeeded"
echo "   • 如果失败：查看错误信息"
echo ""
