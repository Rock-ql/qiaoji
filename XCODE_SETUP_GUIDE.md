# Xcode项目配置指南

## 📋 前提条件

- macOS 14.0 或更高版本
- Xcode 16.0 或更高版本
- Apple开发者账号（用于iCloud功能）

## 🚀 创建新项目

### 步骤1：创建Xcode项目

1. 打开Xcode
2. 选择 `File` -> `New` -> `Project`
3. 在模板选择页面：
   - 平台：选择 **iOS**
   - 应用类型：选择 **App**
   - 点击 `Next`

4. 配置项目：
   - **Product Name**: `ExpenseTracker`
   - **Team**: 选择你的开发团队
   - **Organization Identifier**: `com.yourcompany`
   - **Bundle Identifier**: `com.yourcompany.ExpenseTracker`
   - **Interface**: 选择 **SwiftUI**
   - **Storage**: 选择 **SwiftData**（重要！）
   - **Language**: 选择 **Swift**
   - **Include Tests**: 勾选（可选）
   - 点击 `Next`

5. 选择保存位置，点击 `Create`

### 步骤2：配置项目设置

1. **设置部署目标**
   - 在项目导航器中选择项目根节点
   - 选择 `TARGETS` -> `ExpenseTracker`
   - 在 `General` 标签页中
   - 将 `Minimum Deployments` 设置为 **iOS 17.0**

2. **配置Signing & Capabilities**
   - 选择 `Signing & Capabilities` 标签页
   - 确保 `Automatically manage signing` 已勾选
   - 选择你的 `Team`

3. **添加iCloud能力**
   - 点击 `+ Capability` 按钮
   - 搜索并添加 **iCloud**
   - 勾选 **CloudKit**
   - 在 `Containers` 下，点击 `+` 添加容器
   - 输入：`iCloud.com.yourcompany.ExpenseTracker`
   - 或者选择：`Use default container`

4. **添加Background Modes（可选）**
   - 点击 `+ Capability` 按钮
   - 搜索并添加 **Background Modes**
   - 勾选 **Remote notifications**（用于iCloud同步）

### 步骤3：导入源代码文件

1. **删除自动生成的文件**
   - 在项目导航器中，删除以下文件：
     - `ContentView.swift`（如果存在）
     - `Item.swift`（如果存在）
   - 选择 `Move to Trash`

2. **导入ExpenseTracker文件夹**

   **方法A：拖拽导入（推荐）**
   - 在Finder中打开 `qiaoji/ExpenseTracker` 文件夹
   - 将整个 `ExpenseTracker` 文件夹拖入Xcode项目导航器
   - 在弹出的对话框中：
     - ✅ 勾选 `Copy items if needed`
     - ✅ 选择 `Create groups`
     - ✅ 确保 `Add to targets` 中勾选了 `ExpenseTracker`
     - 点击 `Finish`

   **方法B：使用菜单导入**
   - 右键点击项目根节点
   - 选择 `Add Files to "ExpenseTracker"...`
   - 导航到 `qiaoji/ExpenseTracker` 文件夹
   - 选择整个文件夹，点击 `Add`

3. **验证文件结构**

   导入后，你的项目结构应该如下：
   ```
   ExpenseTracker
   ├── ExpenseTrackerApp.swift (保留自动生成的，或替换为我们的版本)
   ├── ExpenseTracker
   │   ├── App
   │   │   ├── ExpenseTrackerApp.swift
   │   │   └── ContentView.swift
   │   ├── Features
   │   │   ├── Transactions
   │   │   ├── Statistics
   │   │   ├── Budget
   │   │   └── Settings
   │   ├── Core
   │   ├── Shared
   │   └── Resources
   └── Assets.xcassets
   ```

### 步骤4：修复应用入口

1. **方法A：使用导入的入口文件**
   - 删除项目根目录下自动生成的 `ExpenseTrackerApp.swift`
   - 将 `ExpenseTracker/App/ExpenseTrackerApp.swift` 中的 `@main` 标记保留

2. **方法B：修改现有入口文件**
   - 打开项目根目录下的 `ExpenseTrackerApp.swift`
   - 用以下内容替换：
   ```swift
   import SwiftUI
   import SwiftData

   @main
   struct ExpenseTrackerApp: App {
       let container: ModelContainer

       init() {
           do {
               container = try ModelContainer(
                   for: Transaction.self,
                       Category.self,
                       Budget.self,
                       Account.self,
                   configurations: ModelConfiguration(
                       cloudKitDatabase: .private("iCloud.com.yourcompany.ExpenseTracker")
                   )
               )

               Task {
                   await setupDefaultCategories()
               }
           } catch {
               fatalError("无法初始化ModelContainer: \(error.localizedDescription)")
           }
       }

       var body: some Scene {
           WindowGroup {
               ContentView()
                   .modelContainer(container)
           }
       }

       @MainActor
       private func setupDefaultCategories() async {
           // 实现见 ExpenseTracker/App/ExpenseTrackerApp.swift
       }
   }
   ```

### 步骤5：编译和运行

1. **选择运行目标**
   - 在Xcode顶部工具栏
   - 选择模拟器（如 iPhone 15 Pro）或连接的真机

2. **编译项目**
   - 按 `Command + B` 编译项目
   - 检查是否有编译错误

3. **运行项目**
   - 按 `Command + R` 运行项目
   - 应用应该启动并显示空白的交易列表

## ⚠️ 常见问题修复

### 问题1：找不到模块

**错误信息**: `No such module 'SwiftData'`

**解决方案**:
- 确保部署目标设置为 iOS 17.0 或更高
- File -> Packages -> Reset Package Caches
- Product -> Clean Build Folder (Shift + Command + K)
- 重新编译

### 问题2：@Model宏编译错误

**错误信息**: `Cannot find '@Model' in scope`

**解决方案**:
- 确保导入了 `import SwiftData`
- 确保部署目标为 iOS 17.0+
- 重启Xcode

### 问题3：iCloud错误

**错误信息**: `CloudKit access denied`

**解决方案**:
1. 确保在 Capabilities 中添加了 iCloud
2. 确保 Container ID 正确
3. 在模拟器中登录iCloud账号：
   - Settings -> Apple ID -> Sign In
4. 或者临时禁用iCloud：
   ```swift
   // 修改 ModelConfiguration
   configurations: ModelConfiguration(
       cloudKitDatabase: .none  // 禁用iCloud
   )
   ```

### 问题4：SwiftUI预览不工作

**解决方案**:
- 确保在预览代码中提供了 modelContainer：
  ```swift
  #Preview {
      ContentView()
          .modelContainer(for: [Transaction.self, Category.self])
  }
  ```

### 问题5：颜色显示不正确

**解决方案**:
- 检查 Color(hex:) 扩展是否存在
- 在 Assets.xcassets 中添加颜色集（可选）

## 🎨 Assets配置

### 添加应用图标

1. 在 Assets.xcassets 中找到 `AppIcon`
2. 拖入不同尺寸的图标图片
3. 推荐尺寸：
   - 1024x1024 (App Store)
   - 其他尺寸Xcode会自动生成

### 添加启动屏幕

1. 创建 Launch Screen Storyboard（可选）
2. 或使用默认的空白启动屏幕

### 添加自定义颜色

1. 在 Assets.xcassets 中右键
2. 选择 `Color Set`
3. 添加以下颜色：
   - `IncomeGreen`: #2ECC71
   - `ExpenseRed`: #E74C3C
   - `BudgetSafeGreen`: #27AE60
   - `BudgetWarningOrange`: #F39C12
   - `BudgetDangerRed`: #E67E22
   - `BudgetExceededDarkRed`: #C0392B

## 🧪 测试配置

### 运行单元测试

1. 打开 Test Navigator (Command + 6)
2. 点击运行按钮运行所有测试
3. 或右键单个测试运行

### 创建测试目标

如果创建项目时未勾选 Include Tests：

1. File -> New -> Target
2. 选择 `Unit Testing Bundle`
3. 命名为 `ExpenseTrackerTests`
4. 添加测试文件到 Tests 文件夹

## 📱 在真机上测试

1. **连接设备**
   - 使用USB线连接iPhone
   - 在设备上信任此电脑

2. **配置证书**
   - Xcode会自动配置开发证书
   - 首次运行需要在iPhone上：
     - Settings -> General -> Device Management
     - 信任开发者证书

3. **运行应用**
   - 选择你的设备作为运行目标
   - Command + R 运行

## 🔧 高级配置

### 配置Info.plist

添加必要的权限说明：

1. 选择项目 -> Info 标签
2. 添加以下键值：
   - `Privacy - Face ID Usage Description`: "使用Face ID保护您的财务数据"
   - `Privacy - Calendars Usage Description`: "用于预算周期计算"（可选）

### 配置Build Settings

优化编译设置：

1. Build Settings -> Swift Compiler - Code Generation
2. Optimization Level:
   - Debug: `-Onone`
   - Release: `-O`

### 配置Schemes

1. Product -> Scheme -> Edit Scheme
2. Run -> Arguments
3. 添加启动参数（用于测试）：
   - `-resetData 1`（重置数据库）
   - `-disableAnimations 1`（禁用动画）

## 📊 性能优化

### 开启优化选项

1. Build Settings -> Optimization Level
   - Release: `-O` (优化速度和大小)

2. Build Settings -> Compilation Mode
   - Release: `Whole Module`

### 使用Instruments分析

1. Product -> Profile (Command + I)
2. 选择工具：
   - Time Profiler: 分析性能瓶颈
   - Allocations: 分析内存使用
   - Leaks: 检测内存泄漏

## 🎯 下一步

配置完成后，你可以：

1. ✅ 运行应用，测试基础功能
2. ✅ 查看并修改默认分类
3. ✅ 添加第一笔交易记录
4. ✅ 开始开发其他功能模块

## 📚 参考文档

- [Xcode官方文档](https://developer.apple.com/documentation/xcode/)
- [SwiftData配置指南](https://developer.apple.com/documentation/swiftdata/configuring-swiftdata)
- [CloudKit配置](https://developer.apple.com/documentation/cloudkit/enabling_cloudkit_in_your_app)

---

**配置遇到问题？**欢迎查看 [常见问题](README.md#-已知问题) 或提交Issue。
