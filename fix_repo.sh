#!/bin/bash
# 修复 repository.go 中的UTF8编码问题

REPO_FILE="/home/ubuntu/myanmarestate/myanmar-real-estate-kimi/myanmar-real-estate/backend/04-house-service/repository.go"

# 备份原文件
cp "$REPO_FILE" "${REPO_FILE}.bak"

# 使用sed替换关键词搜索部分
# 删除旧的关键词搜索代码(行236-245左右)，替换为新的实现

sed -i '236,245d' "$REPO_FILE"

# 在第236行插入新的代码
sed -i '235a\
\
	// 关键词搜索：优先使用Elasticsearch，降级为LIKE查询\
	if params.Keywords != "" {\
		// 处理中文编码：将关键词转为UTF8并清理特殊字符\
		keywords := strings.TrimSpace(params.Keywords)\
		if keywords != "" {\
			esUsed := false\
			if r.esEnabled {\
				ids, err := r.searchByES(ctx, keywords)\
				if err == nil \&\& len(ids) > 0 {\
					query = query.Where("id IN ?", ids)\
					esUsed = true\
				}\
			}\
			if !esUsed {\
				// 降级：PostgreSQL LIKE查询，使用参数化查询避免编码问题\
				keywordPattern := "%" + keywords + "%"\
				query = query.Where("title ILIKE ? OR address ILIKE ? OR description ILIKE ?",\
					keywordPattern, keywordPattern, keywordPattern)\
			}\
		}\
	}' "$REPO_FILE"

echo "repository.go 修复完成"
