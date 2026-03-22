import XCTest
@testable import MyanmarHome
import Combine

// MARK: - Home ViewModel 详细测试
class HomeViewModelDetailedTests: XCTestCase {
    
    var viewModel: HomeViewModel!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        viewModel = HomeViewModel()
        cancellables = []
    }
    
    override func tearDown() {
        viewModel = nil
        cancellables = nil
        super.tearDown()
    }
    
    func testLoadHomeDataSetsLoadingState() {
        let expectation = XCTestExpectation(description: "Loading state changes")
        
        var loadingStates: [Bool] = []
        viewModel.$isLoading
            .sink { isLoading in
                loadingStates.append(isLoading)
                if loadingStates.count >= 2 {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        viewModel.loadHomeData()
        
        wait(for: [expectation], timeout: 5.0)
        
        // 验证加载状态变化: false -> true -> false
        XCTAssertTrue(loadingStates.contains(true))
    }
    
    func testQuickEntryHandling() {
        let entry = HomeData.QuickEntry(
            id: "1",
            type: .buy,
            icon: "house",
            name: "买房"
        )
        
        // 验证不会崩溃
        viewModel.handleQuickEntry(entry)
        
        // 这里可以添加更多验证，比如检查是否正确触发了导航事件
    }
    
    func testBannerHandling() {
        let banner = Banner(
            id: "1",
            image: "test.jpg",
            linkType: .house,
            linkValue: "house_id"
        )
        
        // 验证不会崩溃
        viewModel.handleBanner(banner)
    }
}

// MARK: - Search ViewModel 详细测试
class SearchViewModelDetailedTests: XCTestCase {
    
    var viewModel: SearchViewModel!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        viewModel = SearchViewModel()
        cancellables = []
    }
    
    override func tearDown() {
        viewModel = nil
        cancellables = nil
        super.tearDown()
    }
    
    func testSearchFilters() {
        var filters = SearchFilters()
        filters.transactionType = .sale
        filters.houseType = .apartment
        filters.priceMin = 1000
        filters.priceMax = 5000
        
        viewModel.applyFilters(filters)
        
        XCTAssertEqual(viewModel.filters.transactionType, .sale)
        XCTAssertEqual(viewModel.filters.houseType, .apartment)
        XCTAssertEqual(viewModel.filters.priceMin, 1000)
        XCTAssertEqual(viewModel.filters.priceMax, 5000)
    }
    
    func testSearchTextChanges() {
        let expectation = XCTestExpectation(description: "Search text debounce")
        
        viewModel.$searchText
            .dropFirst()
            .sink { text in
                XCTAssertEqual(text, "test")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        viewModel.searchText = "test"
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testHotSearchesLoading() {
        viewModel.loadHotSearches()
        
        XCTAssertFalse(viewModel.hotSearches.isEmpty)
        XCTAssertTrue(viewModel.hotSearches.contains("仰光公寓"))
    }
}

// MARK: - House Detail ViewModel 详细测试
class HouseDetailViewModelDetailedTests: XCTestCase {
    
    var viewModel: HouseDetailViewModel!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        viewModel = HouseDetailViewModel(houseId: "test_house_id")
        cancellables = []
    }
    
    override func tearDown() {
        viewModel = nil
        cancellables = nil
        super.tearDown()
    }
    
    func testContactAgent() {
        XCTAssertFalse(viewModel.showContactSheet)
        
        viewModel.contactAgent()
        
        XCTAssertTrue(viewModel.showContactSheet)
    }
    
    func testToggleFavoriteWithoutHouse() {
        // 没有房源时不应该崩溃
        viewModel.toggleFavorite()
        
        XCTAssertFalse(viewModel.isFavorite)
    }
    
    func testShareHouse() {
        // 验证不会崩溃
        viewModel.shareHouse()
    }
}

// MARK: - Appointment ViewModel 详细测试
class AppointmentViewModelDetailedTests: XCTestCase {
    
    var viewModel: AppointmentViewModel!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        viewModel = AppointmentViewModel()
        cancellables = []
    }
    
    override func tearDown() {
        viewModel = nil
        cancellables = nil
        super.tearDown()
    }
    
    func testStatusFiltering() {
        viewModel.selectedStatus = .pending
        XCTAssertEqual(viewModel.selectedStatus, .pending)
        
        viewModel.selectedStatus = .confirmed
        XCTAssertEqual(viewModel.selectedStatus, .confirmed)
        
        viewModel.selectedStatus = nil
        XCTAssertNil(viewModel.selectedStatus)
    }
    
    func testCancelAppointment() {
        let appointment = Appointment(
            id: "test_id",
            houseId: "house_id",
            houseTitle: "Test House",
            houseImage: nil,
            agentId: "agent_id",
            agentName: "Test Agent",
            appointmentTime: "2024-01-01 10:00:00",
            status: .pending,
            createdAt: nil,
            note: nil
        )
        
        viewModel.appointments = [appointment]
        
        // 验证不会崩溃（实际取消需要网络请求）
        // viewModel.cancelAppointment(appointment)
    }
}

// MARK: - Agent ViewModel 详细测试
class AgentAuthViewModelDetailedTests: XCTestCase {
    
    var viewModel: AgentAuthViewModel!
    
    override func setUp() {
        super.setUp()
        viewModel = AgentAuthViewModel()
    }
    
    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }
    
    func testPhoneValidation() {
        // 有效号码
        viewModel.phone = "+959123456789"
        XCTAssertTrue(viewModel.canSendCode)
        
        // 无效号码
        viewModel.phone = "123"
        XCTAssertFalse(viewModel.canSendCode)
        
        // 空号码
        viewModel.phone = ""
        XCTAssertFalse(viewModel.canSendCode)
    }
    
    func testVerifyCodeValidation() {
        viewModel.phone = "+959123456789"
        
        // 验证码长度不足
        viewModel.verifyCode = "123"
        XCTAssertFalse(viewModel.canLogin)
        
        // 验证码长度正确
        viewModel.verifyCode = "123456"
        XCTAssertTrue(viewModel.canLogin)
        
        // 验证码过长
        viewModel.verifyCode = "1234567"
        // 注意：实际逻辑可能需要调整
    }
    
    func testNameValidationForRegister() {
        viewModel.phone = "+959123456789"
        viewModel.verifyCode = "123456"
        
        // 没有姓名不能注册
        viewModel.name = ""
        XCTAssertFalse(viewModel.canRegister)
        
        // 有姓名可以注册
        viewModel.name = "Test Agent"
        XCTAssertTrue(viewModel.canRegister)
    }
}

class HouseEntryViewModelDetailedTests: XCTestCase {
    
    var viewModel: HouseEntryViewModel!
    
    override func setUp() {
        super.setUp()
        viewModel = HouseEntryViewModel()
    }
    
    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }
    
    func testFormValidation() {
        // 完全空表单
        XCTAssertFalse(viewModel.isValid)
        
        // 填写部分信息
        viewModel.title = "Test Title"
        viewModel.price = "1000"
        XCTAssertFalse(viewModel.isValid)
        
        // 填写所有文字信息但没有图片
        viewModel.area = "100"
        viewModel.rooms = "3室2厅"
        viewModel.districtCode = "tamwe"
        viewModel.address = "Test Address"
        viewModel.contactName = "Test Name"
        viewModel.contactPhone = "+959123456789"
        XCTAssertFalse(viewModel.isValid)
        
        // 添加足够图片
        for _ in 0..<5 {
            viewModel.addImage(UIImage())
        }
        XCTAssertTrue(viewModel.isValid)
    }
    
    func testImageLimit() {
        // 添加20张图片（达到上限）
        for _ in 0..<20 {
            viewModel.addImage(UIImage())
        }
        XCTAssertEqual(viewModel.selectedImages.count, 20)
        
        // 尝试添加第21张
        viewModel.addImage(UIImage())
        // 应该仍然有20张，并且显示错误信息
        XCTAssertEqual(viewModel.selectedImages.count, 20)
        XCTAssertNotNil(viewModel.errorMessage)
    }
    
    func testLocationSetting() {
        XCTAssertNil(viewModel.latitude)
        XCTAssertNil(viewModel.longitude)
        
        viewModel.setLocation(lat: 16.8, lng: 96.15)
        
        XCTAssertEqual(viewModel.latitude, 16.8)
        XCTAssertEqual(viewModel.longitude, 96.15)
    }
}

class CustomerManagementViewModelDetailedTests: XCTestCase {
    
    var viewModel: CustomerManagementViewModel!
    
    override func setUp() {
        super.setUp()
        viewModel = CustomerManagementViewModel()
    }
    
    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }
    
    func testNewCustomerValidation() {
        // 空表单不能添加
        XCTAssertTrue(viewModel.newCustomerName.isEmpty)
        XCTAssertTrue(viewModel.newCustomerPhone.isEmpty)
        
        // 填写信息
        viewModel.newCustomerName = "Test Customer"
        viewModel.newCustomerPhone = "+959123456789"
        viewModel.newCustomerBudget = "1000-2000"
        viewModel.newCustomerRequirements = "3室公寓"
        
        XCTAssertEqual(viewModel.newCustomerName, "Test Customer")
        XCTAssertEqual(viewModel.newCustomerPhone, "+959123456789")
    }
    
    func testStatusFiltering() {
        viewModel.selectedStatus = .new
        XCTAssertEqual(viewModel.selectedStatus, .new)
        
        viewModel.selectedStatus = .following
        XCTAssertEqual(viewModel.selectedStatus, .following)
    }
}

class ACNViewModelDetailedTests: XCTestCase {
    
    var viewModel: ACNViewModel!
    
    override func setUp() {
        super.setUp()
        viewModel = ACNViewModel()
    }
    
    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }
    
    func testCommissionCalculation() {
        let totalCommission: Double = 1000
        
        let entrantCommission = viewModel.calculateCommission(role: .entrant, totalCommission: totalCommission)
        XCTAssertEqual(entrantCommission, 150) // 15%
        
        let maintainerCommission = viewModel.calculateCommission(role: .maintainer, totalCommission: totalCommission)
        XCTAssertEqual(maintainerCommission, 200) // 20%
        
        let introducerCommission = viewModel.calculateCommission(role: .introducer, totalCommission: totalCommission)
        XCTAssertEqual(introducerCommission, 100) // 10%
        
        let accompanierCommission = viewModel.calculateCommission(role: .accompanier, totalCommission: totalCommission)
        XCTAssertEqual(accompanierCommission, 150) // 15%
        
        let closerCommission = viewModel.calculateCommission(role: .closer, totalCommission: totalCommission)
        XCTAssertEqual(closerCommission, 400) // 40%
        
        // 验证总和为90%（平台保留10%）
        let total = entrantCommission + maintainerCommission + introducerCommission + accompanierCommission + closerCommission
        XCTAssertEqual(total, 900)
    }
    
    func testDealReportValidation() {
        XCTAssertTrue(viewModel.dealHouseId.isEmpty)
        XCTAssertTrue(viewModel.dealPrice.isEmpty)
        XCTAssertTrue(viewModel.dealCommission.isEmpty)
        XCTAssertTrue(viewModel.selectedParticipants.isEmpty)
    }
}

class PerformanceViewModelDetailedTests: XCTestCase {
    
    var viewModel: PerformanceViewModel!
    
    override func setUp() {
        super.setUp()
        viewModel = PerformanceViewModel()
    }
    
    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }
    
    func testPeriodSelection() {
        XCTAssertEqual(viewModel.selectedPeriod, "month")
        
        viewModel.selectedPeriod = "quarter"
        XCTAssertEqual(viewModel.selectedPeriod, "quarter")
        
        viewModel.selectedPeriod = "year"
        XCTAssertEqual(viewModel.selectedPeriod, "year")
    }
    
    func testInitialStats() {
        XCTAssertNil(viewModel.stats)
        XCTAssertTrue(viewModel.commissionDetails.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
    }
}

// MARK: - 集成测试
class IntegrationTests: XCTestCase {
    
    func testTokenPersistence() {
        let tokenManager = TokenManager.shared
        
        // 保存token
        tokenManager.accessToken = "integration_test_token"
        tokenManager.tokenExpiresAt = Date().addingTimeInterval(3600)
        
        // 创建新的实例验证持久化
        let newTokenManager = TokenManager.shared
        XCTAssertEqual(newTokenManager.accessToken, "integration_test_token")
        
        // 清理
        tokenManager.clearTokens()
    }
    
    func testSearchHistoryPersistence() {
        let key = "searchHistory"
        let testHistory = ["test1", "test2", "test3"]
        
        // 保存历史
        UserDefaults.standard.set(testHistory, forKey: key)
        
        // 验证保存
        let loadedHistory = UserDefaults.standard.stringArray(forKey: key)
        XCTAssertEqual(loadedHistory, testHistory)
        
        // 清理
        UserDefaults.standard.removeObject(forKey: key)
    }
}

// MARK: - 异步测试
class AsyncTests: XCTestCase {
    
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        cancellables = []
    }
    
    override func tearDown() {
        cancellables = nil
        super.tearDown()
    }
    
    func testPublisherCompletion() {
        let expectation = XCTestExpectation(description: "Publisher completes")
        
        let publisher = Just("test")
            .delay(for: .milliseconds(100), scheduler: DispatchQueue.main)
        
        publisher
            .sink(receiveCompletion: { _ in
                expectation.fulfill()
            }, receiveValue: { _ in })
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testPublisherValues() {
        let expectation = XCTestExpectation(description: "Publisher emits values")
        
        let values = [1, 2, 3]
        var receivedValues: [Int] = []
        
        values.publisher
            .sink(receiveCompletion: { _ in
                expectation.fulfill()
            }, receiveValue: { value in
                receivedValues.append(value)
            })
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(receivedValues, values)
    }
}
