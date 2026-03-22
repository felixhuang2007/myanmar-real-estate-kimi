import Foundation
import Combine
import UIKit

// MARK: - 房源录入ViewModel
public class HouseEntryViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var title = ""
    @Published var transactionType: House.TransactionType = .sale
    @Published var houseType: House.HouseType = .apartment
    @Published var price = ""
    @Published var area = ""
    @Published var rooms = ""
    @Published var districtCode = ""
    @Published var address = ""
    @Published var contactName = ""
    @Published var contactPhone = ""
    @Published var selectedImages: [UIImage] = []
    @Published var floor = ""
    @Published var totalFloors = ""
    @Published var decoration: House.DecorationType?
    @Published var orientation: House.Orientation?
    @Published var buildYear = ""
    @Published var propertyType: House.PropertyType?
    @Published var houseDescription = ""
    @Published var facilities: [String] = []
    @Published var latitude: Double?
    @Published var longitude: Double?
    
    // UI状态
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showImagePicker = false
    @Published var uploadProgress: Double = 0
    @Published var isSuccess = false
    
    // MARK: - Computed Properties
    var isValid: Bool {
        !title.isEmpty &&
        !price.isEmpty &&
        !area.isEmpty &&
        !rooms.isEmpty &&
        !districtCode.isEmpty &&
        !address.isEmpty &&
        !contactName.isEmpty &&
        !contactPhone.isEmpty &&
        selectedImages.count >= 5
    }
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    private let houseService: HouseManagementServiceProtocol
    private let networkManager = NetworkManager.shared
    
    // MARK: - Initialization
    public init(houseService: HouseManagementServiceProtocol = HouseManagementService.shared) {
        self.houseService = houseService
    }
    
    // MARK: - Public Methods
    
    /// 提交房源
    public func submit() {
        guard isValid else {
            errorMessage = "请填写完整信息并上传至少5张图片"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        // 先上传图片
        uploadImages()
            .flatMap { [weak self] imageUrls -> AnyPublisher<House, NetworkError> in
                guard let self = self else {
                    return Fail(error: NetworkError.cancelled).eraseToAnyPublisher()
                }
                
                let request = HouseCreateRequest(
                    title: self.title,
                    transactionType: self.transactionType,
                    houseType: self.houseType,
                    price: Double(self.price) ?? 0,
                    area: Double(self.area) ?? 0,
                    rooms: self.rooms,
                    districtCode: self.districtCode,
                    address: self.address,
                    contactName: self.contactName,
                    contactPhone: self.contactPhone,
                    images: imageUrls,
                    floor: self.floor.isEmpty ? nil : self.floor,
                    totalFloors: Int(self.totalFloors),
                    decoration: self.decoration,
                    orientation: self.orientation,
                    buildYear: Int(self.buildYear),
                    propertyType: self.propertyType,
                    description: self.houseDescription.isEmpty ? nil : self.houseDescription,
                    facilities: self.facilities.isEmpty ? nil : self.facilities,
                    video: nil,
                    latitude: self.latitude,
                    longitude: self.longitude
                )
                
                return self.houseService.createHouse(request)
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] _ in
                self?.isSuccess = true
                HapticFeedback.success()
            }
            .store(in: &cancellables)
    }
    
    /// 添加图片
    public func addImage(_ image: UIImage) {
        guard selectedImages.count < 20 else {
            errorMessage = "最多上传20张图片"
            return
        }
        selectedImages.append(image)
    }
    
    /// 删除图片
    public func removeImage(at index: Int) {
        guard index < selectedImages.count else { return }
        selectedImages.remove(at: index)
    }
    
    /// 设置地图位置
    public func setLocation(lat: Double, lng: Double) {
        latitude = lat
        longitude = lng
    }
    
    // MARK: - Private Methods
    
    private func uploadImages() -> AnyPublisher<[String], NetworkError> {
        let imagesData = selectedImages.compactMap { $0.jpegData(compressionQuality: 0.8) }
        return networkManager.uploadImages(imagesData)
    }
}

// MARK: - 验真任务ViewModel
public class VerificationViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var tasks: [VerificationTask] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedStatus: VerificationTask.TaskStatus?
    
    // 验真提交相关
    @Published var verificationPhotos: [UIImage] = []
    @Published var verificationNotes = ""
    @Published var verificationResult: VerificationSubmitRequest.VerificationResult = .passed
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    private let verificationService: VerificationServiceProtocol
    
    private var currentPage = 1
    private var hasMorePages = true
    
    // MARK: - Initialization
    public init(verificationService: VerificationServiceProtocol = VerificationService.shared) {
        self.verificationService = verificationService
    }
    
    // MARK: - Public Methods
    
    /// 加载任务列表
    public func loadTasks() {
        isLoading = true
        errorMessage = nil
        currentPage = 1
        
        verificationService.getTasks(status: selectedStatus, page: currentPage)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] result in
                self?.tasks = result.list
                self?.hasMorePages = result.hasMore
            }
            .store(in: &cancellables)
    }
    
    /// 领取任务
    public func claimTask(_ task: VerificationTask) {
        verificationService.claimTask(id: task.id)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] updatedTask in
                // 更新本地任务状态
                if let index = self?.tasks.firstIndex(where: { $0.id == task.id }) {
                    self?.tasks[index] = updatedTask
                }
                HapticFeedback.success()
            }
            .store(in: &cancellables)
    }
    
    /// 提交验真结果
    public func submitVerification(_ task: VerificationTask) {
        guard !verificationPhotos.isEmpty else {
            errorMessage = "请上传验真照片"
            return
        }
        
        isLoading = true
        
        // 先上传照片
        let imagesData = verificationPhotos.compactMap { $0.jpegData(compressionQuality: 0.8) }
        
        NetworkManager.shared.uploadImages(imagesData)
            .flatMap { [weak self] photoUrls -> AnyPublisher<VerificationTask, NetworkError> in
                guard let self = self else {
                    return Fail(error: NetworkError.cancelled).eraseToAnyPublisher()
                }
                
                let request = VerificationSubmitRequest(
                    result: self.verificationResult,
                    photos: photoUrls,
                    notes: self.verificationNotes.isEmpty ? nil : self.verificationNotes
                )
                
                return self.verificationService.submitVerification(id: task.id, result: request)
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] updatedTask in
                // 更新本地任务状态
                if let index = self?.tasks.firstIndex(where: { $0.id == task.id }) {
                    self?.tasks[index] = updatedTask
                }
                self?.resetSubmissionData()
                HapticFeedback.success()
            }
            .store(in: &cancellables)
    }
    
    /// 重置提交数据
    public func resetSubmissionData() {
        verificationPhotos.removeAll()
        verificationNotes = ""
        verificationResult = .passed
    }
}

// MARK: - 客户管理ViewModel
public class CustomerManagementViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var customers: [Customer] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedStatus: Customer.CustomerStatus?
    
    // 新增客户
    @Published var newCustomerName = ""
    @Published var newCustomerPhone = ""
    @Published var newCustomerBudget = ""
    @Published var newCustomerRequirements = ""
    @Published var newCustomerSource: Customer.CustomerSource = .selfDeveloped
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    private let customerService: CustomerServiceProtocol
    
    private var currentPage = 1
    private var hasMorePages = true
    
    // MARK: - Initialization
    public init(customerService: CustomerServiceProtocol = CustomerManagementService.shared) {
        self.customerService = customerService
    }
    
    // MARK: - Public Methods
    
    /// 加载客户列表
    public func loadCustomers() {
        isLoading = true
        errorMessage = nil
        currentPage = 1
        
        customerService.getCustomers(status: selectedStatus, page: currentPage)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] result in
                self?.customers = result.list
                self?.hasMorePages = result.hasMore
            }
            .store(in: &cancellables)
    }
    
    /// 加载更多
    public func loadMore() {
        guard !isLoading && hasMorePages else { return }
        
        isLoading = true
        currentPage += 1
        
        customerService.getCustomers(status: selectedStatus, page: currentPage)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] result in
                self?.customers.append(contentsOf: result.list)
                self?.hasMorePages = result.hasMore
            }
            .store(in: &cancellables)
    }
    
    /// 添加客户
    public func addCustomer() {
        guard !newCustomerName.isEmpty, !newCustomerPhone.isEmpty else {
            errorMessage = "请填写客户姓名和手机号"
            return
        }
        
        isLoading = true
        
        let request = CustomerCreateRequest(
            name: newCustomerName,
            phone: newCustomerPhone,
            budget: newCustomerBudget.isEmpty ? nil : newCustomerBudget,
            requirements: newCustomerRequirements.isEmpty ? nil : newCustomerRequirements,
            source: newCustomerSource
        )
        
        customerService.createCustomer(request)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] newCustomer in
                self?.customers.insert(newCustomer, at: 0)
                self?.resetNewCustomerForm()
                HapticFeedback.success()
            }
            .store(in: &cancellables)
    }
    
    /// 添加跟进记录
    public func addFollowUp(customerId: String, content: String) {
        customerService.addFollowUp(customerId: customerId, content: content)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] in
                // 更新客户跟进信息
                if let index = self?.customers.firstIndex(where: { $0.id == customerId }) {
                    // 实际项目中应该更新具体字段
                    HapticFeedback.light()
                }
            }
            .store(in: &cancellables)
    }
    
    private func resetNewCustomerForm() {
        newCustomerName = ""
        newCustomerPhone = ""
        newCustomerBudget = ""
        newCustomerRequirements = ""
        newCustomerSource = .selfDeveloped
    }
}

// MARK: - 带看管理ViewModel
public class TourManagementViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var tours: [Appointment] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedDate = Date()
    @Published var selectedStatus: Appointment.AppointmentStatus?
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    private let tourService: TourServiceProtocol
    
    // MARK: - Initialization
    public init(tourService: TourServiceProtocol = TourService.shared) {
        self.tourService = tourService
    }
    
    // MARK: - Public Methods
    
    /// 加载带看列表
    public func loadTours() {
        isLoading = true
        errorMessage = nil
        
        let dateString = selectedDate.formattedString(format: "yyyy-MM-dd")
        
        tourService.getTours(status: selectedStatus, date: dateString)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] tours in
                self?.tours = tours
            }
            .store(in: &cancellables)
    }
    
    /// 确认带看
    public func confirmTour(_ tour: Appointment) {
        tourService.confirmTour(id: tour.id)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] updatedTour in
                self?.updateTour(updatedTour)
                HapticFeedback.success()
            }
            .store(in: &cancellables)
    }
    
    /// 拒绝带看
    public func rejectTour(_ tour: Appointment, reason: String) {
        tourService.rejectTour(id: tour.id, reason: reason)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] updatedTour in
                self?.updateTour(updatedTour)
            }
            .store(in: &cancellables)
    }
    
    /// 完成带看
    public func completeTour(_ tour: Appointment) {
        tourService.completeTour(id: tour.id)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] updatedTour in
                self?.updateTour(updatedTour)
                HapticFeedback.success()
            }
            .store(in: &cancellables)
    }
    
    private func updateTour(_ tour: Appointment) {
        if let index = tours.firstIndex(where: { $0.id == tour.id }) {
            tours[index] = tour
        }
    }
}

// MARK: - ACN ViewModel
public class ACNViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var transactions: [ACNTransaction] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // 成交申报
    @Published var dealHouseId = ""
    @Published var dealPrice = ""
    @Published var dealCommission = ""
    @Published var dealDate = Date()
    @Published var selectedParticipants: [ACNParticipant] = []
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    private let acnService: ACNServiceProtocol
    
    private var currentPage = 1
    private var hasMorePages = true
    
    // MARK: - Initialization
    public init(acnService: ACNServiceProtocol = ACNService.shared) {
        self.acnService = acnService
    }
    
    // MARK: - Public Methods
    
    /// 加载交易列表
    public func loadTransactions() {
        isLoading = true
        errorMessage = nil
        currentPage = 1
        
        acnService.getTransactions(page: currentPage)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] result in
                self?.transactions = result.list
                self?.hasMorePages = result.hasMore
            }
            .store(in: &cancellables)
    }
    
    /// 确认参与
    public func confirmParticipation(_ transaction: ACNTransaction) {
        acnService.confirmParticipation(id: transaction.id)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] in
                // 更新本地状态
                if let index = self?.transactions.firstIndex(where: { $0.id == transaction.id }) {
                    // 更新状态为已确认
                }
                HapticFeedback.success()
            }
            .store(in: &cancellables)
    }
    
    /// 计算分佣
    public func calculateCommission(role: ACNTransaction.ACNRole, totalCommission: Double) -> Double {
        switch role {
        case .entrant:
            return totalCommission * 0.15
        case .maintainer:
            return totalCommission * 0.20
        case .introducer:
            return totalCommission * 0.10
        case .accompanier:
            return totalCommission * 0.15
        case .closer:
            return totalCommission * 0.40
        }
    }
}

// MARK: - ACN参与者
public struct ACNParticipant: Identifiable {
    public let id = UUID()
    public let role: ACNTransaction.ACNRole
    public let agentId: String
    public let agentName: String
}

// MARK: - 业绩ViewModel
public class PerformanceViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var stats: PerformanceStats?
    @Published var commissionDetails: [CommissionDetail] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedPeriod = "month" // month, quarter, year
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    private let performanceService: PerformanceServiceProtocol
    
    private var currentPage = 1
    private var hasMorePages = true
    
    // MARK: - Initialization
    public init(performanceService: PerformanceServiceProtocol = PerformanceService.shared) {
        self.performanceService = performanceService
    }
    
    // MARK: - Public Methods
    
    /// 加载业绩数据
    public func loadPerformance() {
        isLoading = true
        errorMessage = nil
        
        performanceService.getStats(period: selectedPeriod)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] stats in
                self?.stats = stats
            }
            .store(in: &cancellables)
        
        // 同时加载佣金明细
        loadCommissionDetails()
    }
    
    /// 加载佣金明细
    public func loadCommissionDetails() {
        currentPage = 1
        
        performanceService.getCommissionDetails(page: currentPage)
            .receive(on: DispatchQueue.main)
            .sink { _ in } receiveValue: { [weak self] result in
                self?.commissionDetails = result.list
                self?.hasMorePages = result.hasMore
            }
            .store(in: &cancellables)
    }
    
    /// 加载更多佣金明细
    public func loadMoreCommissionDetails() {
        guard !isLoading && hasMorePages else { return }
        
        isLoading = true
        currentPage += 1
        
        performanceService.getCommissionDetails(page: currentPage)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] result in
                self?.commissionDetails.append(contentsOf: result.list)
                self?.hasMorePages = result.hasMore
            }
            .store(in: &cancellables)
    }
}

// MARK: - 经纪人登录ViewModel
public class AgentAuthViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var phone = ""
    @Published var verifyCode = ""
    @Published var name = ""
    @Published var company = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isCodeSent = false
    @Published var countdown = 0
    @Published var isLoggedIn = false
    @Published var isRegisterMode = false
    
    // MARK: - Computed Properties
    var canSendCode: Bool {
        phone.isValidMyanmarPhone && countdown == 0
    }
    
    var canLogin: Bool {
        phone.isValidMyanmarPhone && verifyCode.count == 6
    }
    
    var canRegister: Bool {
        canLogin && !name.isEmpty
    }
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    private var timerCancellable: AnyCancellable?
    private let agentService: AgentServiceProtocol
    
    // MARK: - Initialization
    public init(agentService: AgentServiceProtocol = AgentService.shared) {
        self.agentService = agentService
    }
    
    // MARK: - Public Methods
    
    /// 发送验证码
    public func sendVerifyCode() {
        guard canSendCode else { return }
        
        isLoading = true
        
        UserService.shared.sendVerifyCode(phone: phone)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] in
                self?.isCodeSent = true
                self?.startCountdown()
            }
            .store(in: &cancellables)
    }
    
    /// 登录
    public func login() {
        guard canLogin else { return }
        
        isLoading = true
        errorMessage = nil
        
        agentService.login(phone: phone, code: verifyCode)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] _ in
                self?.isLoggedIn = true
                HapticFeedback.success()
            }
            .store(in: &cancellables)
    }
    
    /// 注册
    public func register() {
        guard canRegister else { return }
        
        isLoading = true
        errorMessage = nil
        
        agentService.register(phone: phone, code: verifyCode, name: name, company: company.isEmpty ? nil : company)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] _ in
                self?.isLoggedIn = true
                HapticFeedback.success()
            }
            .store(in: &cancellables)
    }
    
    /// 切换模式
    public func toggleMode() {
        isRegisterMode.toggle()
        errorMessage = nil
    }
    
    // MARK: - Private Methods
    
    private func startCountdown() {
        countdown = 60
        
        timerCancellable?.cancel()
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                if self?.countdown ?? 0 > 0 {
                    self?.countdown -= 1
                } else {
                    self?.timerCancellable?.cancel()
                }
            }
    }
}
