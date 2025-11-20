-- 自动添加文件到 Xcode 项目
-- 作者: xiaolei

tell application "Xcode"
	activate
	delay 2
end tell

-- 使用系统对话框提示用户
tell application "System Events"
	display dialog "准备添加 6 个文件到 Xcode 项目。

请确保：
1. Xcode 已打开 ExpenseTracker 项目
2. 左侧导航器中可以看到项目结构

点击确定后，请：
1. 在弹出的文件选择器中选择所有 6 个文件
2. 确认设置并点击 Add" buttons {"取消", "确定"} default button "确定"

	if button returned of result is "确定" then
		tell application "Xcode"
			activate
		end tell

		-- 等待用户准备
		delay 1

		-- 尝试打开添加文件对话框
		tell application "System Events"
			tell process "Xcode"
				-- 使用菜单：File → Add Files to "ExpenseTracker"...
				click menu item "Add Files to "ExpenseTracker"…" of menu "File" of menu bar 1
			end tell
		end tell

		-- 等待文件选择器打开
		delay 2

		-- 尝试导航到正确的文件夹
		tell application "System Events"
			keystroke "g" using {command down, shift down} -- 打开 Go to Folder
			delay 0.5
			keystroke "/Users/rockcoder/Desktop/ExpenseTracker/ExpenseTracker 3/Features/Settings/Views"
			delay 0.5
			keystroke return
			delay 1
			-- 全选文件
			keystroke "a" using command down
		end tell

		display dialog "请在打开的对话框中：
1. 确认已选中所有 6 个文件
2. 勾选 'Copy items if needed'
3. 选择 'Create groups'
4. 勾选 Target: ExpenseTracker
5. 点击 'Add' 按钮

完成后点击确定继续..." buttons {"确定"} default button "确定"

	end if
end tell

display notification "文件添加完成！现在请在 Xcode 中执行 Clean Build Folder (⇧⌘K) 然后 Build (⌘B)" with title "Xcode 文件添加"
