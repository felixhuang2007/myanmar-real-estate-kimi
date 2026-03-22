import Foundation
import Combine
import Alamofire

// MARK: - 网络错误类型
public enum NetworkError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case decodingFailed(Error)
    case serverError(Int, String)
    case noData
    case unauthorized
    case networkFailure(Error)
    case cancelled
    
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "无效的URL"
        case .invalidResponse:
            return "无效的服务器响应"
        case .decodingFailed(let error):
            return "数据解析失败: \(error.localizedDescription)"
        case .serverError(let code, let message):
            return "服务器错误 [\(code)]: \(message)"
        case .noData:
            return "没有数据返回"
        case .unauthorized:
            return "未授权，请重新登录"
        case .networkFailure(let error):
            return "网络连接失败: \(error.localizedDescription)"
        case .cancelled:
            return "请求已取消"
        }
    }
}

// MARK: - API配置
public struct APIConfig {
    /// 基础URL，根据环境配置
    public static var baseURL: String {
        #if DEBUG
        return "https://api-staging.myanmarhome.com"
        #else
        return "https://api.myanmarhome.com"
        #endif
    }
    
    /// API版本
    public static let apiVersion = "v1"
    
    /// 超时时间
    public static let timeoutInterval: TimeInterval = 30
    
    /// 分页大小
    public static let pageSize = 20
}

// MARK: - API端点定义
public enum APIEndpoint {
    // MARK: - 用户认证
    case login(phone: String, code: String)
    case register(phone: String, code: String, password: String?)
    case sendVerifyCode(phone: String)
    case verifyIdentity(name: String, idCard: String)
    case refreshToken(token: String)
    
    // MARK: - 首页
    case homeRecommend(city: String, page: Int)
    case banners(city: String)
    
    // MARK: - 房源搜索
    case searchHouses(filters: SearchFilters, page: Int)
    case houseDetail(id: String)
    case similarHouses(id: String)
    
    // MARK: - 地图找房
    case mapAggregate(bounds: MapBounds, zoom: Int, filters: SearchFilters?)
    
    // MARK: - 收藏
    case addFavorite(houseId: String)
    case removeFavorite(houseId: String)
    case favorites(page: Int)
    
    // MARK: - 预约
    case createAppointment(houseId: String, agentId: String, time: String)
    case appointments(page: Int)
    case cancelAppointment(id: String)
    
    // MARK: - IM
    case conversations
    case messages(conversationId: String, page: Int)
    case sendMessage(conversationId: String, type: String, content: String)
    
    // MARK: - 经纪人(B端)
    case agentLogin(phone: String, code: String)
    case agentRegister(phone: String, code: String, name: String, company: String?)
    case agentProfile
    case updateAgentProfile
    
    // MARK: - 房源管理(B端)
    case createHouse
    case updateHouse(id: String)
    case myHouses(status: String?, page: Int)
    case offlineHouse(id: String)
    case refreshHouse(id: String)
    
    // MARK: - 验真(B端)
    case verificationTasks(status: String?, page: Int)
    case claimTask(id: String)
    case submitVerification(id: String)
    
    // MARK: - 客户管理(B端)
    case customers(status: String?, page: Int)
    case createCustomer
    case updateCustomer(id: String)
    case followUp(customerId: String)
    
    // MARK: - 带看管理(B端)
    case tours(status: String?, date: String?)
    case confirmTour(id: String)
    case rejectTour(id: String, reason: String)
    case completeTour(id: String)
    
    // MARK: - ACN(B端)
    case acnTransactions(page: Int)
    case reportDeal
    case confirmParticipation(id: String)
    
    // MARK: - 业绩(B端)
    case performanceStats(period: String)
    case commissionDetails(page: Int)
    
    // MARK: - 上传
    case uploadImage
    case uploadMultipleImages
    
    // MARK: - 计算属性
    var path: String {
        switch self {
        // 用户认证
        case .login: return "/auth/login"
        case .register: return "/auth/register"
        case .sendVerifyCode: return "/auth/verify-code"
        case .verifyIdentity: return "/auth/verify-identity"
        case .refreshToken: return "/auth/refresh-token"
            
        // 首页
        case .homeRecommend: return "/home/recommend"
        case .banners: return "/home/banners"
            
        // 房源搜索
        case .searchHouses: return "/houses/search"
        case .houseDetail(let id): return "/houses/\(id)"
        case .similarHouses(let id): return "/houses/\(id)/similar"
            
        // 地图
        case .mapAggregate: return "/map/aggregate"
            
        // 收藏
        case .addFavorite: return "/favorites"
        case .removeFavorite(let id): return "/favorites/\(id)"
        case .favorites: return "/favorites"
            
        // 预约
        case .createAppointment: return "/appointments"
        case .appointments: return "/appointments"
        case .cancelAppointment(let id): return "/appointments/\(id)/cancel"
            
        // IM
        case .conversations: return "/chat/conversations"
        case .messages(let id, _): return "/chat/conversations/\(id)/messages"
        case .sendMessage(let id, _, _): return "/chat/conversations/\(id)/messages"
            
        // 经纪人
        case .agentLogin: return "/agent/auth/login"
        case .agentRegister: return "/agent/auth/register"
        case .agentProfile: return "/agent/profile"
        case .updateAgentProfile: return "/agent/profile"
            
        // 房源管理
        case .createHouse: return "/agent/houses"
        case .updateHouse(let id): return "/agent/houses/\(id)"
        case .myHouses: return "/agent/houses"
        case .offlineHouse(let id): return "/agent/houses/\(id)/offline"
        case .refreshHouse(let id): return "/agent/houses/\(id)/refresh"
            
        // 验真
        case .verificationTasks: return "/agent/verifications"
        case .claimTask(let id): return "/agent/verifications/\(id)/claim"
        case .submitVerification(let id): return "/agent/verifications/\(id)/submit"
            
        // 客户
        case .customers: return "/agent/customers"
        case .createCustomer: return "/agent/customers"
        case .updateCustomer(let id): return "/agent/customers/\(id)"
        case .followUp(let id): return "/agent/customers/\(id)/follow-up"
            
        // 带看
        case .tours: return "/agent/tours"
        case .confirmTour(let id): return "/agent/tours/\(id)/confirm"
        case .rejectTour(let id, _): return "/agent/tours/\(id)/reject"
        case .completeTour(let id): return "/agent/tours/\(id)/complete"
            
        // ACN
        case .acnTransactions: return "/agent/acn/transactions"
        case .reportDeal: return "/agent/acn/deals"
        case .confirmParticipation(let id): return "/agent/acn/transactions/\(id)/confirm"
            
        // 业绩
        case .performanceStats: return "/agent/performance"
        case .commissionDetails: return "/agent/commission"
            
        // 上传
        case .uploadImage: return "/upload/image"
        case .uploadMultipleImages: return "/upload/images"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .login, .register, .sendVerifyCode, .verifyIdentity, .refreshToken,
             .addFavorite, .createAppointment, .sendMessage,
             .agentLogin, .agentRegister, .createHouse, .createCustomer,
             .followUp, .confirmTour, .rejectTour, .completeTour,
             .reportDeal, .confirmParticipation, .uploadImage, .uploadMultipleImages,
             .claimTask, .submitVerification:
            return .post
            
        case .updateAgentProfile, .updateHouse, .updateCustomer:
            return .put
            
        case .removeFavorite, .cancelAppointment, .offlineHouse:
            return .delete
            
        default:
            return .get
        }
    }
    
    var parameters: Parameters? {
        switch self {
        // 用户认证
        case .login(let phone, let code):
            return ["phone": phone, "verifyCode": code]
        case .register(let phone, let code, let password):
            var params: [String: Any] = ["phone": phone, "verifyCode": code]
            if let password = password {
                params["password"] = password
            }
            return params
        case .sendVerifyCode(let phone):
            return ["phone": phone]
        case .verifyIdentity(let name, let idCard):
            return ["realName": name, "idCardNumber": idCard]
        case .refreshToken(let token):
            return ["refreshToken": token]
            
        // 首页
        case .homeRecommend(let city, let page):
            return ["cityCode": city, "page": page, "pageSize": APIConfig.pageSize]
        case .banners(let city):
            return ["cityCode": city]
            
        // 房源搜索
        case .searchHouses(let filters, let page):
            var params: [String: Any] = ["page": page, "pageSize": APIConfig.pageSize]
            if let type = filters.transactionType {
                params["transactionType"] = type.rawValue
            }
            if let houseType = filters.houseType {
                params["houseType"] = houseType.rawValue
            }
            if let city = filters.cityCode {
                params["cityCode"] = city
            }
            if let district = filters.districtCode {
                params["districtCode"] = district
            }
            if let min = filters.priceMin {
                params["priceMin"] = min
            }
            if let max = filters.priceMax {
                params["priceMax"] = max
            }
            if let min = filters.areaMin {
                params["areaMin"] = min
            }
            if let max = filters.areaMax {
                params["areaMax"] = max
            }
            if let rooms = filters.roomCount {
                params["roomCount"] = rooms
            }
            if let keywords = filters.keywords {
                params["keywords"] = keywords
            }
            if let sort = filters.sortBy {
                params["sortBy"] = sort.rawValue
            }
            return params
            
        case .similarHouses:
            return ["pageSize": 10]
            
        // 地图
        case .mapAggregate(let bounds, let zoom, let filters):
            var params: [String: Any] = [
                "swLat": bounds.swLat,
                "swLng": bounds.swLng,
                "neLat": bounds.neLat,
                "neLng": bounds.neLng,
                "zoom": zoom
            ]
            if let filters = filters {
                if let type = filters.transactionType {
                    params["transactionType"] = type.rawValue
                }
                if let houseType = filters.houseType {
                    params["houseType"] = houseType.rawValue
                }
                if let min = filters.priceMin {
                    params["priceMin"] = min
                }
                if let max = filters.priceMax {
                    params["priceMax"] = max
                }
            }
            return params
            
        // 收藏
        case .favorites(let page):
            return ["page": page, "pageSize": APIConfig.pageSize]
            
        // 预约
        case .createAppointment(let houseId, let agentId, let time):
            return [
                "houseId": houseId,
                "agentId": agentId,
                "appointmentTime": time
            ]
        case .appointments(let page):
            return ["page": page, "pageSize": APIConfig.pageSize]
            
        // IM
        case .messages(_, let page):
            return ["page": page, "pageSize": 50]
        case .sendMessage(_, let type, let content):
            return ["type": type, "content": content]
            
        // 经纪人
        case .agentLogin(let phone, let code):
            return ["phone": phone, "verifyCode": code]
        case .agentRegister(let phone, let code, let name, let company):
            var params: [String: Any] = [
                "phone": phone,
                "verifyCode": code,
                "name": name
            ]
            if let company = company {
                params["company"] = company
            }
            return params
            
        // 房源管理
        case .myHouses(let status, let page):
            var params: [String: Any] = ["page": page, "pageSize": APIConfig.pageSize]
            if let status = status {
                params["status"] = status
            }
            return params
            
        // 验真
        case .verificationTasks(let status, let page):
            var params: [String: Any] = ["page": page, "pageSize": APIConfig.pageSize]
            if let status = status {
                params["status"] = status
            }
            return params
            
        // 客户
        case .customers(let status, let page):
            var params: [String: Any] = ["page": page, "pageSize": APIConfig.pageSize]
            if let status = status {
                params["status"] = status
            }
            return params
            
        // 带看
        case .tours(let status, let date):
            var params: [String: Any] = [:]
            if let status = status {
                params["status"] = status
            }
            if let date = date {
                params["date"] = date
            }
            return params
            
        case .rejectTour(_, let reason):
            return ["reason": reason]
            
        // ACN
        case .acnTransactions(let page):
            return ["page": page, "pageSize": APIConfig.pageSize]
            
        // 业绩
        case .performanceStats(let period):
            return ["period": period]
        case .commissionDetails(let page):
            return ["page": page, "pageSize": APIConfig.pageSize]
            
        default:
            return nil
        }
    }
}

// MARK: - 地图边界
public struct MapBounds {
    public let swLat: Double
    public let swLng: Double
    public let neLat: Double
    public let neLng: Double
    
    public init(swLat: Double, swLng: Double, neLat: Double, neLng: Double) {
        self.swLat = swLat
        self.swLng = swLng
        self.neLat = neLat
        self.neLng = neLng
    }
}
