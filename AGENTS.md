# Repository Guidelines

## 项目结构与模块组织
- `ExpenseTracker.xcodeproj`：Xcode 工程入口，可直接运行或调试。
- `ExpenseTracker/App`：`ExpenseTrackerApp` 与 `ContentView` 负责应用启动、Tab 导航与默认数据初始化。
- `ExpenseTracker/Features`：按业务拆分 Transactions、Settings、Statistics、Budget，包含对应 Models/Views/Services。
- `ExpenseTracker/Shared`：预留通用组件、扩展、修饰器目录，可按需复用。
- `ExpenseTracker/Resources` 与 `Assets.xcassets`：界面资源、配色与图标。

## 构建、测试与本地开发
- `open ExpenseTracker.xcodeproj`：在 Xcode 中开发调试。
- `xcodebuild -scheme ExpenseTracker -destination 'platform=iOS Simulator,name=iPhone 15' clean build`：本地/CI 构建验证。
- `xcodebuild test -scheme ExpenseTracker -destination 'platform=iOS Simulator,name=iPhone 15'`：运行单元/UI 测试（新增用例后务必执行）。
- 主要依赖 SwiftUI + SwiftData，无额外包管理；建议使用 iOS 17+ 模拟器保证 SwiftData 可用。

## 代码风格与命名约定
- Swift 5，4 空格缩进，保持中文注释简洁明了；视图优先用 `struct`，数据持久化使用 `@Model`。
- 类型/文件用大驼峰，属性与方法用小驼峰；枚举 case 使用语义化小写命名。
- 视图文件名以 `View` 结尾，模型以实体名或 `Model` 结尾；避免在 View 内耦合过多持久化逻辑，复杂计算放到 Service 或扩展。

## 测试指引
- 单测放在 `Tests/UnitTests`，UI 测试放在 `Tests/UITests`，文件名以 `*Tests.swift` 结尾。
- 新增功能至少补一项核心逻辑或日期/金额边界用例；涉及异步或时间依赖时优先使用可注入的依赖或测试时钟。
- 提交前在调试设备和目标模拟器各跑一次关键路径（创建/编辑/删除交易），确认统计与列表刷新正常。

## 提交与 PR 规范
- 提交信息沿用仓库现有前缀：`feat/fix/chore/docs/test`，例如 `fix: 修复统计区间金额计算`。
- PR 描述需包含：变更摘要、涉及模块、验证方式（命令/设备）、UI 改动需附主要截图；避免混入无关改动。
- 若计划大规模重构，先拆分为可审查的小 PR，并在描述中标明后续步骤或依赖。

## 配置与安全
- SwiftData 仅启用本地存储，当前禁用 iCloud；勿提交个人账户、证书或敏感配置。
- 如需新增配置，优先使用 Xcode Scheme/本地配置文件并标注默认值，勿将私有设置提交到版本库。
