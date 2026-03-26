---
name: github-secure-push
description: 安全推送到 GitHub 的工作流程 - 处理敏感信息清理、大文件排除和历史重写
trigger:
  - 推送到 GitHub
  - git push
  - 安全推送
  - 清理敏感信息
  - 重写 git 历史
---

# GitHub 安全推送 Skill

## 适用场景

- 首次推送到 GitHub 且代码中包含敏感配置文件
- 需要清理已提交的敏感信息（API 密钥、密码等）
- 仓库中包含大文件需要排除
- 重写 git 历史后重新推送

## 前置检查清单

执行推送前，确认以下事项：

| 检查项 | 命令 | 预期结果 |
|--------|------|----------|
| 列出所有配置文件 | `find . -name "*.yaml" -o -name "*.env*" \| grep -v node_modules \| head -20` | 识别潜在敏感文件 |
| 检查文件大小 | `find . -type f -size +50M ! -path "./.git/*"` | 发现大文件 |
| 查看当前分支 | `git branch -a` | 确认工作分支 |
| 检查远程配置 | `git remote -v` | 确认目标仓库 |

## 标准操作流程

### 步骤 1：备份敏感文件

```bash
# 备份本地配置文件（包含敏感信息）
cp myanmar-real-estate/backend/config.yaml /tmp/config.yaml.backup

# 如有其他敏感文件，一并备份
cp .env /tmp/.env.backup 2>/dev/null || true
```

### 步骤 2：创建孤立分支（重写历史）

```bash
# 创建全新分支（无父提交）
git checkout --orphan temp-clean-branch

# 重置暂存区
git reset
```

### 步骤 3：更新 .gitignore

在 `.gitignore` 中添加敏感文件和大文件规则：

```gitignore
# 敏感配置文件
myanmar-real-estate/backend/config.yaml
myanmar-real-estate/backend/.env*
.env
.env.local
.env.production

# 大文件/缓存
*.pack
*.pack.old
node_modules/.cache/
flutter/build/
```

### 步骤 4：选择性添加文件

```bash
# 添加 .gitignore 本身
git add .gitignore

# 添加所有文件
git add -A

# 从暂存区移除敏感文件（关键！）
git reset -- myanmar-real-estate/backend/config.yaml

# 移除大文件/缓存目录
git reset -- myanmar-real-estate/frontend/web-admin/node_modules/.cache/
```

### 步骤 5：创建干净提交

```bash
# 首次提交 - 干净代码库
git commit -m "feat: initial commit with sensitive data removed

- 缅甸房产平台完整代码
- 已排除包含 API 凭证的配置文件
- 已排除 node_modules 缓存大文件
- 包含所有微服务、Flutter 应用和 Web 管理后台"
```

### 步骤 6：替换主分支

```bash
# 删除旧分支（包含敏感信息的历史）
git branch -D master

# 重命名新分支为 master
git branch -m temp-clean-branch master
```

### 步骤 7：恢复本地配置文件

```bash
# 恢复备份的配置文件（本地开发使用）
cp /tmp/config.yaml.backup myanmar-real-estate/backend/config.yaml
```

### 步骤 8：推送到 GitHub

```bash
# 添加远程（如尚未添加）
git remote add origin https://github.com/用户名/仓库名.git

# 强制推送（覆盖空仓库或重写历史）
git push origin master --force

# 如推送失败，调整缓冲区后重试
git config http.postBuffer 524288000
git push origin master --force
```

## 验证清单

推送后执行以下验证：

```bash
# 1. 验证远程分支存在
git branch -r
# 预期：origin/master

# 2. 验证敏感文件不在历史中
git log --all --full-history -- myanmar-real-estate/backend/config.yaml
# 预期：无输出（文件不在任何提交中）

# 3. 验证 .gitignore 生效
git check-ignore -v myanmar-real-estate/backend/config.yaml
# 预期：显示匹配的 .gitignore 规则

# 4. 检查提交历史简洁
git log --oneline
# 预期：1-3 个干净提交
```

## 常见问题处理

### 问题 1：推送失败 "Large files detected"

**原因**：文件超过 GitHub 100MB 限制

**解决**：
```bash
# 从暂存区移除大文件
git reset -- path/to/large/file

# 添加到 .gitignore
echo "path/to/large/file" >> .gitignore

# 重新提交并推送
```

### 问题 2：推送失败 "Connection reset"

**原因**：仓库过大或网络不稳定

**解决**：
```bash
# 增加缓冲区
git config http.postBuffer 524288000
git config http.version HTTP/1.1

# 或使用 SSH 替代 HTTPS
git remote set-url origin git@github.com:用户名/仓库名.git
```

### 问题 3：敏感信息已泄露到远程

**紧急处理**：
1. 立即撤销/更换已泄露的凭证（API Key、密码等）
2. 按照本流程重写历史
3. 强制推送覆盖远程历史
4. 通知协作者重新克隆仓库

## GitHub 限制参考

| 限制类型 | 限制值 | 说明 |
|----------|--------|------|
| 单文件大小 | 100 MB | 硬限制，超过无法推送 |
| 推荐文件大小 | 50 MB | 警告阈值 |
| 仓库总大小 | 无硬性限制 | 但建议 < 5GB |
| LFS 文件 | 2 GB | 使用 Git LFS 时 |

## 安全最佳实践

1. **永远不要在代码中提交**：
   - API 密钥和 Secret
   - 数据库密码
   - JWT 签名密钥
   - 私钥文件

2. **使用模板文件**：
   - `config.example.yaml` - 提交到 git，作为模板
   - `config.yaml` - 本地使用，不提交

3. **分层配置策略**：
   ```
   config.example.yaml  → 提交到 git（模板）
   config.yaml          → 本地开发（不提交）
   .env                 → 环境变量（不提交）
   环境变量             → 生产环境（最高优先级）
   ```

4. **推送前强制检查**：
   ```bash
   # 检查潜在敏感信息
   git diff --cached --name-only | xargs grep -l "password\|secret\|key" 2>/dev/null
   ```

## 相关命令速查

```bash
# 查看文件是否在历史中
git log --all --full-history -- 文件路径

# 查看 .gitignore 是否生效
git check-ignore -v 文件路径

# 查看大文件
git ls-files | xargs -I {} sh -c 'ls -lh "$1" 2>/dev/null | grep -E "^[0-9]+M"' _ {}

# 清理历史（危险操作）
git filter-repo --path 文件路径 --invert-paths --force

# 垃圾回收
git gc --prune=now --aggressive
```
