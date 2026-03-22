import SwiftUI

@main
struct MyanmarHomeAgentApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            AgentContentView()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // 配置导航栏样式
        configureNavigationBar()
        
        // 配置TabBar样式
        configureTabBar()
        
        return true
    }
    
    private func configureNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground
        appearance.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 17, weight: .semibold),
            .foregroundColor: UIColor.label
        ]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    
    private func configureTabBar() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground
        
        UITabBar.appearance().standardAppearance = appearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}

// MARK: - 主内容视图
struct AgentContentView: View {
    @State private var isLoggedIn = TokenManager.shared.isTokenValid
    
    var body: some View {
        Group {
            if isLoggedIn {
                AgentMainTabView()
            } else {
                AgentLoginView(onLoginSuccess: {
                    isLoggedIn = true
                })
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .agentDidLogout)) { _ in
            isLoggedIn = false
        }
    }
}

// MARK: - 经纪人主Tab视图
struct AgentMainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // 首页/工作台
            NavigationView {
                AgentWorkbenchView()
            }
            .tabItem {
                Image(systemName: "briefcase.fill")
                Text("工作台")
            }
            .tag(0)
            
            // 房源管理
            NavigationView {
                HouseManagementView()
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text("房源")
            }
            .tag(1)
            
            // 客户管理
            NavigationView {
                CustomerListView()
            }
            .tabItem {
                Image(systemName: "person.2.fill")
                Text("客户")
            }
            .tag(2)
            
            // 消息
            NavigationView {
                AgentMessageView()
            }
            .tabItem {
                Image(systemName: "message.fill")
                Text("消息")
            }
            .tag(3)
            
            // 我的
            NavigationView {
                AgentProfileView()
            }
            .tabItem {
                Image(systemName: "person.fill")
                Text("我的")
            }
            .tag(4)
        }
        .accentColor(.theme.primary)
    }
}

// MARK: - 工作台视图
struct AgentWorkbenchView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // 今日数据概览
                TodayStatsView()
                
                // 功能快捷入口
                WorkbenchMenuView()
                
                // 今日带看
                TodayToursView()
            }
            .padding()
        }
        .navigationTitle("工作台")
    }
}

// MARK: - 今日数据概览
struct TodayStatsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("今日数据")
                .font(.headline)
                .foregroundColor(.theme.textPrimary)
            
            HStack(spacing: 0) {
                StatItem(title: "新增客户", value: "5", color: .theme.primary)
                Divider()
                StatItem(title: "带看次数", value: "3", color: .theme.accent)
                Divider()
                StatItem(title: "新增房源", value: "2", color: .theme.success)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .cardShadow()
    }
}

struct StatItem: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.theme.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - 工作台菜单
struct WorkbenchMenuView: View {
    let menuItems: [(icon: String, title: String, color: Color, destination: AnyView)] = [
        ("plus.circle.fill", "录房源", .theme.primary, AnyView(HouseEntryView())),
        ("checkmark.shield.fill", "验真任务", .theme.success, AnyView(VerificationTaskListView())),
        ("person.badge.plus", "新增客户", .theme.accent, AnyView(Text("新增客户"))),
        ("calendar.badge.checkmark", "带看日程", .theme.info, AnyView(TourScheduleView())),
        ("dollarsign.circle.fill", "业绩统计", .theme.warning, AnyView(PerformanceStatsView())),
        ("network", "ACN协作", .theme.primary, AnyView(ACNTransactionListView())),
    ]
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("常用功能")
                .font(.headline)
                .foregroundColor(.theme.textPrimary)
            
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(menuItems, id: \.title) { item in
                    NavigationLink(destination: item.destination) {
                        VStack(spacing: 8) {
                            Image(systemName: item.icon)
                                .font(.system(size: 28))
                                .foregroundColor(item.color)
                            
                            Text(item.title)
                                .font(.caption)
                                .foregroundColor(.theme.textPrimary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.white)
                        .cornerRadius(12)
                        .cardShadow()
                    }
                }
            }
        }
    }
}

// MARK: - 今日带看
struct TodayToursView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("今日带看")
                    .font(.headline)
                    .foregroundColor(.theme.textPrimary)
                
                Spacer()
                
                NavigationLink(destination: TourScheduleView()) {
                    Text("查看全部")
                        .font(.caption)
                        .foregroundColor(.theme.primary)
                }
            }
            
            // 示例带看列表
            ForEach(0..<3) { index in
                TourItemRow(
                    time: "10:00",
                    customerName: "客户\(index + 1)",
                    houseTitle: "仰光公寓 \(index + 1)号",
                    status: index == 0 ? "待确认" : "已确认"
                )
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .cardShadow()
    }
}

struct TourItemRow: View {
    let time: String
    let customerName: String
    let houseTitle: String
    let status: String
    
    var body: some View {
        HStack(spacing: 12) {
            Text(time)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.theme.primary)
                .frame(width: 50, alignment: .leading)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(customerName)
                    .font(.subheadline)
                    .foregroundColor(.theme.textPrimary)
                
                Text(houseTitle)
                    .font(.caption)
                    .foregroundColor(.theme.textSecondary)
            }
            
            Spacer()
            
            Text(status)
                .font(.caption)
                .foregroundColor(status == "已确认" ? .theme.success : .theme.warning)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background((status == "已确认" ? Color.theme.success : Color.theme.warning).opacity(0.1))
                .cornerRadius(4)
        }
        .padding(.vertical, 8)
    }
}

// MARK: - 房源录入视图
struct HouseEntryView: View {
    @StateObject private var viewModel = HouseEntryViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 图片上传区域
                ImageUploadSection(viewModel: viewModel)
                
                // 基本信息
                BasicInfoSection(viewModel: viewModel)
                
                // 房源信息
                HouseInfoSection(viewModel: viewModel)
                
                // 联系信息
                ContactInfoSection(viewModel: viewModel)
                
                // 提交按钮
                PrimaryButton(
                    title: "提交审核",
                    isLoading: viewModel.isLoading,
                    isDisabled: !viewModel.isValid
                ) {
                    viewModel.submit()
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationTitle("录入房源")
        .alert("提交成功", isPresented: $viewModel.isSuccess) {
            Button("确定") {
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text("房源已提交审核，审核通过后将上架展示")
        }
    }
}

// MARK: - 图片上传区域
struct ImageUploadSection: View {
    @ObservedObject var viewModel: HouseEntryViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("房源图片")
                    .font(.headline)
                    .foregroundColor(.theme.textPrimary)
                
                Text("(至少5张)")
                    .font(.caption)
                    .foregroundColor(.theme.textSecondary)
                
                Spacer()
                
                Text("\(viewModel.selectedImages.count)/20")
                    .font(.caption)
                    .foregroundColor(.theme.textSecondary)
            }
            
            // 图片网格
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 8) {
                // 添加按钮
                Button(action: { viewModel.showImagePicker = true }) {
                    VStack {
                        Image(systemName: "plus")
                            .font(.title2)
                            .foregroundColor(.theme.textPlaceholder)
                        Text("添加")
                            .font(.caption)
                            .foregroundColor(.theme.textPlaceholder)
                    }
                    .frame(width: 80, height: 80)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
                
                // 已选图片
                ForEach(0..<viewModel.selectedImages.count, id: \.self) { index in
                    ZStack(alignment: .topTrailing) {
                        Image(uiImage: viewModel.selectedImages[index])
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 80)
                            .cornerRadius(8)
                        
                        Button(action: { viewModel.removeImage(at: index) }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.white)
                                .background(Color.black.opacity(0.5))
                                .clipShape(Circle())
                        }
                        .offset(x: 4, y: -4)
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

// MARK: - 基本信息区域
struct BasicInfoSection: View {
    @ObservedObject var viewModel: HouseEntryViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("基本信息")
                .font(.headline)
                .foregroundColor(.theme.textPrimary)
            
            CustomTextField(
                title: "房源标题",
                placeholder: "请输入房源标题（建议30字以内）",
                text: $viewModel.title
            )
            
            HStack(spacing: 12) {
                Picker("交易类型", selection: $viewModel.transactionType) {
                    Text("出售").tag(House.TransactionType.sale)
                    Text("出租").tag(House.TransactionType.rent)
                }
                .pickerStyle(SegmentedPickerStyle())
                
                Picker("房源类型", selection: $viewModel.houseType) {
                    Text("公寓").tag(House.HouseType.apartment)
                    Text("别墅").tag(House.HouseType.house)
                    Text("排屋").tag(House.HouseType.townhouse)
                    Text("土地").tag(House.HouseType.land)
                }
                .pickerStyle(MenuPickerStyle())
            }
            
            HStack(spacing: 12) {
                CustomTextField(
                    title: "价格",
                    placeholder: "请输入价格",
                    text: $viewModel.price,
                    keyboardType: .decimalPad
                )
                
                CustomTextField(
                    title: "面积",
                    placeholder: "㎡",
                    text: $viewModel.area,
                    keyboardType: .decimalPad
                )
            }
            
            CustomTextField(
                title: "户型",
                placeholder: "如：3室2厅2卫",
                text: $viewModel.rooms
            )
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

// MARK: - 房源信息区域
struct HouseInfoSection: View {
    @ObservedObject var viewModel: HouseEntryViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("详细信息")
                .font(.headline)
                .foregroundColor(.theme.textPrimary)
            
            CustomTextField(
                title: "区域",
                placeholder: "请选择区域",
                text: $viewModel.districtCode
            )
            
            CustomTextField(
                title: "详细地址",
                placeholder: "请输入详细地址",
                text: $viewModel.address
            )
            
            HStack(spacing: 12) {
                CustomTextField(
                    title: "楼层",
                    placeholder: "如：5/20",
                    text: $viewModel.floor
                )
                
                CustomTextField(
                    title: "总楼层",
                    placeholder: "如：20",
                    text: $viewModel.totalFloors,
                    keyboardType: .numberPad
                )
            }
            
            CustomTextField(
                title: "建造年份",
                placeholder: "如：2020",
                text: $viewModel.buildYear,
                keyboardType: .numberPad
            )
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

// MARK: - 联系信息区域
struct ContactInfoSection: View {
    @ObservedObject var viewModel: HouseEntryViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("联系信息")
                .font(.headline)
                .foregroundColor(.theme.textPrimary)
            
            CustomTextField(
                title: "联系人姓名",
                placeholder: "请输入联系人姓名",
                text: $viewModel.contactName
            )
            
            CustomTextField(
                title: "联系人电话",
                placeholder: "请输入联系人电话",
                text: $viewModel.contactPhone,
                keyboardType: .phonePad
            )
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

// MARK: - 验真任务列表
struct VerificationTaskListView: View {
    @StateObject private var viewModel = VerificationViewModel()
    
    var body: some View {
        List {
            ForEach(viewModel.tasks) { task in
                VerificationTaskCard(task: task)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            }
        }
        .listStyle(PlainListStyle())
        .navigationTitle("验真任务")
        .onAppear {
            viewModel.loadTasks()
        }
    }
}

struct VerificationTaskCard: View {
    let task: VerificationTask
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(task.houseTitle ?? "未知房源")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.theme.textPrimary)
                
                Spacer()
                
                StatusBadge(status: task.status)
            }
            
            Text(task.address ?? "")
                .font(.caption)
                .foregroundColor(.theme.textSecondary)
            
            if let deadline = task.deadline {
                HStack {
                    Image(systemName: "clock")
                        .font(.caption2)
                        .foregroundColor(.theme.warning)
                    
                    Text("截止: \(deadline)")
                        .font(.caption)
                        .foregroundColor(.theme.warning)
                }
            }
            
            if task.status == .pending {
                Button(action: {
                    // 领取任务
                }) {
                    Text("领取任务")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.theme.primary)
                        .cornerRadius(8)
                }
            }
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(12)
        .cardShadow()
    }
}

struct StatusBadge: View {
    let status: VerificationTask.TaskStatus
    
    var body: some View {
        Text(statusText)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.1))
            .cornerRadius(4)
    }
    
    private var statusText: String {
        switch status {
        case .pending: return "待领取"
        case .assigned: return "已领取"
        case .inProgress: return "进行中"
        case .completed: return "已完成"
        case .failed: return "失败"
        }
    }
    
    private var color: Color {
        switch status {
        case .pending: return .theme.textSecondary
        case .assigned: return .theme.primary
        case .inProgress: return .theme.accent
        case .completed: return .theme.success
        case .failed: return .theme.error
        }
    }
}

// MARK: - 其他视图占位符
struct HouseManagementView: View {
    var body: some View {
        Text("房源管理")
            .navigationTitle("我的房源")
    }
}

struct CustomerListView: View {
    var body: some View {
        Text("客户列表")
            .navigationTitle("客户管理")
    }
}

struct AgentMessageView: View {
    var body: some View {
        Text("消息中心")
            .navigationTitle("消息")
    }
}

struct TourScheduleView: View {
    var body: some View {
        Text("带看日程")
            .navigationTitle("带看管理")
    }
}

struct PerformanceStatsView: View {
    var body: some View {
        Text("业绩统计")
            .navigationTitle("业绩")
    }
}

struct ACNTransactionListView: View {
    var body: some View {
        Text("ACN交易")
            .navigationTitle("ACN协作")
    }
}

struct AgentProfileView: View {
    var body: some View {
        List {
            Section {
                Button(action: {
                    AgentService.shared.logout()
                    NotificationCenter.default.post(name: .agentDidLogout, object: nil)
                }) {
                    Text("退出登录")
                        .foregroundColor(.theme.error)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
        .navigationTitle("我的")
    }
}

// MARK: - 登录视图
struct AgentLoginView: View {
    let onLoginSuccess: () -> Void
    @StateObject private var viewModel = AgentAuthViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Logo
                VStack(spacing: 12) {
                    Image(systemName: "briefcase.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.theme.primary)
                    
                    Text("MyanmarHome Agent")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.theme.primary)
                    
                    Text("经纪人工作台")
                        .font(.subheadline)
                        .foregroundColor(.theme.textSecondary)
                }
                .padding(.top, 60)
                
                Spacer()
                
                // 登录表单
                VStack(spacing: 16) {
                    if viewModel.isRegisterMode {
                        CustomTextField(
                            title: "姓名",
                            placeholder: "请输入您的姓名",
                            text: $viewModel.name
                        )
                        
                        CustomTextField(
                            title: "公司（选填）",
                            placeholder: "请输入所属公司",
                            text: $viewModel.company
                        )
                    }
                    
                    CustomTextField(
                        title: "手机号",
                        placeholder: "请输入缅甸手机号",
                        text: $viewModel.phone,
                        keyboardType: .phonePad
                    )
                    
                    HStack(spacing: 12) {
                        CustomTextField(
                            title: "验证码",
                            placeholder: "请输入6位验证码",
                            text: $viewModel.verifyCode,
                            keyboardType: .numberPad
                        )
                        
                        Button(action: { viewModel.sendVerifyCode() }) {
                            Text(viewModel.countdown > 0 ? "\(viewModel.countdown)s" : "获取验证码")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(viewModel.canSendCode ? .theme.primary : .theme.textPlaceholder)
                                .frame(width: 100)
                                .padding(.vertical, 12)
                                .background(Color.theme.primary.opacity(0.1))
                                .cornerRadius(8)
                        }
                        .disabled(!viewModel.canSendCode)
                    }
                }
                .padding(.horizontal, 24)
                
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.theme.error)
                        .padding(.horizontal, 24)
                }
                
                Spacer()
                
                // 登录/注册按钮
                if viewModel.isRegisterMode {
                    PrimaryButton(
                        title: "注册",
                        isLoading: viewModel.isLoading,
                        isDisabled: !viewModel.canRegister
                    ) {
                        viewModel.register()
                    }
                    .padding(.horizontal, 24)
                } else {
                    PrimaryButton(
                        title: "登录",
                        isLoading: viewModel.isLoading,
                        isDisabled: !viewModel.canLogin
                    ) {
                        viewModel.login()
                    }
                    .padding(.horizontal, 24)
                }
                
                // 切换模式
                Button(action: { viewModel.toggleMode() }) {
                    Text(viewModel.isRegisterMode ? "已有账号？去登录" : "没有账号？去注册")
                        .font(.subheadline)
                        .foregroundColor(.theme.primary)
                }
                .padding(.bottom, 40)
            }
            .navigationBarHidden(true)
            .onChange(of: viewModel.isLoggedIn) { isLoggedIn in
                if isLoggedIn {
                    onLoginSuccess()
                }
            }
        }
    }
}

// MARK: - 通知扩展
extension Notification.Name {
    static let agentDidLogout = Notification.Name("agentDidLogout")
}

// MARK: - Preview
struct AgentContentView_Previews: PreviewProvider {
    static var previews: some View {
        AgentContentView()
    }
}
