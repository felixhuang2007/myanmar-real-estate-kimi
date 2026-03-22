# AGENT-005 任务书 - 前端工程师

> **角色**: Web前端工程师 (Vue3)  
> **代号**: AGENT-005  
> **项目**: 缅甸房产平台  
> **周期**: 8周  
> **汇报对象**: AI项目经理

---

## 一、角色职责

1. **Web后台开发**: 开发Vue3管理后台
2. **用户管理**: 实现C端/B端用户管理功能
3. **房源审核**: 实现房源审核、验真审核功能
4. **运营配置**: 实现Banner、内容管理等运营功能
5. **数据看板**: 实现BI数据可视化看板
6. **权限管理**: 实现RBAC权限管理系统

---

## 二、任务清单

### Week 1: 环境搭建与基础架构

| 任务ID | 任务描述 | 交付物 | 截止时间 | 优先级 |
|--------|----------|--------|----------|--------|
| F005-001 | Node.js环境搭建 | 开发环境 | Day 1 | P0 |
| F005-002 | Vue3项目初始化(Vite) | 代码框架 | Day 2 | P0 |
| F005-003 | Element Plus集成 | UI组件库 | Day 3 | P0 |
| F005-004 | 路由配置(Vue Router) | 路由系统 | Day 4 | P0 |
| F005-005 | 状态管理(Pinia) | Store架构 | Day 5 | P0 |
| F005-006 | Axios封装 | HTTP客户端 | Day 5 | P0 |

### Week 2: 登录与基础布局

| 任务ID | 任务描述 | 交付物 | 截止时间 | 优先级 |
|--------|----------|--------|----------|--------|
| F005-007 | 登录页面 | LoginPage | Day 7 | P0 |
| F005-008 | 主布局框架 | Layout组件 | Day 8 | P0 |
| F005-009 | 侧边栏菜单 | Sidebar组件 | Day 9 | P0 |
| F005-010 | 顶部导航栏 | Header组件 | Day 10 | P0 |
| F005-011 | 面包屑导航 | Breadcrumb组件 | Day 10 | P0 |
| F005-012 | 权限守卫 | Permission Guard | Day 11 | P0 |
| F005-013 | 标签页导航 | TabNavigation | Day 12 | P1 |

### Week 3: 用户管理模块

| 任务ID | 任务描述 | 交付物 | 截止时间 | 优先级 |
|--------|----------|--------|----------|--------|
| F005-014 | C端用户列表 | UserListPage | Day 14 | P0 |
| F005-015 | 用户详情页面 | UserDetailPage | Day 15 | P0 |
| F005-016 | 用户搜索筛选 | UserSearch | Day 16 | P0 |
| F005-017 | B端经纪人列表 | AgentListPage | Day 17 | P0 |
| F005-018 | 经纪人审核 | AgentAuditPage | Day 18 | P0 |
| F005-019 | 经纪人详情 | AgentDetailPage | Day 19 | P0 |

### Week 4: 房源管理模块

| 任务ID | 任务描述 | 交付物 | 截止时间 | 优先级 |
|--------|----------|--------|----------|--------|
| F005-020 | 房源列表页面 | HouseListPage | Day 21 | P0 |
| F005-021 | 房源搜索筛选 | HouseSearch | Day 22 | P0 |
| F005-022 | 房源详情页面 | HouseDetailPage | Day 23 | P0 |
| F005-023 | 房源审核页面 | HouseAuditPage | Day 24 | P0 |
| F005-024 | 批量操作功能 | BatchActions | Day 25 | P0 |
| F005-025 | 房源上下架 | HouseStatusManage | Day 26 | P0 |

### Week 5: 验真与预约管理

| 任务ID | 任务描述 | 交付物 | 截止时间 | 优先级 |
|--------|----------|--------|----------|--------|
| F005-026 | 验真任务列表 | VerificationListPage | Day 28 | P0 |
| F005-027 | 验真详情审核 | VerificationAuditPage | Day 29 | P0 |
| F005-028 | 验真员管理 | VerifierManagePage | Day 30 | P0 |
| F005-029 | 预约订单列表 | AppointmentListPage | Day 31 | P0 |
| F005-030 | 预约详情页面 | AppointmentDetailPage | Day 32 | P0 |
| F005-031 | 带看统计 | ShowingStatsPage | Day 33 | P0 |

### Week 6: 运营配置模块

| 任务ID | 任务描述 | 交付物 | 截止时间 | 优先级 |
|--------|----------|--------|----------|--------|
| F005-032 | Banner管理 | BannerManagePage | Day 35 | P0 |
| F005-033 | Banner编辑 | BannerEditPage | Day 36 | P0 |
| F005-034 | 内容管理(CMS) | ContentManagePage | Day 37 | P0 |
| F005-035 | 帮助中心配置 | HelpConfigPage | Day 38 | P0 |
| F005-036 | 系统配置 | SystemConfigPage | Day 39 | P0 |
| F005-037 | 分佣规则配置 | CommissionRulePage | Day 40 | P0 |
| F005-038 | 城市区域配置 | CityConfigPage | Day 41 | P0 |

### Week 7: 数据BI与ACN

| 任务ID | 任务描述 | 交付物 | 截止时间 | 优先级 |
|--------|----------|--------|----------|--------|
| F005-039 | 数据看板首页 | DashboardPage | Day 43 | P0 |
| F005-040 | 用户数据图表 | UserStatsCharts | Day 44 | P0 |
| F005-041 | 房源数据图表 | HouseStatsCharts | Day 45 | P0 |
| F005-042 | 交易数据图表 | DealStatsCharts | Day 46 | P0 |
| F005-043 | 经纪人效能分析 | AgentStatsCharts | Day 47 | P0 |
| F005-044 | ACN成交列表 | ACNDealListPage | Day 48 | P0 |
| F005-045 | 分佣结算管理 | CommissionSettlePage | Day 49 | P0 |
| F005-046 | 提现审核 | WithdrawalAuditPage | Day 50 | P0 |
| F005-047 | 地推数据 | GroundStatsPage | Day 51 | P0 |
| F005-048 | 地推人员管理 | GroundPromoterPage | Day 52 | P0 |

### Week 8: 权限管理与交付

| 任务ID | 任务描述 | 交付物 | 截止时间 | 优先级 |
|--------|----------|--------|----------|--------|
| F005-049 | 角色管理 | RoleManagePage | Day 54 | P0 |
| F005-050 | 菜单权限配置 | MenuPermissionPage | Day 55 | P0 |
| F005-051 | 操作日志 | OperationLogPage | Day 56 | P0 |
| F005-052 | 登录日志 | LoginLogPage | Day 57 | P0 |
| F005-053 | 报表导出功能 | ExportFunction | Day 58 | P0 |
| F005-054 | 页面优化 | 优化代码 | Day 59 | P1 |
| F005-055 | Bug修复 | 修复版本 | Day 59-60 | P0 |
| F005-056 | 文档编写 | 使用文档 | Day 60 | P0 |

---

## 三、页面清单

### 3.1 核心页面

| 页面 | 路由 | 功能描述 | 优先级 |
|------|------|----------|--------|
| 登录 | /login | 管理员登录 | P0 |
| 首页看板 | /dashboard | 数据概览 | P0 |
| C端用户 | /users | 用户管理 | P0 |
| 经纪人 | /agents | 经纪人管理 | P0 |
| 房源列表 | /houses | 房源管理 | P0 |
| 房源审核 | /houses/audit | 审核房源 | P0 |
| 验真管理 | /verification | 验真审核 | P0 |
| 预约管理 | /appointments | 预约订单 | P0 |
| Banner管理 | /banner | 运营配置 | P0 |
| 内容管理 | /content | CMS管理 | P0 |
| 成交管理 | /acn/deals | ACN成交 | P0 |
| 分佣结算 | /acn/commission | 佣金管理 | P0 |
| 数据报表 | /reports | BI报表 | P0 |
| 系统设置 | /settings | 系统配置 | P0 |
| 权限管理 | /permissions | RBAC管理 | P0 |

### 3.2 项目结构

```
src/
├── api/                    # API接口
│   ├── user.ts
│   ├── house.ts
│   ├── appointment.ts
│   ├── verification.ts
│   ├── acn.ts
│   └── system.ts
├── assets/                 # 静态资源
├── components/             # 公共组件
│   ├── CommonTable/       # 通用表格
│   ├── SearchForm/        # 搜索表单
│   ├── ImagePreview/      # 图片预览
│   ├── DataCharts/        # 数据图表
│   └── ...
├── composables/            # 组合式函数
├── layouts/                # 布局
│   ├── default.vue
│   └── blank.vue
├── router/                 # 路由
│   └── index.ts
├── stores/                 # 状态管理
│   ├── user.ts
│   ├── permission.ts
│   └── app.ts
├── styles/                 # 样式
│   ├── variables.scss
│   └── index.scss
├── utils/                  # 工具函数
│   ├── request.ts         # Axios封装
│   ├── auth.ts            # 权限工具
│   └── format.ts          # 格式化
├── views/                  # 页面
│   ├── login/
│   ├── dashboard/
│   ├── user/
│   │   ├── index.vue      # C端用户
│   │   └── agent.vue      # B端经纪人
│   ├── house/
│   │   ├── index.vue      # 房源列表
│   │   └── audit.vue      # 房源审核
│   ├── verification/
│   ├── appointment/
│   ├── operation/         # 运营管理
│   │   ├── banner.vue
│   │   └── content.vue
│   ├── acn/               # ACN管理
│   │   ├── deals.vue
│   │   └── commission.vue
│   ├── data/              # 数据报表
│   │   └── index.vue
│   └── system/            # 系统设置
│       ├── settings.vue
│       └── permission.vue
├── App.vue
└── main.ts
```

---

## 四、核心组件设计

### 4.1 通用表格组件

```vue
<template>
  <div class="common-table">
    <!-- 搜索表单 -->
    <SearchForm 
      :columns="searchColumns" 
      @search="handleSearch"
      @reset="handleReset"
    />
    
    <!-- 操作按钮 -->
    <div class="table-toolbar">
      <slot name="toolbar" />
    </div>
    
    <!-- 数据表格 -->
    <el-table
      v-loading="loading"
      :data="tableData"
      @selection-change="handleSelectionChange"
    >
      <el-table-column 
        v-for="col in columns" 
        :key="col.prop"
        v-bind="col"
      >
        <template #default="{ row }">
          <slot :name="col.prop" :row="row">
            {{ row[col.prop] }}
          </slot>
        </template>
      </el-table-column>
    </el-table>
    
    <!-- 分页 -->
    <el-pagination
      v-model:current-page="page"
      v-model:page-size="pageSize"
      :total="total"
      @change="handlePageChange"
    />
  </div>
</template>

<script setup lang="ts">
interface Props {
  api: (params: any) => Promise<PageResult<any>>
  columns: TableColumn[]
  searchColumns: FormColumn[]
}

const props = defineProps<Props>()

const loading = ref(false)
const tableData = ref([])
const page = ref(1)
const pageSize = ref(20)
const total = ref(0)
const searchParams = ref({})

const loadData = async () => {
  loading.value = true
  const res = await props.api({
    page: page.value,
    pageSize: pageSize.value,
    ...searchParams.value
  })
  tableData.value = res.list
  total.value = res.total
  loading.value = false
}
</script>
```

### 4.2 数据看板

```vue
<template>
  <div class="dashboard">
    <!-- 统计卡片 -->
    <el-row :gutter="16">
      <el-col :span="6" v-for="card in statCards" :key="card.title">
        <StatCard v-bind="card" />
      </el-col>
    </el-row>
    
    <!-- 图表区域 -->
    <el-row :gutter="16" class="chart-row">
      <el-col :span="12">
        <ChartCard title="用户增长趋势">
          <LineChart :data="userGrowthData" />
        </ChartCard>
      </el-col>
      <el-col :span="12">
        <ChartCard title="房源分布">
          <PieChart :data="houseDistributionData" />
        </ChartCard>
      </el-col>
    </el-row>
    
    <!-- 数据表格 -->
    <ChartCard title="近期成交">
      <el-table :data="recentDeals">
        <el-table-column prop="dealNo" label="成交单号" />
        <el-table-column prop="houseTitle" label="房源" />
        <el-table-column prop="agentName" label="成交人" />
        <el-table-column prop="amount" label="成交金额" />
        <el-table-column prop="time" label="成交时间" />
      </el-table>
    </ChartCard>
  </div>
</template>
```

---

## 五、权限设计

### 5.1 RBAC模型

```typescript
// 角色定义
const roles = [
  { id: 'super_admin', name: '超级管理员', permissions: ['*'] },
  { id: 'admin', name: '管理员', permissions: ['user:*', 'house:*', 'appointment:*'] },
  { id: 'operator', name: '运营人员', permissions: ['house:view', 'house:audit', 'content:*'] },
  { id: 'finance', name: '财务人员', permissions: ['acn:*', 'withdrawal:*'] },
  { id: 'viewer', name: '数据查看', permissions: ['dashboard:*', 'report:*'] },
]

// 权限指令
const vPermission = {
  mounted(el, binding) {
    const { value } = binding
    const permissions = useUserStore().permissions
    
    if (!permissions.includes(value)) {
      el.remove()
    }
  }
}
```

### 5.2 菜单配置

```typescript
const menus = [
  {
    path: '/dashboard',
    name: '数据看板',
    icon: 'Dashboard',
    permission: 'dashboard:view'
  },
  {
    path: '/users',
    name: '用户管理',
    icon: 'User',
    permission: 'user:view',
    children: [
      { path: '/users', name: 'C端用户', permission: 'user:view' },
      { path: '/agents', name: '经纪人', permission: 'agent:view' },
    ]
  },
  {
    path: '/houses',
    name: '房源管理',
    icon: 'House',
    permission: 'house:view',
    children: [
      { path: '/houses', name: '房源列表', permission: 'house:view' },
      { path: '/houses/audit', name: '房源审核', permission: 'house:audit' },
    ]
  },
  // ...
]
```

---

## 六、验收标准

### 6.1 功能验收

- [ ] 所有页面可正常访问
- [ ] 用户管理功能完整
- [ ] 房源审核流程正常
- [ ] 验真审核可正常操作
- [ ] 数据看板展示正确
- [ ] 权限控制生效
- [ ] 报表可导出

### 6.2 性能验收

- [ ] 页面加载 < 3s
- [ ] 表格数据加载 < 1s
- [ ] 图表渲染流畅
- [ ] 支持同时开多个标签页

### 6.3 兼容性

- [ ] Chrome/Edge/Firefox兼容
- [ ] 响应式布局（适配笔记本+显示器）

---

## 七、依赖与协作

### 7.1 我依赖谁

| 依赖 | 内容 | 时间 |
|------|------|------|
| AGENT-001 | UI设计规范 | Week 1 |
| AGENT-002 | API接口 | Week 2+ |

### 7.2 谁依赖我

| 依赖方 | 内容 | 时间 |
|--------|------|------|
| AGENT-007 | 测试版本 | Week 8 |
| AGENT-008 | 部署 | Week 8 |

---

## 八、技术栈

| 类别 | 技术 | 版本 |
|------|------|------|
| 框架 | Vue | 3.4+ |
| 构建 | Vite | 5.x |
| UI库 | Element Plus | 2.x |
| 状态管理 | Pinia | 2.x |
| 路由 | Vue Router | 4.x |
| HTTP | Axios | 1.x |
| 图表 | ECharts | 5.x |
| 样式 | SCSS | - |

---

*任务书创建: 2026-03-17*  
*版本: v1.0*
