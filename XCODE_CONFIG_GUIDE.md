# Xcode 配置指南 - 应用名称与图标设置

## 问题诊断

您的应用名称和图标在 Xcode 重新打包后仍未更改，这是因为需要在 Xcode 项目设置中进行配置。

## 解决方案

### 方案一：在 Xcode 项目设置中配置（推荐）

#### 1. 配置应用名称

1. 在 Xcode 中打开项目
2. 在左侧导航栏选择项目根节点（蓝色图标）
3. 在 TARGETS 列表中选择 "ExpenseTracker"
4. 进入 "General" 标签页
5. 找到 **Display Name** 字段，填入：`巧记`
6. 找到 **Bundle Identifier**，确保设置了唯一标识符，例如：`com.yourname.qiaoji`

#### 2. 配置应用图标

1. 在同一页面找到 **App Icons and Launch Screen** 部分
2. 点击 **App Icon** 下拉菜单
3. 选择 `AppIcon`（这是我们刚才替换的图标集）
4. 确认图标预览显示正确

#### 3. 配置 Info.plist

1. 在 TARGETS → "Build Settings" 标签页
2. 搜索 "Info.plist"
3. 找到 **Info.plist File** 设置项
4. 设置为：`ExpenseTracker/Info.plist`

#### 4. 清理并重新构建

```bash
# 在终端中执行以下命令清理缓存
cd /Users/rockcoder/IdeaProjects/ai-project/qiaoji
rm -rf ~/Library/Developer/Xcode/DerivedData/*
```

然后在 Xcode 中：
1. 菜单：Product → Clean Build Folder（快捷键：⇧⌘K）
2. 菜单：Product → Build（快捷键：⌘B）
3. 运行应用测试

---

### 方案二：直接修改项目配置文件（如果方案一不可行）

如果您的项目是通过其他方式创建的（如 Swift Package Manager），可能需要创建或修改配置文件。

#### 检查项目结构

请告诉我您的项目是如何创建的：
- [ ] Xcode 新建项目
- [ ] Swift Package Manager
- [ ] 其他工具

---

## 验证步骤

### 1. 验证图标文件

所有图标文件已正确放置在：
```
ExpenseTracker/Resources/Assets.xcassets/AppIcon.appiconset/
```

包含以下 15 个文件：
- Icon-App-1024x1024@1x.png
- Icon-App-20x20@1x.png, @2x.png, @3x.png
- Icon-App-29x29@1x.png, @2x.png, @3x.png
- Icon-App-40x40@1x.png, @2x.png, @3x.png
- Icon-App-60x60@2x.png, @3x.png
- Icon-App-76x76@1x.png, @2x.png
- Icon-App-83.5x83.5@2x.png

### 2. 验证 Info.plist 配置

Info.plist 已配置以下关键项：
```xml
<key>CFBundleDisplayName</key>
<string>巧记</string>

<key>CFBundleIcons</key>
<dict>
    <key>CFBundlePrimaryIcon</key>
    <dict>
        <key>CFBundleIconFiles</key>
        <array>
            <string>AppIcon</string>
        </array>
    </dict>
</dict>
```

---

## 常见问题排查

### 问题 1：应用名称仍显示为 "ExpenseTracker"

**原因**：Xcode 项目设置中的 Display Name 未配置

**解决**：
1. 打开 Xcode 项目
2. 选择 TARGETS → ExpenseTracker → General
3. 设置 Display Name = `巧记`

### 问题 2：图标显示为默认图标

**原因**：App Icon 未在项目设置中选择

**解决**：
1. 选择 TARGETS → ExpenseTracker → General
2. App Icons and Launch Screen → App Icon 选择 `AppIcon`
3. 清理并重新构建项目

### 问题 3：模拟器显示旧图标

**原因**：模拟器缓存未清理

**解决**：
```bash
# 重置模拟器
xcrun simctl shutdown all
xcrun simctl erase all
```

或在模拟器中：
1. 菜单：Device → Erase All Content and Settings...
2. 重新安装应用

### 问题 4：真机显示旧图标

**原因**：应用未完全卸载

**解决**：
1. 在真机上完全卸载旧应用
2. 重启设备
3. 重新安装应用

---

## 备份信息

原有图标已备份到：
```
ExpenseTracker/Resources/Assets.xcassets/AppIcon.appiconset.backup/
```

如需恢复，可执行：
```bash
cd /Users/rockcoder/IdeaProjects/ai-project/qiaoji
rm -rf ExpenseTracker/Resources/Assets.xcassets/AppIcon.appiconset
mv ExpenseTracker/Resources/Assets.xcassets/AppIcon.appiconset.backup ExpenseTracker/Resources/Assets.xcassets/AppIcon.appiconset
```

---

## 需要进一步帮助？

如果按照上述步骤仍无法解决问题，请提供以下信息：

1. 您的 Xcode 版本
2. 项目创建方式
3. TARGETS → General 中的截图
4. 构建日志中的错误信息

我可以提供更详细的指导。
