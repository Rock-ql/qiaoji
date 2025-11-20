# Repository Guidelines

## 项目结构与模块组织
ExpenseTracker 目录下按 SwiftUI 模块拆分：`App/` 保存应用入口与导航，`Core/` 负责数据库、网络与安全服务，`Features/` 以 Transactions、Budget、Statistics、Settings 等子目录划分业务功能，`Shared/` 收纳通用组件、修饰器与扩展，`Resources/` 放置素材资源，`Tests/` 则容纳 Swift 单元与快照测试。提交新功能前先在各自模块内建子文件夹，维持“功能->模型/视图/视图模型” 的层次，避免跨层引用造成耦合。

## 构建、测试与开发命令
- `xcodebuild -scheme ExpenseTracker -destination "platform=iOS Simulator,name=iPhone 15" build`：在命令行触发基础编译，适合 CI 快速冒烟。
- `xcodebuild -scheme ExpenseTracker -destination "platform=iOS Simulator,name=iPhone 15" test`：运行 `Tests/` 里的 ViewModel 与业务用例，确保数据层逻辑稳定。
- `./verify-fix.sh`：静态脚本，检查 `App/ContentView.swift` 中常见的 Color 扩展与类型引用问题。
- `./clean-xcode.sh` 与 `./sync-to-xcode.sh`：前者清理 DerivedData，后者同步 Swift 文件到既有 Xcode 工程，解决缓存或引用缺失。

## 编码风格与命名约定
使用 Swift 5.9，代码块统一四空格缩进，结构体与类名采用 UpperCamelCase，属性与函数使用 lowerCamelCase；枚举 case 以动词或名词短语命名，保持语义自解释。所有 Swift 文件在首行标记作者 `// Author: xiaolei`，重要段落用 `// MARK:` 切分，关键业务逻辑添加中文注释。尽量利用协议与组合层次，ViewModel 避免直接依赖 View。

## 测试指南
`Tests/` 中每个功能模块对应 `FeatureNameTests` 目录，文件命名遵循 `SubjectTests.swift`，测试函数以 `test_shouldDoSomething` 形式表达意图。新增 ViewModel 或 Service 时同步补齐 Given-When-Then 风格的单元测试，覆盖关键分支和失败路径。涉及图表或 SwiftUI 视图，可借助快照测试验证布局一致性，变更前后至少保持原有效用例通过。

## 提交与 Pull Request 指南
提交信息使用简洁中文总结，例如 `feat: 完成预算列表交互`，一条提交只聚焦一个议题，并确保已经在本地构建与测试通过。PR 描述需包含问题背景、解决方案、受影响模块与验证步骤，若涉及 UI 变化应附截图或录屏，关联 Issue 或任务编号并列出回归检查点。

## 安全与配置提示
启用 iCloud/CloudKit 前在 Xcode 中设置唯一 Bundle Identifier 与私有容器，保证 Transaction 等模型同步。敏感配置（如账户、租户信息）放入 Xcode Scheme 的环境变量，不写入仓库。脚本 `完成构建.sh` 可自动触发 Clean Build；若遇到权限或路径调整，请先复制备份后再运行。提交前核对 `Resources/Assets.xcassets` 中的图标遵循 SF Symbols 版权限制。
