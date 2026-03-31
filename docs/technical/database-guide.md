# 缅甸房产平台数据库技术指南

## 1. 概述

### 1.1 数据库基本信息
- **数据库类型**: PostgreSQL 15
- **扩展**: uuid-ossp, postgis, pg_trgm
- **表数量**: 35张
- **设计日期**: 2026-03-17

### 1.2 启用扩展
```sql
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";    -- UUID生成
CREATE EXTENSION IF NOT EXISTS "postgis";       -- 地理空间数据
CREATE EXTENSION IF NOT EXISTS "pg_trgm";       -- 模糊搜索
```

## 2. 数据库表分类

### 2.1 模块分类总览

| 模块 | 表数量 | 表名 |
|------|--------|------|
| 用户模块 | 6 | users, user_verifications, user_profiles, user_oauths, user_devices, user_favorites, user_browsing_history, sms_verification_codes |
| 经纪人模块 | 5 | companies, agents, agent_statistics, teams, team_members |
| 房源模块 | 7 | cities, districts, communities, houses, house_images, house_videos, house_audit_logs, house_price_history |
| 验真模块 | 3 | verification_tasks, verification_items, verification_photos |
| 客户模块 | 2 | clients, client_follow_ups |
| 预约模块 | 2 | appointments, agent_schedules |
| IM消息模块 | 3 | conversations, messages, quick_replies |
| ACN分佣模块 | 3 | acn_roles, acn_transactions, acn_commission_details, acn_disputes |
| 财务管理模块 | 3 | agent_accounts, agent_account_logs, withdrawal_requests |
| 地推模块 | 2 | promoters, promotion_tasks |
| 后台管理模块 | 4 | admins, system_configs, banners, operation_logs |

> **总计**: 35张表

## 3. 核心表详细说明

### 3.1 用户模块 (User Module)

#### users - 用户基础表
| 字段 | 类型 | 说明 |
|------|------|------|
| id | BIGSERIAL | 主键，自增 |
| uuid | UUID | 唯一标识，对外暴露使用 |
| phone | VARCHAR(20) | 手机号，唯一索引 |
| email | VARCHAR(255) | 邮箱 |
| password_hash | VARCHAR(255) | 密码哈希 |
| status | VARCHAR(20) | active/inactive/suspended/deleted |
| user_type | VARCHAR(20) | individual/company/admin |

**关键索引**: `idx_users_phone`, `idx_users_status`

#### user_profiles - 用户资料表
| 字段 | 类型 | 业务说明 |
|------|------|----------|
| user_id | BIGINT | 关联users表 |
| preferred_city | VARCHAR(50) | 意向城市 |
| preferred_districts | VARCHAR(255) | 意向区域（JSON数组） |
| budget_min/budget_max | BIGINT | 预算范围（缅分） |

#### user_favorites - 用户收藏表
- 功能: 用户收藏房源
- 唯一约束: `(user_id, house_id)`
- 索引: 分别对用户和房源建立索引用于查询

---

### 3.2 房源模块 (House Module)

#### houses - 房源主表
**这是系统最核心的业务表，字段较多，按功能分组说明：**

**基础信息**
| 字段 | 类型 | 说明 |
|------|------|------|
| house_code | VARCHAR(50) | 房源编码，唯一 |
| title/title_my | VARCHAR(500) | 标题（中文/缅语） |
| transaction_type | VARCHAR(20) | sale-出售 / rent-出租 |
| house_type | VARCHAR(50) | 房屋类型 |
| status | VARCHAR(20) | 房源状态 |

**价格信息**
| 字段 | 类型 | 说明 |
|------|------|------|
| price | BIGINT | 价格（缅分） |
| price_unit | VARCHAR(20) | 价格单位 |
| original_price | BIGINT | 原价（调价记录） |

**户型面积**
| 字段 | 类型 | 说明 |
|------|------|------|
| area | DECIMAL(10,2) | 建筑面积 |
| usable_area | DECIMAL(10,2) | 使用面积 |
| rooms | VARCHAR(20) | 户型描述如"3室2厅" |
| bedrooms/living_rooms/bathrooms/kitchens | INT | 各房间数 |

**位置信息**
| 字段 | 类型 | 说明 |
|------|------|------|
| city_id/district_id/community_id | INT/BIGINT | 城市/区域/小区 |
| address/address_my | TEXT | 地址 |
| latitude/longitude | DECIMAL | 经纬度坐标 |

**ACN归属**
| 字段 | 类型 | 业务说明 |
|------|------|----------|
| entrant_id | BIGINT | 录入人（首次录入房源的经纪人） |
| maintainer_id | BIGINT | 维护人（日常维护房源的经纪人） |
| company_id | BIGINT | 所属公司 |

**验真状态**
| 字段 | 类型 | 说明 |
|------|------|------|
| verification_status | VARCHAR(20) | unverified/verifying/verified/failed |
| verified_at | TIMESTAMP | 验真通过时间 |
| verifier_id | BIGINT | 执行验真的经纪人 |

**推广相关**
| 字段 | 类型 | 说明 |
|------|------|------|
| is_featured | BOOLEAN | 是否精选 |
| is_urgent | BOOLEAN | 是否急售 |
| view_count/favorite_count/inquiry_count/showing_count | INT | 统计字段 |

**重要索引**
```sql
-- 状态查询
idx_houses_status ON houses(status)
idx_houses_transaction_type ON houses(transaction_type)

-- 地理查询
idx_houses_city_id ON houses(city_id)
idx_houses_district_id ON houses(district_id)

-- 价格/面积范围查询
idx_houses_price ON houses(price)
idx_houses_area ON houses(area)

-- ACN归属查询
idx_houses_entrant_id ON houses(entrant_id)
idx_houses_maintainer_id ON houses(maintainer_id)

-- 搜索专用（全文检索）
idx_houses_search ON houses USING GIN(
    to_tsvector('simple', COALESCE(title, '') || ' ' || COALESCE(address, ''))
)
```

#### cities/districts/communities - 地理层级表
**层级关系**: cities → districts → communities

**cities - 城市表**
| 字段 | 说明 |
|------|------|
| code | 城市编码，如"yangon" |
| name/name_en/name_my | 多语言名称 |
| latitude/longitude | 城市中心坐标 |

**districts - 镇区表**
- 关联: `city_id` 指向 cities
- 唯一约束: `(city_id, code)`

**communities - 商圈/小区表**
| 字段 | 说明 |
|------|------|
| district_id | 所属镇区 |
| alias | 别名（JSON数组） |
| build_year | 建造年份 |
| avg_price | 小区均价 |
| facilities | 配套设施（JSONB） |

---

### 3.3 ACN分佣模块 (ACN Commission Module)

这是系统的**核心业务模块**，实现5角色的佣金分配机制。

#### acn_roles - ACN角色定义表
**5角色模型**:

| 角色代码 | 角色名称 | 默认比例 | 类型 | 说明 |
|----------|----------|----------|------|------|
| ENTRANT | 房源录入人 | 15% | source | 首个录入房源的经纪人 |
| MAINTAINER | 房源维护人 | 20% | source | 日常维护、陪同看房 |
| INTRODUCER | 客源转介绍 | 10% | client | 首次推荐客户 |
| ACCOMPANIER | 带看人 | 15% | client | 实际陪同看房 |
| CLOSER | 成交人 | 40% | client | 最终促成签约 |

> **注**: 平台收取 10% 服务费，实际分配 90% 佣金

#### acn_transactions - ACN成交单表
**核心字段说明**:

| 字段组 | 字段 | 说明 |
|--------|------|------|
| 成交信息 | deal_price | 成交价格 |
| | commission_amount | 佣金总额 |
| | deal_date | 成交日期 |
| 房源方 | entrant_id / entrant_ratio / entrant_amount | 录入人 |
| | maintainer_id / maintainer_ratio / maintainer_amount | 维护人 |
| 客源方 | introducer_id / introducer_ratio / introducer_amount | 转介绍 |
| | accompanier_id / accompanier_ratio / accompanier_amount | 带看人 |
| | closer_id / closer_ratio / closer_amount | 成交人（必填） |
| 平台 | platform_ratio / platform_amount | 平台服务费 |
| 状态 | status | pending_confirm/confirmed/disputed/settled/cancelled |

**状态流转**:
```
pending_confirm → confirmed → settled
       ↓
   disputed → resolved
```

#### acn_commission_details - 分佣明细表
- 每笔成交为每个参与角色生成一条明细
- 支持单独确认、申诉、支付
- 关键字段: `status` (pending/confirmed/disputed/paid)

---

### 3.4 预约带看模块 (Appointment Module)

#### appointments - 预约表
| 字段 | 说明 |
|------|------|
| appointment_code | 预约编号，唯一 |
| house_id | 房源 |
| client_id | 客户 |
| agent_id | 带看经纪人 |
| appointment_date | 预约日期 |
| appointment_time_start/end | 预约时间段 |
| status | pending/confirmed/rejected/cancelled/completed/no_show |

**客户信息快照**:
- `client_name`, `client_phone`, `client_note`
- 原因: 客户信息可能变更，预约时需保存当时的信息

**带看反馈**:
- `showing_result`: interested/considering/not_interested/negotiating
- `showing_feedback`: 文字反馈

#### agent_schedules - 经纪人时间表
- 用于管理经纪人的可预约时段
- 字段: `work_date`, `time_slot`, `is_available`, `max_appointments`, `booked_count`
- 唯一约束: `(agent_id, work_date, time_slot)`

---

### 3.5 财务管理模块 (Finance Module)

#### agent_accounts - 账户余额表
| 字段 | 说明 |
|------|------|
| balance | 可用余额（缅分） |
| frozen_amount | 冻结金额 |
| total_earned | 累计收入 |
| total_withdrawn | 累计提现 |

#### agent_account_logs - 账户流水表
- 类型: commission/bonus/penalty/withdrawal/refund
- 记录每次余额变动的明细

#### withdrawal_requests - 提现申请表
**状态流转**:
```
pending → approved → processing → completed
     ↓
  rejected / failed
```

---

## 4. 核心表关系图

```
┌─────────────────────────────────────────────────────────────────┐
│                         用户体系                                 │
├──────────────┬──────────────┬──────────────┬──────────────────┤
│    users     │user_profiles │ user_oauths  │  user_devices    │
└──────┬───────┴──────────────┴──────────────┴──────────────────┘
       │
       │ 1:1
       ▼
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│    agents   │────▶│  companies  │     │    teams    │
└──────┬──────┘     └─────────────┘     └──────┬──────┘
       │                                        │
       │                                        │
       ▼                                        ▼
┌─────────────────────────────────────────────────────────────┐
│                      房源体系                                │
│  ┌─────────┐   ┌─────────┐   ┌─────────┐   ┌─────────┐    │
│  │  cities │──▶│districts│──▶│communities│ │ houses  │    │
│  └─────────┘   └─────────┘   └─────────┘   └────┬────┘    │
│                                                 │          │
│                        ┌────────────────────────┘          │
│                        ▼                                   │
│  ┌──────────────┐  ┌─────────────┐  ┌──────────────┐      │
│  │ house_images │  │ house_videos │  │ house_audit_logs │ │
│  └──────────────┘  └─────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                      ACN分佣体系                             │
│                                                             │
│  ┌─────────────────┐                                        │
│  │   acn_roles     │ (角色定义)                              │
│  └─────────────────┘                                        │
│           ▲                                                 │
│           │                                                 │
│  ┌────────┴──────────────────────────────────────────┐     │
│  │              acn_transactions                      │     │
│  │  (成交单 - 包含5角色分配比例和金额)                │     │
│  └────────────────────────────────────────────────────┘     │
│           │                                                 │
│           ▼                                                 │
│  ┌─────────────────┐      ┌─────────────────┐              │
│  │acn_commission_  │      │   acn_disputes  │              │
│  │    details      │      │   (争议申诉)    │              │
│  └─────────────────┘      └─────────────────┘              │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                    财务管理体系                              │
│                                                             │
│  ┌───────────────┐  ┌───────────────┐  ┌─────────────────┐ │
│  │ agent_accounts│  │agent_account_ │  │withdrawal_      │ │
│  │   (余额)      │  │    logs       │  │   requests      │ │
│  │               │  │  (流水明细)   │  │   (提现申请)    │ │
│  └───────────────┘  └───────────────┘  └─────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

---

## 5. 关键索引说明

### 5.1 搜索优化索引

#### 房源全文搜索
```sql
CREATE INDEX idx_houses_search ON houses USING GIN (
    to_tsvector('simple', COALESCE(title, '') || ' ' || COALESCE(address, ''))
);
```
- 用途: 支持房源标题和地址的模糊搜索
- 技术: PostgreSQL 全文检索 + GIN 索引

### 5.2 地理查询索引
```sql
-- 需要PostGIS扩展
CREATE INDEX idx_houses_location ON houses USING GIST(location);
```
- 用途: 地图找房、附近房源搜索
- 注: 当前schema中该索引被注释掉

### 5.3 外键查询索引
所有外键字段都建立了索引以优化JOIN查询:
- `idx_houses_city_id`, `idx_houses_district_id`
- `idx_appointments_house_id`, `idx_appointments_agent_id`
- `idx_conversations_user_id`, `idx_conversations_agent_id`

### 5.4 业务查询索引
- `idx_houses_status`: 按状态筛选房源
- `idx_houses_price`, `idx_houses_area`: 价格/面积范围查询
- `idx_acn_transactions_deal_date`: 按成交日期统计

---

## 6. 性能注意事项

### 6.1 大数据量表
| 表名 | 预计数据量 | 注意事项 |
|------|-----------|----------|
| houses | 百万级 | 已建立多维度索引，注意定期分析表 |
| house_images | 千万级 | 考虑按house_id分区 |
| messages | 千万级 | 考虑按conversation_id分区 |
| operation_logs | 亿级 | 建议归档策略，定期清理历史数据 |
| agent_account_logs | 千万级 | 考虑按时间分区 |

### 6.2 JSONB字段使用
以下表使用JSONB存储灵活数据:

| 表 | 字段 | 用途 |
|---|------|------|
| user_oauths | provider_data | 第三方登录原始数据 |
| communities | facilities | 小区配套设施 |
| communities | images | 小区图片 |
| houses | highlights | 房源亮点标签 |
| houses | facilities | 房源配套设施 |
| acn_transactions | confirmed_by | 确认人信息 |

**JSONB查询建议**:
- 使用 `->>` 操作符提取字段
- 对常用查询的JSONB路径建立GIN索引

### 6.3 触发器
所有核心表都有 `updated_at` 自动更新触发器:
```sql
CREATE TRIGGER update_houses_updated_at
BEFORE UPDATE ON houses
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
```

涉及的表: users, user_profiles, agents, houses, conversations, messages 等

---

## 7. 数据一致性约束

### 7.1 CHECK约束示例
```sql
-- 房源状态检查
status VARCHAR(20) CHECK (status IN (
    'pending', 'under_review', 'approved',
    'rejected', 'online', 'offline',
    'sold', 'rented', 'expired'
))

-- ACN比例检查
platform_ratio DECIMAL(5,2) DEFAULT 10.00
-- 业务逻辑: 各角色比例之和应为90%，平台10%
```

### 7.2 唯一约束
```sql
-- 用户手机号唯一
phone VARCHAR(20) UNIQUE

-- 用户收藏唯一
UNIQUE(user_id, house_id)

-- 城市编码唯一
code VARCHAR(20) UNIQUE

-- ACN角色代码唯一
code VARCHAR(20) UNIQUE
```

---

## 8. 数据归档建议

### 8.1 归档策略

| 表 | 归档条件 | 归档方式 |
|---|----------|----------|
| operation_logs | created_at > 1年 | 迁移到冷存储 |
| sms_verification_codes | created_at > 7天 | 直接删除 |
| user_browsing_history | 保留最近100条/用户 | 删除旧记录 |
| house_audit_logs | created_at > 2年 | 迁移到冷存储 |
| acn_transactions | status='cancelled' 且 > 1年 | 迁移到冷存储 |

### 8.2 分区建议

对于高写入的表，建议按时间分区:
```sql
-- messages表示例
CREATE TABLE messages_2024_01 PARTITION OF messages
FOR VALUES FROM ('2024-01-01') TO ('2024-02-01');
```

---

## 9. 常用查询示例

### 9.1 查询经纪人带看的房源
```sql
SELECT h.*, a.real_name as agent_name
FROM houses h
JOIN appointments apt ON h.id = apt.house_id
JOIN agents a ON apt.agent_id = a.id
WHERE apt.agent_id = ?
AND apt.status = 'completed'
ORDER BY apt.appointment_date DESC;
```

### 9.2 查询ACN佣金分配
```sql
SELECT
    t.transaction_code,
    t.deal_price,
    t.commission_amount,
    t.platform_amount,
    ae.real_name as entrant_name,
    t.entrant_amount,
    am.real_name as maintainer_name,
    t.maintainer_amount,
    ac.real_name as closer_name,
    t.closer_amount
FROM acn_transactions t
LEFT JOIN agents ae ON t.entrant_id = ae.id
LEFT JOIN agents am ON t.maintainer_id = am.id
LEFT JOIN agents ac ON t.closer_id = ac.id
WHERE t.status = 'confirmed';
```

### 9.3 房源搜索（全文检索）
```sql
SELECT *
FROM houses
WHERE status = 'online'
AND to_tsvector('simple', title || ' ' || address) @@ plainto_tsquery('simple', '关键词')
ORDER BY created_at DESC;
```

---

## 10. 数据库维护检查清单

- [ ] 定期执行 `ANALYZE` 更新统计信息
- [ ] 监控慢查询日志
- [ ] 定期检查索引使用情况
- [ ] 定期归档历史数据
- [ ] 监控表空间增长
- [ ] 定期备份（建议每日全量+实时增量）

---

**文档版本**: v1.0
**最后更新**: 2026-03-31
**维护人**: 技术团队
