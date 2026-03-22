# 缅甸房产平台 - 项目文件清单

> 生成时间: 2026-03-17  
> 总代码行数: ~36,000+ 行  
> 总文件数: 200+ 个

---

## 📋 文档类 (Documentation)

| 文件路径 | 功能说明 |
|----------|----------|
| `AGENTS.md` | AI员工工作规范指南 |
| `BOOTSTRAP.md` | 首次启动引导（项目初始化）|
| `IDENTITY.md` | AI身份定义（Kimi Claw）|
| `SOUL.md` | AI人格设定（守护型中二/老妈子/热血男二）|
| `USER.md` | 用户信息档案（待填充）|
| `TOOLS.md` | 本地工具配置备忘 |
| `MEMORY.md` | 缅甸房产平台项目记忆 |
| `HEARTBEAT.md` | 心跳任务配置（空）|
| `ai-project-checklist.md` | AI项目检查清单 |
| `缅甸房产平台_PRD_产品经理版.md` | 产品需求文档（PRD）|

---

## 🎨 设计文档 (Design)

| 文件路径 | 功能说明 |
|----------|----------|
| `design/01-design-system.md` | 设计系统规范（色彩/字体/组件/布局）|
| `design/02-c端-app-design.md` | C端APP设计（首页/搜索/详情/IM/我的）|
| `design/03-b端-app-design.md` | B端APP设计（工作台/录房/验真/ACN）|
| `design/04-web-admin-design.md` | Web管理后台设计（Dashboard/管理/设置）|
| `design/05-mini-program-design.md` | 微信小程序设计（轻量化版本）|

---

## 📱 Flutter APP (主力移动端 - 11,832行)

### 入口文件
| 文件路径 | 功能说明 |
|----------|----------|
| `flutter/lib/main_buyer.dart` | C端APP入口 |
| `flutter/lib/main_agent.dart` | B端APP入口 |
| `flutter/pubspec.yaml` | Flutter依赖配置 |

### 核心层 (Core)
| 文件路径 | 功能说明 |
|----------|----------|
| `flutter/lib/core/theme/app_colors.dart` | 缅甸金配色系统 |
| `flutter/lib/core/theme/app_theme.dart` | Material主题配置 |
| `flutter/lib/core/router/buyer_router.dart` | C端路由配置（GoRouter）|
| `flutter/lib/core/router/agent_router.dart` | B端路由配置（GoRouter）|
| `flutter/lib/core/api/dio_client.dart` | Dio网络请求封装 |
| `flutter/lib/core/api/user_api.dart` | 用户相关API接口 |
| `flutter/lib/core/api/house_api.dart` | 房源相关API接口 |
| `flutter/lib/core/models/user.dart` | 用户数据模型 |
| `flutter/lib/core/models/house.dart` | 房源数据模型 |
| `flutter/lib/core/models/api_response.dart` | API响应包装模型 |
| `flutter/lib/core/storage/local_storage.dart` | Hive本地存储封装 |
| `flutter/lib/core/utils/app_utils.dart` | 通用工具函数 |
| `flutter/lib/core/constants/app_constants.dart` | 应用常量定义 |

### C端Buyer APP (13个页面)
| 文件路径 | 功能说明 |
|----------|----------|
| `flutter/lib/buyer/presentation/pages/splash_page.dart` | 启动页 |
| `flutter/lib/buyer/presentation/pages/onboarding_page.dart` | 引导页 |
| `flutter/lib/buyer/presentation/pages/login_page.dart` | 登录页（手机验证码）|
| `flutter/lib/buyer/presentation/pages/register_page.dart` | 注册页 |
| `flutter/lib/buyer/presentation/pages/main_page.dart` | 主页面（BottomNav）|
| `flutter/lib/buyer/presentation/pages/home_page.dart` | 首页（推荐流+Banner）|
| `flutter/lib/buyer/presentation/pages/search_page.dart` | 搜索页 |
| `flutter/lib/buyer/presentation/pages/search_result_page.dart` | 搜索结果页（筛选+排序）|
| `flutter/lib/buyer/presentation/pages/map_search_page.dart` | 地图找房页 |
| `flutter/lib/buyer/presentation/pages/map_page.dart` | 地图组件页 |
| `flutter/lib/buyer/presentation/pages/house_detail_page.dart` | 房源详情页 |
| `flutter/lib/buyer/presentation/pages/chat_page.dart` | IM聊天页 |
| `flutter/lib/buyer/presentation/pages/profile_page.dart` | 个人中心页 |
| `flutter/lib/buyer/presentation/widgets/banner_widget.dart` | Banner轮播组件 |
| `flutter/lib/buyer/presentation/widgets/house_card.dart` | 房源卡片组件 |
| `flutter/lib/buyer/providers/auth_provider.dart` | 认证状态管理（Riverpod）|
| `flutter/lib/buyer/providers/house_provider.dart` | 房源状态管理（Riverpod）|

### B端Agent APP (10个页面)
| 文件路径 | 功能说明 |
|----------|----------|
| `flutter/lib/agent/presentation/pages/agent_main_page.dart` | B端主页面 |
| `flutter/lib/agent/presentation/pages/agent_home_page.dart` | 工作台首页 |
| `flutter/lib/agent/presentation/pages/agent_house_add_page.dart` | 房源录入页 |
| `flutter/lib/agent/presentation/pages/agent_house_manage_page.dart` | 房源管理页 |
| `flutter/lib/agent/presentation/pages/verification_task_page.dart` | 验真任务页 |
| `flutter/lib/agent/presentation/pages/client_list_page.dart` | 客户管理页 |
| `flutter/lib/agent/presentation/pages/showing_schedule_page.dart` | 带看管理页 |
| `flutter/lib/agent/presentation/pages/acn_deal_page.dart` | ACN成交申报页 |
| `flutter/lib/agent/presentation/pages/performance_page.dart` | 业绩统计页 |
| `flutter/lib/agent/presentation/pages/agent_profile_page.dart` | 经纪人个人中心 |
| `flutter/lib/agent/presentation/widgets/stat_card.dart` | 统计卡片组件 |
| `flutter/lib/agent/presentation/widgets/quick_action_grid.dart` | 快捷入口网格 |

### 共享组件 (Shared)
| 文件路径 | 功能说明 |
|----------|----------|
| `flutter/lib/shared/widgets/image_picker_widget.dart` | 图片选择组件 |
| `flutter/lib/shared/widgets/refresh_load_more.dart` | 下拉刷新上拉加载 |

---

## 🖥️ 后端服务 (Backend - ~10,000行)

### 数据库
| 文件路径 | 功能说明 |
|----------|----------|
| `backend/01-database-schema.sql` | PostgreSQL建表脚本（35张表）|
| `backend/02-api-spec.md` | RESTful API接口文档（155+接口）|

### 用户服务 (User Service)
| 文件路径 | 功能说明 |
|----------|----------|
| `backend/03-user-service/controller.go` | HTTP控制器（注册/登录/认证）|
| `backend/03-user-service/service.go` | 业务逻辑层 |
| `backend/03-user-service/repository.go` | 数据访问层 |
| `backend/03-user-service/model.go` | 用户数据模型 |
| `backend/03-user-service/jwt_service.go` | JWT Token服务 |

### 房源服务 (House Service)
| 文件路径 | 功能说明 |
|----------|----------|
| `backend/04-house-service/service.go` | 房源CRUD/搜索/地图找房 |
| `backend/04-house-service/repository.go` | 房源数据访问 |
| `backend/04-house-service/model.go` | 房源数据模型 |

### ACN分佣服务 (ACN Service)
| 文件路径 | 功能说明 |
|----------|----------|
| `backend/05-acn-service/service.go` | ACN分佣计算引擎（核心）|
| `backend/05-acn-service/repository.go` | 分佣数据访问 |
| `backend/05-acn-service/model.go` | 分佣/成交模型 |

### 预约服务 (Appointment Service)
| 文件路径 | 功能说明 |
|----------|----------|
| `backend/06-appointment-service/service.go` | 预约带看/日程管理 |
| `backend/06-appointment-service/repository.go` | 预约数据访问 |
| `backend/06-appointment-service/model.go` | 预约模型 |

### IM消息服务 (IM Service)
| 文件路径 | 功能说明 |
|----------|----------|
| `backend/08-im-service/service.go` | IM消息服务 |
| `backend/08-im-service/repository.go` | 消息数据访问 |
| `backend/08-im-service/model.go` | 消息模型 |

### 验真服务 (Verification Service)
| 文件路径 | 功能说明 |
|----------|----------|
| `backend/09-verification-service/service.go` | 房源验真流程 |
| `backend/09-verification-service/repository.go` | 验真数据访问 |
| `backend/09-verification-service/model.go` | 验真模型 |

### 公共库 (Common)
| 文件路径 | 功能说明 |
|----------|----------|
| `backend/07-common/config.go` | 配置管理 |
| `backend/07-common/database.go` | 数据库连接 |
| `backend/07-common/logger.go` | 日志工具 |
| `backend/07-common/errors.go` | 错误定义 |
| `backend/07-common/response.go` | 统一响应格式 |

### 其他服务
| 文件路径 | 功能说明 |
|----------|----------|
| `backend/10-utils/utils.go` | 通用工具函数 |
| `backend/11-upload-service/service.go` | 文件上传服务 |
| `backend/cmd/server/main.go` | 服务入口 |
| `backend/config.yaml` | 应用配置 |
| `backend/docker-compose.yml` | 本地开发编排 |

---

## 🌐 前端 (Frontend - 5,233行)

### Web管理后台 (React + TypeScript)
| 文件路径 | 功能说明 |
|----------|----------|
| `frontend/web-admin/config/config.ts` | Umi配置（路由/代理）|
| `frontend/web-admin/src/app.tsx` | 应用入口 |
| `frontend/web-admin/src/components/AuthGuard/index.tsx` | 登录权限守卫 |
| `frontend/web-admin/src/components/AccessGuard/index.tsx` | 角色权限守卫 |
| `frontend/web-admin/src/pages/Login/index.tsx` | 登录页 |
| `frontend/web-admin/src/pages/Dashboard/index.tsx` | 数据大屏首页 |
| `frontend/web-admin/src/pages/Houses/List/index.tsx` | 房源列表 |
| `frontend/web-admin/src/pages/Houses/Audit/index.tsx` | 房源审核 |
| `frontend/web-admin/src/pages/Houses/Verification/index.tsx` | 验真管理 |
| `frontend/web-admin/src/pages/Users/CEnd/index.tsx` | C端用户管理 |
| `frontend/web-admin/src/pages/Users/Agents/index.tsx` | 经纪人管理 |
| `frontend/web-admin/src/pages/Agents/List/index.tsx` | 经纪人列表 |
| `frontend/web-admin/src/pages/Agents/ACN/index.tsx` | ACN协作管理 |
| `frontend/web-admin/src/pages/Agents/Performance/index.tsx` | 业绩统计 |
| `frontend/web-admin/src/pages/Finance/Commission/index.tsx` | 佣金结算 |
| `frontend/web-admin/src/pages/Finance/Withdrawal/index.tsx` | 提现审核 |
| `frontend/web-admin/src/pages/Finance/Reports/index.tsx` | 财务报表 |
| `frontend/web-admin/src/pages/Operations/Banners/index.tsx` | Banner管理 |
| `frontend/web-admin/src/pages/Operations/Content/index.tsx` | 内容管理 |
| `frontend/web-admin/src/pages/Settings/General/index.tsx` | 系统设置 |
| `frontend/web-admin/src/pages/Settings/Roles/index.tsx` | 角色权限 |
| `frontend/web-admin/src/pages/Settings/CommissionRules/index.tsx` | 分佣规则 |
| `frontend/web-admin/src/services/request.ts` | HTTP请求封装 |
| `frontend/web-admin/src/services/user.ts` | 用户API服务 |
| `frontend/web-admin/src/services/house.ts` | 房源API服务 |
| `frontend/web-admin/src/services/dashboard.ts` | 仪表盘API服务 |
| `frontend/web-admin/src/services/index.ts` | 服务导出 |
| `frontend/web-admin/src/stores/auth.ts` | 认证状态（Zustand）|
| `frontend/web-admin/src/stores/index.ts` | Store导出 |
| `frontend/web-admin/src/types/index.ts` | TypeScript类型定义 |
| `frontend/web-admin/src/utils/index.ts` | 工具函数 |

### 微信小程序 (Mini Program)
| 文件路径 | 功能说明 |
|----------|----------|
| `frontend/mini-program/app.json` | 小程序全局配置 |
| `frontend/mini-program/app.ts` | 应用入口 |
| `frontend/mini-program/pages/index/index.ts` | 首页 |
| `frontend/mini-program/pages/login/login.ts` | 登录页 |
| `frontend/mini-program/pages/search/search.ts` | 搜索页 |
| `frontend/mini-program/services/request.ts` | HTTP请求封装 |
| `frontend/mini-program/services/user.ts` | 用户服务 |
| `frontend/mini-program/services/house.ts` | 房源服务 |
| `frontend/mini-program/services/appointment.ts` | 预约服务 |
| `frontend/mini-program/services/index.ts` | 服务导出 |
| `frontend/mini-program/stores/user.ts` | 用户状态 |
| `frontend/mini-program/stores/system.ts` | 系统状态 |
| `frontend/mini-program/stores/index.ts` | Store导出 |
| `frontend/mini-program/types/user.ts` | 用户类型定义 |
| `frontend/mini-program/types/house.ts` | 房源类型定义 |
| `frontend/mini-program/types/agent.ts` | 经纪人类型定义 |
| `frontend/mini-program/types/appointment.ts` | 预约类型定义 |
| `frontend/mini-program/types/im.ts` | IM类型定义 |
| `frontend/mini-program/types/app.ts` | 应用类型定义 |
| `frontend/mini-program/types/index.ts` | 类型导出 |
| `frontend/mini-program/utils/storage.ts` | 存储工具 |
| `frontend/mini-program/utils/index.ts` | 工具导出 |

---

## 🍎 iOS原生 (Swift - 7,427行 - 备选方案)

| 文件路径 | 功能说明 |
|----------|----------|
| `ios/MyanmarHome/BuyerApp/MyanmarHomeBuyerApp.swift` | C端APP入口（SwiftUI）|
| `ios/MyanmarHome/BuyerApp/Features/Home/HomeViews.swift` | 首页/搜索/详情UI |
| `ios/MyanmarHome/BuyerApp/ViewModels/BuyerViewModels.swift` | C端视图模型 |
| `ios/MyanmarHome/AgentApp/MyanmarHomeAgentApp.swift` | B端APP入口 |
| `ios/MyanmarHome/AgentApp/ViewModels/AgentViewModels.swift` | B端视图模型 |
| `ios/MyanmarHome/Common/Models/Models.swift` | 数据模型（User/House/Appointment）|
| `ios/MyanmarHome/Common/Network/APIEndpoint.swift` | API端点定义 |
| `ios/MyanmarHome/Common/Network/NetworkManager.swift` | 网络管理器（Alamofire+Combine）|
| `ios/MyanmarHome/Common/Network/Services.swift` | 业务服务层 |
| `ios/MyanmarHome/Common/UIComponents/CommonViews.swift` | 通用UI组件 |
| `ios/MyanmarHome/Common/Utils/Extensions.swift` | Swift扩展工具 |
| `ios/MyanmarHome/Tests/NetworkTests/NetworkTests.swift` | 网络层单元测试 |
| `ios/MyanmarHome/Tests/ViewModelTests/ViewModelTests.swift` | ViewModel单元测试 |
| `ios/MyanmarHome/Package.swift` | SPM依赖配置 |

---

## 🤖 Android原生 (Kotlin - 3,950行 - 备选方案)

### 共享模块 (Common)
| 文件路径 | 功能说明 |
|----------|----------|
| `android/myanmarhome/common/ui/theme/Theme.kt` | Material Design 3主题 |
| `android/myanmarhome/common/ui/theme/Type.kt` | 字体配置 |
| `android/myanmarhome/common/ui/component/Button.kt` | 按钮组件 |
| `android/myanmarhome/common/ui/component/TextField.kt` | 输入框组件 |
| `android/myanmarhome/common/ui/component/Loading.kt` | 加载组件 |
| `android/myanmarhome/common/ui/component/Error.kt` | 错误组件 |
| `android/myanmarhome/common/ui/component/Image.kt` | 图片组件 |
| `android/myanmarhome/common/data/remote/api/HouseApi.kt` | 房源API接口（Retrofit）|
| `android/myanmarhome/common/data/remote/api/ApiResponse.kt` | API响应包装 |
| `android/myanmarhome/common/data/remote/interceptor/AuthInterceptor.kt` | 认证拦截器 |
| `android/myanmarhome/common/data/local/database/AppDatabase.kt` | Room数据库 |
| `android/myanmarhome/common/data/local/database/Converters.kt` | 类型转换器 |
| `android/myanmarhome/common/data/local/entity/LocalEntities.kt` | 本地实体 |
| `android/myanmarhome/common/data/local/dao/HouseDao.kt` | 房源DAO |
| `android/myanmarhome/common/data/repository/HouseRepositoryImpl.kt` | 房源仓库实现 |
| `android/myanmarhome/common/domain/model/House.kt` | 房源领域模型 |
| `android/myanmarhome/common/domain/model/User.kt` | 用户领域模型 |
| `android/myanmarhome/common/domain/model/Home.kt` | 首页领域模型 |
| `android/myanmarhome/common/domain/model/ACN.kt` | ACN领域模型 |
| `android/myanmarhome/common/domain/model/Communication.kt` | 通讯领域模型 |
| `android/myanmarhome/common/domain/repository/HouseRepository.kt` | 房源仓库接口 |
| `android/myanmarhome/common/domain/repository/AuthRepository.kt` | 认证仓库接口 |
| `android/myanmarhome/common/domain/repository/ChatRepository.kt` | 聊天仓库接口 |
| `android/myanmarhome/common/domain/repository/AppointmentRepository.kt` | 预约仓库接口 |
| `android/myanmarhome/common/di/AppModule.kt` | Hilt应用模块 |
| `android/myanmarhome/common/di/RepositoryModule.kt` | Hilt仓库模块 |
| `android/myanmarhome/common/utils/ResultState.kt` | 结果状态封装 |
| `android/myanmarhome/common/utils/Utils.kt` | 通用工具函数 |

### C端Buyer APP
| 文件路径 | 功能说明 |
|----------|----------|
| `android/myanmarhome/buyer-app/MainActivity.kt` | 主Activity |
| `android/myanmarhome/buyer-app/BuyerApplication.kt` | 应用类 |
| `android/myanmarhome/buyer-app/navigation/BuyerNavigation.kt` | 导航配置 |
| `android/myanmarhome/buyer-app/features/home/HomeScreen.kt` | 首页 |
| `android/myanmarhome/buyer-app/features/home/HomeViewModel.kt` | 首页ViewModel |
| `android/myanmarhome/buyer-app/features/search/SearchScreen.kt` | 搜索页 |
| `android/myanmarhome/buyer-app/features/auth/LoginScreen.kt` | 登录页 |
| `android/myanmarhome/buyer-app/features/profile/ProfileScreen.kt` | 个人中心 |

### B端Agent APP
| 文件路径 | 功能说明 |
|----------|----------|
| `android/myanmarhome/agent-app/MainActivity.kt` | 主Activity |
| `android/myanmarhome/agent-app/AgentApplication.kt` | 应用类 |
| `android/myanmarhome/agent-app/navigation/AgentNavigation.kt` | 导航配置 |
| `android/myanmarhome/agent-app/features/home/AgentHomeScreen.kt` | 工作台首页 |
| `android/myanmarhome/agent-app/features/house/AddHouseScreen.kt` | 房源录入 |
| `android/myanmarhome/agent-app/features/house/HouseManageScreen.kt` | 房源管理 |
| `android/myanmarhome/agent-app/features/profile/AgentProfileScreen.kt` | 个人中心 |

### 构建配置
| 文件路径 | 功能说明 |
|----------|----------|
| `android/myanmarhome/buildSrc/src/main/kotlin/Dependencies.kt` | 依赖版本管理 |

---

## 🚀 DevOps (3,000+行)

### CI/CD流水线
| 文件路径 | 功能说明 |
|----------|----------|
| `devops/ci-cd/backend-ci.yml` | 后端GitHub Actions CI/CD |
| `devops/ci-cd/frontend-web-ci.yml` | Web前端CI/CD |
| `devops/ci-cd/mobile-ci.yml` | 移动端CI/CD |
| `devops/ci-cd/.gitlab-ci.yml` | GitLab CI配置 |

### Docker编排
| 文件路径 | 功能说明 |
|----------|----------|
| `devops/docker/docker-compose.yml` | 本地开发环境（12服务）|
| `devops/docker/docker-compose.prod.yml` | 生产环境编排 |
| `devops/docker/nginx/nginx.dev.conf` | 开发环境Nginx配置 |
| `devops/docker/nginx/nginx.prod.conf` | 生产环境Nginx配置 |

### 监控告警
| 文件路径 | 功能说明 |
|----------|----------|
| `devops/docker/monitoring/prometheus.yml` | Prometheus开发配置 |
| `devops/docker/monitoring/prometheus.prod.yml` | Prometheus生产配置 |
| `devops/docker/monitoring/alert_rules.yml` | 告警规则定义 |
| `devops/docker/monitoring/grafana/datasources/datasources.yml` | Grafana数据源 |
| `devops/docker/monitoring/grafana/dashboards/dashboard.json` | 缅甸房产平台监控面板 |

### 部署文档
| 文件路径 | 功能说明 |
|----------|----------|
| `devops/deployment/DEPLOYMENT_GUIDE.md` | 完整部署指南 |
| `devops/deployment/.env.example` | 环境变量模板（40+项）|
| `devops/CONFIGURATION_GUIDE.md` | 配置详细说明 |
| `devops/README.md` | DevOps使用说明 |

---

## 🧪 QA测试 (195条用例)

### 测试用例
| 文件路径 | 功能说明 |
|----------|----------|
| `qa/test-cases/functional/c-app.yml` | C端APP功能测试（63条）|
| `qa/test-cases/functional/b-app.yml` | B端APP功能测试（50条）|
| `qa/test-cases/functional/admin.yml` | 管理后台测试（45条）|
| `qa/test-cases/api/api-tests.yml` | API接口测试（47条）|
| `qa/test-cases/compatibility/compatibility.yml` | 兼容性测试（13条）|
| `qa/test-cases/statistics.md` | 用例统计报告 |

### 代码Review
| 文件路径 | 功能说明 |
|----------|----------|
| `qa/code-review/template.md` | 代码Review模板 |
| `qa/code-review/execution-guide.md` | Review执行指南 |

### Bug追踪
| 文件路径 | 功能说明 |
|----------|----------|
| `qa/bug-reports/template.md` | Bug报告模板 |

### 其他
| 文件路径 | 功能说明 |
|----------|----------|
| `qa/execution-plan.md` | 测试执行计划 |
| `qa/README.md` | QA文档说明 |

---

## 📊 项目管理

### 计划文档
| 文件路径 | 功能说明 |
|----------|----------|
| `project-management/plans/项目主计划.md` | 8周项目主计划 |
| `project-management/plans/项目启动清单.md` | 启动前检查清单 |
| `project-management/plans/风险登记册.md` | 项目风险管理 |

### AI员工任务书
| 文件路径 | 功能说明 |
|----------|----------|
| `project-management/agents/AGENT-001-架构师任务书.md` | 架构师职责 |
| `project-management/agents/AGENT-002-后端工程师任务书.md` | 后端工程师职责 |
| `project-management/agents/AGENT-003-C端APP开发工程师任务书.md` | C端开发职责 |
| `project-management/agents/AGENT-004-B端APP开发工程师任务书.md` | B端开发职责 |
| `project-management/agents/AGENT-005-前端工程师任务书.md` | 前端工程师职责 |
| `project-management/agents/AGENT-006-数据库工程师任务书.md` | 数据库工程师职责 |
| `project-management/agents/AGENT-007-测试工程师任务书.md` | 测试工程师职责 |
| `project-management/agents/AGENT-008-DevOps工程师任务书.md` | DevOps工程师职责 |

### 日报
| 文件路径 | 功能说明 |
|----------|----------|
| `project-management/reports/日报_2026-03-17_04.md` | 04:27进度报告 |
| `project-management/reports/日报_2026-03-17_08.md` | 08:27进度报告 |
| `project-management/reports/日报模板.md` | 日报格式模板 |

### 其他
| 文件路径 | 功能说明 |
|----------|----------|
| `project-management/Agent启动命令参考.md` | Agent启动命令 |
| `project-management/README.md` | 项目管理说明 |

---

## 📝 记忆文件

| 文件路径 | 功能说明 |
|----------|----------|
| `memory/2026-03-17.md` | 项目启动日记录 |

---

## 统计汇总

| 模块 | 语言 | 代码行数 | 文件数 |
|------|------|----------|--------|
| Flutter APP | Dart | 11,832 | 46 |
| 后端服务 | Go | ~10,000 | 36 |
| Web后台 | TSX/TS | ~3,500 | 35 |
| 小程序 | TS | ~1,700 | 30 |
| iOS原生 | Swift | 7,427 | 14 |
| Android原生 | Kotlin | 3,950 | 45 |
| DevOps | YAML/Shell | 3,000+ | 20+ |
| QA测试 | YAML/Markdown | - | 11 |
| **总计** | - | **~41,409+** | **200+** |

---

*文件清单生成时间: 2026-03-17*  
*项目: 缅甸房产平台 - AI员工8小时冲刺成果*
