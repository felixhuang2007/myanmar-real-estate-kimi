#!/usr/bin/env python3
import re

file_path = '/home/ubuntu/myanmarestate/myanmar-real-estate-kimi/myanmar-real-estate/backend/04-house-service/repository.go'

with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# The old pattern to replace
old_pattern = r'''\t// 关键词搜索：优先使用Elasticsearch，降级为LIKE查询
\tif params\.Keywords != "" \{\n\t\tesUsed := false
\t\tif r\.esEnabled \{\n\t\t\tids, err := r\.searchByES\(ctx, params\.Keywords\)'''

# The new code
new_code = '''\t// 关键词搜索：优先使用Elasticsearch，降级为LIKE查询
\tif params.Keywords != "" {
\t\t// 处理中文编码：将关键词转为UTF8并清理特殊字符
\t\tkeywords := strings.TrimSpace(params.Keywords)
\t\tif keywords != "" {
\t\t\tesUsed := false
\t\t\tif r.esEnabled {
\t\t\t\tids, err := r.searchByES(ctx, keywords)'''

# Check if old pattern exists
if 'TrimSpace' in content:
    print("UTF8 fix already applied")
    exit(0)

# Simple string replacement
old_simple = '''\t// 关键词搜索：优先使用Elasticsearch，降级为LIKE查询
\tif params.Keywords != "" {
\t\tesUsed := false
\t\tif r.esEnabled {
\t\t\tids, err := r.searchByES(ctx, params.Keywords)'''

new_simple = '''\t// 关键词搜索：优先使用Elasticsearch，降级为LIKE查询
\tif params.Keywords != "" {
\t\t// 处理中文编码：将关键词转为UTF8并清理特殊字符
\t\tkeywords := strings.TrimSpace(params.Keywords)
\t\tif keywords != "" {
\t\t\tesUsed := false
\t\t\tif r.esEnabled {
\t\t\t\tids, err := r.searchByES(ctx, keywords)'''

if old_simple in content:
    content = content.replace(old_simple, new_simple)
    print("Applied first part of UTF8 fix")
else:
    print("Could not find pattern to replace (first part)")
    # Print surrounding context for debugging
    idx = content.find('关键词搜索')
    if idx > 0:
        print("Found at index", idx)
        print(repr(content[idx:idx+200]))

# Also need to close the extra if block and update the LIKE query
# Find and replace the LIKE query part
old_like = '''\t\t\t// 降级：PostgreSQL LIKE查询，使用参数化查询避免编码问题
\t\t\tkeywordPattern := "%" + params.Keywords + "%"'''

new_like = '''\t\t\t// 降级：PostgreSQL LIKE查询，使用参数化查询避免编码问题
\t\t\t\tkeywordPattern := "%" + keywords + "%"'''

if old_like in content:
    content = content.replace(old_like, new_like)
    print("Applied LIKE query fix")

# Fix indentation for the query.Where line
old_query = '''\t\t\tquery = query.Where("title ILIKE ? OR address ILIKE ? OR description ILIKE ?",
\t\t\t\tkeywordPattern, keywordPattern, keywordPattern)
\t\t}
\t}'''

new_query = '''\t\t\t\tquery = query.Where("title ILIKE ? OR address ILIKE ? OR description ILIKE ?",
\t\t\t\t\tkeywordPattern, keywordPattern, keywordPattern)
\t\t\t}
\t\t}
\t}'''

if old_query in content:
    content = content.replace(old_query, new_query)
    print("Applied query fix")

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)

print("Fix applied successfully")
