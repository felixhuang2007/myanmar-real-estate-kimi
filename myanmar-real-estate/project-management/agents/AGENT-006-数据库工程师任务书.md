# AGENT-006 任务书 - 数据库工程师

> **角色**: 数据库工程师  
> **代号**: AGENT-006  
> **项目**: 缅甸房产平台  
> **周期**: 8周  
> **汇报对象**: AI项目经理

---

## 一、角色职责

1. **数据库设计**: 设计完整的数据库Schema，包括表结构、索引、关系
2. **性能优化**: 优化数据库性能，确保高并发下的查询效率
3. **数据迁移**: 编写数据库迁移脚本，支持版本管理
4. **数据安全**: 设计数据备份策略，确保数据安全
5. **查询优化**: 优化复杂查询，编写高效SQL

---

## 二、任务清单

### Week 1: 数据库架构设计

| 任务ID | 任务描述 | 交付物 | 截止时间 | 优先级 |
|--------|----------|--------|----------|--------|
| D006-001 | 数据库选型与版本确定 | 选型报告 | Day 1 | P0 |
| D006-002 | 数据库架构设计 | 架构文档 | Day 2 | P0 |
| D006-003 | 命名规范制定 | 规范文档 | Day 3 | P0 |
| D006-004 | 用户模块表设计 | 用户表Schema | Day 4 | P0 |
| D006-005 | 房源模块表设计 | 房源表Schema | Day 5 | P0 |
| D006-006 | ER图绘制 | ER图 | Day 5 | P0 |

### Week 2: 核心表结构与迁移

| 任务ID | 任务描述 | 交付物 | 截止时间 | 优先级 |
|--------|----------|--------|----------|--------|
| D006-007 | 用户相关表DDL | 用户表Migration | Day 7 | P0 |
| D006-008 | 房源相关表DDL | 房源表Migration | Day 9 | P0 |
| D006-009 | 索引设计 | 索引脚本 | Day 10 | P0 |
| D006-010 | 基础数据初始化 | Seed数据 | Day 11 | P0 |
| D006-011 | 数据库文档 | Schema文档 | Day 12 | P0 |

### Week 3: 交易与预约模块

| 任务ID | 任务描述 | 交付物 | 截止时间 | 优先级 |
|--------|----------|--------|----------|--------|
| D006-012 | 预约订单表设计 | 预约表Schema | Day 14 | P0 |
| D006-013 | 收藏表设计 | 收藏表Schema | Day 15 | P0 |
| D006-014 | IM消息表设计 | 消息表Schema | Day 16 | P0 |
| D006-015 | 会话表设计 | 会话表Schema | Day 17 | P0 |
| D006-016 | 搜索相关索引 | 搜索索引 | Day 18 | P0 |
| D006-017 | 地图GeoHash索引 | 空间索引 | Day 19 | P0 |

### Week 4: 验真与工作流

| 任务ID | 任务描述 | 交付物 | 截止时间 | 优先级 |
|--------|----------|--------|----------|--------|
| D006-018 | 验真任务表设计 | 验真表Schema | Day 21 | P0 |
| D006-019 | 验真报告表设计 | 报告表Schema | Day 22 | P0 |
| D006-020 | 工作流状态表设计 | 状态机表 | Day 23 | P0 |
| D006-021 | 客户管理表设计 | CRM表Schema | Day 24 | P0 |
| D006-022 | 客户跟进表设计 | 跟进表Schema | Day 25 | P0 |
| D006-023 | 图片资源表设计 | 图片表Schema | Day 26 | P0 |

### Week 5: ACN与分佣

| 任务ID | 任务描述 | 交付物 | 截止时间 | 优先级 |
|--------|----------|--------|----------|--------|
| D006-024 | ACN角色配置表 | ACN配置表 | Day 28 | P0 |
| D006-025 | 成交订单表设计 | 成交表Schema | Day 30 | P0 |
| D006-026 | 分佣明细表设计 | 分佣表Schema | Day 31 | P0 |
| D006-027 | 业绩统计表设计 | 业绩表Schema | Day 32 | P0 |
| D006-028 | 账户余额表设计 | 余额表Schema | Day 33 | P0 |
| D006-029 | 提现记录表设计 | 提现表Schema | Day 34 | P0 |
| D006-030 | 地推关系表设计 | 地推表Schema | Day 35 | P0 |

### Week 6: 后台与运营

| 任务ID | 任务描述 | 交付物 | 截止时间 | 优先级 |
|--------|----------|--------|----------|--------|
| D006-031 | 管理员账户表 | 管理员表 | Day 37 | P0 |
| D006-032 | 权限角色表设计 | RBAC表 | Day 38 | P0 |
| D006-033 | 操作日志表设计 | 日志表Schema | Day 39 | P0 |
| D006-034 | Banner配置表 | Banner表 | Day 40 | P0 |
| D006-035 | 内容管理表设计 | CMS表Schema | Day 41 | P0 |
| D006-036 | 城市区域字典表 | 字典表 | Day 42 | P0 |
| D006-037 | 系统配置表设计 | 配置表Schema | Day 43 | P0 |
| D006-038 | 数据埋点表设计 | 埋点表Schema | Day 44 | P0 |
| D006-039 | 消息通知表设计 | 通知表Schema | Day 45 | P0 |

### Week 7: 优化与视图

| 任务ID | 任务描述 | 交付物 | 截止时间 | 优先级 |
|--------|----------|--------|----------|--------|
| D006-040 | 统计视图创建 | 统计View | Day 47 | P0 |
| D006-041 | 复杂查询优化 | 优化SQL | Day 49 | P0 |
| D006-042 | 分区表设计(大表) | 分区方案 | Day 50 | P0 |
| D006-043 | 读写分离方案 | 分离配置 | Day 51 | P0 |
| D006-044 | 缓存策略设计 | 缓存方案 | Day 52 | P0 |
| D006-045 | 慢查询监控配置 | 监控配置 | Day 53 | P0 |
| D006-046 | 数据库性能测试 | 测试报告 | Day 54 | P0 |
| D006-047 | 存储过程(复杂计算) | 存储过程 | Day 55 | P0 |

### Week 8: 交付与文档

| 任务ID | 任务描述 | 交付物 | 截止时间 | 优先级 |
|--------|----------|--------|----------|--------|
| D006-048 | 备份脚本编写 | 备份脚本 | Day 56 | P0 |
| D006-049 | 恢复脚本编写 | 恢复脚本 | Day 57 | P0 |
| D006-050 | 完整Schema导出 | DDL文件 | Day 58 | P0 |
| D006-051 | 数据库文档更新 | 文档 | Day 59 | P0 |
| D006-052 | 生产环境配置 | 配置文档 | Day 60 | P0 |

---

## 三、核心表设计

### 3.1 用户表

```sql
-- 用户基础表
CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    phone VARCHAR(20) UNIQUE NOT NULL,
    password_hash VARCHAR(255),
    nickname VARCHAR(50),
    avatar_url VARCHAR(500),
    real_name VARCHAR(50),
    id_card_number VARCHAR(50),
    id_card_front VARCHAR(500),
    id_card_back VARCHAR(500),
    verify_status SMALLINT DEFAULT 0, -- 0未认证 1审核中 2已认证 3失败
    user_type SMALLINT DEFAULT 1, -- 1普通用户 2房东
    status SMALLINT DEFAULT 1, -- 0禁用 1正常
    last_login_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 索引
CREATE INDEX idx_users_phone ON users(phone);
CREATE INDEX idx_users_verify_status ON users(verify_status);
CREATE INDEX idx_users_created_at ON users(created_at);

COMMENT ON TABLE users IS 'C端用户表';
```

### 3.2 经纪人表

```sql
-- 经纪人表
CREATE TABLE agents (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT REFERENCES users(id),
    agent_no VARCHAR(20) UNIQUE NOT NULL,
    company_name VARCHAR(100),
    company_address VARCHAR(255),
    business_license VARCHAR(100),
    work_city VARCHAR(50),
    work_district VARCHAR(50),
    audit_status SMALLINT DEFAULT 0, -- 0待审核 1审核中 2已通过 3拒绝
    audit_remark TEXT,
    level SMALLINT DEFAULT 1, -- 等级
    credit_score INT DEFAULT 100,
    total_deals INT DEFAULT 0,
    total_commission DECIMAL(15,2) DEFAULT 0,
    status SMALLINT DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_agents_user_id ON agents(user_id);
CREATE INDEX idx_agents_audit_status ON agents(audit_status);
CREATE INDEX idx_agents_city ON agents(work_city, work_district);

COMMENT ON TABLE agents IS '经纪人表';
```

### 3.3 房源表

```sql
-- 房源表
CREATE TABLE houses (
    id BIGSERIAL PRIMARY KEY,
    house_no VARCHAR(30) UNIQUE NOT NULL,
    title VARCHAR(200) NOT NULL,
    transaction_type SMALLINT NOT NULL, -- 1出售 2出租
    house_type SMALLINT NOT NULL, -- 1公寓 2独栋 3联排 4土地 5商业
    price DECIMAL(15,2) NOT NULL,
    price_unit VARCHAR(20), -- 万缅币/月
    area DECIMAL(10,2),
    rooms VARCHAR(20), -- 3室2厅
    bedrooms SMALLINT,
    living_rooms SMALLINT,
    bathrooms SMALLINT,
    floor VARCHAR(20),
    total_floors SMALLINT,
    decoration SMALLINT, -- 1毛坯 2简装 3精装 4豪华
    orientation VARCHAR(20),
    build_year SMALLINT,
    property_type SMALLINT, -- 1地契 2许可证 3合同
    property_certificate VARCHAR(100),
    has_loan BOOLEAN DEFAULT FALSE,
    address TEXT NOT NULL,
    city_code VARCHAR(20),
    district_code VARCHAR(20),
    community_id BIGINT,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    geohash VARCHAR(12),
    description TEXT,
    facilities JSONB,
    images JSONB, -- 图片数组
    video_url VARCHAR(500),
    
    -- 业主信息
    owner_name VARCHAR(50),
    owner_phone VARCHAR(20),
    
    -- 房源方
    entrant_id BIGINT REFERENCES agents(id),
    maintainer_id BIGINT REFERENCES agents(id),
    
    -- 状态
    status SMALLINT DEFAULT 0, -- 0草稿 1待审核 2审核中 3已上架 4已下架 5已成交
    verify_status SMALLINT DEFAULT 0, -- 0未验真 1验真中 2已验真 3失败
    source_type SMALLINT DEFAULT 1, -- 1经纪人录入 2房东自发布
    
    view_count INT DEFAULT 0,
    favorite_count INT DEFAULT 0,
    inquiry_count INT DEFAULT 0,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    published_at TIMESTAMP
);

-- 索引
CREATE INDEX idx_houses_status ON houses(status);
CREATE INDEX idx_houses_verify_status ON houses(verify_status);
CREATE INDEX idx_houses_transaction_type ON houses(transaction_type);
CREATE INDEX idx_houses_city ON houses(city_code, district_code);
CREATE INDEX idx_houses_geohash ON houses(geohash);
CREATE INDEX idx_houses_price ON houses(price);
CREATE INDEX idx_houses_entrant ON houses(entrant_id);
CREATE INDEX idx_houses_maintainer ON houses(maintainer_id);
CREATE INDEX idx_houses_created_at ON houses(created_at);

-- 全文搜索索引
CREATE INDEX idx_houses_title ON houses USING GIN(to_tsvector('english', title));

COMMENT ON TABLE houses IS '房源表';
```

### 3.4 预约表

```sql
-- 预约表
CREATE TABLE appointments (
    id BIGSERIAL PRIMARY KEY,
    appointment_no VARCHAR(30) UNIQUE NOT NULL,
    house_id BIGINT REFERENCES houses(id),
    user_id BIGINT REFERENCES users(id),
    agent_id BIGINT REFERENCES agents(id),
    appointment_date DATE NOT NULL,
    appointment_time TIME NOT NULL,
    status SMALLINT DEFAULT 0, -- 0待确认 1已确认 2已完成 3已取消 4已拒绝
    remark TEXT,
    cancel_reason TEXT,
    user_confirmed BOOLEAN DEFAULT FALSE,
    agent_confirmed BOOLEAN DEFAULT FALSE,
    showing_feedback TEXT,
    showing_rating SMALLINT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_appointments_user_id ON appointments(user_id);
CREATE INDEX idx_appointments_agent_id ON appointments(agent_id);
CREATE INDEX idx_appointments_house_id ON appointments(house_id);
CREATE INDEX idx_appointments_status ON appointments(status);
CREATE INDEX idx_appointments_date ON appointments(appointment_date);

COMMENT ON TABLE appointments IS '预约带看表';
```

### 3.5 ACN成交表

```sql
-- ACN成交表
CREATE TABLE acn_deals (
    id BIGSERIAL PRIMARY KEY,
    deal_no VARCHAR(30) UNIQUE NOT NULL,
    house_id BIGINT REFERENCES houses(id),
    transaction_type SMALLINT NOT NULL, -- 1出售 2出租
    deal_price DECIMAL(15,2) NOT NULL,
    commission_amount DECIMAL(15,2) NOT NULL,
    platform_fee DECIMAL(15,2) NOT NULL, -- 平台服务费
    
    -- 参与方
    entrant_id BIGINT REFERENCES agents(id), -- 录入人
    entrant_ratio DECIMAL(5,2) DEFAULT 0.15,
    entrant_amount DECIMAL(15,2),
    
    maintainer_id BIGINT REFERENCES agents(id), -- 维护人
    maintainer_ratio DECIMAL(5,2) DEFAULT 0.20,
    maintainer_amount DECIMAL(15,2),
    
    introducer_id BIGINT REFERENCES agents(id), -- 转介绍
    introducer_ratio DECIMAL(5,2) DEFAULT 0.10,
    introducer_amount DECIMAL(15,2),
    
    accompanier_id BIGINT REFERENCES agents(id), -- 带看人
    accompanier_ratio DECIMAL(5,2) DEFAULT 0.15,
    accompanier_amount DECIMAL(15,2),
    
    closer_id BIGINT REFERENCES agents(id) NOT NULL, -- 成交人
    closer_ratio DECIMAL(5,2) DEFAULT 0.40,
    closer_amount DECIMAL(15,2),
    
    status SMALLINT DEFAULT 0, -- 0待确认 1已确认 2结算中 3已结算 4争议
    contract_image VARCHAR(500),
    deal_date DATE NOT NULL,
    settle_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_acn_deals_house_id ON acn_deals(house_id);
CREATE INDEX idx_acn_deals_closer_id ON acn_deals(closer_id);
CREATE INDEX idx_acn_deals_status ON acn_deals(status);
CREATE INDEX idx_acn_deals_deal_date ON acn_deals(deal_date);

COMMENT ON TABLE acn_deals IS 'ACN成交表';
```

---

## 四、命名规范

### 4.1 表命名

- 小写字母，下划线分隔
- 复数形式
- 业务前缀(可选): `sys_`系统表, `log_`日志表

### 4.2 字段命名

- 小写字母，下划线分隔
- 主键: `id`
- 外键: `{table}_id`
- 状态字段: `{entity}_status`或`status`
- 时间字段: `{action}_at`
- 布尔字段: `is_{description}`或`has_{description}`

### 4.3 索引命名

- 主键: `pk_{table}`
- 唯一索引: `uk_{table}_{column}`
- 普通索引: `idx_{table}_{column}`

---

## 五、验收标准

### 5.1 设计验收

- [ ] 所有表结构符合三范式
- [ ] 索引设计合理，覆盖查询场景
- [ ] 字段类型选择合理
- [ ] 外键关系定义清晰
- [ ] 有完整的注释

### 5.2 性能验收

- [ ] 主键查询 < 10ms
- [ ] 索引查询 < 50ms
- [ ] 复杂查询 < 200ms
- [ ] 批量插入 > 1000条/秒

### 5.3 文档验收

- [ ] ER图完整
- [ ] 表结构文档
- [ ] 索引说明文档
- [ ] 迁移脚本可执行

---

## 六、依赖与协作

### 6.1 我依赖谁

| 依赖 | 内容 | 时间 |
|------|------|------|
| AGENT-001 | 架构设计 | Week 1 |

### 6.2 谁依赖我

| 依赖方 | 内容 | 时间 |
|--------|------|------|
| AGENT-002 | 数据模型 | Week 1-2 |
| 全体开发 | 表结构 | Week 1+ |

---

*任务书创建: 2026-03-17*  
*版本: v1.0*
