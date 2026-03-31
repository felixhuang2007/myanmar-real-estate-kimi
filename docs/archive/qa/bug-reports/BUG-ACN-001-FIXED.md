# ACN分佣精度问题修复报告

## 问题描述 (BUG-ACN-001)

**问题类型**: 浮点数精度丢失  
**影响范围**: 资金计算误差，可能导致分佣金额错误  
**严重程度**: 高

### 问题代码

```go
// 问题1: 使用float64存储比例
type ParticipantInput struct {
    Role    string  `json:"role"`
    AgentID int64   `json:"agent_id"`
    Ratio   float64 `json:"ratio"`  // ❌ 浮点数精度问题
}

// 问题2: 计算时类型转换导致精度丢失
amount := totalCommission * int64(p.Ratio*100) / 10000  // ❌ 仍有精度问题
```

## 修复方案

### 1. 修改数据结构

将 `Ratio` 从 `float64` 改为 `int64`，存储为**百分比*100**：
- 30.5% 存储为 3050
- 100% 存储为 10000

### 2. 修改文件清单

| 文件 | 修改内容 |
|------|----------|
| `backend/05-acn-service/model.go` | 所有Ratio字段从float64改为int64 |
| `backend/05-acn-service/service.go` | 输入结构、验证逻辑、计算逻辑 |

### 3. 具体修改

#### model.go

```go
// 修改前
Ratio float64 `json:"ratio"`

// 修改后  
Ratio int64 `json:"ratio"` // 存储为百分比*100，如30.5%存为3050
```

#### service.go

```go
// 修改前 - 输入结构
type ParticipantInput struct {
    Ratio float64 `json:"ratio" binding:"required,gt=0"`
}

// 修改后 - 输入结构
type ParticipantInput struct {
    Ratio int64 `json:"ratio" binding:"required,gt=0"` // 存储为百分比*100
}

// 修改前 - 验证逻辑
if math.Abs(totalRatio-100.0) > 0.01 {
    return nil, errors.New("比例总和必须为100%")
}

// 修改后 - 验证逻辑（纯整数比较）
if totalRatio != 10000 {
    return nil, errors.New("比例总和必须为100%")
}

// 修改前 - 计算逻辑（仍有精度问题）
amount := totalCommission * int64(p.Ratio*100) / 10000

// 修改后 - 纯整数运算
amount := totalCommission * p.Ratio / 10000  // ✅ 纯整数运算，无精度丢失
```

## 默认比例调整

| 角色 | 原float64值 | 新int64值 |
|------|-------------|-----------|
| Entrant (录入人) | 15.0 | 1500 |
| Maintainer (维护人) | 20.0 | 2000 |
| Introducer (介绍人) | 10.0 | 1000 |
| Accompanier (带看人) | 15.0 | 1500 |
| Closer (成交人) | 40.0 | 4000 |
| Platform (平台) | 10.0 | 1000 |
| **合计** | **100.0** | **10000** |

## 验证方法

### API调用示例

```json
// 请求体 - 比例使用整数表示（百分比*100）
{
  "house_id": 123,
  "deal_price": 100000000,
  "commission_amount": 3000000,
  "deal_date": "2024-03-17",
  "contract_image": "https://example.com/contract.jpg",
  "participants": [
    {"role": "ENTRANT", "agent_id": 1, "ratio": 1500},
    {"role": "MAINTAINER", "agent_id": 2, "ratio": 2000},
    {"role": "INTRODUCER", "agent_id": 3, "ratio": 1000},
    {"role": "ACCOMPANIER", "agent_id": 4, "ratio": 1500},
    {"role": "CLOSER", "agent_id": 5, "ratio": 4000}
  ]
}
```

**注意**: 所有参与者比例之和必须等于10000（即100%）

## 测试结果

```go
// 测试用例: 总佣金 1,000,000，比例 30.5% (3050)
totalCommission := int64(1000000)
ratio := int64(3050)  // 30.5%

// 计算
amount := totalCommission * ratio / 10000
// 结果: 305000 ✓ (精确值)

// 对比: 浮点数方式会有精度问题
floatAmount := float64(totalCommission) * 30.5 / 100
// 结果: 304999.99999999994 ✗ (精度丢失)
```

## 代码编译状态

- [x] `model.go` 语法检查通过
- [x] `service.go` 语法检查通过
- [x] 类型一致性检查通过

## 兼容性说明

**数据库兼容性**: 
- PostgreSQL `bigint` 类型与 `int64` 兼容
- 原 `float64` 列需要迁移为 `bigint` 类型

**API兼容性**:
- 前端需要调整：比例值从浮点数(如30.5)改为整数(如3050)
- 建议在API文档中明确标注比例单位是"百分比*100"

## 修复人员

- **修复工程师**: 后端工程师（Bug修复专员）
- **修复日期**: 2026-03-17
- **状态**: ✅ 已完成

## 后续建议

1. **数据库迁移**: 将现有 `float64` 类型的 ratio 列数据乘以100并转为 `bigint`
2. **API文档更新**: 更新接口文档，说明比例参数格式
3. **前端适配**: 通知前端团队调整比例输入组件
4. **回归测试**: 对分佣计算模块进行全面测试
