import Foundation
import Combine

// MARK: - 用户服务协议
public protocol UserServiceProtocol {
    func login(phone: String, code: String) -> AnyPublisher<User, NetworkError>
    func register(phone: String, code: String, password: String?) -> AnyPublisher<User, NetworkError>
    func sendVerifyCode(phone: String) -> AnyPublisher<Void, NetworkError>
    func verifyIdentity(name: String, idCard: String) -> AnyPublisher<Void, NetworkError>
    func logout()
}

// MARK: - 用户服务
public class UserService: UserServiceProtocol {
    public static let shared = UserService()
    
    private let networkManager: NetworkManager
    private let tokenManager: TokenManaging
    
    init(
        networkManager: NetworkManager = .shared,
        tokenManager: TokenManaging = TokenManager.shared
    ) {
        self.networkManager = networkManager
        self.tokenManager = tokenManager
    }
    
    public func login(phone: String, code: String) -> AnyPublisher<User, NetworkError> {
        return networkManager.request(
            .login(phone: phone, code: code),
            decodeTo: User.self
        )
        .handleEvents(receiveOutput: { [weak self] user in
            // 保存用户信息到本地
            UserDefaults.standard.set(try? JSONEncoder().encode(user), forKey: "currentUser")
        })
        .eraseToAnyPublisher()
    }
    
    public func register(phone: String, code: String, password: String?) -> AnyPublisher<User, NetworkError> {
        return networkManager.request(
            .register(phone: phone, code: code, password: password),
            decodeTo: User.self
        )
        .eraseToAnyPublisher()
    }
    
    public func sendVerifyCode(phone: String) -> AnyPublisher<Void, NetworkError> {
        return networkManager.request(.sendVerifyCode(phone: phone))
    }
    
    public func verifyIdentity(name: String, idCard: String) -> AnyPublisher<Void, NetworkError> {
        return networkManager.request(.verifyIdentity(name: name, idCard: idCard))
    }
    
    public func logout() {
        tokenManager.clearTokens()
        UserDefaults.standard.removeObject(forKey: "currentUser")
    }
    
    /// 获取当前登录用户
    public var currentUser: User? {
        guard let data = UserDefaults.standard.data(forKey: "currentUser"),
              let user = try? JSONDecoder().decode(User.self, from: data) else {
            return nil
        }
        return user
    }
}

// MARK: - 首页服务
public protocol HomeServiceProtocol {
    func getHomeRecommend(city: String, page: Int) -> AnyPublisher<HomeData, NetworkError>
    func getBanners(city: String) -> AnyPublisher<[Banner], NetworkError>
}

public class HomeService: HomeServiceProtocol {
    public static let shared = HomeService()
    
    private let networkManager: NetworkManager
    
    init(networkManager: NetworkManager = .shared) {
        self.networkManager = networkManager
    }
    
    public func getHomeRecommend(city: String, page: Int) -> AnyPublisher<HomeData, NetworkError> {
        return networkManager.request(
            .homeRecommend(city: city, page: page),
            decodeTo: HomeData.self
        )
    }
    
    public func getBanners(city: String) -> AnyPublisher<[Banner], NetworkError> {
        return networkManager.request(
            .banners(city: city),
            decodeTo: [Banner].self
        )
    }
}

// MARK: - 房源服务
public protocol HouseServiceProtocol {
    func searchHouses(filters: SearchFilters, page: Int) -> AnyPublisher<APIPagedResponse<House>.PagedData<House>, NetworkError>
    func getHouseDetail(id: String) -> AnyPublisher<House, NetworkError>
    func getSimilarHouses(id: String) -> AnyPublisher<[House], NetworkError>
    func getMapAggregate(bounds: MapBounds, zoom: Int, filters: SearchFilters?) -> AnyPublisher<MapClusterResponse, NetworkError>
}

public struct MapClusterResponse: Codable {
    public let level: Int
    public let clusters: [MapCluster]
    public let houses: [House]?
}

public class HouseService: HouseServiceProtocol {
    public static let shared = HouseService()
    
    private let networkManager: NetworkManager
    
    init(networkManager: NetworkManager = .shared) {
        self.networkManager = networkManager
    }
    
    public func searchHouses(filters: SearchFilters, page: Int) -> AnyPublisher<APIPagedResponse<House>.PagedData<House>, NetworkError> {
        return networkManager.requestPaged(
            .searchHouses(filters: filters, page: page),
            decodeTo: House.self
        )
    }
    
    public func getHouseDetail(id: String) -> AnyPublisher<House, NetworkError> {
        return networkManager.request(
            .houseDetail(id: id),
            decodeTo: House.self
        )
    }
    
    public func getSimilarHouses(id: String) -> AnyPublisher<[House], NetworkError> {
        return networkManager.request(
            .similarHouses(id: id),
            decodeTo: [House].self
        )
    }
    
    public func getMapAggregate(bounds: MapBounds, zoom: Int, filters: SearchFilters?) -> AnyPublisher<MapClusterResponse, NetworkError> {
        return networkManager.request(
            .mapAggregate(bounds: bounds, zoom: zoom, filters: filters),
            decodeTo: MapClusterResponse.self
        )
    }
}

// MARK: - 收藏服务
public protocol FavoriteServiceProtocol {
    func addFavorite(houseId: String) -> AnyPublisher<Void, NetworkError>
    func removeFavorite(houseId: String) -> AnyPublisher<Void, NetworkError>
    func getFavorites(page: Int) -> AnyPublisher<APIPagedResponse<House>.PagedData<House>, NetworkError>
}

public class FavoriteService: FavoriteServiceProtocol {
    public static let shared = FavoriteService()
    
    private let networkManager: NetworkManager
    
    init(networkManager: NetworkManager = .shared) {
        self.networkManager = networkManager
    }
    
    public func addFavorite(houseId: String) -> AnyPublisher<Void, NetworkError> {
        return networkManager.request(.addFavorite(houseId: houseId))
    }
    
    public func removeFavorite(houseId: String) -> AnyPublisher<Void, NetworkError> {
        return networkManager.request(.removeFavorite(houseId: houseId))
    }
    
    public func getFavorites(page: Int) -> AnyPublisher<APIPagedResponse<House>.PagedData<House>, NetworkError> {
        return networkManager.requestPaged(
            .favorites(page: page),
            decodeTo: House.self
        )
    }
}

// MARK: - 预约服务
public protocol AppointmentServiceProtocol {
    func createAppointment(houseId: String, agentId: String, time: String) -> AnyPublisher<Appointment, NetworkError>
    func getAppointments(page: Int) -> AnyPublisher<APIPagedResponse<Appointment>.PagedData<Appointment>, NetworkError>
    func cancelAppointment(id: String) -> AnyPublisher<Void, NetworkError>
}

public class AppointmentService: AppointmentServiceProtocol {
    public static let shared = AppointmentService()
    
    private let networkManager: NetworkManager
    
    init(networkManager: NetworkManager = .shared) {
        self.networkManager = networkManager
    }
    
    public func createAppointment(houseId: String, agentId: String, time: String) -> AnyPublisher<Appointment, NetworkError> {
        return networkManager.request(
            .createAppointment(houseId: houseId, agentId: agentId, time: time),
            decodeTo: Appointment.self
        )
    }
    
    public func getAppointments(page: Int) -> AnyPublisher<APIPagedResponse<Appointment>.PagedData<Appointment>, NetworkError> {
        return networkManager.requestPaged(
            .appointments(page: page),
            decodeTo: Appointment.self
        )
    }
    
    public func cancelAppointment(id: String) -> AnyPublisher<Void, NetworkError> {
        return networkManager.request(.cancelAppointment(id: id))
    }
}

// MARK: - IM服务
public protocol ChatServiceProtocol {
    func getConversations() -> AnyPublisher<[ChatConversation], NetworkError>
    func getMessages(conversationId: String, page: Int) -> AnyPublisher<APIPagedResponse<ChatMessage>.PagedData<ChatMessage>, NetworkError>
    func sendMessage(conversationId: String, type: ChatMessage.MessageType, content: String) -> AnyPublisher<ChatMessage, NetworkError>
}

public class ChatService: ChatServiceProtocol {
    public static let shared = ChatService()
    
    private let networkManager: NetworkManager
    
    init(networkManager: NetworkManager = .shared) {
        self.networkManager = networkManager
    }
    
    public func getConversations() -> AnyPublisher<[ChatConversation], NetworkError> {
        return networkManager.request(
            .conversations,
            decodeTo: [ChatConversation].self
        )
    }
    
    public func getMessages(conversationId: String, page: Int) -> AnyPublisher<APIPagedResponse<ChatMessage>.PagedData<ChatMessage>, NetworkError> {
        return networkManager.requestPaged(
            .messages(conversationId: conversationId, page: page),
            decodeTo: ChatMessage.self
        )
    }
    
    public func sendMessage(conversationId: String, type: ChatMessage.MessageType, content: String) -> AnyPublisher<ChatMessage, NetworkError> {
        return networkManager.request(
            .sendMessage(conversationId: conversationId, type: type.rawValue, content: content),
            decodeTo: ChatMessage.self
        )
    }
}

// MARK: - 经纪人服务
public protocol AgentServiceProtocol {
    func login(phone: String, code: String) -> AnyPublisher<AgentUser, NetworkError>
    func register(phone: String, code: String, name: String, company: String?) -> AnyPublisher<AgentUser, NetworkError>
    func getProfile() -> AnyPublisher<AgentUser, NetworkError>
    func logout()
}

public class AgentService: AgentServiceProtocol {
    public static let shared = AgentService()
    
    private let networkManager: NetworkManager
    private let tokenManager: TokenManaging
    
    init(
        networkManager: NetworkManager = .shared,
        tokenManager: TokenManaging = TokenManager.shared
    ) {
        self.networkManager = networkManager
        self.tokenManager = tokenManager
    }
    
    public func login(phone: String, code: String) -> AnyPublisher<AgentUser, NetworkError> {
        return networkManager.request(
            .agentLogin(phone: phone, code: code),
            decodeTo: AgentUser.self
        )
        .handleEvents(receiveOutput: { user in
            UserDefaults.standard.set(try? JSONEncoder().encode(user), forKey: "currentAgent")
        })
        .eraseToAnyPublisher()
    }
    
    public func register(phone: String, code: String, name: String, company: String?) -> AnyPublisher<AgentUser, NetworkError> {
        return networkManager.request(
            .agentRegister(phone: phone, code: code, name: name, company: company),
            decodeTo: AgentUser.self
        )
    }
    
    public func getProfile() -> AnyPublisher<AgentUser, NetworkError> {
        return networkManager.request(
            .agentProfile,
            decodeTo: AgentUser.self
        )
    }
    
    public func logout() {
        tokenManager.clearTokens()
        UserDefaults.standard.removeObject(forKey: "currentAgent")
    }
    
    public var currentAgent: AgentUser? {
        guard let data = UserDefaults.standard.data(forKey: "currentAgent"),
              let agent = try? JSONDecoder().decode(AgentUser.self, from: data) else {
            return nil
        }
        return agent
    }
}

// MARK: - 房源管理服务(B端)
public protocol HouseManagementServiceProtocol {
    func createHouse(_ house: HouseCreateRequest) -> AnyPublisher<House, NetworkError>
    func updateHouse(id: String, _ house: HouseCreateRequest) -> AnyPublisher<House, NetworkError>
    func getMyHouses(status: HouseStatus?, page: Int) -> AnyPublisher<APIPagedResponse<House>.PagedData<House>, NetworkError>
    func offlineHouse(id: String) -> AnyPublisher<Void, NetworkError>
    func refreshHouse(id: String) -> AnyPublisher<Void, NetworkError>
}

public struct HouseCreateRequest: Codable {
    public var title: String
    public var transactionType: House.TransactionType
    public var houseType: House.HouseType
    public var price: Double
    public var area: Double
    public var rooms: String
    public var districtCode: String
    public var address: String
    public var contactName: String
    public var contactPhone: String
    public var images: [String]
    public var floor: String?
    public var totalFloors: Int?
    public var decoration: House.DecorationType?
    public var orientation: House.Orientation?
    public var buildYear: Int?
    public var propertyType: House.PropertyType?
    public var description: String?
    public var facilities: [String]?
    public var video: String?
    public var latitude: Double?
    public var longitude: Double?
}

public enum HouseStatus: String, Codable {
    case pending = "pending"
    case active = "active"
    case offline = "offline"
    case sold = "sold"
}

public class HouseManagementService: HouseManagementServiceProtocol {
    public static let shared = HouseManagementService()
    
    private let networkManager: NetworkManager
    
    init(networkManager: NetworkManager = .shared) {
        self.networkManager = networkManager
    }
    
    public func createHouse(_ house: HouseCreateRequest) -> AnyPublisher<House, NetworkError> {
        // 这里需要将house对象转换为参数
        // 简化处理，实际需要构建parameters
        return networkManager.request(
            .createHouse,
            decodeTo: House.self
        )
    }
    
    public func updateHouse(id: String, _ house: HouseCreateRequest) -> AnyPublisher<House, NetworkError> {
        return networkManager.request(
            .updateHouse(id: id),
            decodeTo: House.self
        )
    }
    
    public func getMyHouses(status: HouseStatus?, page: Int) -> AnyPublisher<APIPagedResponse<House>.PagedData<House>, NetworkError> {
        return networkManager.requestPaged(
            .myHouses(status: status?.rawValue, page: page),
            decodeTo: House.self
        )
    }
    
    public func offlineHouse(id: String) -> AnyPublisher<Void, NetworkError> {
        return networkManager.request(.offlineHouse(id: id))
    }
    
    public func refreshHouse(id: String) -> AnyPublisher<Void, NetworkError> {
        return networkManager.request(.refreshHouse(id: id))
    }
}

// MARK: - 验真服务(B端)
public protocol VerificationServiceProtocol {
    func getTasks(status: VerificationTask.TaskStatus?, page: Int) -> AnyPublisher<APIPagedResponse<VerificationTask>.PagedData<VerificationTask>, NetworkError>
    func claimTask(id: String) -> AnyPublisher<VerificationTask, NetworkError>
    func submitVerification(id: String, result: VerificationSubmitRequest) -> AnyPublisher<VerificationTask, NetworkError>
}

public struct VerificationSubmitRequest: Codable {
    public let result: VerificationResult
    public let photos: [String]
    public let notes: String?
    
    public enum VerificationResult: String, Codable {
        case passed = "passed"
        case failed = "failed"
    }
}

public class VerificationService: VerificationServiceProtocol {
    public static let shared = VerificationService()
    
    private let networkManager: NetworkManager
    
    init(networkManager: NetworkManager = .shared) {
        self.networkManager = networkManager
    }
    
    public func getTasks(status: VerificationTask.TaskStatus?, page: Int) -> AnyPublisher<APIPagedResponse<VerificationTask>.PagedData<VerificationTask>, NetworkError> {
        return networkManager.requestPaged(
            .verificationTasks(status: status?.rawValue, page: page),
            decodeTo: VerificationTask.self
        )
    }
    
    public func claimTask(id: String) -> AnyPublisher<VerificationTask, NetworkError> {
        return networkManager.request(
            .claimTask(id: id),
            decodeTo: VerificationTask.self
        )
    }
    
    public func submitVerification(id: String, result: VerificationSubmitRequest) -> AnyPublisher<VerificationTask, NetworkError> {
        return networkManager.request(
            .submitVerification(id: id),
            decodeTo: VerificationTask.self
        )
    }
}

// MARK: - 客户服务(B端)
public protocol CustomerServiceProtocol {
    func getCustomers(status: Customer.CustomerStatus?, page: Int) -> AnyPublisher<APIPagedResponse<Customer>.PagedData<Customer>, NetworkError>
    func createCustomer(_ customer: CustomerCreateRequest) -> AnyPublisher<Customer, NetworkError>
    func updateCustomer(id: String, _ customer: CustomerCreateRequest) -> AnyPublisher<Customer, NetworkError>
    func addFollowUp(customerId: String, content: String) -> AnyPublisher<Void, NetworkError>
}

public struct CustomerCreateRequest: Codable {
    public let name: String
    public let phone: String
    public let budget: String?
    public let requirements: String?
    public let source: Customer.CustomerSource
}

public class CustomerManagementService: CustomerServiceProtocol {
    public static let shared = CustomerManagementService()
    
    private let networkManager: NetworkManager
    
    init(networkManager: NetworkManager = .shared) {
        self.networkManager = networkManager
    }
    
    public func getCustomers(status: Customer.CustomerStatus?, page: Int) -> AnyPublisher<APIPagedResponse<Customer>.PagedData<Customer>, NetworkError> {
        return networkManager.requestPaged(
            .customers(status: status?.rawValue, page: page),
            decodeTo: Customer.self
        )
    }
    
    public func createCustomer(_ customer: CustomerCreateRequest) -> AnyPublisher<Customer, NetworkError> {
        return networkManager.request(
            .createCustomer,
            decodeTo: Customer.self
        )
    }
    
    public func updateCustomer(id: String, _ customer: CustomerCreateRequest) -> AnyPublisher<Customer, NetworkError> {
        return networkManager.request(
            .updateCustomer(id: id),
            decodeTo: Customer.self
        )
    }
    
    public func addFollowUp(customerId: String, content: String) -> AnyPublisher<Void, NetworkError> {
        return networkManager.request(.followUp(customerId: customerId))
    }
}

// MARK: - 带看服务(B端)
public protocol TourServiceProtocol {
    func getTours(status: Appointment.AppointmentStatus?, date: String?) -> AnyPublisher<[Appointment], NetworkError>
    func confirmTour(id: String) -> AnyPublisher<Appointment, NetworkError>
    func rejectTour(id: String, reason: String) -> AnyPublisher<Appointment, NetworkError>
    func completeTour(id: String) -> AnyPublisher<Appointment, NetworkError>
}

public class TourService: TourServiceProtocol {
    public static let shared = TourService()
    
    private let networkManager: NetworkManager
    
    init(networkManager: NetworkManager = .shared) {
        self.networkManager = networkManager
    }
    
    public func getTours(status: Appointment.AppointmentStatus?, date: String?) -> AnyPublisher<[Appointment], NetworkError> {
        return networkManager.request(
            .tours(status: status?.rawValue, date: date),
            decodeTo: [Appointment].self
        )
    }
    
    public func confirmTour(id: String) -> AnyPublisher<Appointment, NetworkError> {
        return networkManager.request(
            .confirmTour(id: id),
            decodeTo: Appointment.self
        )
    }
    
    public func rejectTour(id: String, reason: String) -> AnyPublisher<Appointment, NetworkError> {
        return networkManager.request(
            .rejectTour(id: id, reason: reason),
            decodeTo: Appointment.self
        )
    }
    
    public func completeTour(id: String) -> AnyPublisher<Appointment, NetworkError> {
        return networkManager.request(
            .completeTour(id: id),
            decodeTo: Appointment.self
        )
    }
}

// MARK: - ACN服务(B端)
public protocol ACNServiceProtocol {
    func getTransactions(page: Int) -> AnyPublisher<APIPagedResponse<ACNTransaction>.PagedData<ACNTransaction>, NetworkError>
    func reportDeal(_ deal: DealReportRequest) -> AnyPublisher<ACNTransaction, NetworkError>
    func confirmParticipation(id: String) -> AnyPublisher<Void, NetworkError>
}

public struct DealReportRequest: Codable {
    public let houseId: String
    public let price: Double
    public let commission: Double
    public let dealDate: String
    public let participants: [ParticipantInfo]
    public let contractImage: String
    
    public struct ParticipantInfo: Codable {
        public let role: ACNTransaction.ACNRole
        public let agentId: String
    }
}

public class ACNService: ACNServiceProtocol {
    public static let shared = ACNService()
    
    private let networkManager: NetworkManager
    
    init(networkManager: NetworkManager = .shared) {
        self.networkManager = networkManager
    }
    
    public func getTransactions(page: Int) -> AnyPublisher<APIPagedResponse<ACNTransaction>.PagedData<ACNTransaction>, NetworkError> {
        return networkManager.requestPaged(
            .acnTransactions(page: page),
            decodeTo: ACNTransaction.self
        )
    }
    
    public func reportDeal(_ deal: DealReportRequest) -> AnyPublisher<ACNTransaction, NetworkError> {
        return networkManager.request(
            .reportDeal,
            decodeTo: ACNTransaction.self
        )
    }
    
    public func confirmParticipation(id: String) -> AnyPublisher<Void, NetworkError> {
        return networkManager.request(.confirmParticipation(id: id))
    }
}

// MARK: - 业绩服务(B端)
public protocol PerformanceServiceProtocol {
    func getStats(period: String) -> AnyPublisher<PerformanceStats, NetworkError>
    func getCommissionDetails(page: Int) -> AnyPublisher<APIPagedResponse<CommissionDetail>.PagedData<CommissionDetail>, NetworkError>
}

public struct CommissionDetail: Codable, Identifiable {
    public let id: String
    public let amount: Double
    public let type: CommissionType
    public let description: String
    public let createdAt: String
    public let status: CommissionStatus
    
    public enum CommissionType: String, Codable {
        case deal = "deal"
        case bonus = "bonus"
        case penalty = "penalty"
    }
    
    public enum CommissionStatus: String, Codable {
        case pending = "pending"
        case confirmed = "confirmed"
        case paid = "paid"
    }
}

public class PerformanceService: PerformanceServiceProtocol {
    public static let shared = PerformanceService()
    
    private let networkManager: NetworkManager
    
    init(networkManager: NetworkManager = .shared) {
        self.networkManager = networkManager
    }
    
    public func getStats(period: String) -> AnyPublisher<PerformanceStats, NetworkError> {
        return networkManager.request(
            .performanceStats(period: period),
            decodeTo: PerformanceStats.self
        )
    }
    
    public func getCommissionDetails(page: Int) -> AnyPublisher<APIPagedResponse<CommissionDetail>.PagedData<CommissionDetail>, NetworkError> {
        return networkManager.requestPaged(
            .commissionDetails(page: page),
            decodeTo: CommissionDetail.self
        )
    }
}
