import Foundation

// MARK: - 房源模型
public struct House: Codable, Identifiable {
    public let id: String
    public let title: String
    public let coverImage: String
    public let price: Double
    public let priceUnit: String
    public let area: Double
    public let rooms: String
    public let location: String
    public let district: String
    public let community: String?
    public let tags: [String]
    public let verificationStatus: VerificationStatus
    public let publishTime: String
    public let latitude: Double?
    public let longitude: Double?
    
    // 详情页额外字段
    public let priceNote: String?
    public let houseType: HouseType?
    public let transactionType: TransactionType?
    public let floor: String?
    public let totalFloors: Int?
    public let decoration: DecorationType?
    public let orientation: Orientation?
    public let buildYear: Int?
    public let address: String?
    public let nearby: [POI]?
    public let description: String?
    public let highlights: [String]?
    public let facilities: [String]?
    public let propertyType: PropertyType?
    public let ownership: String?
    public let hasLoan: Bool?
    public let propertyCertificate: String?
    public let verifiedAt: String?
    public let verifiedBy: String?
    public let reportUrl: String?
    public let images: [String]?
    public let video: String?
    public let agent: Agent?
    
    public enum VerificationStatus: String, Codable {
        case verified = "verified"
        case pending = "pending"
        case unverified = "unverified"
        case failed = "failed"
    }
    
    public enum HouseType: String, Codable {
        case apartment = "apartment"      // 公寓/Condo
        case house = "house"              // 独栋/别墅
        case townhouse = "townhouse"      // 联排/排屋
        case land = "land"                // 土地/地块
        case commercial = "commercial"    // 商业地产
    }
    
    public enum TransactionType: String, Codable {
        case sale = "sale"      // 出售
        case rent = "rent"      // 出租
    }
    
    public enum DecorationType: String, Codable {
        case rough = "rough"        // 毛坯
        case simple = "simple"      // 简装
        case fine = "fine"          // 精装
        case luxury = "luxury"      // 豪华
    }
    
    public enum Orientation: String, Codable {
        case east = "east"
        case south = "south"
        case west = "west"
        case north = "north"
        case southeast = "southeast"
        case southwest = "southwest"
        case northeast = "northeast"
        case northwest = "northwest"
    }
    
    public enum PropertyType: String, Codable {
        case grant = "grant"           // 地契(ဂရန်)
        case license = "license"       // 许可证(လိုင်စင်)
        case contract = "contract"     // 合同转让
        case other = "other"
    }
}

// MARK: - 周边POI
public struct POI: Codable, Identifiable {
    public let id: String
    public let type: POIType
    public let name: String
    public let distance: String
    
    public enum POIType: String, Codable {
        case school = "school"
        case hospital = "hospital"
        case mall = "mall"
        case transport = "transport"
        case restaurant = "restaurant"
        case park = "park"
    }
}

// MARK: - 经纪人模型
public struct Agent: Codable, Identifiable {
    public let id: String
    public let name: String
    public let avatar: String?
    public let company: String?
    public let rating: Double?
    public let dealCount: Int?
    public let phone: String?
}

// MARK: - 用户模型
public struct User: Codable, Identifiable {
    public let id: String
    public let phone: String
    public let nickname: String?
    public let avatar: String?
    public let realName: String?
    public let idCardNumber: String?
    public let verificationStatus: IdentityStatus
    public let createdAt: String?
    
    public enum IdentityStatus: String, Codable {
        case unverified = "unverified"
        case pending = "pending"
        case verified = "verified"
        case failed = "failed"
    }
}

// MARK: - 经纪人用户模型
public struct AgentUser: Codable, Identifiable {
    public let id: String
    public let name: String
    public let phone: String
    public let avatar: String?
    public let company: String?
    public let companyId: String?
    public let teamId: String?
    public let status: AgentStatus
    public let role: AgentRole
    public let rating: Double?
    public let dealCount: Int?
    public let verificationStatus: IdentityStatus
    
    public enum AgentStatus: String, Codable {
        case pending = "pending"      // 待审核
        case active = "active"        // 正常
        case suspended = "suspended"  // 暂停
        case inactive = "inactive"    // 停用
    }
    
    public enum AgentRole: String, Codable {
        case agent = "agent"          // 普通经纪人
        case teamLeader = "teamLeader" // 团队长
        case manager = "manager"      // 店长
        case promoter = "promoter"    // 地推
    }
    
    public enum IdentityStatus: String, Codable {
        case unverified = "unverified"
        case pending = "pending"
        case verified = "verified"
        case failed = "failed"
    }
}

// MARK: - Banner模型
public struct Banner: Codable, Identifiable {
    public let id: String
    public let image: String
    public let linkType: LinkType
    public let linkValue: String
    
    public enum LinkType: String, Codable {
        case house = "house"           // 房源详情
        case search = "search"         // 搜索结果
        case web = "web"               // H5页面
    }
}

// MARK: - 地图聚合点
public struct MapCluster: Codable, Identifiable {
    public let id: String
    public let name: String
    public let latitude: Double
    public let longitude: Double
    public let avgPrice: Double
    public let totalCount: Int
    public let bounds: MapBounds?
    
    public struct MapBounds: Codable {
        public let swLat: Double
        public let swLng: Double
        public let neLat: Double
        public let neLng: Double
    }
}

// MARK: - 预约模型
public struct Appointment: Codable, Identifiable {
    public let id: String
    public let houseId: String
    public let houseTitle: String?
    public let houseImage: String?
    public let agentId: String
    public let agentName: String?
    public let appointmentTime: String
    public let status: AppointmentStatus
    public let createdAt: String?
    public let note: String?
    
    public enum AppointmentStatus: String, Codable {
        case pending = "pending"       // 待确认
        case confirmed = "confirmed"   // 已确认
        case rejected = "rejected"     // 已拒绝
        case completed = "completed"   // 已完成
        case cancelled = "cancelled"   // 已取消
        case noShow = "noShow"         // 爽约
    }
}

// MARK: - 消息模型
public struct ChatMessage: Codable, Identifiable {
    public let id: String
    public let senderId: String
    public let receiverId: String
    public let type: MessageType
    public let content: String
    public let timestamp: String
    public let status: MessageStatus
    public let houseId: String?
    
    public enum MessageType: String, Codable {
        case text = "text"
        case image = "image"
        case voice = "voice"
        case houseCard = "house_card"
        case system = "system"
    }
    
    public enum MessageStatus: String, Codable {
        case sending = "sending"
        case sent = "sent"
        case delivered = "delivered"
        case read = "read"
        case failed = "failed"
    }
}

// MARK: - 会话模型
public struct ChatConversation: Codable, Identifiable {
    public let id: String
    public let targetId: String
    public let targetName: String
    public let targetAvatar: String?
    public let lastMessage: String?
    public let lastMessageTime: String?
    public let unreadCount: Int
    public let houseId: String?
}

// MARK: - 客户模型
public struct Customer: Codable, Identifiable {
    public let id: String
    public let name: String
    public let phone: String
    public let budget: String?
    public let requirements: String?
    public let source: CustomerSource
    public let status: CustomerStatus
    public let createdAt: String?
    public let lastFollowUp: String?
    public let followUpCount: Int?
    
    public enum CustomerSource: String, Codable {
        case platform = "platform"     // 平台分配
        case referral = "referral"     // 转介绍
        case selfDeveloped = "self"    // 自开发
        case walkIn = "walkIn"         // 自然到访
    }
    
    public enum CustomerStatus: String, Codable {
        case new = "new"               // 新线索
        case following = "following"   // 跟进中
        case showing = "showing"       // 带看中
        case negotiating = "negotiating" // 谈判中
        case deal = "deal"             // 已成交
        case lost = "lost"             // 已流失
    }
}

// MARK: - ACN成交模型
public struct ACNTransaction: Codable, Identifiable {
    public let id: String
    public let houseId: String
    public let houseTitle: String?
    public let price: Double
    public let commission: Double
    public let dealDate: String
    public let participants: [ACNParticipant]
    public let platformFee: Double
    public let status: TransactionStatus
    
    public struct ACNParticipant: Codable, Identifiable {
        public let id: String
        public let role: ACNRole
        public let agentId: String
        public let agentName: String?
        public let commission: Double
        public let status: ParticipantStatus
        
        public enum ParticipantStatus: String, Codable {
            case pending = "pending"
            case confirmed = "confirmed"
            case rejected = "rejected"
        }
    }
    
    public enum ACNRole: String, Codable {
        case entrant = "ENTRANT"           // 房源录入人
        case maintainer = "MAINTAINER"     // 房源维护人
        case introducer = "INTRODUCER"     // 客源转介绍
        case accompanier = "ACCOMPANIER"   // 带看人
        case closer = "CLOSER"             // 成交人
    }
    
    public enum TransactionStatus: String, Codable {
        case pendingConfirm = "pending_confirm"
        case confirmed = "confirmed"
        case settled = "settled"
        case disputed = "disputed"
    }
}

// MARK: - API响应模型
public struct APIResponse<T: Codable>: Codable {
    public let code: Int
    public let message: String
    public let data: T?
    
    public var isSuccess: Bool {
        return code == 200
    }
}

public struct APIPagedResponse<T: Codable>: Codable {
    public let code: Int
    public let message: String
    public let data: PagedData<T>?
    
    public struct PagedData<D: Codable>: Codable {
        public let total: Int
        public let page: Int
        public let pageSize: Int
        public let list: [D]
        
        public var hasMore: Bool {
            return page * pageSize < total
        }
    }
    
    public var isSuccess: Bool {
        return code == 200
    }
}

// MARK: - 搜索筛选模型
public struct SearchFilters: Codable {
    public var transactionType: House.TransactionType?
    public var houseType: House.HouseType?
    public var cityCode: String?
    public var districtCode: String?
    public var community: String?
    public var priceMin: Double?
    public var priceMax: Double?
    public var areaMin: Double?
    public var areaMax: Double?
    public var roomCount: String?
    public var keywords: String?
    public var sortBy: SortOption?
    
    public enum SortOption: String, Codable {
        case `default` = "default"
        case priceAsc = "price_asc"
        case priceDesc = "price_desc"
        case date = "date"
        case area = "area"
    }
    
    public init(
        transactionType: House.TransactionType? = nil,
        houseType: House.HouseType? = nil,
        cityCode: String? = nil,
        districtCode: String? = nil,
        community: String? = nil,
        priceMin: Double? = nil,
        priceMax: Double? = nil,
        areaMin: Double? = nil,
        areaMax: Double? = nil,
        roomCount: String? = nil,
        keywords: String? = nil,
        sortBy: SortOption? = nil
    ) {
        self.transactionType = transactionType
        self.houseType = houseType
        self.cityCode = cityCode
        self.districtCode = districtCode
        self.community = community
        self.priceMin = priceMin
        self.priceMax = priceMax
        self.areaMin = areaMin
        self.areaMax = areaMax
        self.roomCount = roomCount
        self.keywords = keywords
        self.sortBy = sortBy
    }
}

// MARK: - 首页数据模型
public struct HomeData: Codable {
    public let banners: [Banner]
    public let quickEntries: [QuickEntry]
    public let houses: [House]
    
    public struct QuickEntry: Codable, Identifiable {
        public let id: String
        public let type: EntryType
        public let icon: String
        public let name: String
        
        public enum EntryType: String, Codable {
            case buy = "buy"
            case rent = "rent"
            case publish = "publish"
            case map = "map"
        }
    }
}

// MARK: - 验真任务模型
public struct VerificationTask: Codable, Identifiable {
    public let id: String
    public let houseId: String
    public let houseTitle: String?
    public let address: String?
    public let status: TaskStatus
    public let assignedAt: String?
    public let deadline: String?
    public let completedAt: String?
    
    public enum TaskStatus: String, Codable {
        case pending = "pending"           // 待领取
        case assigned = "assigned"         // 已领取
        case inProgress = "in_progress"    // 进行中
        case completed = "completed"       // 已完成
        case failed = "failed"             // 验真失败
    }
}

// MARK: - 业绩统计模型
public struct PerformanceStats: Codable {
    public let period: String
    public let totalDealCount: Int
    public let totalGMV: Double
    public let totalCommission: Double
    public let newHouses: Int
    public let newCustomers: Int
    public let showings: Int
    public let ranking: Int?
}
