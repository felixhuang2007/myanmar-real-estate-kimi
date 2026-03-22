import SwiftUI

@main
struct MyanmarHomeBuyerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // 配置导航栏样式
        configureNavigationBar()
        
        // 配置TabBar样式
        configureTabBar()
        
        // 配置日志
        #if DEBUG
        print("App Started in DEBUG mode")
        #endif
        
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
struct ContentView: View {
    @State private var selectedTab = 0
    @State private var isLoggedIn = TokenManager.shared.isTokenValid
    
    var body: some View {
        Group {
            if isLoggedIn {
                MainTabView(selectedTab: $selectedTab)
            } else {
                LoginView(onLoginSuccess: {
                    isLoggedIn = true
                })
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .userDidLogout)) { _ in
            isLoggedIn = false
        }
    }
}

// MARK: - 主Tab视图
struct MainTabView: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationView {
                HomeView()
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text("首页")
            }
            .tag(0)
            
            NavigationView {
                SearchView()
            }
            .tabItem {
                Image(systemName: "magnifyingglass")
                Text("搜索")
            }
            .tag(1)
            
            NavigationView {
                FavoritesView()
            }
            .tabItem {
                Image(systemName: "heart.fill")
                Text("收藏")
            }
            .tag(2)
            
            NavigationView {
                ProfileView()
            }
            .tabItem {
                Image(systemName: "person.fill")
                Text("我的")
            }
            .tag(3)
        }
        .accentColor(.theme.primary)
    }
}

// MARK: - 登录视图
struct LoginView: View {
    let onLoginSuccess: () -> Void
    
    @StateObject private var viewModel = LoginViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Logo
                VStack(spacing: 12) {
                    Image(systemName: "house.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.theme.primary)
                    
                    Text("MyanmarHome")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.theme.primary)
                    
                    Text("缅甸房产首选平台")
                        .font(.subheadline)
                        .foregroundColor(.theme.textSecondary)
                }
                .padding(.top, 60)
                
                Spacer()
                
                // 登录表单
                VStack(spacing: 16) {
                    // 手机号输入
                    CustomTextField(
                        title: "手机号",
                        placeholder: "请输入缅甸手机号",
                        text: $viewModel.phone,
                        keyboardType: .phonePad,
                        errorMessage: viewModel.phoneError
                    )
                    
                    // 验证码输入
                    HStack(spacing: 12) {
                        CustomTextField(
                            title: "验证码",
                            placeholder: "请输入6位验证码",
                            text: $viewModel.verifyCode,
                            keyboardType: .numberPad,
                            errorMessage: viewModel.codeError
                        )
                        
                        Button(action: { viewModel.sendCode() }) {
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
                
                // 登录按钮
                PrimaryButton(
                    title: "登录",
                    isLoading: viewModel.isLoading,
                    isDisabled: !viewModel.canLogin
                ) {
                    viewModel.login { success in
                        if success {
                            onLoginSuccess()
                        }
                    }
                }
                .padding(.horizontal, 24)
                
                // 用户协议
                Text("登录即表示您同意《用户协议》和《隐私政策》")
                    .font(.caption)
                    .foregroundColor(.theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
            }
            .navigationBarHidden(true)
        }
    }
}

// MARK: - 收藏视图
struct FavoritesView: View {
    @StateObject private var viewModel = FavoritesViewModel()
    
    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.favorites.isEmpty {
                LoadingView(message: "加载中...")
            } else if let errorMessage = viewModel.errorMessage {
                ErrorView(message: errorMessage) {
                    viewModel.loadFavorites()
                }
            } else if viewModel.favorites.isEmpty {
                EmptyStateView(
                    icon: "heart.slash",
                    title: "暂无收藏",
                    message: "您还没有收藏任何房源，\n快去浏览心仪的房源吧！",
                    actionTitle: "去浏览",
                    action: {
                        // 切换到首页
                        NotificationCenter.default.post(name: .switchToHomeTab, object: nil)
                    }
                )
            } else {
                List {
                    ForEach(viewModel.favorites) { house in
                        NavigationLink(destination: HouseDetailView(houseId: house.id)) {
                            HouseCard(house: house)
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                viewModel.removeFavorite(house)
                            } label: {
                                Label("删除", systemImage: "trash")
                            }
                        }
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    }
                }
                .listStyle(PlainListStyle())
            }
        }
        .navigationTitle("我的收藏")
        .onAppear {
            viewModel.loadFavorites()
        }
    }
}

// MARK: - 个人中心视图
struct ProfileView: View {
    @State private var showLogoutAlert = false
    
    var body: some View {
        List {
            // 用户信息头部
            Section {
                ProfileHeaderView()
            }
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets())
            
            // 功能菜单
            Section("我的服务") {
                NavigationLink(destination: AppointmentListView()) {
                    ProfileMenuItem(
                        icon: "calendar",
                        iconColor: .theme.primary,
                        title: "我的预约"
                    )
                }
                
                NavigationLink(destination: Text("我的发布")) {
                    ProfileMenuItem(
                        icon: "doc.text",
                        iconColor: .theme.accent,
                        title: "我的发布"
                    )
                }
                
                NavigationLink(destination: Text("浏览历史")) {
                    ProfileMenuItem(
                        icon: "clock",
                        iconColor: .theme.info,
                        title: "浏览历史"
                    )
                }
            }
            
            Section("设置") {
                NavigationLink(destination: Text("账号安全")) {
                    ProfileMenuItem(
                        icon: "shield",
                        iconColor: .theme.success,
                        title: "账号安全"
                    )
                }
                
                NavigationLink(destination: Text("通知设置")) {
                    ProfileMenuItem(
                        icon: "bell",
                        iconColor: .theme.warning,
                        title: "通知设置"
                    )
                }
                
                NavigationLink(destination: Text("关于我们")) {
                    ProfileMenuItem(
                        icon: "info.circle",
                        iconColor: .theme.textSecondary,
                        title: "关于我们"
                    )
                }
            }
            
            Section {
                Button(action: { showLogoutAlert = true }) {
                    Text("退出登录")
                        .foregroundColor(.theme.error)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle("我的")
        .alert("确认退出", isPresented: $showLogoutAlert) {
            Button("取消", role: .cancel) { }
            Button("退出", role: .destructive) {
                UserService.shared.logout()
                NotificationCenter.default.post(name: .userDidLogout, object: nil)
            }
        } message: {
            Text("退出后将需要重新登录")
        }
    }
}

// MARK: - 用户头部视图
struct ProfileHeaderView: View {
    var body: some View {
        HStack(spacing: 16) {
            // 头像
            ZStack {
                Circle()
                    .fill(Color.theme.primary.opacity(0.1))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "person.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.theme.primary)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                if let user = UserService.shared.currentUser {
                    Text(user.nickname ?? user.phone.maskedPhone)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.theme.textPrimary)
                    
                    if user.verificationStatus == .verified {
                        Label("已实名认证", systemImage: "checkmark.shield.fill")
                            .font(.caption)
                            .foregroundColor(.theme.success)
                    } else {
                        Text("未实名认证")
                            .font(.caption)
                            .foregroundColor(.theme.textSecondary)
                    }
                } else {
                    Text("未登录")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.theme.textPrimary)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.theme.textPlaceholder)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
        .padding()
    }
}

// MARK: - 菜单项
struct ProfileMenuItem: View {
    let icon: String
    let iconColor: Color
    let title: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(iconColor)
                .frame(width: 32, height: 32)
            
            Text(title)
                .font(.body)
                .foregroundColor(.theme.textPrimary)
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

// MARK: - 预约列表视图
struct AppointmentListView: View {
    @StateObject private var viewModel = AppointmentViewModel()
    
    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.appointments.isEmpty {
                LoadingView(message: "加载中...")
            } else if let errorMessage = viewModel.errorMessage {
                ErrorView(message: errorMessage) {
                    viewModel.loadAppointments()
                }
            } else if viewModel.appointments.isEmpty {
                EmptyStateView(
                    icon: "calendar.badge.minus",
                    title: "暂无预约",
                    message: "您还没有预约任何带看"
                )
            } else {
                List {
                    ForEach(viewModel.appointments) { appointment in
                        AppointmentCard(appointment: appointment)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    }
                }
                .listStyle(PlainListStyle())
            }
        }
        .navigationTitle("我的预约")
        .onAppear {
            viewModel.loadAppointments()
        }
    }
}

// MARK: - 预约卡片
struct AppointmentCard: View {
    let appointment: Appointment
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // 房源图片
                AsyncImage(url: URL(string: appointment.houseImage ?? "")) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    default:
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                    }
                }
                .frame(width: 80, height: 60)
                .cornerRadius(8)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(appointment.houseTitle ?? "未知房源")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.theme.textPrimary)
                    
                    Text("经纪人: \(appointment.agentName ?? "未知")")
                        .font(.caption)
                        .foregroundColor(.theme.textSecondary)
                }
                
                Spacer()
                
                // 状态标签
                StatusTag(status: appointment.status)
            }
            
            Divider()
            
            HStack {
                Image(systemName: "calendar")
                    .font(.caption)
                    .foregroundColor(.theme.textSecondary)
                
                Text(appointment.appointmentTime)
                    .font(.caption)
                    .foregroundColor(.theme.textSecondary)
                
                Spacer()
            }
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(12)
        .cardShadow()
    }
}

// MARK: - 状态标签
struct StatusTag: View {
    let status: Appointment.AppointmentStatus
    
    var body: some View {
        Text(statusText)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(textColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(backgroundColor)
            .cornerRadius(4)
    }
    
    private var statusText: String {
        switch status {
        case .pending: return "待确认"
        case .confirmed: return "已确认"
        case .rejected: return "已拒绝"
        case .completed: return "已完成"
        case .cancelled: return "已取消"
        case .noShow: return "爽约"
        }
    }
    
    private var textColor: Color {
        switch status {
        case .pending: return .theme.warning
        case .confirmed: return .theme.success
        case .rejected, .cancelled, .noShow: return .theme.error
        case .completed: return .theme.primary
        }
    }
    
    private var backgroundColor: Color {
        textColor.opacity(0.1)
    }
}

// MARK: - 登录ViewModel
class LoginViewModel: ObservableObject {
    @Published var phone = ""
    @Published var verifyCode = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var countdown = 0
    
    var canSendCode: Bool {
        phone.isValidMyanmarPhone && countdown == 0
    }
    
    var canLogin: Bool {
        phone.isValidMyanmarPhone && verifyCode.count == 6
    }
    
    var phoneError: String? {
        if phone.isEmpty { return nil }
        return phone.isValidMyanmarPhone ? nil : "请输入有效的缅甸手机号"
    }
    
    var codeError: String? {
        if verifyCode.isEmpty { return nil }
        return verifyCode.count == 6 ? nil : "验证码为6位数字"
    }
    
    private var cancellables = Set<AnyCancellable>()
    private var timerCancellable: AnyCancellable?
    
    func sendCode() {
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
                self?.startCountdown()
            }
            .store(in: &cancellables)
    }
    
    func login(completion: @escaping (Bool) -> Void) {
        guard canLogin else { return }
        
        isLoading = true
        errorMessage = nil
        
        UserService.shared.login(phone: phone, code: verifyCode)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                self?.isLoading = false
                if case .failure(let error) = result {
                    self?.errorMessage = error.localizedDescription
                    completion(false)
                }
            } receiveValue: { _ in
                completion(true)
            }
            .store(in: &cancellables)
    }
    
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

// MARK: - 通知扩展
extension Notification.Name {
    static let userDidLogout = Notification.Name("userDidLogout")
    static let switchToHomeTab = Notification.Name("switchToHomeTab")
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
