# ============================================
# 缅甸房产平台 - Makefile
# 常用命令快捷方式
# ============================================

.PHONY: help install dev build test lint clean deploy

# 默认目标
.DEFAULT_GOAL := help

# 颜色定义
BLUE := \033[36m
GREEN := \033[32m
YELLOW := \033[33m
RED := \033[31m
RESET := \033[0m

# ============================================
# 帮助信息
# ============================================
help: ## 显示帮助信息
	@echo "$(BLUE)缅甸房产平台 - 开发命令$(RESET)"
	@echo ""
	@echo "$(GREEN)使用方法:$(RESET)"
	@echo "  make $(YELLOW)<命令>$(RESET)"
	@echo ""
	@echo "$(GREEN)可用命令:$(RESET)"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  $(YELLOW)%-20s$(RESET) %s\n", $$1, $$2}' $(MAKEFILE_LIST)

# ============================================
# 开发环境
# ============================================
install: ## 安装所有依赖
	@echo "$(BLUE)安装后端依赖...$(RESET)"
	cd backend && npm install
	@echo "$(BLUE)安装前端依赖...$(RESET)"
	cd frontend-web && npm install
	@echo "$(BLUE)安装移动端依赖...$(RESET)"
	cd mobile && flutter pub get
	@echo "$(GREEN)✓ 依赖安装完成$(RESET)"

dev: ## 启动开发环境 (Docker Compose)
	@echo "$(BLUE)启动开发环境...$(RESET)"
	cd devops/docker && docker-compose up -d
	@echo "$(GREEN)✓ 开发环境已启动$(RESET)"
	@echo "  - API: http://localhost:3000"
	@echo "  - Web: http://localhost:5173"
	@echo "  - Admin: http://localhost:5174"
	@echo "  - PostgreSQL: localhost:5432"
	@echo "  - Redis: localhost:6379"
	@echo "  - MinIO: http://localhost:9000"
	@echo "  - Grafana: http://localhost:3001"
	@echo "  - Prometheus: http://localhost:9090"

dev-stop: ## 停止开发环境
	@echo "$(BLUE)停止开发环境...$(RESET)"
	cd devops/docker && docker-compose down
	@echo "$(GREEN)✓ 开发环境已停止$(RESET)"

dev-logs: ## 查看开发环境日志
	cd devops/docker && docker-compose logs -f

dev-clean: ## 清理开发环境 (删除容器和卷)
	@echo "$(RED)⚠️  这将删除所有数据!$(RESET)"
	@read -p "确定继续? [y/N] " confirm && [ $$confirm = y ] && \
		cd devops/docker && docker-compose down -v --remove-orphans && \
		docker system prune -f && \
		echo "$(GREEN)✓ 清理完成$(RESET)" || \
		echo "$(YELLOW)已取消$(RESET)"

# ============================================
# 后端命令
# ============================================
backend-dev: ## 启动后端开发服务器
	cd backend && npm run dev

backend-build: ## 构建后端
	cd backend && npm run build

backend-test: ## 运行后端测试
	cd backend && npm run test

backend-test-coverage: ## 运行后端测试并生成覆盖率报告
	cd backend && npm run test:cov

backend-lint: ## 运行后端代码检查
	cd backend && npm run lint

backend-lint-fix: ## 修复后端代码格式问题
	cd backend && npm run lint:fix

backend-migration-generate: ## 生成数据库迁移
	cd backend && npm run migration:generate -- -n $(name)

backend-migration-run: ## 执行数据库迁移
	cd backend && npm run migration:run

backend-migration-revert: ## 回滚数据库迁移
	cd backend && npm run migration:revert

# ============================================
# 前端命令
# ============================================
frontend-dev: ## 启动前端开发服务器
	cd frontend-web && npm run dev

frontend-build: ## 构建前端
	cd frontend-web && npm run build

frontend-build-dev: ## 构建前端 (开发环境)
	cd frontend-web && npm run build:dev

frontend-test: ## 运行前端测试
	cd frontend-web && npm run test

frontend-lint: ## 运行前端代码检查
	cd frontend-web && npm run lint

admin-dev: ## 启动管理后台开发服务器
	cd admin-web && npm run dev

admin-build: ## 构建管理后台
	cd admin-web && npm run build

# ============================================
# 移动端命令
# ============================================
mobile-dev: ## 启动移动端开发
	cd mobile && flutter run

mobile-build-android: ## 构建 Android APK (调试)
	cd mobile && flutter build apk --debug

mobile-build-android-release: ## 构建 Android AAB (发布)
	cd mobile && flutter build appbundle --release

mobile-build-ios: ## 构建 iOS (需要 macOS)
	cd mobile && flutter build ios --release

mobile-test: ## 运行移动端测试
	cd mobile && flutter test

mobile-clean: ## 清理移动端构建
	cd mobile && flutter clean && flutter pub get

# ============================================
# Docker 命令
# ============================================
docker-build-backend: ## 构建后端 Docker 镜像
	cd backend && docker build -t myanmarestate/backend:latest -f ../devops/docker/Dockerfile.backend .

docker-build-frontend: ## 构建前端 Docker 镜像
	cd frontend-web && docker build -t myanmarestate/frontend-web:latest -f ../devops/docker/Dockerfile.frontend-web .

docker-push: ## 推送 Docker 镜像到仓库
	docker push myanmarestate/backend:latest
	docker push myanmarestate/frontend-web:latest

# ============================================
# 部署命令
# ============================================
deploy-dev: ## 部署到开发环境
	@echo "$(BLUE)部署到开发环境...$(RESET)"
	ssh $(DEV_SERVER) "cd /opt/myanmarestate && git pull && docker-compose up -d"
	@echo "$(GREEN)✓ 开发环境部署完成$(RESET)"

deploy-prod: ## 部署到生产环境 (需要确认)
	@echo "$(RED)⚠️  即将部署到生产环境!$(RESET)"
	@read -p "确定继续? [y/N] " confirm && [ $$confirm = y ] && \
		ssh $(PROD_SERVER) "cd /opt/myanmarestate && git pull && docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d" && \
		echo "$(GREEN)✓ 生产环境部署完成$(RESET)" || \
		echo "$(YELLOW)已取消$(RESET)"

# ============================================
# 数据库命令
# ============================================
db-backup: ## 备份数据库
	@echo "$(BLUE)备份数据库...$(RESET)"
	@mkdir -p backups
	cd devops/docker && docker-compose exec -T postgres pg_dump -U postgres myanmarestate | gzip > ../../backups/db_$$(date +%Y%m%d_%H%M%S).sql.gz
	@echo "$(GREEN)✓ 备份完成$(RESET)"

db-restore: ## 恢复数据库 (使用最新的备份)
	@echo "$(BLUE)恢复数据库...$(RESET)"
	@LATEST_BACKUP=$$(ls -t backups/db_*.sql.gz | head -1); \
	if [ -z "$$LATEST_BACKUP" ]; then \
		echo "$(RED)✗ 未找到备份文件$(RESET)"; \
	else \
		gunzip < $$LATEST_BACKUP | cd devops/docker && docker-compose exec -T postgres psql -U postgres -d myanmarestate; \
		echo "$(GREEN)✓ 恢复完成: $$LATEST_BACKUP$(RESET)"; \
	fi

db-reset: ## 重置数据库 (谨慎使用!)
	@echo "$(RED)⚠️  这将删除所有数据!$(RESET)"
	@read -p "确定继续? [y/N] " confirm && [ $$confirm = y ] && \
		cd devops/docker && \
		docker-compose down && \
		docker volume rm docker_postgres_data && \
		docker-compose up -d postgres && \
		echo "$(GREEN)✓ 数据库已重置$(RESET)" || \
		echo "$(YELLOW)已取消$(RESET)"

# ============================================
# 测试命令
# ============================================
test: ## 运行所有测试
	@echo "$(BLUE)运行后端测试...$(RESET)"
	cd backend && npm run test
	@echo "$(BLUE)运行前端测试...$(RESET)"
	cd frontend-web && npm run test
	@echo "$(BLUE)运行移动端测试...$(RESET)"
	cd mobile && flutter test
	@echo "$(GREEN)✓ 所有测试完成$(RESET)"

test-e2e: ## 运行端到端测试
	@echo "$(BLUE)运行 E2E 测试...$(RESET)"
	cd backend && npm run test:e2e

# ============================================
# 代码质量
# ============================================
lint: ## 运行所有代码检查
	@echo "$(BLUE)检查后端代码...$(RESET)"
	cd backend && npm run lint
	@echo "$(BLUE)检查前端代码...$(RESET)"
	cd frontend-web && npm run lint
	@echo "$(GREEN)✓ 代码检查完成$(RESET)"

format: ## 格式化所有代码
	@echo "$(BLUE)格式化后端代码...$(RESET)"
	cd backend && npm run format
	@echo "$(BLUE)格式化前端代码...$(RESET)"
	cd frontend-web && npm run format
	@echo "$(GREEN)✓ 代码格式化完成$(RESET)"

# ============================================
# 清理命令
# ============================================
clean: ## 清理构建产物
	@echo "$(BLUE)清理构建产物...$(RESET)"
	cd backend && rm -rf dist node_modules coverage
	cd frontend-web && rm -rf dist node_modules coverage
	cd mobile && flutter clean
	docker system prune -f
	@echo "$(GREEN)✓ 清理完成$(RESET)"

# ============================================
# Git 快捷命令
# ============================================
git-status: ## 查看所有仓库状态
	@echo "$(BLUE)后端状态:$(RESET)"
	cd backend && git status -sb
	@echo "$(BLUE)前端状态:$(RESET)"
	cd frontend-web && git status -sb
	@echo "$(BLUE)移动端状态:$(RESET)"
	cd mobile && git status -sb

# ============================================
# 文档命令
# ============================================
docs-serve: ## 本地启动文档服务器
	@echo "$(BLUE)启动文档服务器...$(RESET)"
	cd docs && python3 -m http.server 8080
	@echo "文档地址: http://localhost:8080"
