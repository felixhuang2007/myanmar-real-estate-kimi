# AGENT-004 任务书 - B端APP开发工程师

> **角色**: Flutter B端APP开发工程师  
> **代号**: AGENT-004  
> **项目**: 缅甸房产平台  
> **周期**: 8周  
> **汇报对象**: AI项目经理

---

## 一、角色职责

1. **B端APP开发**: 开发Flutter B端APP（经纪人/团队长使用）
2. **工作台开发**: 实现经纪人工作台、房源管理、客户管理等功能
3. **录房功能**: 实现快速录房、验真任务执行
4. **ACN协作**: 实现ACN分佣、业绩统计、成交申报
5. **地推功能**: 实现地推人员拉新任务管理

---

## 二、任务清单

### Week 1: 环境搭建与基础架构

| 任务ID | 任务描述 | 交付物 | 截止时间 | 优先级 |
|--------|----------|--------|----------|--------|
| B004-001 | Flutter环境搭建 | 开发环境 | Day 1 | P0 |
| B004-002 | 项目结构初始化 | 代码框架 | Day 2 | P0 |
| B004-003 | 网络层封装(Dio) | HTTP客户端 | Day 3 | P0 |
| B004-004 | 状态管理配置(GetX/Bloc) | 状态管理 | Day 4 | P0 |
| B004-005 | 路由管理配置 | 路由系统 | Day 5 | P0 |
| B004-006 | B端主题与样式配置 | UI主题 | Day 5 | P0 |

### Week 2: 账号与认证

| 任务ID | 任务描述 | 交付物 | 截止时间 | 优先级 |
|--------|----------|--------|----------|--------|
| B004-007 | 经纪人注册页面 | AgentRegisterPage | Day 7 | P0 |
| B004-008 | 经纪人登录页面 | AgentLoginPage | Day 8 | P0 |
| B004-009 | 经纪人资质审核状态 | AuditStatusPage | Day 9 | P0 |
| B004-010 | 个人资料管理 | ProfileManagePage | Day 10 | P0 |
| B004-011 | 账号服务集成 | AgentAuthService | Day 10 | P0 |

### Week 3: 录房与房源管理

| 任务ID | 任务描述 | 交付物 | 截止时间 | 优先级 |
|--------|----------|--------|----------|--------|
| B004-012 | 房源录入页面 | HouseEntryPage | Day 12 | P0 |
| B004-013 | 表单字段组件 | FormFieldWidgets | Day 14 | P0 |
| B004-014 | 图片批量上传 | MultiImageUploader | Day 15 | P0 |
| B004-015 | 地图位置标注 | MapLocationPicker | Day 16 | P0 |
| B004-016 | 房源草稿箱 | DraftHousePage | Day 17 | P0 |
| B004-017 | 我的房源列表 | MyHousesPage | Day 18 | P0 |

### Week 4: 房源状态与IM

| 任务ID | 任务描述 | 交付物 | 截止时间 | 优先级 |
|--------|----------|--------|----------|--------|
| B004-018 | 房源状态管理 | HouseStatusWidget | Day 20 | P0 |
| B004-019 | 房源刷新功能 | HouseRefreshWidget | Day 21 | P0 |
| B004-020 | IM会话列表 | ChatListPage | Day 23 | P0 |
| B004-021 | 聊天页面 | ChatPage | Day 24 | P0 |
| B004-022 | 快捷话术功能 | QuickReplyWidget | Day 25 | P0 |
| B004-023 | IM服务集成 | IMService | Day 26 | P0 |

### Week 5: 客户管理与预约

| 任务ID | 任务描述 | 交付物 | 截止时间 | 优先级 |
|--------|----------|--------|----------|--------|
| B004-024 | 客户线索池 | ClientPoolPage | Day 29 | P0 |
| B004-025 | 我的客户页面 | MyClientsPage | Day 30 | P0 |
| B004-026 | 客户详情页面 | ClientDetailPage | Day 31 | P0 |
| B004-027 | 跟进记录功能 | FollowUpWidget | Day 32 | P0 |
| B004-028 | 客户标签功能 | ClientTagWidget | Day 33 | P0 |
| B004-029 | 带看日程页面 | ShowingSchedulePage | Day 34 | P0 |
| B004-030 | 预约确认/拒绝 | AppointmentActionPage | Day 35 | P0 |

### Week 6: 验真与带看

| 任务ID | 任务描述 | 交付物 | 截止时间 | 优先级 |
|--------|----------|--------|----------|--------|
| B004-031 | 验真任务列表 | VerificationTaskPage | Day 37 | P0 |
| B004-032 | 验真执行页面 | VerificationExecutePage | Day 39 | P0 |
| B004-033 | 水印相机功能 | WatermarkCamera | Day 40 | P0 |
| B004-034 | 验真报告填写 | VerificationReportPage | Day 41 | P0 |
| B004-035 | 带看确认签到 | ShowingSignInPage | Day 42 | P0 |
| B004-036 | 带看反馈填写 | ShowingFeedbackPage | Day 43 | P0 |
| B004-037 | 房源维护转移 | HouseTransferPage | Day 44 | P0 |
| B004-038 | 业绩看板页面 | PerformanceDashboard | Day 45 | P0 |

### Week 7: ACN与地推

| 任务ID | 任务描述 | 交付物 | 截止时间 | 优先级 |
|--------|----------|--------|----------|--------|
| B004-039 | 成交申报页面 | DealReportPage | Day 46 | P0 |
| B004-040 | 成交参与方选择 | ParticipantSelector | Day 48 | P0 |
| B004-041 | 分佣明细页面 | CommissionDetailPage | Day 50 | P0 |
| B004-042 | 业绩统计页面 | PerformanceStatsPage | Day 51 | P0 |
| B004-043 | 排行榜页面 | RankingPage | Day 52 | P0 |
| B004-044 | 地推注册功能 | GroundPromoterRegister | Day 53 | P0 |
| B004-045 | 地推任务页面 | GroundTaskPage | Day 54 | P0 |
| B004-046 | 佣金提现功能 | WithdrawalPage | Day 55 | P0 |

### Week 8: 测试与交付

| 任务ID | 任务描述 | 交付物 | 截止时间 | 优先级 |
|--------|----------|--------|----------|--------|
| B004-047 | 单元测试编写 | 测试代码 | Day 56 | P1 |
| B004-048 | Widget测试 | 测试代码 | Day 57 | P1 |
| B004-049 | 集成测试 | 测试报告 | Day 58 | P0 |
| B004-050 | Bug修复 | 修复版本 | Day 59-60 | P0 |
| B004-051 | 代码整理与文档 | 最终版本 | Day 60 | P0 |

---

## 三、页面清单

### 3.1 核心页面

| 页面 | 路由 | 功能描述 | 优先级 |
|------|------|----------|--------|
| 注册页 | /register | 经纪人注册 | P0 |
| 登录页 | /login | 经纪人登录 | P0 |
| 工作台 | /dashboard | 经纪人首页 | P0 |
| 录房页 | /house/entry | 录入房源 | P0 |
| 我的房源 | /house/my | 房源管理 | P0 |
| 客户线索 | /client/pool | 线索池 | P0 |
| 我的客户 | /client/my | 客户管理 | P0 |
| 带看日程 | /schedule | 日程管理 | P0 |
| 验真任务 | /verification | 验真执行 | P0 |
| IM聊天 | /chat | 客户沟通 | P0 |
| 业绩统计 | /performance | 业绩看板 | P0 |
| 成交申报 | /deal/report | ACN申报 | P0 |
| 佣金明细 | /commission | 分佣明细 | P0 |
| 地推任务 | /ground/task | 拉新任务 | P1 |

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
│   │   └── profile/
│   ├── dashboard/               # 工作台模块
│   ├── house/                   # 房源模块
│   │   ├── entry/              # 录房
│   │   ├── my/                 # 我的房源
│   │   └── manage/             # 房源管理
│   ├── client/                  # 客户模块
│   │   ├── pool/               # 线索池
│   │   └── my/                 # 我的客户
│   ├── schedule/                # 日程模块
│   ├── verification/            # 验真模块
│   ├── chat/                    # IM模块
│   ├── performance/             # 业绩模块
│   ├── acn/                     # ACN模块
│   └── ground/                  # 地推模块
├── services/                    # 服务层
├── models/                      # 数据模型
├── widgets/                     # 公共组件
├── utils/                       # 工具类
└── config/                      # 配置
```

---

## 四、核心功能详解

### 4.1 极速录房

```dart
class HouseEntryController extends GetxController {
  // 表单数据
  final form = HouseEntryForm().obs;
  
  // 图片列表
  final images = <XFile>[].obs;
  
  // 位置信息
  final location = Rx<LatLng?>(null);
  
  // 提交房源
  Future<void> submitHouse() async {
    // 1. 表单验证
    if (!validateForm()) return;
    
    // 2. 上传图片
    final imageUrls = await uploadImages();
    
    // 3. 提交数据
    await HouseService.createHouse(
      form: form.value,
      images: imageUrls,
      location: location.value,
    );
    
    // 4. 清空草稿
    clearDraft();
  }
  
  // 保存草稿
  Future<void> saveDraft() async {
    await LocalStorage.save('house_draft', form.value.toJson());
  }
}
```

### 4.2 水印相机

```dart
class WatermarkCamera extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 相机预览
        CameraPreview(controller),
        
        // 水印叠加层
        Positioned(
          bottom: 20,
          right: 20,
          child: Container(
            padding: EdgeInsets.all(8),
            color: Colors.black54,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('验真专用', style: TextStyle(color: Colors.white)),
                Text(DateTime.now().toString(), 
                  style: TextStyle(color: Colors.white)),
                Text('${agentName} ${agentPhone}', 
                  style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
```

### 4.3 带看日程

```dart
class SchedulePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 日历视图
          TableCalendar(
            focusedDay: selectedDay,
            selectedDayPredicate: (day) => isSameDay(selectedDay, day),
            onDaySelected: (selected, focused) {
              setState(() => selectedDay = selected);
            },
            eventLoader: (day) => getEventsForDay(day),
          ),
          
          // 日程列表
          Expanded(
            child: ListView.builder(
              itemCount: appointments.length,
              itemBuilder: (context, index) {
                return AppointmentCard(
                  appointment: appointments[index],
                  onConfirm: () => confirmAppointment(appointments[index]),
                  onCancel: () => cancelAppointment(appointments[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## 五、B端特有组件

### 5.1 工作台卡片

```dart
class DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            SizedBox(height: 8),
            Text(value, style: TextStyle(
              fontSize: 24, 
              fontWeight: FontWeight.bold,
            )),
            Text(title, style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
```

### 5.2 业绩看板

```dart
class PerformanceDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 本月业绩
        DashboardCard(
          title: '本月业绩',
          value: '¥${performance.thisMonth}',
          icon: Icons.monetization_on,
          color: Colors.green,
        ),
        
        // 待结算佣金
        DashboardCard(
          title: '待结算',
          value: '¥${performance.pending}',
          icon: Icons.account_balance_wallet,
          color: Colors.orange,
        ),
        
        // 成交单数
        DashboardCard(
          title: '成交单数',
          value: '${performance.dealCount}',
          icon: Icons.assignment_turned_in,
          color: Colors.blue,
        ),
        
        // 带看次数
        DashboardCard(
          title: '本月带看',
          value: '${performance.showingCount}',
          icon: Icons.visibility,
          color: Colors.purple,
        ),
      ],
    );
  }
}
```

---

## 六、验收标准

### 6.1 功能验收

- [ ] 经纪人可完成注册、登录
- [ ] 可快速录入房源，支持草稿
- [ ] 可管理房源状态
- [ ] 可接收客户咨询（IM）
- [ ] 可管理客户线索
- [ ] 可确认/拒绝预约
- [ ] 可执行验真任务
- [ ] 可申报成交
- [ ] 可查看业绩和分佣

### 6.2 性能验收

- [ ] 录房提交 < 5s
- [ ] 图片上传有进度提示
- [ ] 页面切换流畅
- [ ] 离线草稿不丢失

---

## 七、依赖与协作

### 7.1 我依赖谁

| 依赖 | 内容 | 时间 |
|------|------|------|
| AGENT-001 | UI设计规范 | Week 1 |
| AGENT-002 | API接口 | Week 2+ |
| AGENT-002 | IM服务 | Week 4 |

### 7.2 谁依赖我

| 依赖方 | 内容 | 时间 |
|--------|------|------|
| AGENT-007 | 测试版本 | Week 8 |

---

*任务书创建: 2026-03-17*  
*版本: v1.0*
