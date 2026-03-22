import Foundation
import Combine
import Alamofire

// MARK: - 认证Token管理
public protocol TokenManaging {
    var accessToken: String? { get set }
    var refreshToken: String? { get set }
    var tokenExpiresAt: Date? { get set }
    var isTokenValid: Bool { get }
    
    func clearTokens()
}

public class TokenManager: TokenManaging {
    public static let shared = TokenManager()
    
    private let userDefaults = UserDefaults.standard
    private let accessTokenKey = "com.myanmarhome.accessToken"
    private let refreshTokenKey = "com.myanmarhome.refreshToken"
    private let tokenExpiresKey = "com.myanmarhome.tokenExpires"
    
    public var accessToken: String? {
        get { userDefaults.string(forKey: accessTokenKey) }
        set { userDefaults.set(newValue, forKey: accessTokenKey) }
    }
    
    public var refreshToken: String? {
        get { userDefaults.string(forKey: refreshTokenKey) }
        set { userDefaults.set(newValue, forKey: refreshTokenKey) }
    }
    
    public var tokenExpiresAt: Date? {
        get { userDefaults.object(forKey: tokenExpiresKey) as? Date }
        set { userDefaults.set(newValue, forKey: tokenExpiresKey) }
    }
    
    public var isTokenValid: Bool {
        guard let expiresAt = tokenExpiresAt else { return false }
        return Date() < expiresAt.addingTimeInterval(-300) // 提前5分钟认为过期
    }
    
    public func clearTokens() {
        accessToken = nil
        refreshToken = nil
        tokenExpiresAt = nil
    }
}

// MARK: - 网络管理器
public class NetworkManager {
    public static let shared = NetworkManager()
    
    private var session: Session
    private var tokenManager: TokenManaging
    private var cancellables = Set<AnyCancellable>()
    
    // 用于存储正在进行的请求，以便可以取消
    private var activeRequests: [String: DataRequest] = [:]
    private let requestLock = NSLock()
    
    private init(tokenManager: TokenManaging = TokenManager.shared) {
        self.tokenManager = tokenManager
        
        // 配置Alamofire会话
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = APIConfig.timeoutInterval
        configuration.timeoutIntervalForResource = APIConfig.timeoutInterval * 2
        
        self.session = Session(configuration: configuration)
    }
    
    // MARK: - 请求方法
    
    /// 发送API请求并返回解码后的数据
    public func request<T: Codable>(
        _ endpoint: APIEndpoint,
        decodeTo type: T.Type,
        requestId: String? = nil
    ) -> AnyPublisher<T, NetworkError> {
        
        guard let url = URL(string: APIConfig.baseURL + APIConfig.apiVersion + endpoint.path) else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        
        // 构建请求
        var headers: HTTPHeaders = [
            "Accept": "application/json",
            "Content-Type": "application/json"
        ]
        
        // 添加认证Token
        if let token = tokenManager.accessToken {
            headers.add(HTTPHeader(name: "Authorization", value: "Bearer \(token)"))
        }
        
        // 创建请求
        let request = session.request(
            url,
            method: endpoint.method,
            parameters: endpoint.parameters,
            encoding: endpoint.method == .get ? URLEncoding.default : JSONEncoding.default,
            headers: headers
        )
        .validate(statusCode: 200..<300)
        .responseData { [weak self] response in
            if let requestId = requestId {
                self?.removeActiveRequest(id: requestId)
            }
        }
        
        // 存储请求以便可以取消
        if let requestId = requestId {
            storeActiveRequest(request, id: requestId)
        }
        
        return request
            .publishData()
            .tryMap { [weak self] response -> Data in
                switch response.result {
                case .success(let data):
                    return data
                case .failure(let error):
                    throw self?.handleError(error, response: response.response, data: response.data) ?? error
                }
            }
            .decode(type: APIResponse<T>.self, decoder: JSONDecoder())
            .tryMap { response -> T in
                if response.isSuccess, let data = response.data {
                    return data
                } else {
                    throw NetworkError.serverError(response.code, response.message)
                }
            }
            .mapError { error -> NetworkError in
                if let networkError = error as? NetworkError {
                    return networkError
                } else if let decodingError = error as? DecodingError {
                    return NetworkError.decodingFailed(decodingError)
                } else {
                    return NetworkError.networkFailure(error)
                }
            }
            .eraseToAnyPublisher()
    }
    
    /// 发送API请求并返回分页数据
    public func requestPaged<T: Codable>(
        _ endpoint: APIEndpoint,
        decodeTo type: T.Type,
        requestId: String? = nil
    ) -> AnyPublisher<APIPagedResponse<T>.PagedData<T>, NetworkError> {
        
        guard let url = URL(string: APIConfig.baseURL + APIConfig.apiVersion + endpoint.path) else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        
        var headers: HTTPHeaders = [
            "Accept": "application/json",
            "Content-Type": "application/json"
        ]
        
        if let token = tokenManager.accessToken {
            headers.add(HTTPHeader(name: "Authorization", value: "Bearer \(token)"))
        }
        
        let request = session.request(
            url,
            method: endpoint.method,
            parameters: endpoint.parameters,
            encoding: endpoint.method == .get ? URLEncoding.default : JSONEncoding.default,
            headers: headers
        )
        .validate(statusCode: 200..<300)
        .responseData { [weak self] response in
            if let requestId = requestId {
                self?.removeActiveRequest(id: requestId)
            }
        }
        
        if let requestId = requestId {
            storeActiveRequest(request, id: requestId)
        }
        
        return request
            .publishData()
            .tryMap { [weak self] response -> Data in
                switch response.result {
                case .success(let data):
                    return data
                case .failure(let error):
                    throw self?.handleError(error, response: response.response, data: response.data) ?? error
                }
            }
            .decode(type: APIPagedResponse<T>.self, decoder: JSONDecoder())
            .tryMap { response -> APIPagedResponse<T>.PagedData<T> in
                if response.isSuccess, let data = response.data {
                    return data
                } else {
                    throw NetworkError.serverError(response.code, response.message)
                }
            }
            .mapError { error -> NetworkError in
                if let networkError = error as? NetworkError {
                    return networkError
                } else if let decodingError = error as? DecodingError {
                    return NetworkError.decodingFailed(decodingError)
                } else {
                    return NetworkError.networkFailure(error)
                }
            }
            .eraseToAnyPublisher()
    }
    
    /// 上传图片
    public func uploadImage(
        _ imageData: Data,
        fileName: String = "image.jpg",
        mimeType: String = "image/jpeg"
    ) -> AnyPublisher<String, NetworkError> {
        
        guard let url = URL(string: APIConfig.baseURL + APIConfig.apiVersion + APIEndpoint.uploadImage.path) else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        
        var headers: HTTPHeaders = [:]
        if let token = tokenManager.accessToken {
            headers.add(HTTPHeader(name: "Authorization", value: "Bearer \(token)"))
        }
        
        return session.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(imageData, withName: "file", fileName: fileName, mimeType: mimeType)
            },
            to: url,
            headers: headers
        )
        .validate(statusCode: 200..<300)
        .publishData()
        .tryMap { [weak self] response -> Data in
            switch response.result {
            case .success(let data):
                return data
            case .failure(let error):
                throw self?.handleError(error, response: response.response, data: response.data) ?? error
            }
        }
        .decode(type: APIResponse<String>.self, decoder: JSONDecoder())
        .tryMap { response -> String in
            if response.isSuccess, let data = response.data {
                return data
            } else {
                throw NetworkError.serverError(response.code, response.message)
            }
        }
        .mapError { error -> NetworkError in
            if let networkError = error as? NetworkError {
                return networkError
            } else if let decodingError = error as? DecodingError {
                return NetworkError.decodingFailed(decodingError)
            } else {
                return NetworkError.networkFailure(error)
            }
        }
        .eraseToAnyPublisher()
    }
    
    /// 批量上传图片
    public func uploadImages(
        _ imagesData: [Data]
    ) -> AnyPublisher<[String], NetworkError> {
        
        guard let url = URL(string: APIConfig.baseURL + APIConfig.apiVersion + APIEndpoint.uploadMultipleImages.path) else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        
        var headers: HTTPHeaders = [:]
        if let token = tokenManager.accessToken {
            headers.add(HTTPHeader(name: "Authorization", value: "Bearer \(token)"))
        }
        
        return session.upload(
            multipartFormData: { multipartFormData in
                for (index, data) in imagesData.enumerated() {
                    multipartFormData.append(data, withName: "files", fileName: "image_\(index).jpg", mimeType: "image/jpeg")
                }
            },
            to: url,
            headers: headers
        )
        .validate(statusCode: 200..<300)
        .publishData()
        .tryMap { [weak self] response -> Data in
            switch response.result {
            case .success(let data):
                return data
            case .failure(let error):
                throw self?.handleError(error, response: response.response, data: response.data) ?? error
            }
        }
        .decode(type: APIResponse<[String]>.self, decoder: JSONDecoder())
        .tryMap { response -> [String] in
            if response.isSuccess, let data = response.data {
                return data
            } else {
                throw NetworkError.serverError(response.code, response.message)
            }
        }
        .mapError { error -> NetworkError in
            if let networkError = error as? NetworkError {
                return networkError
            } else if let decodingError = error as? DecodingError {
                return NetworkError.decodingFailed(decodingError)
            } else {
                return NetworkError.networkFailure(error)
            }
        }
        .eraseToAnyPublisher()
    }
    
    /// 取消指定ID的请求
    public func cancelRequest(id: String) {
        requestLock.lock()
        defer { requestLock.unlock() }
        
        if let request = activeRequests[id] {
            request.cancel()
            activeRequests.removeValue(forKey: id)
        }
    }
    
    /// 取消所有活跃请求
    public func cancelAllRequests() {
        requestLock.lock()
        defer { requestLock.unlock() }
        
        activeRequests.values.forEach { $0.cancel() }
        activeRequests.removeAll()
    }
    
    // MARK: - Private Methods
    
    private func storeActiveRequest(_ request: DataRequest, id: String) {
        requestLock.lock()
        defer { requestLock.unlock() }
        activeRequests[id] = request
    }
    
    private func removeActiveRequest(id: String) {
        requestLock.lock()
        defer { requestLock.unlock() }
        activeRequests.removeValue(forKey: id)
    }
    
    private func handleError(_ error: AFError, response: HTTPURLResponse?, data: Data?) -> Error {
        // 处理认证失败
        if let response = response, response.statusCode == 401 {
            tokenManager.clearTokens()
            return NetworkError.unauthorized
        }
        
        // 尝试解析服务器错误信息
        if let data = data,
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            let code = json["code"] as? Int ?? response?.statusCode ?? 500
            let message = json["message"] as? String ?? "未知错误"
            return NetworkError.serverError(code, message)
        }
        
        return NetworkError.networkFailure(error)
    }
}

// MARK: - 网络状态监控
public class NetworkMonitor: ObservableObject {
    public static let shared = NetworkMonitor()
    
    @Published public var isConnected: Bool = true
    @Published public var connectionType: ConnectionType = .unknown
    
    public enum ConnectionType {
        case wifi
        case cellular
        case ethernet
        case unknown
        case none
    }
    
    private init() {
        // 实际项目中可以使用 NWPathMonitor 来监控网络状态
        // 这里简化处理
    }
}

// MARK: - 便捷扩展
extension NetworkManager {
    /// 发送空响应的请求（如删除操作）
    public func request(
        _ endpoint: APIEndpoint,
        requestId: String? = nil
    ) -> AnyPublisher<Void, NetworkError> {
        return self.request(endpoint, decodeTo: EmptyResponse.self, requestId: requestId)
            .map { _ in () }
            .eraseToAnyPublisher()
    }
}

// MARK: - 空响应
struct EmptyResponse: Codable {}
