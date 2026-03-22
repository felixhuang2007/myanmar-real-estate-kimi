import Foundation
import Combine

// MARK: - 首页ViewModel
public class HomeViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var banners: [Banner] = []
    @Published var quickEntries: [HomeData.QuickEntry] = []
    @Published var recommendedHouses: [House] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    private let homeService: HomeServiceProtocol
    private let houseService: HouseServiceProtocol
    
    private var currentPage = 1
    private var hasMorePages = true
    private let cityCode = "yangon" // 默认城市
    
    // MARK: - Initialization
    public init(
        homeService: HomeServiceProtocol = HomeService.shared,
        houseService: HouseServiceProtocol = HouseService.shared
    ) {
        self.homeService = homeService
        self.houseService = houseService
    }
    
    // MARK: - Public Methods
    
    /// 加载首页数据
    public func loadHomeData() {
        isLoading = true
        errorMessage = nil
        currentPage = 1
        
        // 并行加载Banner和推荐房源
        Publishers.Zip(
            homeService.getBanners(city: cityCode),
            homeService.getHomeRecommend(city: cityCode, page: currentPage)
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] completion in
            self?.isLoading = false
            if case .failure(let error) = completion {
                self?.errorMessage = error.localizedDescription
            }
        } receiveValue: { [weak self] banners, homeData in
            self?.banners = banners
            self?.quickEntries = homeData.quickEntries
            self?.recommendedHouses = homeData.houses
            self?.hasMorePages = homeData.houses.count >= APIConfig.pageSize
        }
        .store(in: &cancellables)
    }
    
    /// 加载更多推荐房源
    public func loadMoreHouses() {
        guard !isLoading && hasMorePages else { return }
        
        isLoading = true
        currentPage += 1
        
        homeService.getHomeRecommend(city: cityCode, page: currentPage)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] homeData in
                self?.recommendedHouses.append(contentsOf: homeData.houses)
                self?.hasMorePages = homeData.houses.count >= APIConfig.pageSize
            }
            .store(in: &cancellables)
    }
    
    /// 刷新数据
    public func refresh() {
        loadHomeData()
    }
    
    /// 处理快捷入口点击
    public func handleQuickEntry(_ entry: HomeData.QuickEntry) {
        // 通知Coordinator处理导航
        // 实际项目中通过委托或通知机制
        Logger.info("点击快捷入口: \(entry.name)")
    }
    
    /// 处理Banner点击
    public func handleBanner(_ banner: Banner) {
        Logger.info("点击Banner: \(banner.linkType)")
    }
}

// MARK: - 搜索ViewModel
public class SearchViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var searchText = ""
    @Published var filters = SearchFilters()
    @Published var houses: [House] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchHistory: [String] = []
    @Published var hotSearches: [String] = []
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    private let houseService: HouseServiceProtocol
    
    private var currentPage = 1
    private var hasMorePages = true
    private var searchCancellable: AnyCancellable?
    
    // MARK: - Initialization
    public init(houseService: HouseServiceProtocol = HouseService.shared) {
        self.houseService = houseService
        loadSearchHistory()
        setupSearchDebounce()
    }
    
    // MARK: - Public Methods
    
    /// 执行搜索
    public func search() {
        guard !searchText.isEmpty else {
            houses = []
            return
        }
        
        isLoading = true
        errorMessage = nil
        currentPage = 1
        
        var searchFilters = filters
        searchFilters.keywords = searchText
        
        houseService.searchHouses(filters: searchFilters, page: currentPage)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] result in
                self?.houses = result.list
                self?.hasMorePages = result.hasMore
                // 保存搜索历史
                self?.saveSearchHistory(self?.searchText ?? "")
            }
            .store(in: &cancellables)
    }
    
    /// 应用筛选条件
    public func applyFilters(_ newFilters: SearchFilters) {
        filters = newFilters
        search()
    }
    
    /// 加载更多
    public func loadMore() {
        guard !isLoading && hasMorePages else { return }
        
        isLoading = true
        currentPage += 1
        
        var searchFilters = filters
        searchFilters.keywords = searchText
        
        houseService.searchHouses(filters: searchFilters, page: currentPage)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] result in
                self?.houses.append(contentsOf: result.list)
                self?.hasMorePages = result.hasMore
            }
            .store(in: &cancellables)
    }
    
    /// 清除搜索
    public func clearSearch() {
        searchText = ""
        houses = []
        errorMessage = nil
    }
    
    /// 从历史记录搜索
    public func searchFromHistory(_ keyword: String) {
        searchText = keyword
        search()
    }
    
    /// 清除历史记录
    public func clearHistory() {
        searchHistory.removeAll()
        UserDefaults.standard.removeObject(forKey: "searchHistory")
    }
    
    /// 获取热门搜索
    public func loadHotSearches() {
        // 实际项目中从API获取
        hotSearches = ["仰光公寓", "别墅", "学区房", "新盘", "精装修"]
    }
    
    // MARK: - Private Methods
    
    private func setupSearchDebounce() {
        searchCancellable = $searchText
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .filter { !$0.isEmpty }
            .sink { [weak self] _ in
                // 可以在这里实现实时搜索建议
            }
    }
    
    private func loadSearchHistory() {
        searchHistory = UserDefaults.standard.stringArray(forKey: "searchHistory") ?? []
    }
    
    private func saveSearchHistory(_ keyword: String) {
        guard !keyword.isEmpty else { return }
        
        // 去重并移到最前面
        searchHistory.removeAll { $0 == keyword }
        searchHistory.insert(keyword, at: 0)
        
        // 最多保存10条
        if searchHistory.count > 10 {
            searchHistory = Array(searchHistory.prefix(10))
        }
        
        UserDefaults.standard.set(searchHistory, forKey: "searchHistory")
    }
}

// MARK: - 房源详情ViewModel
public class HouseDetailViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var house: House?
    @Published var similarHouses: [House] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isFavorite = false
    @Published var showContactSheet = false
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    private let houseService: HouseServiceProtocol
    private let favoriteService: FavoriteServiceProtocol
    
    private let houseId: String
    
    // MARK: - Initialization
    public init(
        houseId: String,
        houseService: HouseServiceProtocol = HouseService.shared,
        favoriteService: FavoriteServiceProtocol = FavoriteService.shared
    ) {
        self.houseId = houseId
        self.houseService = houseService
        self.favoriteService = favoriteService
    }
    
    // MARK: - Public Methods
    
    /// 加载房源详情
    public func loadDetail() {
        isLoading = true
        errorMessage = nil
        
        houseService.getHouseDetail(id: houseId)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] house in
                self?.house = house
            }
            .store(in: &cancellables)
        
        // 同时加载相似房源
        houseService.getSimilarHouses(id: houseId)
            .receive(on: DispatchQueue.main)
            .sink { _ in } receiveValue: { [weak self] houses in
                self?.similarHouses = houses
            }
            .store(in: &cancellables)
    }
    
    /// 切换收藏状态
    public func toggleFavorite() {
        guard let house = house else { return }
        
        let publisher: AnyPublisher<Void, NetworkError>
        if isFavorite {
            publisher = favoriteService.removeFavorite(houseId: house.id)
        } else {
            publisher = favoriteService.addFavorite(houseId: house.id)
        }
        
        publisher
            .receive(on: DispatchQueue.main)
            .sink { _ in } receiveValue: { [weak self] in
                self?.isFavorite.toggle()
                HapticFeedback.light()
            }
            .store(in: &cancellables)
    }
    
    /// 联系经纪人
    public func contactAgent() {
        showContactSheet = true
    }
    
    /// 预约带看
    public func makeAppointment() {
        // 导航到预约页面
        Logger.info("预约带看: \(houseId)")
    }
    
    /// 分享房源
    public func shareHouse() {
        // 调起分享面板
        Logger.info("分享房源: \(houseId)")
    }
}

// MARK: - 预约ViewModel
public class AppointmentViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var appointments: [Appointment] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedStatus: Appointment.AppointmentStatus?
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    private let appointmentService: AppointmentServiceProtocol
    
    private var currentPage = 1
    private var hasMorePages = true
    
    // MARK: - Initialization
    public init(appointmentService: AppointmentServiceProtocol = AppointmentService.shared) {
        self.appointmentService = appointmentService
    }
    
    // MARK: - Public Methods
    
    /// 加载预约列表
    public func loadAppointments() {
        isLoading = true
        errorMessage = nil
        currentPage = 1
        
        appointmentService.getAppointments(page: currentPage)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] result in
                self?.appointments = result.list
                self?.hasMorePages = result.hasMore
            }
            .store(in: &cancellables)
    }
    
    /// 加载更多
    public func loadMore() {
        guard !isLoading && hasMorePages else { return }
        
        isLoading = true
        currentPage += 1
        
        appointmentService.getAppointments(page: currentPage)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] result in
                self?.appointments.append(contentsOf: result.list)
                self?.hasMorePages = result.hasMore
            }
            .store(in: &cancellables)
    }
    
    /// 取消预约
    public func cancelAppointment(_ appointment: Appointment) {
        appointmentService.cancelAppointment(id: appointment.id)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] in
                // 更新本地状态
                if let index = self?.appointments.firstIndex(where: { $0.id == appointment.id }) {
                    self?.appointments[index] = Appointment(
                        id: appointment.id,
                        houseId: appointment.houseId,
                        houseTitle: appointment.houseTitle,
                        houseImage: appointment.houseImage,
                        agentId: appointment.agentId,
                        agentName: appointment.agentName,
                        appointmentTime: appointment.appointmentTime,
                        status: .cancelled,
                        createdAt: appointment.createdAt,
                        note: appointment.note
                    )
                }
            }
            .store(in: &cancellables)
    }
}

// MARK: - 我的收藏ViewModel
public class FavoritesViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var favorites: [House] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    private let favoriteService: FavoriteServiceProtocol
    
    private var currentPage = 1
    private var hasMorePages = true
    
    // MARK: - Initialization
    public init(favoriteService: FavoriteServiceProtocol = FavoriteService.shared) {
        self.favoriteService = favoriteService
    }
    
    // MARK: - Public Methods
    
    /// 加载收藏列表
    public func loadFavorites() {
        isLoading = true
        errorMessage = nil
        currentPage = 1
        
        favoriteService.getFavorites(page: currentPage)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] result in
                self?.favorites = result.list
                self?.hasMorePages = result.hasMore
            }
            .store(in: &cancellables)
    }
    
    /// 加载更多
    public func loadMore() {
        guard !isLoading && hasMorePages else { return }
        
        isLoading = true
        currentPage += 1
        
        favoriteService.getFavorites(page: currentPage)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] result in
                self?.favorites.append(contentsOf: result.list)
                self?.hasMorePages = result.hasMore
            }
            .store(in: &cancellables)
    }
    
    /// 取消收藏
    public func removeFavorite(_ house: House) {
        favoriteService.removeFavorite(houseId: house.id)
            .receive(on: DispatchQueue.main)
            .sink { _ in } receiveValue: { [weak self] in
                self?.favorites.removeAll { $0.id == house.id }
            }
            .store(in: &cancellables)
    }
}
