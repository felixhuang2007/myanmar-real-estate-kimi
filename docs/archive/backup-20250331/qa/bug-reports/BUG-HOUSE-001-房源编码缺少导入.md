# Bug-20260317-002: 房源编码生成缺少导入

## Bug基本信息

| 字段 | 内容 |
|------|------|
| Bug ID | BUG-HOUSE-001 |
| 报告日期 | 2026-03-17 |
| 报告人 | AI测试工程师 |
| 模块 | 房源模块 |
| 功能 | 房源编码生成 |
| 严重程度 | ⬜ 致命 ⬜ 严重 ⬜ 一般 ⬜ 轻微 |
| 优先级 | ⬜ P0 ⬜ P1 ⬜ P2 ⬜ P3 |
| Bug类型 | ⬜ 功能 ⬜ 性能 ⬜ 兼容性 ⬜ UI ⬜ 安全 |

---

## 环境信息

| 字段 | 内容 |
|------|------|
| 测试环境 | ⬜ 开发环境 ⬜ 测试环境 ⬜ 预发布 ⬜ 生产环境 |
| 代码版本 | main @ 2026-03-17 |
| 文件位置 | `backend/04-house-service/repository.go` |

---

## Bug描述

### 问题概述
`GenerateHouseCode`函数使用了`time`和`rand`包，但文件头部缺少对应的import语句，导致编译失败。

### 问题代码
```go
// backend/04-house-service/repository.go

package repository

import (
    "context"
    "fmt"
    // "time"    // ❌ 缺少
    // "math/rand"  // ❌ 缺少
    "gorm.io/gorm"
    "myanmar-property/backend/04-house-service"
)

// ...

// GenerateHouseCode 生成房源编码
func GenerateHouseCode() string {
    return fmt.Sprintf("HS%s%06d", time.Now().Format("20060102"), rand.Intn(999999))
    // 编译错误：undefined: time
    // 编译错误：undefined: rand
}
```

### 预期结果
代码应能正常编译通过。

### 实际结果
编译失败，错误信息：
```
./repository.go:XXX: undefined: time
./repository.go:XXX: undefined: rand
```

---

## 修复方案

```go
package repository

import (
    "context"
    "fmt"
    "math/rand"  // ✅ 添加
    "time"       // ✅ 添加
    "gorm.io/gorm"
    "myanmar-property/backend/04-house-service"
)
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
