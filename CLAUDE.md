# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概述

ExpenseTracker 是一个 iOS 个人记账应用，使用 SwiftUI + SwiftData 构建，支持 iOS 17+。

## 构建与测试命令

```bash
# 在 Xcode 中打开项目
open ExpenseTracker.xcodeproj

# 命令行构建
xcodebuild -scheme ExpenseTracker -destination 'platform=iOS Simulator,name=iPhone 15' clean build

# 运行测试
xcodebuild test -scheme ExpenseTracker -destination 'platform=iOS Simulator,name=iPhone 15'
```

## 架构设计

### 数据层
- **SwiftData** 管理持久化，四个核心模型：`Transaction`、`Category`、`Budget`、`Account`
- ModelContainer 在 `ExpenseTrackerApp.swift` 初始化，当前禁用 iCloud 同步
- 模型间关系：Transaction → Category（多对一），Transaction → Account（多对一）

### 业务模块（Features/）
按功能垂直划分，每个模块包含 Models/Views/Services：

| 模块 | 职责 |
|------|------|
| **Transactions** | 交易记录 CRUD、自定义数字键盘 |
| **Statistics** | 数据统计聚合（按周/月/年）、分类占比计算 |
| **Settings** | 分类管理、账户管理、颜色/图标选择器 |
| **Budget** | 预算管理（待完善） |

### 统计服务（StatisticsService）
- `getPeriodOptions()`: 生成周期选择器选项（本周/上周、本月/上月、今年/去年 + 历史数据）
- `calculateStatistics()`: 计算指定周期的收支汇总和分类聚合
- 注意：SwiftData Predicate 不直接支持枚举比较，需用 rawValue 或内存过滤

### 视图层
- `ContentView.swift`: TabView 导航容器 + 默认分类初始化
- 视图优先用 `struct`，复杂计算下沉到 Service 或扩展
- 颜色使用十六进制字符串存储，通过 `Color(_: String)` 扩展转换

## 代码规范

- Swift 5，4 空格缩进，中文注释
- 类型/文件大驼峰，属性/方法小驼峰
- 视图文件以 `View` 结尾，测试文件以 `Tests.swift` 结尾
- 提交信息前缀：`feat`/`fix`/`chore`/`docs`/`test`

## SwiftData 注意事项

- `@Model` 类需要在 ModelContainer 注册
- Predicate 闭包中的外部变量需先捕获为局部常量
- 枚举类型在 Predicate 中需特殊处理（使用 rawValue 或内存过滤）
