# AGENT-003 任务书 - C端APP开发工程师

> **角色**: Flutter C端APP开发工程师  
> **代号**: AGENT-003  
> **项目**: 缅甸房产平台  
> **周期**: 8周  
> **汇报对象**: AI项目经理

---

## 一、角色职责

1. **C端APP开发**: 开发Flutter C端APP（购房者/租房者使用）
2. **UI实现**: 实现产品设计的UI界面
3. **功能开发**: 实现房源浏览、搜索、IM咨询、预约等功能
4. **状态管理**: 管理APP状态，确保数据一致性
5. **性能优化**: 优化APP性能，确保流畅体验

---

## 二、任务清单

### Week 1: 环境搭建与基础架构

| 任务ID | 任务描述 | 交付物 | 截止时间 | 优先级 |
|--------|----------|--------|----------|--------|
| C003-001 | Flutter环境搭建 | 开发环境 | Day 1 | P0 |
| C003-002 | 项目结构初始化 | 代码框架 | Day 2 | P0 |
| C003-003 | 网络层封装(Dio) | HTTP客户端 | Day 3 | P0 |
| C003-004 | 状态管理配置(GetX/Bloc) | 状态管理 | Day 4 | P0 |
| C003-005 | 路由管理配置 | 路由系统 | Day 5 | P0 |
| C003-006 | 主题与样式配置 | UI主题 | Day 5 | P0 |

### Week 2: 账号模块

| 任务ID | 任务描述 | 交付物 | 截止时间 | 优先级 |
|--------|----------|--------|----------|--------|
| C003-007 | 登录页面 | LoginPage | Day 7 | P0 |
| C003-008 | 注册页面 | RegisterPage | Day 8 | P0 |
| C003-009 | 验证码输入组件 | VerifyCodeWidget | Day 9 | P0 |
| C003-010 | 实名认证页面 | VerificationPage | Day 10 | P0 |
| C003-011 | 账号服务集成 | AuthService | Day 10 | P0 |

### Week 3: 首页与房源列表

| 任务ID | 任务描述 | 交付物 | 截止时间 | 优先级 |
|--------|----------|--------|----------|--------|
| C003-012 | 首页框架 | HomePage | Day 12 | P0 |
| C003-013 | Banner轮播组件 | BannerWidget | Day 13 | P0 |
| C003-014 | 房源推荐流 | HouseListWidget | Day 14 | P0 |
| C003-015 | 快捷入口组件 | QuickEntryWidget | Day 15 | P0 |
| C003-016 | 搜索页面 | SearchPage | Day 16 | P0 |
| C003-017 | 筛选组件 | FilterWidget | Day 17 | P0 |
| C003-018 | 房源卡片组件 | HouseCardWidget | Day 18 | P0 |

### Week 4: 地图找房与房源详情

| 任务ID | 任务描述 | 交付物 | 截止时间 | 优先级 |
|--------|----------|--------|----------|--------|
| C003-019 | 地图页面框架 | MapPage | Day 20 | P0 |
| C003-020 | 地图SDK集成 | MapService | Day 21 | P0 |
| C003-021 | 聚合标记组件 | ClusterMarker | Day 23 | P0 |
| C003-022 | 房源标记组件 | HouseMarker | Day 24 | P0 |
| C003-023 | 房源详情页面 | HouseDetailPage | Day 25 | P0 |
| C003-024 | 图片轮播组件 | ImageGallery | Day 26 | P0 |
| C003-025 | 收藏功能 | FavoriteService | Day 26 | P0 |

### Week 5: IM咨询与预约

| 任务ID | 任务描述 | 交付物 | 截止时间 | 优先级 |
|--------|----------|--------|----------|--------|
| C003-026 | 会话列表页面 | ChatListPage | Day 29 | P0 |
| C003-027 | 聊天页面 | ChatPage | Day 31 | P0 |
| C003-028 | IM服务集成 | IMService | Day 32 | P0 |
| C003-029 | 消息组件(文字/图片/语音) | MessageWidgets | Day 33 | P0 |
| C003-030 | 预约页面 | AppointmentPage | Day 34 | P0 |
| C003-031 | 时间选择组件 | TimePickerWidget | Day 35 | P0 |
| C003-032 | 预约管理页面 | MyAppointmentsPage | Day 35 | P0 |

### Week 6: 个人中心与其他

| 任务ID | 任务描述 | 交付物 | 截止时间 | 优先级 |
|--------|----------|--------|----------|--------|
| C003-033 | 个人中心页面 | ProfilePage | Day 37 | P0 |
| C003-034 | 我的收藏页面 | MyFavoritesPage | Day 38 | P0 |
| C003-035 | 浏览历史页面 | HistoryPage | Day 39 | P0 |
| C003-036 | 设置页面 | SettingsPage | Day 40 | P0 |
| C003-037 | 消息通知中心 | NotificationCenter | Day 42 | P0 |
| C003-038 | 帮助与反馈页面 | HelpPage | Day 43 | P0 |
| C003-039 | 房东发布入口 | PublishEntryPage | Day 44 | P0 |
| C003-040 | 房贷计算器 | CalculatorWidget | Day 45 | P1 |

### Week 7: 功能完善与优化

| 任务ID | 任务描述 | 交付物 | 截止时间 | 优先级 |
|--------|----------|--------|----------|--------|
| C003-041 | 地图画圈找房 | CircleSearch | Day 47 | P1 |
| C003-042 | 周边配套展示 | NearbyPOI | Day 48 | P1 |
| C003-043 | 分享功能 | ShareService | Day 49 | P1 |
| C003-044 | 搜索历史与建议 | SearchHistory | Day 50 | P1 |
| C003-045 | 性能优化 | 优化代码 | Day 52 | P1 |
| C003-046 | 图片懒加载优化 | ImageLazyLoad | Day 53 | P1 |

### Week 8: 测试与交付

| 任务ID | 任务描述 | 交付物 | 截止时间 | 优先级 |
|--------|----------|--------|----------|--------|
| C003-047 | 单元测试编写 | 测试代码 | Day 55 | P1 |
| C003-048 | Widget测试 | 测试代码 | Day 56 | P1 |
| C003-049 | 集成测试 | 测试报告 | Day 57 | P0 |
| C003-050 | Bug修复 | 修复版本 | Day 58-59 | P0 |
| C003-051 | 代码整理与文档 | 最终版本 | Day 60 | P0 |

---

## 三、页面清单

### 3.1 核心页面

| 页面 | 路由 | 功能描述 | 优先级 |
|------|------|----------|--------|
| 登录页 | /login | 手机号登录 | P0 |
| 注册页 | /register | 手机号注册 | P0 |
| 实名认证页 | /verify | 身份证认证 | P0 |
| 首页 | /home | 推荐房源 | P0 |
| 搜索页 | /search | 房源搜索筛选 | P0 |
| 地图找房 | /map | 地图聚合展示 | P0 |
| 房源详情 | /house/:id | 房源详细信息 | P0 |
| IM聊天 | /chat/:id | 即时通讯 | P0 |
| 预约页 | /appointment | 预约带看 | P0 |
| 我的预约 | /my-appointments | 预约管理 | P0 |
| 个人中心 | /profile | 用户信息 | P0 |
| 我的收藏 | /favorites | 收藏列表 | P0 |

### 3.2 页面结构

```
lib/
├── main.dart                    # 入口
├── app.dart                     # App配置
├── routes/                      # 路由
│   ├── app_pages.dart
│   └── app_routes.dart
├── modules/                     # 业务模块
│   ├── auth/                    # 认证模块
│   │   ├── login/
│   │   ├── register/
│   │   └── verification/
│   ├── home/                    # 首页模块
│   │   ├── controllers/
│   │   └── views/
│   ├── search/                  # 搜索模块
│   ├── map/                     # 地图模块
│   ├── house/                   # 房源模块
│   ├── chat/                    # IM模块
│   ├── appointment/             # 预约模块
│   └── profile/                 # 个人中心模块
├── services/                    # 服务层
│   ├── api_service.dart
│   ├── auth_service.dart
│   ├── house_service.dart
│   ├── chat_service.dart
│   └── location_service.dart
├── models/                      # 数据模型
├── widgets/                     # 公共组件
├── utils/                       # 工具类
└── config/                      # 配置
```

---

## 四、UI组件规范

### 4.1 色彩规范

```dart
class AppColors {
  // 主色调
  static const Color primary = Color(0xFF1890FF);
  static const Color primaryLight = Color(0xFF40A9FF);
  static const Color primaryDark = Color(0xFF096DD9);
  
  // 功能色
  static const Color success = Color(0xFF52C41A);
  static const Color warning = Color(0xFFFAAD14);
  static const Color error = Color(0xFFF5222D);
  
  // 中性色
  static const Color textPrimary = Color(0xFF262626);
  static const Color textSecondary = Color(0xFF595959);
  static const Color textDisabled = Color(0xFF8C8C8C);
  static const Color border = Color(0xFFD9D9D9);
  static const Color background = Color(0xFFF5F5F5);
}
```

### 4.2 字体规范

```dart
class AppTextStyles {
  static const TextStyle heading1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle heading2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle body = TextStyle(
    fontSize: 14,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    color: AppColors.textSecondary,
  );
}
```

### 4.3 房源卡片组件

```dart
class HouseCard extends StatelessWidget {
  final House house;
  final VoidCallback? onTap;
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          // 图片区域
          CachedNetworkImage(imageUrl: house.coverImage),
          
          // 信息区域
          Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(house.title, style: AppTextStyles.heading2),
                SizedBox(height: 8),
                Row(
                  children: [
                    Text('${house.area}㎡'),
                    Text('${house.rooms}'),
                    Text(house.district),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Text('${house.price}万缅币', 
                      style: TextStyle(color: AppColors.error)),
                    if (house.isVerified)
                      VerifiedTag(),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## 五、验收标准

### 5.1 功能验收

- [ ] 所有页面按设计稿实现
- [ ] 所有功能可正常使用
- [ ] 与后端API联调通过
- [ ] IM消息收发正常

### 5.2 UI验收

- [ ] 符合UI设计规范
- [ ] 支持响应式布局
- [ ] 支持缅语显示
- [ ] 图片加载正常

### 5.3 性能验收

- [ ] 首页加载 < 2s
- [ ] 页面切换流畅
- [ ] 列表滚动不卡顿
- [ ] 内存占用合理

---

## 六、依赖与协作

### 6.1 我依赖谁

| 依赖 | 内容 | 时间 |
|------|------|------|
| AGENT-001 | UI设计规范 | Week 1 |
| AGENT-002 | API接口 | Week 2+ |
| AGENT-002 | IM服务 | Week 5 |

### 6.2 谁依赖我

| 依赖方 | 内容 | 时间 |
|--------|------|------|
| AGENT-007 | 测试版本 | Week 8 |

---

## 七、技术栈

| 类别 | 技术 | 版本 |
|------|------|------|
| 框架 | Flutter | 3.x |
| 状态管理 | GetX / Flutter Bloc | 最新 |
| 网络请求 | Dio | 5.x |
| 图片缓存 | CachedNetworkImage | 最新 |
| 地图 | Google Maps Flutter | 最新 |
| IM | 第三方SDK | - |
| 本地存储 | Hive / SharedPreferences | 最新 |
| 路由 | GetX Routing | - |

---

*任务书创建: 2026-03-17*  
*版本: v1.0*
