# Bug-20260317-001: ACN分佣金额计算精度问题

## Bug基本信息

| 字段 | 内容 |
|------|------|
| Bug ID | BUG-ACN-001 |
| 报告日期 | 2026-03-17 |
| 报告人 | AI测试工程师 |
| 模块 | ACN分佣模块 |
| 功能 | 分佣金额计算 |
| 严重程度 | ⬜ 致命 ⬜ 严重 ⬜ 一般 ⬜ 轻微 |
| 优先级 | ⬜ P0 ⬜ P1 ⬜ P2 ⬜ P3 |
| Bug类型 | ⬜ 功能 ⬜ 性能 ⬜ 兼容性 ⬜ UI ⬜ 安全 |

---

## 环境信息

| 字段 | 内容 |
|------|------|
| 测试环境 | ⬜ 开发环境 ⬜ 测试环境 ⬜ 预发布 ⬜ 生产环境 |
| 代码版本 | main @ 2026-03-17 |
| 文件位置 | `backend/05-acn-service/service.go` |

---

## Bug描述

### 问题概述
ACN分佣金额计算使用`float64`类型进行浮点数运算，可能导致资金计算精度丢失，造成分佣金额与实际应收金额不符。

### 复现代码
```go
// 当前实现（问题代码）
func (s *acnService) calculateCommission(totalCommission int64, participants []ParticipantInput) *model.CommissionCalculationResult {
    platformRatio := s.config.ACN.PlatformRatio  // float64
    platformAmount := int64(float64(totalCommission) * platformRatio / 100)  // 精度问题！
    
    for _, p := range participants {
        amount := int64(float64(totalCommission) * p.Ratio / 100)  // 精度问题！
        // ...
    }
}
```

### 预期结果
分佣金额计算应精确到整数分，不存在精度误差。

例如：佣金1,000,000 MMK，比例15.5%，应得155,000 MMK

### 实际结果
浮点数转换可能导致金额偏差1-2分。

例如：`int64(float64(1000000) * 15.5 / 100)` 可能得到154999或155001

### 复现频率
⬜ 必现 ⬜ 高概率 ⬜ 偶现 ⬜ 无法复现

---

## 建议修复方案

```go
// 方案1：使用整数运算（推荐）
func (s *acnService) calculateCommission(totalCommission int64, participants []ParticipantInput) *model.CommissionCalculationResult {
    // 将比例存储为万分比（整数）
    // 15.5% -> 1550
    platformRatioInt := int64(s.config.ACN.PlatformRatio * 100)  // 1550
    platformAmount := totalCommission * platformRatioInt / 10000  // 精确计算
    
    var results []model.ParticipantResult
    for _, p := range participants {
        ratioInt := int64(p.Ratio * 100)  // 1550
        amount := totalCommission * ratioInt / 10000  // 精确计算
        results = append(results, model.ParticipantResult{
            AgentID:  p.AgentID,
            RoleCode: p.Role,
            Ratio:    p.Ratio,
            Amount:   amount,
        })
    }
    // ...
}

// 方案2：使用decimal库
type CommissionCalculator struct {
    totalCommission decimal.Decimal
}

func (c *CommissionCalculator) Calculate(ratio float64) decimal.Decimal {
    ratioDecimal := decimal.NewFromFloat(ratio)
    return c.totalCommission.Mul(ratioDecimal).Div(decimal.NewFromInt(100))
}
```

---

## 处理流程

| 阶段 | 处理人 | 时间 | 处理结果 |
|------|--------|------|----------|
| 提交 | AI测试工程师 | 2026-03-17 | - |
| 分配 | | | |
| 修复 | | | |
| 验证 | | | |
| 关闭 | | | |

---

**影响范围**: 所有涉及资金计算的功能  
**修复紧急度**: 🔴 极高（涉及资金安全）
