#!/usr/bin/env ruby
# 添加 CustomNumericKeyboard.swift 到 Xcode 项目
# 作者: xiaolei

require 'securerandom'

# Xcode项目路径
PROJECT_PATH = "/Users/rockcoder/Desktop/ExpenseTracker/ExpenseTracker.xcodeproj/project.pbxproj"

# 要添加的文件
FILE_TO_ADD = "CustomNumericKeyboard.swift"

# 文件所在目录（相对于Xcode项目）
FILES_DIR = "Features/Transactions/Views"

puts "🔧 开始添加 #{FILE_TO_ADD} 到Xcode项目..."
puts ""

# 1. 备份原文件
backup_path = PROJECT_PATH + ".backup." + Time.now.strftime("%Y%m%d_%H%M%S")
puts "📦 备份项目文件到: #{backup_path}"
File.write(backup_path, File.read(PROJECT_PATH))

# 2. 读取项目文件
project_content = File.read(PROJECT_PATH)

# 3. 生成UUID
file_ref_id = SecureRandom.hex(12).upcase
build_file_id = SecureRandom.hex(12).upcase

puts "✓ #{FILE_TO_ADD}"
puts "  FileRef: #{file_ref_id}"
puts "  BuildFile: #{build_file_id}"
puts ""

# 4. 生成PBXFileReference条目
file_ref_entry = "\t\t#{file_ref_id} /* #{FILE_TO_ADD} */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = #{FILE_TO_ADD}; sourceTree = \"<group>\"; };\n"

# 5. 生成PBXBuildFile条目
build_file_entry = "\t\t#{build_file_id} /* #{FILE_TO_ADD} in Sources */ = {isa = PBXBuildFile; fileRef = #{file_ref_id} /* #{FILE_TO_ADD} */; };\n"

# 6. 查找插入位置并插入
# 查找PBXFileReference section
if project_content =~ /(\/\* Begin PBXFileReference section \*\/\n)/
  insert_pos = project_content.index($1) + $1.length
  project_content.insert(insert_pos, file_ref_entry)
  puts "✓ 添加PBXFileReference条目"
else
  puts "❌ 找不到PBXFileReference section"
  exit 1
end

# 查找PBXBuildFile section
if project_content =~ /(\/\* Begin PBXBuildFile section \*\/\n)/
  insert_pos = project_content.index($1) + $1.length
  project_content.insert(insert_pos, build_file_entry)
  puts "✓ 添加PBXBuildFile条目"
else
  puts "❌ 找不到PBXBuildFile section"
  exit 1
end

# 7. 查找Views group并添加文件引用
puts "🔍 查找Views组..."

# 查找Views group的UUID（通过搜索"Views"关键字）
# 需要找到Transactions下的Views组
if project_content =~ /([A-F0-9]{24}) \/\* Views \*\/ = \{[^}]*isa = PBXGroup;[^}]*children = \([^)]*\);[^}]*path = Views;[^}]*\}/m
  views_group_match = $&
  views_group_id = $1
  puts "✓ 找到Views组: #{views_group_id}"

  # 在children数组中添加文件引用
  project_content.gsub!(/#{views_group_id} \/\* Views \*\/ = \{([^}]*children = \()([^)]*\);)/) do |match|
    before_children = $1
    existing_children = $2
    "#{views_group_id} /* Views */ = {#{before_children}\n\t\t\t\t#{file_ref_id} /* #{FILE_TO_ADD} */,\n\t\t\t\t#{existing_children};"
  end

  puts "✓ 添加文件到Views组"
else
  puts "⚠️  找不到Views组"
  exit 1
end

# 8. 将文件添加到PBXSourcesBuildPhase
if project_content =~ /(\/\* Sources \*\/ = \{[^}]*files = \([^)]*)/m
  sources_section = $1

  project_content.sub!(sources_section) do |match|
    match + "\n\t\t\t\t#{build_file_id} /* #{FILE_TO_ADD} in Sources */,"
  end

  puts "✓ 添加文件到构建阶段"
else
  puts "❌ 找不到Sources构建阶段"
  exit 1
end

# 9. 写回文件
File.write(PROJECT_PATH, project_content)

puts ""
puts "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
puts "✅ 文件添加完成！"
puts ""
puts "📌 备份文件: #{backup_path}"
puts ""
puts "🔨 接下来将自动构建项目..."
puts ""
