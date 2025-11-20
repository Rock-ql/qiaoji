# ExpenseTracker - iOS记账应用

## 📱 项目简介

ExpenseTracker是一款基于SwiftUI + SwiftData开发的现代化iOS记账应用，专注个人使用场景，提供简洁易用的记账体验。

### 核心特性

- ✅ **基础记账**：快速记录收入支出，支持多分类管理
- ✅ **数据统计**：图表可视化展示消费趋势和分类占比
- ✅ **预算管理**：设置预算、实时追踪、超支预警
- ✅ **iCloud同步**：数据自动云端备份，多设备无缝同步
- ✅ **深色模式**：完整支持iOS系统主题切换

## 🎯 技术栈

| 技术领域 | 选型方案 | 版本要求 |
|---------|---------|---------|
| **UI框架** | SwiftUI | iOS 17+ |
| **数据持久化** | SwiftData + CloudKit | iOS 17+ |
| **图表库** | Swift Charts | iOS 16+ |
| **架构模式** | MVVM | - |
| **开发工具** | Xcode 16+ | macOS 14+ |

## 📂 项目结构

```
ExpenseTracker/
├── App/                                # 应用入口
│   ├── ExpenseTrackerApp.swift         # 主App入口
│   └── ContentView.swift               # 主导航视图
│
├── Features/                           # 功能模块
│   ├── Transactions/                   # 交易模块
│   │   ├── Models/
│   │   │   └── Transaction.swift       # 交易数据模型
│   │   ├── Views/
│   │   └── ViewModels/
│   │
│   ├── Budget/                         # 预算模块
│   │   ├── Models/
│   │   │   └── Budget.swift            # 预算数据模型
│   │   ├── Views/
│   │   └── ViewModels/
│   │
│   ├── Statistics/                     # 统计模块
│   │   ├── Views/
│   │   ├── ViewModels/
│   │   └── Models/
│   │
│   └── Settings/                       # 设置模块
│       ├── Models/
│       │   ├── Category.swift          # 分类数据模型
│       │   └── Account.swift           # 账户数据模型
│       ├── Views/
│       └── ViewModels/
│
├── Core/                               # 核心服务
│   ├── Database/                       # 数据库配置
│   ├── Services/                       # 业务服务
│   ├── Security/                       # 安全模块
│   └── Networking/                     # 网络服务
│
├── Shared/                             # 共享组件
│   ├── Components/                     # UI组件
│   ├── Modifiers/                      # 视图修饰符
│   └── Extensions/                     # 扩展
│
└── Resources/                          # 资源文件
    └── Assets.xcassets                 # 图片资源
```

## 🚀 快速开始

### 方式一：在现有Xcode项目中集成（推荐）

如果你已经有一个Xcode项目，按以下步骤操作：

1. **将文件导入项目**
   ```bash
   # 在Xcode中，右键项目 -> Add Files to "YourProject"
   # 选择 ExpenseTracker 文件夹，勾选 "Copy items if needed"
   ```

2. **配置项目设置**
   - 打开项目设置 -> Signing & Capabilities
   - 添加 iCloud 能力，勾选 CloudKit
   - 设置 Bundle Identifier
   - 设置最低部署版本为 iOS 17.0

3. **运行项目**
   - 选择模拟器或真机
   - Command + R 运行

### 方式二：创建新的Xcode项目

1. **创建项目**
   - 打开Xcode
   - File -> New -> Project
   - 选择 iOS -> App
   - 项目名称：ExpenseTracker
   - Interface: SwiftUI
   - Storage: SwiftData
   - Language: Swift

2. **替换生成的文件**
   - 删除自动生成的 ContentView.swift 和其他文件
   - 将本项目的 ExpenseTracker 文件夹中的文件拖入项目

3. **配置项目**
   - 按上述"方式一"的步骤2配置

## 📊 数据模型设计

### Transaction（交易记录）
```swift
- id: UUID                    // 唯一标识
- amount: Double              // 交易金额
- type: TransactionType       // 收入/支出
- date: Date                  // 交易日期
- note: String                // 备注
- merchant: String?           // 商户名称
- category: Category?         // 关联分类
- account: Account?           // 关联账户
```

### Category（分类）
```swift
- id: UUID                    // 唯一标识
- name: String                // 分类名称
- icon: String                // SF Symbol图标
- color: String               // 颜色（十六进制）
- type: TransactionType       // 收入/支出
- isSystem: Bool              // 是否系统预设
- sortOrder: Int              // 排序顺序
```

### Budget（预算）
```swift
- id: UUID                    // 唯一标识
- amount: Double              // 预算金额
- period: BudgetPeriod        // 周期（日/周/月/年）
- startDate: Date             // 开始日期
- endDate: Date               // 结束日期
- alertThreshold: Double      // 预警阈值
- alertEnabled: Bool          // 是否启用预警
- category: Category?         // 关联分类
```

### Account（账户）
```swift
- id: UUID                    // 唯一标识
- name: String                // 账户名称
- type: AccountType           // 账户类型
- initialBalance: Double      // 初始余额
- icon: String                // SF Symbol图标
- color: String               // 颜色（十六进制）
- isDefault: Bool             // 是否默认账户
```

## 🎨 默认分类

### 支出分类
- 餐饮 🍴
- 交通 🚗
- 购物 🛒
- 娱乐 🎮
- 医疗 ⚕️
- 教育 📚
- 住房 🏠
- 其他 ⋯

### 收入分类
- 工资 💵
- 奖金 🎁
- 投资 📈
- 其他收入 ➕

## 🔧 核心功能实现

### 1. 添加交易

```swift
// 创建交易记录
let transaction = Transaction(
    amount: 100.0,
    type: .expense,
    date: Date(),
    note: "午餐",
    category: foodCategory
)

// 保存到数据库
modelContext.insert(transaction)
try? modelContext.save()
```

### 2. 查询交易

```swift
// 使用 @Query 自动查询
@Query(sort: \Transaction.date, order: .reverse)
var transactions: [Transaction]

// 或使用 FetchDescriptor 手动查询
let descriptor = FetchDescriptor<Transaction>(
    predicate: #Predicate { $0.type == .expense },
    sortBy: [SortDescriptor(\.date, order: .reverse)]
)
let results = try? modelContext.fetch(descriptor)
```

### 3. 数据统计

```swift
// 按分类统计
let grouped = Dictionary(grouping: transactions, by: \.category)
let stats = grouped.map { category, items in
    CategoryStatistic(
        category: category,
        total: items.reduce(0) { $0 + $1.amount },
        count: items.count
    )
}
```

### 4. 预算追踪

```swift
// 计算预算使用情况
func calculateProgress(budget: Budget, transactions: [Transaction]) -> BudgetProgress {
    let used = transactions
        .filter { $0.category == budget.category }
        .reduce(0) { $0 + $1.amount }

    return BudgetProgress(
        used: used,
        remaining: budget.amount - used,
        percentage: used / budget.amount,
        status: determineStatus(percentage)
    )
}
```

## 📱 应用截图

（待添加）

## 🔐 隐私与安全

- ✅ 所有数据存储在本地设备
- ✅ 使用iCloud私有数据库加密同步
- ✅ 支持Face ID/Touch ID保护
- ✅ 完全遵循Apple隐私政策

## 🛣️ 开发路线图

### ✅ 第一阶段（已完成）
- [x] 项目架构搭建
- [x] 核心数据模型设计
- [x] 基础UI框架
- [x] 交易添加功能
- [x] 交易列表展示

### 🚧 第二阶段（进行中）
- [ ] 完善交易编辑/删除功能
- [ ] 实现数据统计图表
- [ ] 开发预算管理功能
- [ ] 添加分类管理
- [ ] 账户管理

### 📋 第三阶段（计划中）
- [ ] 数据导出（CSV/JSON）
- [ ] 搜索和筛选功能
- [ ] 周期性消费识别
- [ ] 自定义主题颜色
- [ ] Widget小组件

### 🎯 第四阶段（未来）
- [ ] 多货币支持
- [ ] 账户间转账
- [ ] 数据可视化增强
- [ ] AI智能分类
- [ ] Apple Watch支持

## 🐛 已知问题

1. **编译问题**：本项目包含Swift源代码文件，需要在Xcode中打开才能编译运行
2. **iCloud配置**：首次运行需要配置有效的iCloud Container ID
3. **最低版本要求**：需要iOS 17+系统支持

## 💡 使用提示

1. **第一次运行**：应用会自动创建默认分类，可在设置中自定义
2. **添加交易**：点击浮动的 + 按钮快速添加
3. **删除交易**：在列表中左滑删除
4. **编辑交易**：点击交易行进入详情（待实现）
5. **数据备份**：iCloud自动同步，无需手动备份

## 📝 代码规范

- 所有代码包含详细中文注释
- 每个文件包含作者信息（xiaolei）
- 遵循Swift命名规范和编码风格
- 使用MARK注释分隔代码区块

## 🤝 贡献指南

欢迎提交Issue和Pull Request！

## 📄 许可证

MIT License

## 👨‍💻 作者

**xiaolei**

## 📧 联系方式

有问题或建议？欢迎通过以下方式联系：
- 提交GitHub Issue
- 发送邮件至：[your-email@example.com]

---

## 🔗 相关资源

- [SwiftUI官方文档](https://developer.apple.com/documentation/swiftui/)
- [SwiftData官方文档](https://developer.apple.com/documentation/swiftdata/)
- [Swift Charts官方文档](https://developer.apple.com/documentation/charts/)
- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)

---

**最后更新**: 2025年11月12日
