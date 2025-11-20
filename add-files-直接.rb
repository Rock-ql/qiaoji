#!/usr/bin/env ruby
# 直接修改Xcode项目文件添加新文件
# 作者: xiaolei

require 'securerandom'

# Xcode项目路径
PROJECT_PATH = "/Users/rockcoder/Desktop/ExpenseTracker/ExpenseTracker.xcodeproj/project.pbxproj"

# 要添加的文件
FILES_TO_ADD = [
  "CategoryManagementView.swift",
  "CategoryListRow.swift",
  "AddCategoryView.swift",
  "EditCategoryView.swift",
  "IconPickerView.swift",
  "ColorPickerView.swift"
]

# 文件所在目录
FILES_DIR = "/Users/rockcoder/Desktop/ExpenseTracker/ExpenseTracker 3/Features/Settings/Views"

puts "🔧 开始添加文件到Xcode项目..."
puts ""

# 1. 备份原文件
backup_path = PROJECT_PATH + ".backup." + Time.now.strftime("%Y%m%d_%H%M%S")
puts "📦 备份项目文件到: #{backup_path}"
File.write(backup_path, File.read(PROJECT_PATH))

# 2. 读取项目文件
project_content = File.read(PROJECT_PATH)

# 3. 为每个文件生成UUID
file_refs = {}
build_files = {}

FILES_TO_ADD.each do |filename|
  # 生成24位十六进制UUID（Xcode格式）
  file_ref_id = SecureRandom.hex(12).upcase
  build_file_id = SecureRandom.hex(12).upcase

  file_refs[filename] = file_ref_id
  build_files[filename] = build_file_id

  puts "✓ #{filename}"
  puts "  FileRef: #{file_ref_id}"
  puts "  BuildFile: #{build_file_id}"
end

puts ""
puts "📝 生成Xcode配置..."

# 4. 生成PBXFileReference条目
file_refs_section = ""
FILES_TO_ADD.each do |filename|
  file_refs_section += "\t\t#{file_refs[filename]} /* #{filename} */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = #{filename}; sourceTree = \"<group>\"; };\n"
end

# 5. 生成PBXBuildFile条目
build_files_section = ""
FILES_TO_ADD.each do |filename|
  build_files_section += "\t\t#{build_files[filename]} /* #{filename} in Sources */ = {isa = PBXBuildFile; fileRef = #{file_refs[filename]} /* #{filename} */; };\n"
end

# 6. 查找插入位置并插入
# 查找PBXFileReference section
if project_content =~ /(\/\* Begin PBXFileReference section \*\/\n)/
  insert_pos = project_content.index($1) + $1.length
  project_content.insert(insert_pos, file_refs_section)
  puts "✓ 添加PBXFileReference条目"
else
  puts "❌ 找不到PBXFileReference section"
  exit 1
end

# 查找PBXBuildFile section
if project_content =~ /(\/\* Begin PBXBuildFile section \*\/\n)/
  insert_pos = project_content.index($1) + $1.length
  project_content.insert(insert_pos, build_files_section)
  puts "✓ 添加PBXBuildFile条目"
else
  puts "❌ 找不到PBXBuildFile section"
  exit 1
end

# 7. 查找Settings/Views group并添加文件引用
# 这是最复杂的部分，需要找到正确的group
puts "🔍 查找Settings/Views组..."

# 查找Views group的UUID（通过搜索"Views"关键字）
if project_content =~ /([A-F0-9]{24}) \/\* Views \*\/ = \{[^\}]*children = \([^)]*\);/m
  views_group_id = $1
  puts "✓ 找到Views组: #{views_group_id}"

  # 在children数组中添加文件引用
  children_list = FILES_TO_ADD.map { |f| "#{file_refs[f]} /* #{f} */," }.join("\n\t\t\t\t")

  # 查找并替换children数组
  project_content.gsub!(/#{views_group_id} \/\* Views \*\/ = \{([^\}]*children = \()([^)]*\);)/) do |match|
    before_children = $1
    existing_children = $2
    "#{views_group_id} /* Views */ = {#{before_children}\n\t\t\t\t#{children_list}\n\t\t\t\t#{existing_children};"
  end

  puts "✓ 添加文件到Views组"
else
  puts "⚠️  找不到Views组，将在根目录添加"
end

# 8. 将文件添加到PBXSourcesBuildPhase
if project_content =~ /(\/\* Sources \*\/ = \{[^}]*files = \([^)]*)/m
  sources_section = $1
  sources_build_files = FILES_TO_ADD.map { |f| "#{build_files[f]} /* #{f} in Sources */," }.join("\n\t\t\t\t")

  project_content.sub!(sources_section) do |match|
    match + "\n\t\t\t\t" + sources_build_files
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
puts "🔨 接下来请在Xcode中："
puts "   1. 关闭Xcode（如果打开）"
puts "   2. 重新打开项目"
puts "   3. Clean Build Folder (⇧⌘K)"
puts "   4. Build (⌘B)"
puts ""
