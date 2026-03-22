import SwiftUI

// MARK: - 首页视图
public struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    
    public init() {}
    
    public var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                // Banner轮播
                BannerCarousel(banners: viewModel.banners)
                    .frame(height: 180)
                
                // 快捷入口
                QuickEntryGrid(entries: viewModel.quickEntries) { entry in
                    viewModel.handleQuickEntry(entry)
                }
                .padding(.vertical, 16)
                
                // 推荐房源标题
                HStack {
                    Text("为你推荐")
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    NavigationLink(destination: SearchView()) {
                        HStack(spacing: 4) {
                            Text("更多")
                                .font(.subheadline)
                            Image(systemName: "chevron.right")
                                .font(.caption)
                        }
                        .foregroundColor(.theme.primary)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
                
                // 房源列表
                if viewModel.isLoading && viewModel.recommendedHouses.isEmpty {
                    LoadingView(message: "加载中...")
                        .padding(.top, 40)
                } else if let errorMessage = viewModel.errorMessage {
                    ErrorView(message: errorMessage) {
                        viewModel.loadHomeData()
                    }
                    .padding(.top, 40)
                } else if viewModel.recommendedHouses.isEmpty {
                    EmptyStateView(
                        icon: "house",
                        title: "暂无推荐房源",
                        message: "去看看更多房源吧"
                    )
                    .padding(.top, 40)
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.recommendedHouses) { house in
                            NavigationLink(destination: HouseDetailView(houseId: house.id)) {
                                HouseCard(house: house)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        
                        // 加载更多
                        if viewModel.isLoading {
                            ProgressView()
                                .padding()
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
        }
        .refreshable {
            viewModel.refresh()
        }
        .onAppear {
            viewModel.loadHomeData()
        }
    }
}

// MARK: - Banner轮播
struct BannerCarousel: View {
    let banners: [Banner]
    @State private var currentIndex = 0
    
    var body: some View {
        TabView(selection: $currentIndex) {
            ForEach(0..<banners.count, id: \.self) { index in
                AsyncImage(url: URL(string: banners[index].image)) { phase in
                    switch phase {
                    case .empty:
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .overlay(
                                Image(systemName: "photo")
                                    .foregroundColor(.gray)
                            )
                    @unknown default:
                        EmptyView()
                    }
                }
                .tag(index)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
    }
}

// MARK: - 快捷入口网格
struct QuickEntryGrid: View {
    let entries: [HomeData.QuickEntry]
    let onTap: (HomeData.QuickEntry) -> Void
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(entries) { entry in
                Button(action: { onTap(entry) }) {
                    VStack(spacing: 8) {
                        Image(systemName: iconName(for: entry.type))
                            .font(.system(size: 28))
                            .foregroundColor(.theme.primary)
                            .frame(width: 56, height: 56)
                            .background(Color.theme.primary.opacity(0.1))
                            .cornerRadius(16)
                        
                        Text(entry.name)
                            .font(.caption)
                            .foregroundColor(.theme.textPrimary)
                    }
                }
            }
        }
        .padding(.horizontal, 16)
    }
    
    private func iconName(for type: HomeData.QuickEntry.EntryType) -> String {
        switch type {
        case .buy:
            return "house.fill"
        case .rent:
            return "key.fill"
        case .publish:
            return "plus.circle.fill"
        case .map:
            return "map.fill"
        }
    }
}

// MARK: - 房源卡片
public struct HouseCard: View {
    let house: House
    
    public init(house: House) {
        self.house = house
    }
    
    public var body: some View {
        HStack(spacing: 12) {
            // 房源图片
            AsyncImage(url: URL(string: house.coverImage)) { phase in
                switch phase {
                case .empty:
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .overlay(ProgressView())
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure:
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.gray)
                        )
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 120, height: 90)
            .cornerRadius(8)
            .clipped()
            
            // 房源信息
            VStack(alignment: .leading, spacing: 6) {
                Text(house.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.theme.textPrimary)
                    .lineLimit(2)
                
                HStack(spacing: 4) {
                    Text(house.rooms)
                        .font(.caption)
                        .foregroundColor(.theme.textSecondary)
                    
                    Text("|")
                        .font(.caption)
                        .foregroundColor(.theme.divider)
                    
                    Text(house.area.formattedArea)
                        .font(.caption)
                        .foregroundColor(.theme.textSecondary)
                    
                    if let floor = house.floor {
                        Text("|")
                            .font(.caption)
                            .foregroundColor(.theme.divider)
                        
                        Text(floor)
                            .font(.caption)
                            .foregroundColor(.theme.textSecondary)
                    }
                }
                
                Text(house.location)
                    .font(.caption)
                    .foregroundColor(.theme.textSecondary)
                    .lineLimit(1)
                
                HStack {
                    PriceTag(price: house.price, unit: house.priceUnit, size: .small)
                    
                    Spacer()
                    
                    // 验真标签
                    if house.verificationStatus == .verified {
                        HouseTag(text: "已验真", type: .verified)
                    }
                }
            }
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(12)
        .cardShadow()
    }
}

// MARK: - 搜索视图
public struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            // 搜索栏
            SearchBar(
                text: $viewModel.searchText,
                placeholder: "搜索小区、商圈或地址...",
                onSearch: { viewModel.search() },
                onClear: { viewModel.clearSearch() }
            )
            .padding()
            
            // 搜索结果或历史记录
            if viewModel.houses.isEmpty && viewModel.searchText.isEmpty {
                // 显示历史记录和热门搜索
                SearchHistoryView(
                    history: viewModel.searchHistory,
                    hotSearches: viewModel.hotSearches,
                    onSelectHistory: { keyword in
                        viewModel.searchFromHistory(keyword)
                    },
                    onClearHistory: {
                        viewModel.clearHistory()
                    }
                )
            } else {
                // 搜索结果列表
                List {
                    ForEach(viewModel.houses) { house in
                        NavigationLink(destination: HouseDetailView(houseId: house.id)) {
                            HouseCard(house: house)
                        }
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    }
                    
                    // 加载更多
                    if viewModel.isLoading {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                        .listRowSeparator(.hidden)
                    }
                }
                .listStyle(PlainListStyle())
            }
        }
        .navigationTitle("搜索房源")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.loadHotSearches()
        }
    }
}

// MARK: - 搜索历史视图
struct SearchHistoryView: View {
    let history: [String]
    let hotSearches: [String]
    let onSelectHistory: (String) -> Void
    let onClearHistory: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // 搜索历史
                if !history.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("搜索历史")
                                .font(.headline)
                                .foregroundColor(.theme.textPrimary)
                            
                            Spacer()
                            
                            Button(action: onClearHistory) {
                                Image(systemName: "trash")
                                    .font(.caption)
                                    .foregroundColor(.theme.textSecondary)
                            }
                        }
                        
                        FlowLayout(spacing: 8) {
                            ForEach(history, id: \.self) { keyword in
                                Button(action: { onSelectHistory(keyword) }) {
                                    Text(keyword)
                                        .font(.subheadline)
                                        .foregroundColor(.theme.textSecondary)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color(.systemGray6))
                                        .cornerRadius(16)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // 热门搜索
                VStack(alignment: .leading, spacing: 12) {
                    Text("热门搜索")
                        .font(.headline)
                        .foregroundColor(.theme.textPrimary)
                    
                    FlowLayout(spacing: 8) {
                        ForEach(hotSearches, id: \.self) { keyword in
                            Button(action: { onSelectHistory(keyword) }) {
                                Text(keyword)
                                    .font(.subheadline)
                                    .foregroundColor(.theme.textSecondary)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.theme.accent.opacity(0.1))
                                    .cornerRadius(16)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding(.vertical)
        }
    }
}

// MARK: - 流式布局
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x,
                                      y: bounds.minY + result.positions[index].y),
                         proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var rowHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if x + size.width > maxWidth && x > 0 {
                    x = 0
                    y += rowHeight + spacing
                    rowHeight = 0
                }
                
                positions.append(CGPoint(x: x, y: y))
                rowHeight = max(rowHeight, size.height)
                x += size.width + spacing
            }
            
            self.size = CGSize(width: maxWidth, height: y + rowHeight)
        }
    }
}

// MARK: - 房源详情视图
public struct HouseDetailView: View {
    let houseId: String
    @StateObject private var viewModel: HouseDetailViewModel
    
    public init(houseId: String) {
        self.houseId = houseId
        self._viewModel = StateObject(wrappedValue: HouseDetailViewModel(houseId: houseId))
    }
    
    public var body: some View {
        ScrollView {
            if let house = viewModel.house {
                VStack(spacing: 0) {
                    // 图片轮播
                    if let images = house.images, !images.isEmpty {
                        ImageCarousel(images: images)
                            .frame(height: 280)
                    } else {
                        AsyncImage(url: URL(string: house.coverImage)) { phase in
                            switch phase {
                            case .empty:
                                Rectangle()
                                    .fill(Color.gray.opacity(0.2))
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                            case .failure:
                                Rectangle()
                                    .fill(Color.gray.opacity(0.2))
                            @unknown default:
                                EmptyView()
                            }
                        }
                        .frame(height: 280)
                    }
                    
                    // 房源信息
                    VStack(alignment: .leading, spacing: 16) {
                        // 标题和价格
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(house.title)
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.theme.textPrimary)
                                
                                Spacer()
                                
                                // 收藏按钮
                                Button(action: { viewModel.toggleFavorite() }) {
                                    Image(systemName: viewModel.isFavorite ? "heart.fill" : "heart")
                                        .font(.title3)
                                        .foregroundColor(viewModel.isFavorite ? .red : .gray)
                                }
                            }
                            
                            PriceTag(price: house.price, unit: house.priceUnit, size: .large)
                        }
                        
                        // 标签
                        HStack(spacing: 8) {
                            if house.verificationStatus == .verified {
                                HouseTag(text: "已验真", type: .verified)
                            }
                            if let type = house.houseType {
                                HouseTag(text: type.rawValue, type: .plain)
                            }
                            if let decoration = house.decoration {
                                HouseTag(text: decoration.rawValue, type: .decoration)
                            }
                        }
                        
                        ListDivider()
                        
                        // 基础信息
                        VStack(alignment: .leading, spacing: 12) {
                            Text("房源信息")
                                .font(.headline)
                                .foregroundColor(.theme.textPrimary)
                            
                            InfoRow(title: "户型", value: house.rooms)
                            InfoRow(title: "面积", value: house.area.formattedArea)
                            if let floor = house.floor {
                                InfoRow(title: "楼层", value: floor)
                            }
                            if let orientation = house.orientation {
                                InfoRow(title: "朝向", value: orientation.rawValue)
                            }
                            if let buildYear = house.buildYear {
                                InfoRow(title: "建造年份", value: "\(buildYear)年")
                            }
                        }
                        
                        ListDivider()
                        
                        // 位置信息
                        VStack(alignment: .leading, spacing: 12) {
                            Text("位置信息")
                                .font(.headline)
                                .foregroundColor(.theme.textPrimary)
                            
                            InfoRow(title: "地址", value: house.location)
                        }
                        
                        // 经纪人信息
                        if let agent = house.agent {
                            ListDivider()
                            
                            HStack(spacing: 12) {
                                AsyncImage(url: URL(string: agent.avatar ?? "")) { phase in
                                    switch phase {
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFill()
                                    default:
                                        Circle()
                                            .fill(Color.gray.opacity(0.2))
                                    }
                                }
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(agent.name)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    
                                    if let company = agent.company {
                                        Text(company)
                                            .font(.caption)
                                            .foregroundColor(.theme.textSecondary)
                                    }
                                }
                                
                                Spacer()
                                
                                Button(action: { viewModel.contactAgent() }) {
                                    Text("咨询")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(Color.theme.primary)
                                        .cornerRadius(20)
                                }
                            }
                        }
                    }
                    .padding()
                }
            } else if viewModel.isLoading {
                LoadingView(message: "加载中...")
                    .padding(.top, 100)
            } else if let errorMessage = viewModel.errorMessage {
                ErrorView(message: errorMessage) {
                    viewModel.loadDetail()
                }
                .padding(.top, 100)
            }
        }
        .navigationTitle("房源详情")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { viewModel.shareHouse() }) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
        .onAppear {
            viewModel.loadDetail()
        }
    }
}

// MARK: - 信息行
struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.theme.textSecondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .foregroundColor(.theme.textPrimary)
        }
    }
}
