import XCTest
@testable import MyanmarHome
import Combine

// MARK: - 网络层测试
class NetworkManagerTests: XCTestCase {
    
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        cancellables = []
    }
    
    override func tearDown() {
        cancellables = nil
        super.tearDown()
    }
    
    // 测试Token管理
    func testTokenManager() {
        let tokenManager = TokenManager.shared
        
        // 初始状态应该没有token
        XCTAssertNil(tokenManager.accessToken)
        XCTAssertNil(tokenManager.refreshToken)
        XCTAssertFalse(tokenManager.isTokenValid)
        
        // 设置token
        tokenManager.accessToken = "test_access_token"
        tokenManager.refreshToken = "test_refresh_token"
        tokenManager.tokenExpiresAt = Date().addingTimeInterval(3600)
        
        // 验证token
        XCTAssertEqual(tokenManager.accessToken, "test_access_token")
        XCTAssertEqual(tokenManager.refreshToken, "test_refresh_token")
        XCTAssertTrue(tokenManager.isTokenValid)
        
        // 清除token
        tokenManager.clearTokens()
        XCTAssertNil(tokenManager.accessToken)
        XCTAssertNil(tokenManager.refreshToken)
        XCTAssertFalse(tokenManager.isTokenValid)
    }
    
    // 测试缅甸手机号验证
    func testMyanmarPhoneValidation() {
        // 有效号码
        XCTAssertTrue("+959123456789".isValidMyanmarPhone)
        XCTAssertTrue("09123456789".isValidMyanmarPhone)
        XCTAssertTrue("9123456789".isValidMyanmarPhone)
        
        // 无效号码
        XCTAssertFalse("1234567890".isValidMyanmarPhone)
        XCTAssertFalse("+95123456789".isValidMyanmarPhone)
        XCTAssertFalse("".isValidMyanmarPhone)
        XCTAssertFalse("invalid".isValidMyanmarPhone)
    }
    
    // 测试价格格式化
    func testPriceFormatting() {
        let smallPrice: Double = 500
        XCTAssertEqual(smallPrice.formattedPrice, "500万")
        
        let mediumPrice: Double = 1500
        XCTAssertEqual(mediumPrice.formattedPrice, "1.5千万")
        
        let largePrice: Double = 25000
        XCTAssertEqual(largePrice.formattedPrice, "2.5亿")
    }
    
    // 测试日期格式化
    func testDateFormatting() {
        let now = Date()
        XCTAssertEqual(now.relativeTimeString, "刚刚")
        
        let oneMinuteAgo = Date().addingTimeInterval(-60)
        XCTAssertEqual(oneMinuteAgo.relativeTimeString, "1分钟前")
        
        let oneHourAgo = Date().addingTimeInterval(-3600)
        XCTAssertEqual(oneHourAgo.relativeTimeString, "1小时前")
        
        let yesterday = Date().addingTimeInterval(-86400)
        XCTAssertEqual(yesterday.relativeTimeString, "昨天")
    }
}

// MARK: - ViewModel测试
class HomeViewModelTests: XCTestCase {
    
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
    
    func testInitialState() {
        XCTAssertTrue(viewModel.banners.isEmpty)
        XCTAssertTrue(viewModel.quickEntries.isEmpty)
        XCTAssertTrue(viewModel.recommendedHouses.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testLoadingState() {
        // 模拟开始加载
        viewModel.isLoading = true
        XCTAssertTrue(viewModel.isLoading)
        
        // 模拟加载完成
        viewModel.isLoading = false
        XCTAssertFalse(viewModel.isLoading)
    }
}

class SearchViewModelTests: XCTestCase {
    
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
    
    func testSearchValidation() {
        // 空搜索
        viewModel.searchText = ""
        XCTAssertTrue(viewModel.houses.isEmpty)
        
        // 设置搜索词
        viewModel.searchText = "仰光"
        XCTAssertEqual(viewModel.searchText, "仰光")
    }
    
    func testSearchHistory() {
        // 初始应该没有历史记录
        XCTAssertTrue(viewModel.searchHistory.isEmpty)
        
        // 添加搜索历史
        viewModel.searchFromHistory("公寓")
        // 注意：实际测试需要等待异步操作完成
    }
    
    func testClearSearch() {
        viewModel.searchText = "test"
        viewModel.houses = [House.mock()]
        
        viewModel.clearSearch()
        
        XCTAssertTrue(viewModel.searchText.isEmpty)
        XCTAssertTrue(viewModel.houses.isEmpty)
        XCTAssertNil(viewModel.errorMessage)
    }
}

class HouseDetailViewModelTests: XCTestCase {
    
    var viewModel: HouseDetailViewModel!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        viewModel = HouseDetailViewModel(houseId: "test_id")
        cancellables = []
    }
    
    override func tearDown() {
        viewModel = nil
        cancellables = nil
        super.tearDown()
    }
    
    func testInitialState() {
        XCTAssertNil(viewModel.house)
        XCTAssertTrue(viewModel.similarHouses.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.isFavorite)
        XCTAssertFalse(viewModel.showContactSheet)
    }
    
    func testHouseId() {
        XCTAssertEqual(viewModel.houseId, "test_id")
    }
}

class HouseEntryViewModelTests: XCTestCase {
    
    var viewModel: HouseEntryViewModel!
    
    override func setUp() {
        super.setUp()
        viewModel = HouseEntryViewModel()
    }
    
    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }
    
    func testValidation() {
        // 初始状态应该无效
        XCTAssertFalse(viewModel.isValid)
        
        // 填写必填项
        viewModel.title = "测试房源"
        viewModel.price = "1000"
        viewModel.area = "100"
        viewModel.rooms = "3室2厅"
        viewModel.districtCode = "tamwe"
        viewModel.address = "Test Address"
        viewModel.contactName = "Test Name"
        viewModel.contactPhone = "+959123456789"
        
        // 仍然无效，因为没有图片
        XCTAssertFalse(viewModel.isValid)
    }
    
    func testImageManagement() {
        // 添加图片
        let testImage = UIImage()
        viewModel.addImage(testImage)
        XCTAssertEqual(viewModel.selectedImages.count, 1)
        
        // 删除图片
        viewModel.removeImage(at: 0)
        XCTAssertTrue(viewModel.selectedImages.isEmpty)
    }
}

class AgentAuthViewModelTests: XCTestCase {
    
    var viewModel: AgentAuthViewModel!
    
    override func setUp() {
        super.setUp()
        viewModel = AgentAuthViewModel()
    }
    
    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }
    
    func testInitialState() {
        XCTAssertTrue(viewModel.phone.isEmpty)
        XCTAssertTrue(viewModel.verifyCode.isEmpty)
        XCTAssertTrue(viewModel.name.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.isCodeSent)
        XCTAssertEqual(viewModel.countdown, 0)
        XCTAssertFalse(viewModel.isLoggedIn)
        XCTAssertFalse(viewModel.isRegisterMode)
    }
    
    func testSendCodeValidation() {
        // 空号码不能发送
        XCTAssertFalse(viewModel.canSendCode)
        
        // 有效号码可以发送
        viewModel.phone = "+959123456789"
        XCTAssertTrue(viewModel.canSendCode)
        
        // 倒计时期间不能发送
        viewModel.countdown = 30
        XCTAssertFalse(viewModel.canSendCode)
    }
    
    func testLoginValidation() {
        // 空信息不能登录
        XCTAssertFalse(viewModel.canLogin)
        
        // 只有手机号不能登录
        viewModel.phone = "+959123456789"
        XCTAssertFalse(viewModel.canLogin)
        
        // 手机号和验证码可以登录
        viewModel.verifyCode = "123456"
        XCTAssertTrue(viewModel.canLogin)
    }
    
    func testRegisterValidation() {
        // 需要姓名才能注册
        viewModel.phone = "+959123456789"
        viewModel.verifyCode = "123456"
        XCTAssertFalse(viewModel.canRegister)
        
        viewModel.name = "Test Agent"
        XCTAssertTrue(viewModel.canRegister)
    }
    
    func testModeToggle() {
        XCTAssertFalse(viewModel.isRegisterMode)
        
        viewModel.toggleMode()
        XCTAssertTrue(viewModel.isRegisterMode)
        
        viewModel.toggleMode()
        XCTAssertFalse(viewModel.isRegisterMode)
    }
}

// MARK: - Mock数据
extension House {
    static func mock() -> House {
        return House(
            id: "test_id",
            title: "测试房源",
            coverImage: "",
            price: 1000,
            priceUnit: "万缅币",
            area: 100,
            rooms: "3室2厅",
            location: "仰光 Tamwe",
            district: "Tamwe",
            community: "Test Community",
            tags: ["验真", "精装"],
            verificationStatus: .verified,
            publishTime: "2024-01-01",
            latitude: 16.8,
            longitude: 96.15,
            priceNote: nil,
            houseType: .apartment,
            transactionType: .sale,
            floor: "5/20",
            totalFloors: 20,
            decoration: .fine,
            orientation: .south,
            buildYear: 2020,
            address: "Test Address",
            nearby: nil,
            description: "Test description",
            highlights: nil,
            facilities: nil,
            propertyType: .grant,
            ownership: nil,
            hasLoan: nil,
            propertyCertificate: nil,
            verifiedAt: nil,
            verifiedBy: nil,
            reportUrl: nil,
            images: nil,
            video: nil,
            agent: nil
        )
    }
}

// MARK: - 性能测试
class PerformanceTests: XCTestCase {
    
    func testHouseListPerformance() {
        measure {
            // 模拟加载100个房源
            var houses: [House] = []
            for i in 0..<100 {
                let house = House.mock()
                houses.append(house)
            }
            XCTAssertEqual(houses.count, 100)
        }
    }
    
    func testPriceFormattingPerformance() {
        measure {
            for _ in 0..<1000 {
                let price: Double = Double.random(in: 100...50000)
                _ = price.formattedPrice
            }
        }
    }
}
