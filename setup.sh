#!/bin/bash

# ExpenseTracker 项目设置脚本
# 作者: xiaolei
# 用途: 帮助快速检查环境和准备项目

set -e

echo "🚀 ExpenseTracker 项目设置助手"
echo "================================"
echo ""

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 1. 检查macOS版本
echo "📋 步骤 1/5: 检查系统环境"
echo "----------------------------"
macos_version=$(sw_vers -productVersion)
echo "macOS 版本: $macos_version"

if [[ $(echo "$macos_version 14.0" | awk '{print ($1 >= $2)}') -eq 1 ]]; then
    echo -e "${GREEN}✅ macOS 版本满足要求 (需要 14.0+)${NC}"
else
    echo -e "${RED}❌ macOS 版本过低，需要 14.0 或更高版本${NC}"
    exit 1
fi
echo ""

# 2. 检查Xcode
echo "📋 步骤 2/5: 检查Xcode"
echo "----------------------------"
if command -v xcodebuild &> /dev/null; then
    xcode_version=$(xcodebuild -version | head -n 1 | awk '{print $2}')
    echo "Xcode 版本: $xcode_version"

    if [[ $(echo "$xcode_version 16.0" | awk '{print ($1 >= $2)}') -eq 1 ]]; then
        echo -e "${GREEN}✅ Xcode 版本满足要求 (需要 16.0+)${NC}"
    else
        echo -e "${YELLOW}⚠️  Xcode 版本较低，建议更新到 16.0+${NC}"
    fi
else
    echo -e "${RED}❌ 未找到 Xcode，请从 App Store 安装${NC}"
    echo "   下载地址: https://apps.apple.com/app/xcode/id497799835"
    exit 1
fi
echo ""

# 3. 检查项目文件
echo "📋 步骤 3/5: 检查项目文件"
echo "----------------------------"
if [ -d "ExpenseTracker" ]; then
    echo -e "${GREEN}✅ 找到 ExpenseTracker 源代码目录${NC}"

    swift_files=$(find ExpenseTracker -name "*.swift" | wc -l | xargs)
    echo "   Swift 文件数: $swift_files"

    if [ "$swift_files" -ge 6 ]; then
        echo -e "${GREEN}✅ 核心文件完整${NC}"
    else
        echo -e "${RED}❌ Swift 文件不完整，应该有 6 个${NC}"
    fi
else
    echo -e "${RED}❌ 未找到 ExpenseTracker 目录${NC}"
    exit 1
fi
echo ""

# 4. 列出必需的文件
echo "📋 步骤 4/5: 验证关键文件"
echo "----------------------------"
required_files=(
    "ExpenseTracker/App/ExpenseTrackerApp.swift"
    "ExpenseTracker/App/ContentView.swift"
    "ExpenseTracker/Features/Transactions/Models/Transaction.swift"
    "ExpenseTracker/Features/Settings/Models/Category.swift"
    "ExpenseTracker/Features/Budget/Models/Budget.swift"
    "ExpenseTracker/Features/Settings/Models/Account.swift"
)

all_files_exist=true
for file in "${required_files[@]}"; do
    if [ -f "$file" ]; then
        echo -e "${GREEN}✅${NC} $file"
    else
        echo -e "${RED}❌${NC} $file (缺失)"
        all_files_exist=false
    fi
done
echo ""

# 5. 生成项目建议
echo "📋 步骤 5/5: 下一步操作建议"
echo "----------------------------"

if [ "$all_files_exist" = true ]; then
    echo -e "${GREEN}🎉 所有检查通过！${NC}"
    echo ""
    echo "接下来的步骤："
    echo ""
    echo "1️⃣  打开 Xcode"
    echo "   在终端运行: open -a Xcode"
    echo ""
    echo "2️⃣  创建新项目"
    echo "   - File -> New -> Project"
    echo "   - 选择 iOS -> App"
    echo "   - Product Name: ExpenseTracker"
    echo "   - Interface: SwiftUI ⚠️"
    echo "   - Storage: SwiftData ⚠️"
    echo ""
    echo "3️⃣  导入源代码"
    echo "   运行以下命令在Finder中打开源码文件夹："
    echo "   ${YELLOW}open $(pwd)/ExpenseTracker${NC}"
    echo ""
    echo "   然后将整个 ExpenseTracker 文件夹拖入 Xcode"
    echo "   ⚠️ 勾选 'Copy items if needed'"
    echo ""
    echo "4️⃣  配置项目"
    echo "   - 设置 Minimum Deployments 为 iOS 17.0"
    echo "   - 添加 iCloud Capability (可选)"
    echo "   - 如果不需要 iCloud，修改代码："
    echo "     cloudKitDatabase: .none"
    echo ""
    echo "5️⃣  运行项目"
    echo "   - 选择模拟器 (iPhone 15 Pro 推荐)"
    echo "   - 按 Command + R 运行"
    echo ""
    echo "📖 详细步骤请查看: 快速启动指南.md"
    echo ""

    # 询问是否打开Xcode
    read -p "是否现在打开 Xcode? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "正在打开 Xcode..."
        open -a Xcode
        sleep 2
        echo "正在打开源代码文件夹..."
        open "$(pwd)/ExpenseTracker"
    fi

else
    echo -e "${RED}❌ 部分文件缺失，请检查项目完整性${NC}"
    exit 1
fi

echo ""
echo "✨ 设置检查完成！祝你开发愉快！"
