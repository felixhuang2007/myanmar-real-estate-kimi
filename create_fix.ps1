$content = @'
// 关键词搜索：优先使用Elasticsearch，降级为LIKE查询
	if params.Keywords != "" {
		// 处理中文编码：将关键词转为UTF8并清理特殊字符
		keywords := strings.TrimSpace(params.Keywords)
		if keywords != "" {
			esUsed := false
			if r.esEnabled {
				ids, err := r.searchByES(ctx, keywords)
				if err == nil && len(ids) > 0 {
					query = query.Where("id IN ?", ids)
					esUsed = true
				}
			}
			if !esUsed {
				// 降级：PostgreSQL LIKE查询，使用参数化查询避免编码问题
				keywordPattern := "%" + keywords + "%"
				query = query.Where("title ILIKE ? OR address ILIKE ? OR description ILIKE ?",
					keywordPattern, keywordPattern, keywordPattern)
			}
		}
	}
'@

$content | Out-File -FilePath "D:\work\myanmar-real-estate-kimi\search_fix.txt" -Encoding UTF8
