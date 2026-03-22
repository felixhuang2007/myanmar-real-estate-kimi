# QA测试文档说明

**技术栈: Flutter跨平台框架**  
适配日期: 2026-03-17

## 文档结构

```
qa/
├── test-cases/              # 测试用例
│   ├── functional/          # 功能测试用例
│   │   ├── c-app.yml       # C端APP测试用例（63个）
│   │   ├── b-app.yml       # B端APP测试用例（50个）
│   │   └── admin.yml       # 管理后台测试用例（45个）
│   ├── api/                 # 接口测试用例
│   │   └── api-tests.yml   # API接口测试用例（47个）
│   ├── compatibility/       # 兼容性测试用例（Flutter适配）
│   │   └── compatibility.yml # 兼容性测试用例（15个）
│   └── statistics.md        # 测试用例统计报告
├── code-review/             # 代码Review
│   ├── template.md          # Review模板
│   └── execution-guide.md   # Review执行指南
├── bug-reports/             # Bug报告
│   └── template.md          # Bug报告模板
└── execution-plan.md        # 测试执行计划
```

## Flutter测试特别说明

### 测试重点

1. **平台通道 (Platform Channel)**
   - MethodChannel调用原生地图/推送/支付
   - 数据序列化/反序列化正确性
   - 异常处理和超时机制

2. **Flutter引擎**
   - 渲染性能（Skia/Impeller）
   - 内存管理
   - 包体积优化

3. **Widget测试**
   - UI组件渲染一致性
   - 状态管理（Provider/BLoC/setState）
   - 响应式布局适配

### Flutter测试命令

```bash
# 静态分析
flutter analyze

# 单元测试
flutter test

# 集成测试
flutter drive --target=test_driver/app.dart

# 性能分析
flutter run --profile

# 构建Release
flutter build apk --release
flutter build ios --release
```

## 测试用例统计

| 类别 | 用例数量 | 占比 |
|------|----------|------|
| C端APP功能测试 | 63 | 32.3% |
| B端APP功能测试 | 50 | 25.6% |
| 管理后台功能测试 | 45 | 23.1% |
| 接口测试 | 47 | 23.0% |
| 兼容性测试(Flutter) | 15 | 7.4% |
| **总计** | **220** | **100%** |

> 注：部分接口用例与功能用例有重叠，去重后总计约197个独立用例

## 优先级分布

| 优先级 | 说明 | 数量 | 占比 |
|--------|------|------|------|
| P0 (核心) | 必须测试 | 131 | 66.2% |
| P1 (重要) | 建议测试 | 52 | 26.4% |
| P2 (一般) | 可选测试 | 14 | 7.1% |

## 执行计划

详见 `execution-plan.md`：
- 准备阶段：环境、数据、账号
- 冒烟测试：2小时，执行P0用例
- 功能测试：8小时，全量用例
- 兼容测试：3小时，Flutter专项
- 代码Review：使用 `code-review/execution-guide.md`
- Bug追踪：使用 `bug-reports/template.md`

## 使用指南

### 1. 功能测试执行

```bash
# 按模块执行
# C端账号模块：TC-C-001 ~ TC-C-011
# C端搜索模块：TC-C-031 ~ TC-C-038
# B端录房模块：TC-B-011 ~ TC-B-016
# ...以此类推
```

### 2. 接口测试执行

使用Postman或JMeter导入测试用例，按模块执行：
- 用户模块：API-001 ~ API-009
- 房源模块：API-021 ~ API-029
- IM模块：API-041 ~ API-047
- 预约模块：API-061 ~ API-070
- ACN模块：API-081 ~ API-088

### 3. 兼容性测试

在以下设备/环境执行兼容性测试用例：
- Android：Samsung、Xiaomi、OPPO、vivo主流机型
- iOS：iPhone 12/13/14/15系列
- 后台：Chrome、Firefox、Safari、Edge

### 4. Bug记录

发现Bug后，使用 `bug-reports/template.md` 模板记录，按以下格式命名文件：
```
bug-reports/BUG-20260317-001.md
```

### 5. 代码Review

各模块开发完成后，使用 `code-review/template.md` 进行代码审查，命名格式：
```
code-review/Review-模块名-日期.md
```

## 测试流程

```
1. 冒烟测试（Smoke Test）
   └─ 执行所有P0用例，确保核心流程通畅

2. 功能测试（Functional Test）
   └─ 执行全部功能测试用例
   └─ 记录Bug并跟踪修复

3. 接口测试（API Test）
   └─ 执行接口测试用例
   └─ 验证接口响应和数据正确性

4. 兼容性测试（Compatibility Test）
   └─ 在多种设备和浏览器上测试

5. 回归测试（Regression Test）
   └─ Bug修复后重新执行相关用例
   └─ 上线前全量回归P0用例
```

## 注意事项

1. **测试数据**：执行测试前需准备充足的测试数据（用户、房源、订单等）
2. **测试环境**：确保测试环境与生产环境配置一致
3. **网络环境**：部分用例需在弱网环境下测试
4. **权限配置**：后台测试需配置不同权限的测试账号
5. **埋点验证**：功能测试同时验证数据埋点是否正确上报

## 更新记录

| 日期 | 版本 | 更新内容 |
|------|------|----------|
| 2026-03-17 | v1.1 | 适配Flutter技术栈，更新兼容性测试和Review指南 |
| 2026-03-17 | v1.0 | 初始版本，完成测试用例设计 |

## 联系方式

如有问题，请联系测试团队。
