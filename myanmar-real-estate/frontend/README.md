# 缅甸房产平台 - 前端项目

## 项目结构

```
frontend/
├── mini-program/          # 微信小程序
└── web-admin/            # Web管理后台
```

## 微信小程序 (myanmarhome-mini)

### 技术栈
- 微信原生小程序
- TypeScript
- 组件化开发

### 目录结构
```
mini-program/
├── app.json              # 小程序配置
├── app.ts                # 应用入口
├── app.wxss              # 全局样式
├── pages/                # 页面
│   ├── index/           # 首页
│   ├── search/          # 搜索
│   ├── map/             # 地图找房
│   ├── detail/          # 房源详情
│   ├── login/           # 登录
│   ├── profile/         # 个人中心
│   └── agent-center/    # 经纪人工作台
├── components/          # 公共组件
├── services/            # API服务
├── stores/              # 状态管理
├── types/               # TypeScript类型
└── utils/               # 工具函数
```

### 主要功能模块
1. **首页** - 房源推荐、Banner、快捷入口
2. **搜索** - 多维度筛选、关键词搜索
3. **地图找房** - LBS定位、聚合展示
4. **房源详情** - 信息展示、验真标识、IM咨询入口
5. **登录** - 手机号验证码登录
6. **个人中心** - 我的收藏、预约记录
7. **经纪人工作台** - 房源管理、客户管理、业绩统计

## Web管理后台 (myanmarhome-admin)

### 技术栈
- React 18
- TypeScript
- Ant Design Pro 5
- UmiJS 4
- Zustand (状态管理)
- Recharts (图表)

### 目录结构
```
web-admin/
├── config/
│   └── config.ts        # Umi配置
├── src/
│   ├── pages/           # 页面
│   │   ├── Dashboard/   # 数据大屏
│   │   ├── Houses/      # 房源管理
│   │   ├── Users/       # 用户管理
│   │   ├── Agents/      # 经纪人管理
│   │   ├── Finance/     # 财务结算
│   │   ├── Operations/  # 运营管理
│   │   ├── Settings/    # 系统设置
│   │   └── Login/       # 登录页
│   ├── components/      # 公共组件
│   ├── services/        # API服务
│   ├── stores/          # 状态管理
│   ├── types/           # TypeScript类型
│   └── utils/           # 工具函数
└── package.json
```

### 主要功能模块

#### 1. 数据大屏
- 核心指标卡片（用户数、房源数、成交量、GMV）
- 趋势图表（用户增长、房源增长、交易趋势）
- 经纪人统计

#### 2. 房源管理
- 房源列表 - 查看、筛选、上下架、删除
- 房源审核 - 审核待上架房源
- 验真管理 - 验真任务管理

#### 3. 用户管理
- C端用户列表
- 经纪人列表

#### 4. 经纪人管理
- 经纪人列表
- 业绩统计
- ACN协作管理

#### 5. 财务结算
- 佣金结算
- 提现审核
- 财务报表

#### 6. 运营管理
- Banner管理
- 内容管理

#### 7. 系统设置
- 基础配置
- 分佣规则配置
- 权限管理（RBAC）

## 开发环境

### 小程序
```bash
cd mini-program
# 使用微信开发者工具打开
```

### Web管理后台
```bash
cd web-admin
npm install
npm run dev
```

## 环境变量

### 小程序
- 开发环境: `https://dev-api.myanmarhome.com`
- 生产环境: `https://api.myanmarhome.com`

### Web管理后台
- 开发环境: 配置在 `config/config.ts` 中的 proxy
- 生产环境: 根据部署环境配置

## 响应式布局

Web管理后台支持响应式布局，适配：
- PC端（≥1280px）
- 平板端（768px - 1279px）
- 小屏设备（<768px）

## 权限控制（RBAC）

基于角色的访问控制：
- 超级管理员（super_admin）- 所有权限
- 运营人员（operator）- 运营相关权限
- 财务人员（finance）- 财务相关权限
- 客服人员（customer_service）- 客服相关权限
