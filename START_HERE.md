# 🚀 从这里开始 - 3分钟快速启动

> **你的系统环境检查通过！✅**
> - macOS 15.7.1 ✅
> - Xcode 26.0.1 ✅
> - 所有源文件完整 ✅

---

## 📺 视频式步骤（跟着做就行）

### 第 1 步：打开Xcode（10秒）

```bash
# 在终端运行这个命令，或在应用程序中找到Xcode双击打开
open -a Xcode
```

等待Xcode启动...

---

### 第 2 步：创建新项目（30秒）

1. 看到Xcode欢迎界面
2. 点击 **"Create New Project"** 大按钮
3. 或者点击菜单栏：`File` → `New` → `Project`

**选择模板：**
- 顶部选择：**iOS** 标签页
- 找到并点击：**App** 图标（一个蓝色的应用图标）
- 点击右下角：**Next**

**填写项目信息：**（⚠️ 每一项都很重要）
```
┌─────────────────────────────────────────────────┐
│ Product Name:  ExpenseTracker                   │
│ Team:          选择你的（或Add Account登录）    │
│ Organization:  com.yourname                     │
│ Bundle ID:     com.yourname.ExpenseTracker      │
│                                                 │
│ Interface:     SwiftUI  ⚠️ 必须选这个           │
│ Storage:       SwiftData ⚠️ 必须选这个          │
│ Language:      Swift                            │
└─────────────────────────────────────────────────┘
```

**选择保存位置：**
- 建议：`~/Documents/` 或 `~/Desktop/`
- **不要**选择当前的 `qiaoji` 文件夹
- 点击 **Create**

---

### 第 3 步：删除自动生成的文件（10秒）

在Xcode左侧文件列表中：

1. 找到 **`ContentView.swift`**
   - 右键点击 → 选择 **Delete**
   - 在弹窗中选择 **Move to Trash**

2. 找到 **`Item.swift`**（如果有）
   - 右键点击 → 选择 **Delete**
   - 在弹窗中选择 **Move to Trash**

---

### 第 4 步：打开源代码文件夹（5秒）

```bash
# 复制下面这行命令到终端运行
open /Users/rockcoder/IdeaProjects/ai-project/qiaoji/ExpenseTracker
```

会弹出一个Finder窗口，显示 ExpenseTracker 文件夹

---

### 第 5 步：导入源代码（重要！30秒）

**这一步要仔细看！**

1. **在Finder窗口中**（刚才打开的）
   - 找到 **ExpenseTracker** 文件夹
   - 看到里面有 App、Features 等子文件夹

2. **拖拽操作**
   - 用鼠标点住 **ExpenseTracker** 文件夹（整个文件夹）
   - 拖到 **Xcode 左侧项目导航器**
   - 拖到 **ExpenseTracker** 项目名称上面（蓝色图标）
   - 看到蓝色高亮后再松开鼠标

3. **配置导入选项**（重要！）
   - 会弹出一个对话框
   - ✅ **必须勾选**：`Copy items if needed`
   - ✅ **必须选择**：`Create groups`（有小黄色文件夹图标）
   - ✅ **必须勾选**：`Add to targets: ExpenseTracker`
   - 点击 **Finish**

4. **验证导入成功**
   - 左侧应该看到黄色的 ExpenseTracker 文件夹
   - 展开后看到 App、Features 等子文件夹
   - 文件夹图标是**黄色**的（不是蓝色）

---

### 第 6 步：配置项目设置（40秒）

#### A. 设置iOS版本

1. 点击左侧最顶部的 **ExpenseTracker**（蓝色图标，项目名）
2. 中间区域选择 **TARGETS** → **ExpenseTracker**
3. 在 **General** 标签页
4. 找到 **Minimum Deployments**
5. 下拉框改为：**iOS 17.0**

#### B. 配置签名（如果提示错误）

1. 切换到 **Signing & Capabilities** 标签页
2. ✅ 确保 **Automatically manage signing** 已勾选
3. **Team** 下拉框：
   - 有团队就选择
   - 没有就点击 `Add Account`，用Apple ID登录

#### C. 配置iCloud（可选，建议先跳过）

**第一次运行建议跳过，等运行成功后再配置**

如果想配置：
1. 在 **Signing & Capabilities** 标签页
2. 点击 **+ Capability**
3. 搜索并添加 **iCloud**
4. 勾选 **CloudKit**

**或者禁用iCloud（推荐新手）：**

1. 打开 **ExpenseTracker/App/ExpenseTrackerApp.swift**
2. 找到第21行左右：
   ```swift
   cloudKitDatabase: .private("iCloud.com.expensetracker.app")
   ```
3. 改为：
   ```swift
   cloudKitDatabase: .none  // 禁用iCloud，仅本地存储
   ```

---

### 第 7 步：编译项目（30秒）

1. 按键盘：**Command + B**
2. 或点击菜单：`Product` → `Build`
3. 等待编译...（第一次会慢一些）

**观察底部进度条**
- 如果显示 **"Build Succeeded"** ✅ 成功！
- 如果有红色错误 ❌ 往下看解决方案

**常见错误：**

❌ **错误1：Cannot find 'Transaction' in scope**
- 原因：文件未正确导入
- 解决：重新执行第5步，确保勾选了"Copy items"

❌ **错误2：CloudKit相关错误**
- 解决：按第6步C的方法，改为 `.none`

❌ **错误3：其他错误**
- 按 **Shift + Command + K** 清理
- 重新编译 **Command + B**

---

### 第 8 步：选择模拟器（10秒）

在Xcode顶部工具栏：

1. 找到设备选择器（中间偏左位置）
2. 当前显示：`ExpenseTracker > iPhone ...`
3. 点击它，会出现下拉菜单
4. 选择：**iPhone 15 Pro**（或任何 iOS 17+ 的模拟器）

---

### 第 9 步：运行应用！🎉（30秒）

1. 按键盘：**Command + R**
2. 或点击左上角的 **▶️ 播放按钮**
3. 等待模拟器启动...（第一次很慢，要1-2分钟）

**成功的标志：**

✅ 模拟器出现 iPhone 界面
✅ 应用自动打开
✅ 看到底部有 4 个 Tab：交易、统计、预算、设置
✅ 中间显示"暂无交易记录"
✅ 右下角有蓝色的 **+** 按钮

---

### 第 10 步：测试功能（1分钟）

**添加第一笔交易：**

1. 点击浮动的 **+** 按钮
2. 顶部选择 **"支出"**
3. 输入金额：`100`
4. 选择分类：点击 **餐饮** 🍴（或其他分类）
5. 点击右上角 **"保存"**
6. 返回列表，应该能看到刚才的记录！

**查看分类：**
- 点击底部 **"设置"** Tab
- 看到各种设置选项

**恭喜！🎉 应用运行成功！**

---

## 🎯 快速命令参考卡

```bash
# 编译项目
Command + B

# 运行项目
Command + R

# 停止运行
Command + .

# 清理构建
Shift + Command + K

# 打开设备管理器
Command + Shift + 2

# 显示/隐藏左侧导航器
Command + 0

# 显示/隐藏右侧检查器
Option + Command + 0
```

---

## ❓ 遇到问题？

### 问题：模拟器启动失败

```bash
# 尝试重启模拟器
xcrun simctl shutdown all
xcrun simctl boot "iPhone 15 Pro"
```

### 问题：应用崩溃

1. 查看Xcode底部的控制台（红色错误信息）
2. 如果看到 "ModelContainer" 错误
   - 打开 ExpenseTrackerApp.swift
   - 改为 `cloudKitDatabase: .none`

### 问题：看不到文件

- 按 **Command + 1** 打开项目导航器
- 检查文件夹图标是否为**黄色**

### 问题：编译太慢

- 第一次编译需要1-2分钟，这是正常的
- Xcode在构建缓存
- 后续编译会快很多

---

## 📚 延伸阅读

- 📖 [快速启动指南.md](快速启动指南.md) - 详细版本
- 📖 [README.md](README.md) - 项目说明
- 📖 [XCODE_SETUP_GUIDE.md](XCODE_SETUP_GUIDE.md) - 高级配置

---

## 🎊 成功运行后

接下来你可以：

1. ✅ 探索应用功能
2. ✅ 查看源代码，学习SwiftUI
3. ✅ 修改UI，自定义样式
4. ✅ 开发新功能（统计图表、预算管理）
5. ✅ 在真机上测试

---

**总耗时：约3-5分钟**（不包括首次模拟器启动时间）

**祝你运行成功！如有问题，欢迎反馈！** 🚀
