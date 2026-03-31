# 缅甸房产平台 Mock/真实服务切换指南

## 1. 概述

本文档说明系统中各外部服务的 Mock 实现与真实服务切换方法。

### 1.1 服务状态总览

| 服务 | 当前状态 | 真实提供商 | 优先级 |
|------|----------|------------|--------|
| SMS | Mock | 待调研缅甸本地 | P1 |
| IM | 接口预留 | 环信/融云 | P2 |
| 支付 | Mock | KBZ Pay | P1 |
| 文件存储 | 真实(MinIO) | 腾讯云 COS | P1 |
| Elasticsearch | 真实(本地) | 腾讯云 ES | P2 |
| Redis | 真实(本地) | 腾讯云 Redis | P2 |
| 地图 | Mock | Google Maps/高德 | P3 |

---

## 2. SMS 服务

### 2.1 Mock 实现

**配置**:
```yaml
sms:
  provider: mock
  mock_code: "123456"
  expire_minutes: 5
```

**行为**:
- 任何手机号发送验证码，都返回 `123456`
- 验证码5分钟有效
- 不调用真实短信通道

### 2.2 真实服务切换（缅甸本地）

**待调研提供商**:
- MPT SMS Gateway
- Ooredoo SMS API
- Telenor SMS Gateway
- MyTel SMS API

**切换配置**:
```yaml
sms:
  provider: mytel  # 或 mpt, ooredoo, telenor
  api_key: "your-api-key"
  api_secret: "your-api-secret"
  sender_id: "MYANMAR_PROPERTY"
  template_code: "SMS_123456"
```

**切换检查清单**:
- [ ] 获取短信服务商 API 账号
- [ ] 完成实名认证
- [ ] 申请短信签名和模板
- [ ] 测试发送成功率
- [ ] 配置发送频率限制

---

## 3. IM 即时消息服务

### 3.1 当前状态

**已实现**:
- 会话列表/详情 API
- 消息历史查询 API
- 快捷话术管理 API

**预留接口**:
- 发送消息
- 撤回消息
- 实时消息推送

### 3.2 Mock 实现

**配置**:
```yaml
im:
  provider: mock
```

**行为**:
- 发送消息接口返回固定成功
- 不实际推送消息
- 消息历史为空

### 3.3 真实服务切换

#### 方案A: 环信 Easemob

**配置**:
```yaml
im:
  provider: easemob
  app_key: "your-app-key"
  client_id: "your-client-id"
  client_secret: "your-client-secret"
  rest_api: "https://a1.easemob.com"
```

**对接步骤**:
1. 注册环信开发者账号
2. 创建应用获取 App Key
3. 实现服务端 Token 获取
4. 用户注册/登录对接
5. 消息推送对接

#### 方案B: 融云 RongCloud

**配置**:
```yaml
im:
  provider: rongcloud
  app_key: "your-app-key"
  app_secret: "your-app-secret"
  api_url: "https://api-cn.ronghub.com"
```

**对比**:

| 特性 | 环信 | 融云 |
|------|------|------|
| 国内稳定性 | 高 | 高 |
| 海外节点 | 新加坡 | 新加坡 |
| 缅甸访问 | 需测试 | 需测试 |
| 价格 | 按DAU计费 | 按消息量计费 |
| Flutter SDK | 官方支持 | 社区支持 |

**切换检查清单**:
- [ ] 注册 IM 服务商账号
- [ ] 集成 Flutter IM SDK
- [ ] 实现用户体系对接
- [ ] 配置消息推送（FCM/APNs）
- [ ] 测试消息到达率

---

## 4. 支付服务

### 4.1 Mock 实现

**配置**:
```yaml
payment:
  provider: mock
  auto_success: true
```

**行为**:
- 所有支付直接返回成功
- 不调用真实支付通道
- 资金变动为虚拟数据

### 4.2 KBZ Pay 对接（优先）

**简介**:
KBZ Pay 是缅甸 KBZ 银行推出的电子钱包，是当地主流支付方式之一。

**配置**:
```yaml
payment:
  provider: kbzp
  merchant_id: "your-merchant-id"
  api_key: "your-api-key"
  api_secret: "your-api-secret"
  sandbox: true  # 测试环境
```

**对接流程**:
1. 注册 KBZ Pay 商户账号
2. 提交公司资质审核
3. 获取 API 密钥
4. 集成支付 SDK
5. 配置回调地址

**API 清单**:
| API | 说明 |
|-----|------|
| 创建订单 | 发起支付请求 |
| 查询订单 | 查询支付状态 |
| 退款 | 发起退款 |
| 回调通知 | 支付结果通知 |

**切换检查清单**:
- [ ] 注册 KBZ Pay 商户账号
- [ ] 完成公司资质审核
- [ ] 获取生产环境 API 密钥
- [ ] 配置支付回调地址和密钥
- [ ] 测试支付全流程
- [ ] 配置退款流程
- [ ] 处理汇率转换（缅元/美元）

### 4.3 其他支付方式（备选）

| 支付方式 | 提供商 | 状态 |
|----------|--------|------|
| Wave Pay | Wave Money | 调研中 |
| OK Dollar | OK Myanmar | 调研中 |
| CB Pay | CB Bank | 调研中 |
| AYA Pay | AYA Bank | 调研中 |

---

## 5. 文件存储服务

### 5.1 当前实现 (MinIO)

**配置**:
```yaml
storage:
  type: minio
  endpoint: "localhost:9000"
  access_key: "minioadmin"
  secret_key: "minioadmin"
  bucket: "myanmar-property"
  use_ssl: false
```

**特点**:
- 本地部署，完全可控
- S3 兼容 API
- 适合开发和测试环境

### 5.2 腾讯云 COS 切换

**配置**:
```yaml
storage:
  type: tencent
  region: "ap-singapore"  # 新加坡节点（离缅甸近）
  secret_id: "your-secret-id"
  secret_key: "your-secret-key"
  bucket: "myanmar-property-125xxxxxx"
  domain: "https://cdn.myanmar-property.com"
```

**迁移步骤**:
1. 注册腾讯云账号
2. 开通 COS 服务，选择新加坡区域
3. 创建存储桶
4. 配置自定义 CDN 域名（可选）
5. 迁移 MinIO 存量文件
6. 更新服务端配置

**图片处理**:
腾讯云 COS 支持图片处理参数：
```
# 缩略图
https://cdn.example.com/image.jpg?imageView2/1/w/200/h/200

# 水印
https://cdn.example.com/image.jpg?watermark/2/text/5ZWG5Lia
```

**切换检查清单**:
- [ ] 注册腾讯云账号
- [ ] 创建新加坡区域存储桶
- [ ] 配置访问密钥
- [ ] 迁移存量文件
- [ ] 配置 CDN 加速（可选）
- [ ] 测试图片上传/访问
- [ ] 配置图片处理样式

---

## 6. Elasticsearch 搜索服务

### 6.1 当前实现 (本地 Docker)

**配置**:
```yaml
elasticsearch:
  url: "http://localhost:9200"
  username: "elastic"
  password: "elastic"
```

### 6.2 腾讯云 ES 切换

**配置**:
```yaml
elasticsearch:
  url: "https://es-xxxxxx.ap-singapore.tencentelasticsearch.com:9200"
  username: "elastic"
  password: "your-password"
```

**注意事项**:
- 选择新加坡区域降低延迟
- 配置适当节点规格（建议2核4G起步）
- 开启自动快照备份

---

## 7. Redis 缓存服务

### 7.1 当前实现 (本地 Docker)

**配置**:
```yaml
redis:
  host: "localhost"
  port: 6379
  password: ""
  db: 0
```

### 7.2 腾讯云 Redis 切换

**配置**:
```yaml
redis:
  host: "xxx.redis.cache.tencentcloud.com"
  port: 6379
  password: "your-password"
  db: 0
```

**注意**: Redis 主要用于会话和缓存，迁移时需考虑：
- 会话数据会丢失，需通知用户重新登录
- 缓存数据需要重建

---

## 8. 地图服务

### 8.1 Mock 实现

**配置**:
```yaml
map:
  provider: mock
  default_lat: 16.8661  # 仰光纬度
  default_lng: 96.1951  # 仰光经度
```

### 8.2 真实服务切换

**方案A: Google Maps**
```yaml
map:
  provider: google
  api_key: "your-google-maps-api-key"
```

**方案B: 高德地图（需要海外版）**
```yaml
map:
  provider: amap
  api_key: "your-amap-key"
```

**缅甸地图数据**: 由于缅甸地图数据可能不完整，建议：
- 主要城市使用真实地图
- 郊区使用简化地图
- 提供手动校正机制

---

## 9. 环境配置对照表

### 9.1 本地开发环境 (Local)

```yaml
# config.local.yaml
environment: development

sms:
  provider: mock

im:
  provider: mock

payment:
  provider: mock

storage:
  type: minio
  endpoint: "localhost:9000"

elasticsearch:
  url: "http://localhost:9200"

redis:
  host: "localhost"
  port: 6379
```

### 9.2 测试环境 (Test)

```yaml
# config.test.yaml
environment: test

sms:
  provider: mock  # 或真实服务商沙箱环境

im:
  provider: mock

payment:
  provider: mock  # 或 KBZ Pay 沙箱

storage:
  type: tencent
  bucket: "myanmar-property-test"

elasticsearch:
  url: "https://es-test.xxx.tencentelasticsearch.com:9200"

redis:
  host: "xxx-test.redis.cache.tencentcloud.com"
```

### 9.3 生产环境 (Production)

```yaml
# config.production.yaml
environment: production

sms:
  provider: mytel  # 真实服务商

im:
  provider: easemob  # 真实 IM 服务

payment:
  provider: kbzp  # KBZ Pay
  sandbox: false

storage:
  type: tencent
  bucket: "myanmar-property-prod"
  domain: "https://cdn.myanmar-property.com"

elasticsearch:
  url: "https://es-prod.xxx.tencentelasticsearch.com:9200"

redis:
  host: "xxx-prod.redis.cache.tencentcloud.com"
```

---

## 10. 切换检查清单模板

### 10.1 切换前准备

- [ ] 获取真实服务账号和密钥
- [ ] 在测试环境完成集成测试
- [ ] 准备回滚方案
- [ ] 准备监控和告警

### 10.2 切换执行

- [ ] 更新配置文件
- [ ] 重启服务
- [ ] 验证基本功能
- [ ] 监控错误率

### 10.3 切换后验证

- [ ] 检查服务健康状态
- [ ] 验证核心业务流程
- [ ] 监控性能和延迟
- [ ] 收集用户反馈

---

## 11. 配置加载优先级

代码中配置加载顺序（高优先级覆盖低优先级）：

1. 环境变量（最高优先级）
2. 配置文件（config.{env}.yaml）
3. 默认配置（config.default.yaml）

**示例**:
```bash
# 环境变量覆盖配置
export SMS_PROVIDER=mytel
export SMS_API_KEY=xxx

# 启动服务
./server
```

---

## 12. 代码中服务切换实现

### 12.1 工厂模式示例

```go
// service/sms/sms_factory.go
package sms

func NewSMSService(config *Config) SMSService {
    switch config.Provider {
    case "mock":
        return &MockSMSService{Code: config.MockCode}
    case "mytel":
        return &MyTelSMSService{
            APIKey:    config.APIKey,
            APISecret: config.APISecret,
        }
    case "ooredoo":
        return &OoredooSMSService{
            APIKey: config.APIKey,
        }
    default:
        return &MockSMSService{}
    }
}
```

### 12.2 配置文件结构

```go
// config/config.go
type Config struct {
    SMS struct {
        Provider   string `yaml:"provider" env:"SMS_PROVIDER"`
        APIKey     string `yaml:"api_key" env:"SMS_API_KEY"`
        APISecret  string `yaml:"api_secret" env:"SMS_API_SECRET"`
        MockCode   string `yaml:"mock_code"`
    }

    IM struct {
        Provider    string `yaml:"provider" env:"IM_PROVIDER"`
        AppKey      string `yaml:"app_key" env:"IM_APP_KEY"`
        AppSecret   string `yaml:"app_secret" env:"IM_APP_SECRET"`
    }

    Payment struct {
        Provider  string `yaml:"provider" env:"PAYMENT_PROVIDER"`
        MerchantID string `yaml:"merchant_id"`
        APIKey    string `yaml:"api_key"`
        Sandbox   bool   `yaml:"sandbox"`
    }

    Storage struct {
        Type      string `yaml:"type" env:"STORAGE_TYPE"`
        Endpoint  string `yaml:"endpoint"`
        SecretID  string `yaml:"secret_id"`
        SecretKey string `yaml:"secret_key"`
        Bucket    string `yaml:"bucket"`
    }
}
```

---

## 13. 迁移时间表建议

| 阶段 | 时间 | 内容 |
|------|------|------|
| 第1阶段 | 1-2周 | 文件存储 → 腾讯云 COS |
| 第2阶段 | 2-3周 | 支付 → KBZ Pay |
| 第3阶段 | 3-4周 | SMS → 本地服务商 |
| 第4阶段 | 4-6周 | IM → 环信/融云 |
| 第5阶段 | 持续 | Elasticsearch/Redis 上云 |

---

**文档版本**: v1.0
**最后更新**: 2026-03-31
**维护人**: 技术团队
