#!/usr/bin/env ruby
# 使用 xcodeproj gem 添加 CustomNumericKeyboard.swift 到 Xcode 项目
# 作者: xiaolei

require 'xcodeproj'

# Xcode项目路径
PROJECT_PATH = "/Users/rockcoder/Desktop/ExpenseTracker/ExpenseTracker.xcodeproj"

# 要添加的文件（绝对路径）
FILE_PATH = "/Users/rockcoder/Desktop/ExpenseTracker/ExpenseTracker/ExpenseTracker/Features/Transactions/Views/CustomNumericKeyboard.swift"

# 文件名
FILE_NAME = "CustomNumericKeyboard.swift"

puts "🔧 使用 xcodeproj gem 添加 #{FILE_NAME} 到Xcode项目..."
puts ""

begin
  # 1. 打开项目
  project = Xcodeproj::Project.open(PROJECT_PATH)
  puts "✓ 打开项目: #{PROJECT_PATH}"

  # 2. 查找 target
  target = project.targets.first
  puts "✓ 找到 target: #{target.name}"

  # 3. 查找 Views 组
  # 首先查找 Features 组
  features_group = project.main_group.groups.find { |g| g.display_name == 'ExpenseTracker' }
  if features_group
    features_group = features_group.groups.find { |g| g.display_name == 'Features' }
  end

  unless features_group
    puts "❌ 找不到 Features 组"
    exit 1
  end
  puts "✓ 找到 Features 组"

  # 查找 Transactions 组
  transactions_group = features_group.groups.find { |g| g.display_name == 'Transactions' }
  unless transactions_group
    puts "❌ 找不到 Transactions 组"
    exit 1
  end
  puts "✓ 找到 Transactions 组"

  # 查找 Views 组
  views_group = transactions_group.groups.find { |g| g.display_name == 'Views' }
  unless views_group
    puts "❌ 找不到 Views 组"
    exit 1
  end
  puts "✓ 找到 Views 组"

  # 4. 检查文件是否已存在
  existing_file = views_group.files.find { |f| f.display_name == FILE_NAME }
  if existing_file
    puts "⚠️  文件已存在，跳过添加"
  else
    # 5. 添加文件引用
    file_ref = views_group.new_reference(FILE_PATH)
    puts "✓ 添加文件引用"

    # 6. 将文件添加到 target 的构建阶段
    target.add_file_references([file_ref])
    puts "✓ 添加到构建阶段"
  end

  # 7. 保存项目
  project.save
  puts ""
  puts "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  puts "✅ 文件添加完成！"
  puts ""

rescue => e
  puts ""
  puts "❌ 错误: #{e.message}"
  puts e.backtrace.join("\n")
  exit 1
end
