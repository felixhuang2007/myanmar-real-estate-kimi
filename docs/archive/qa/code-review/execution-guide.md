# 代码Review执行指南
# 缅甸房产平台 - Flutter版

---

## 一、Review触发条件

当以下代码产出后，启动Review流程：

| 模块 | 代码路径 | 触发条件 |
|------|----------|----------|
| C端Flutter | /frontend/mobile/ | 功能开发完成，提交PR |
| B端Flutter | /frontend/agent-app/ | 功能开发完成，提交PR |
| 后端API | /backend/ | 接口开发完成，提交PR |
| 管理后台 | /frontend/admin/ | 页面开发完成，提交PR |

---

## 二、Review流程

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│  接收PR通知 │ → │  静态检查   │ → │  逻辑Review │ → │  输出报告   │
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
       │                  │                  │                  │
       ↓                  ↓                  ↓                  ↓
   获取代码           工具扫描           人工检查           反馈问题
   了解变更           代码规范           业务逻辑           跟踪修复
```

---

## 三、Flutter代码Review重点

### 3.1 Dart代码规范检查

| 检查项 | 工具 | 标准 | 权重 |
|--------|------|------|------|
| 代码格式化 | dart format | 无警告 | 10% |
| 静态分析 | dart analyze | 无error/warning | 15% |
| 代码复杂度 | 人工检查 | 函数<50行，圈复杂度<10 | 10% |
| 命名规范 | 人工检查 | 符合Dart风格指南 | 10% |

### 3.2 Flutter Widget检查

| 检查项 | 说明 | 示例 |
|--------|------|------|
| Widget重建优化 | 使用const构造函数 | `const Text('标题')` |
| 状态管理 | 合理使用setState/Provider/BLoC | 避免过度setState |
| 图片加载 | 使用cached_network_image | 避免重复下载 |
| 列表优化 | 使用ListView.builder | 大数据量下性能 |
| 异步操作 | 使用Future/Stream | 正确处理loading和error |

### 3.3 平台通道检查

```dart
// MethodChannel调用示例
static const platform = MethodChannel('com.myanmarproperty/payment');

Future<void> makePayment() async {
  try {
    final result = await platform.invokeMethod('pay', {
      'amount': 10000,
      'currency': 'MMK',
    });
    // 处理结果
  } on PlatformException catch (e) {
    // 必须处理异常
    log('支付失败: ${e.message}');
  }
}
```

**检查点：**
- [ ] 平台通道名称使用唯一前缀
- [ ] 所有invokeMethod都有try-catch
- [ ] 异步操作有loading状态
- [ ] 返回值有类型检查

### 3.4 依赖管理检查

```yaml
# pubspec.yaml检查

dependencies:
  flutter:
    sdk: flutter
  
  # 检查版本约束是否合理
  http: ^1.1.0                    # ✓ 使用^允许兼容版本
  google_maps_flutter: ^2.5.0     # ✓ 地图插件
  firebase_messaging: ^14.7.0     # ✓ 推送插件
  
  # 避免使用
  some_package: any               # ✗ 不允许使用any
  git_package: 
    git: url                      # ✗ 尽量避免git依赖
```

---

## 四、后端API代码Review重点

### 4.1 API设计检查

| 检查项 | 标准 | 示例 |
|--------|------|------|
| RESTful规范 | 正确使用方法 | GET /houses, POST /appointments |
| 接口版本 | URL中包含版本 | /api/v1/houses |
| 幂等性 | 重试不会导致重复 | 订单创建使用唯一键 |
| 参数校验 | 入参有校验 | 使用validator |
| 错误码 | 统一错误码体系 | code: 4001, message: "参数错误" |

### 4.2 安全性检查

| 检查项 | 检查方法 | 风险等级 |
|--------|----------|----------|
| SQL注入 | 检查是否使用参数化查询 | 🔴 致命 |
| XSS攻击 | 检查输出是否转义 | 🔴 致命 |
| 接口鉴权 | 检查敏感接口是否有鉴权 | 🔴 致命 |
| 敏感信息 | 检查日志是否脱敏 | 🟡 严重 |
| 文件上传 | 检查文件类型和大小限制 | 🟡 严重 |

### 4.3 数据库检查

```sql
-- 检查点1: 索引检查
EXPLAIN SELECT * FROM houses WHERE district_code = 'tamwe';
-- 确保使用了索引，没有全表扫描

-- 检查点2: N+1查询检查
-- 避免在循环中查询数据库
```

**检查清单：**
- [ ] 复杂查询有索引支持
- [ ] 无N+1查询问题
- [ ] 事务边界正确
- [ ] 连接池配置合理

---

## 五、Review执行步骤

### 步骤1: 环境准备（5分钟）

```bash
# 拉取代码
cd /frontend/mobile
git fetch origin
git checkout feature/xxx

# 安装依赖
flutter pub get

# 运行静态分析
flutter analyze
```

### 步骤2: 静态检查（10分钟）

| 工具 | 命令 | 通过标准 |
|------|------|----------|
| Dart Analyzer | `flutter analyze` | 0 issues |
| Dart Format | `dart format --output=none --set-exit-if-changed .` | 无格式问题 |
| 测试运行 | `flutter test` | 所有测试通过 |

### 步骤3: 代码走读（30-60分钟）

按以下顺序Review：

1. **业务入口** → 理解功能流程
2. **数据层** → 检查API调用和数据处理
3. **业务逻辑层** → 检查核心逻辑实现
4. **UI层** → 检查Widget构建和状态管理

### 步骤4: 问题记录（10分钟）

使用Review模板记录问题：

```markdown
## Review发现问题

### 严重问题
| 序号 | 问题描述 | 位置 | 建议修复方案 |
|------|----------|------|--------------|
| 1 | SQL注入风险 | house_service.dart:45 | 使用参数化查询 |
| 2 | 未处理异常 | payment_page.dart:120 | 添加try-catch |

### 中等问题
| 序号 | 问题描述 | 位置 | 建议修复方案 |
|------|----------|------|--------------|
| 1 | 函数过长 | search_filter.dart:80 | 拆分为小函数 |
```

### 步骤5: 反馈与跟踪（持续）

1. 在PR中提交Review意见
2. 开发者修复后验证
3. 确认修复后Approve PR

---

## 六、Review通过标准

| 检查项 | 权重 | 通过标准 |
|--------|------|----------|
| 静态检查通过 | 20% | 0 error/warning |
| 单元测试通过 | 20% | 覆盖率>60% |
| 代码规范 | 20% | 无严重规范问题 |
| 安全性 | 20% | 无安全漏洞 |
| 业务逻辑 | 20% | 符合PRD要求 |
| **总分** | **100%** | **≥80分通过** |

**特殊情况：**
- 有致命安全问题 → 直接不通过
- 有阻塞性业务Bug → 直接不通过

---

## 七、Review模板使用示例

### 7.1 Flutter代码Review示例

```markdown
## Review: C端首页模块

### 基本信息
| 项目 | 内容 |
|------|------|
| Review日期 | 2026-03-17 |
| 开发 | 张三 |
| 模块 | C端-首页 |
| PR链接 | #123 |

### 检查结果

| 检查项 | 状态 | 备注 |
|--------|------|------|
| flutter analyze | ✅ 通过 | 0 issues |
| 单元测试 | ✅ 通过 | 覆盖率65% |
| 代码规范 | ⚠️ 需改进 | 有2处命名不规范 |

### 发现问题

**中等问题**
1. home_page.dart:56 - 函数过长（80行），建议拆分
2. banner_widget.dart:34 - 图片未使用缓存

### 结论
✅ 有条件通过 - 修复中等问题后合并
```

### 7.2 后端API Review示例

```markdown
## Review: 房源API模块

### 安全问题 🔴
1. house_repository.dart:45 - SQL拼接，存在注入风险
   ```dart
   // 当前代码
   "SELECT * FROM houses WHERE id = $houseId"
   
   // 建议改为
   "SELECT * FROM houses WHERE id = ?", [houseId]
   ```

### 业务逻辑问题 🟡
1. 分页最大限制100，但未在代码中体现，建议在API层限制

### 结论
❌ 不通过 - 必须修复安全问题后重新Review
```

---

## 八、常见问题处理

| 问题 | 处理方式 |
|------|----------|
| 开发者不同意修改意见 | 升级到技术负责人仲裁 |
| Review时间不够 | 优先检查安全和核心业务逻辑 |
| 代码量太大（>500行） | 要求拆分为小PR |
| 紧急上线无法完整Review | 先检查安全，技术债记录待修复 |

---

## 九、Review工具推荐

| 工具 | 用途 | 链接 |
|------|------|------|
| Flutter DevTools | 性能分析 | flutter.dev/tools/devtools |
| Dart Code Metrics | 代码质量分析 | pub.dev/packages/dart_code_metrics |
| SonarQube | 持续代码质量 | sonarqube.org |
| GitHub/GitLab Review | PR Review | - |

---

## 十、Checklist速查表

### Flutter Review Checklist

```
□ flutter analyze 无警告
□ flutter test 全部通过
□ 无使用any的依赖
□ Widget有const优化
□ 平台通道有异常处理
□ 图片使用缓存
□ 列表使用builder
□ 异步操作有loading
```

### 后端Review Checklist

```
□ 单元测试通过
□ 无SQL注入
□ 接口有鉴权
□ 参数有校验
□ 日志无敏感信息
□ 错误码统一
□ 复杂查询有索引
□ 无N+1查询
```
