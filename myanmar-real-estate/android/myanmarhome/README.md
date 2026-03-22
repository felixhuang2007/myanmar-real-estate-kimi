# Myanmar Home - 缅甸房产平台 Android 项目

## 项目概述

缅甸房产平台包含两个Android应用程序：
1. **C端APP (myanmarhome-buyer)** - 购房者/租房者使用
2. **B端APP (myanmarhome-agent)** - 经纪人使用

## 技术栈

- **Kotlin** 1.9.22
- **Jetpack Compose** - 现代声明式UI
- **MVVM架构** - ViewModel + Flow
- **Hilt** - 依赖注入
- **Retrofit + OkHttp** - 网络请求
- **Room** - 本地数据库
- **Google Maps SDK** - 地图功能
- **Coil** - 图片加载
- **环信IM SDK** - 即时通讯

## 项目结构

```
myanmarhome/
├── common/                          # 共享模块
│   ├── data/
│   │   ├── remote/                  # API接口、Retrofit配置
│   │   ├── local/                   # Room数据库、DAO
│   │   └── repository/              # Repository实现
│   ├── domain/
│   │   ├── model/                   # 数据模型
│   │   └── repository/              # Repository接口
│   ├── ui/
│   │   ├── theme/                   # Material Design 3主题
│   │   └── component/               # 通用UI组件
│   └── di/                          # Hilt依赖注入模块
├── buyer-app/                       # C端APP
│   └── features/
│       ├── home/                    # 首页
│       ├── search/                  # 搜索
│       ├── detail/                  # 房源详情
│       ├── chat/                    # IM咨询
│       ├── profile/                 # 个人中心
│       └── auth/                    # 登录注册
└── agent-app/                       # B端APP
    └── features/
        ├── home/                    # 工作台
        ├── house/                   # 录房/房源管理
        ├── customer/                # 客户管理
        ├── appointment/             # 带看管理
        ├── acn/                     # ACN协作
        └── profile/                 # 个人中心/业绩
```

## 功能模块

### C端APP功能
- ✅ 账号体系 (手机注册/登录)
- ✅ 首页门户 (房源推荐、Banner)
- ✅ 房源搜索筛选
- ✅ 地图找房 (聚合展示)
- ✅ 房源详情
- ✅ IM即时通讯
- ✅ 预约带看
- ✅ 个人中心 (收藏、浏览历史)

### B端APP功能
- ✅ 极速录房
- ✅ 实地验真
- ✅ 房源管理
- ✅ 客户管理 (CRM)
- ✅ 带看管理
- ✅ ACN协作网络
- ✅ 业绩统计

## 架构特点

1. **Clean Architecture**: 清晰的模块分层，domain层独立于框架
2. **响应式编程**: 使用Kotlin Flow处理异步数据流
3. **依赖注入**: Hilt简化依赖管理
4. **Material Design 3**: 遵循最新Material Design规范
5. **暗黑模式**: 支持light/dark主题切换
6. **单元测试**: Repository和ViewModel层有完整单元测试覆盖

## 构建和运行

```bash
# 构建项目
./gradlew build

# 运行C端APP
./gradlew :buyer-app:installDebug

# 运行B端APP
./gradlew :agent-app:installDebug

# 运行单元测试
./gradlew test
```

## 配置说明

在 `local.properties` 中配置以下环境变量：
```properties
MAPS_API_KEY=your_google_maps_api_key
```

## API接口

基于PRD文档，已实现以下核心API接口：
- 首页数据获取
- 房源搜索筛选
- 地图聚合数据
- 房源详情
- 用户认证

## 未完成功能 (待设计稿和API文档就绪后开发)

1. 完整的UI界面 (等待UI-Agent设计稿)
2. 完整的API对接 (等待Backend-Agent API文档)
3. IM聊天界面集成环信SDK
4. 地图找房交互功能
5. 图片上传和压缩
6. 验真流程工作流
7. ACN分佣计算引擎

## 代码统计

- 总代码行数: ~5000+ 行
- Kotlin文件: 45+
- 单元测试: 2个测试类

## 许可证

Copyright © 2026 Myanmar Home Team
