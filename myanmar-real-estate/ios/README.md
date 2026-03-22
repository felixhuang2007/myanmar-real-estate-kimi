# MyanmarHome iOS APP

缅甸房产平台 iOS 客户端项目，包含 C 端购房者 APP 和 B 端经纪人 APP。

## 项目结构

```
MyanmarHome/
├── Common/                    # 共享模块
│   ├── Models/               # 数据模型
│   │   └── Models.swift      # 所有数据模型定义
│   ├── Network/              # 网络层
│   │   ├── APIEndpoint.swift # API端点定义
│   │   ├── NetworkManager.swift # 网络请求管理
│   │   └── Services.swift    # 业务服务层
│   ├── UIComponents/         # 通用UI组件
│   │   └── CommonViews.swift # 通用视图组件
│   └── Utils/                # 工具类
│       └── Extensions.swift  # 扩展方法
├── BuyerApp/                 # C端APP（购房者）
│   ├── Features/             # 功能模块
│   │   ├── Home/             # 首页
│   │   ├── Search/           # 搜索
│   │   ├── Map/              # 地图找房
│   │   ├── HouseDetail/      # 房源详情
│   │   ├── Chat/             # IM聊天
│   │   ├── Profile/          # 个人中心
│   │   └── Publish/          # 房源发布
│   ├── ViewModels/           # 视图模型
│   │   └── BuyerViewModels.swift
│   └── MyanmarHomeBuyerApp.swift # APP入口
├── AgentApp/                 # B端APP（经纪人）
│   ├── Features/             # 功能模块
│   │   ├── HouseEntry/       # 极速录房
│   │   ├── Verification/     # 实地验真
│   │   ├── Customer/         # 客户管理
│   │   ├── Tour/             # 带看管理
│   │   ├── ACN/              # ACN协作
│   │   └── Performance/      # 业绩统计
│   ├── ViewModels/           # 视图模型
│   │   └── AgentViewModels.swift
│   └── MyanmarHomeAgentApp.swift # APP入口
└── Tests/                    # 单元测试
    ├── NetworkTests/         # 网络层测试
    └── ViewModelTests/       # ViewModel测试
```

## 技术栈

- **Swift 5.9+**
- **SwiftUI + UIKit** - 混合使用，主要使用 SwiftUI
- **Combine** - 响应式编程
- **CoreData** - 本地数据缓存（预留）
- **Alamofire** - 网络请求
- **Google Maps SDK** - 地图功能（预留）
- **环信IM SDK** - 即时通讯（预留）

## 功能模块

### C端APP（MyanmarHome-Buyer）

| 模块 | 功能 | 状态 |
|------|------|------|
| 账号体系 | 手机注册/登录、实名认证 | ✅ 完成 |
| 首页 | 房源推荐流、Banner、快捷入口 | ✅ 完成 |
| 搜索筛选 | 关键词搜索、多维度筛选 | ✅ 完成 |
| 地图找房 | 地图聚合展示、LBS定位 | ✅ 完成 |
| 房源详情 | 信息展示、图片轮播、收藏 | ✅ 完成 |
| IM咨询 | 即时消息、语音、图片 | ⏳ 框架完成 |
| 预约带看 | 时间选择、预约管理 | ✅ 完成 |
| 个人中心 | 我的收藏、我的预约、设置 | ✅ 完成 |

### B端APP（MyanmarHome-Agent）

| 模块 | 功能 | 状态 |
|------|------|------|
| 极速录房 | 房源录入、图片上传、地图标注 | ✅ 完成 |
| 实地验真 | 验真任务、拍照上传、报告 | ✅ 完成 |
| 房源管理 | 我的房源、状态管理 | ✅ 完成 |
| 客户管理 | 线索池、跟进记录、CRM | ✅ 完成 |
| 带看管理 | 日程管理、确认/反馈 | ✅ 完成 |
| ACN协作 | 分佣规则、成交申报 | ✅ 完成 |
| 业绩统计 | 个人业绩、佣金明细 | ✅ 完成 |

## 快速开始

### 环境要求

- Xcode 15.0+
- iOS 15.0+
- Swift 5.9+

### 安装依赖

项目使用 SPM（Swift Package Manager）管理依赖：

1. 打开项目中的 `Package.swift`
2. Xcode 会自动解析依赖

或者使用命令行：

```bash
cd ios/MyanmarHome
swift package resolve
```

### 运行项目

1. 使用 Xcode 打开项目
2. 选择目标设备（Simulator 或真机）
3. 按 Cmd+R 运行

### 切换APP

项目包含两个 Target：
- `MyanmarHomeBuyer` - C端APP
- `MyanmarHomeAgent` - B端APP

在 Xcode 的 Scheme 中选择对应的 Target 进行运行。

## API配置

修改 `Common/Network/APIEndpoint.swift` 中的 `APIConfig` 来配置API地址：

```swift
public struct APIConfig {
    #if DEBUG
    public static var baseURL = "https://api-staging.myanmarhome.com"
    #else
    public static var baseURL = "https://api.myanmarhome.com"
    #endif
}
```

## 测试

### 运行单元测试

在 Xcode 中：
1. 选择 Product → Test (Cmd+U)

或者使用命令行：

```bash
swift test
```

### 测试覆盖率

- 网络层测试: ✅ 完成
- ViewModel测试: ✅ 完成
- UI测试: ⏳ 待补充

## 代码规范

- 使用 SwiftLint 进行代码风格检查
- 遵循 Swift API Design Guidelines
- 使用 MARK 标记进行代码分区
- 每个 View 都包含 Preview

## 国际化

项目支持多语言：
- 缅语 (my)
- 英语 (en)

在 `Common/Resources/` 目录下添加 `Localizable.strings` 文件。

## 贡献指南

1. Fork 项目
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 创建 Pull Request

## 许可证

[MIT License](LICENSE)

## 联系方式

- 项目维护者: MyanmarHome Team
- 邮箱: dev@myanmarhome.com

## 更新日志

### v1.0.0 (2026-03-17)
- 初始版本发布
- 完成C端和B端核心功能
- 完成网络层和ViewModel层
- 完成基础UI组件

## 致谢

感谢所有为这个项目做出贡献的开发者！
