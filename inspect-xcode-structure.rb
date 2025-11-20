#!/usr/bin/env ruby
# 检查 Xcode 项目结构
# 作者: xiaolei

require 'xcodeproj'

# Xcode项目路径
PROJECT_PATH = "/Users/rockcoder/Desktop/ExpenseTracker/ExpenseTracker.xcodeproj"

puts "🔍 检查 Xcode 项目结构..."
puts ""

begin
  # 打开项目
  project = Xcodeproj::Project.open(PROJECT_PATH)
  puts "✓ 打开项目: #{PROJECT_PATH}"
  puts ""

  # 打印主组结构
  def print_group(group, indent = 0)
    prefix = "  " * indent
    puts "#{prefix}📁 #{group.display_name || group.path || 'Root'}"

    # 打印文件
    group.files.each do |file|
      puts "#{prefix}  📄 #{file.display_name}"
    end

    # 递归打印子组
    group.groups.each do |subgroup|
      print_group(subgroup, indent + 1)
    end
  end

  puts "项目组结构:"
  puts "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  print_group(project.main_group)
  puts "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

rescue => e
  puts ""
  puts "❌ 错误: #{e.message}"
  puts e.backtrace.join("\n")
  exit 1
end
