import SwiftUI

// MARK: - 加载指示器
public struct LoadingView: View {
    let message: String?
    
    public init(message: String? = nil) {
        self.message = message
    }
    
    public var body: some View {
        VStack(spacing: 12) {
            ProgressView()
                .scaleEffect(1.2)
            
            if let message = message {
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.theme.textSecondary)
            }
        }
        .padding(24)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 10)
    }
}

// MARK: - 空状态视图
public struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String?
    let actionTitle: String?
    let action: (() -> Void)?
    
    public init(
        icon: String = "doc.text.magnifyingglass",
        title: String,
        message: String? = nil,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }
    
    public var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(.theme.textPlaceholder)
            
            Text(title)
                .font(.headline)
                .foregroundColor(.theme.textPrimary)
            
            if let message = message {
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                        .background(Color.theme.primary)
                        .cornerRadius(20)
                }
                .padding(.top, 8)
            }
        }
        .padding()
    }
}

// MARK: - 错误视图
public struct ErrorView: View {
    let message: String
    let retryAction: (() -> Void)?
    
    public init(message: String, retryAction: (() -> Void)? = nil) {
        self.message = message
        self.retryAction = retryAction
    }
    
    public var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.theme.warning)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.theme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            if let retryAction = retryAction {
                Button(action: retryAction) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.clockwise")
                        Text("重试")
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.theme.primary)
                }
            }
        }
        .padding()
    }
}

// MARK: - 价格标签
public struct PriceTag: View {
    let price: Double
    let unit: String
    let size: PriceTagSize
    
    public enum PriceTagSize {
        case small
        case medium
        case large
        
        var font: Font {
            switch self {
            case .small: return .subheadline
            case .medium: return .headline
            case .large: return .title2
            }
        }
        
        var unitFont: Font {
            switch self {
            case .small: return .caption
            case .medium: return .subheadline
            case .large: return .subheadline
            }
        }
    }
    
    public init(price: Double, unit: String = "万缅币", size: PriceTagSize = .medium) {
        self.price = price
        self.unit = unit
        self.size = size
    }
    
    public var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 2) {
            Text(price.formattedPrice)
                .font(size.font)
                .fontWeight(.bold)
                .foregroundColor(.theme.accent)
            
            Text(unit)
                .font(size.unitFont)
                .foregroundColor(.theme.accent.opacity(0.8))
        }
    }
}

// MARK: - 房源标签
public struct HouseTag: View {
    let text: String
    let type: TagType
    
    public enum TagType {
        case verified     // 已验真
        case urgent       // 急售
        case new          // 新上
        case decoration   // 装修
        case feature      // 特色
        case plain        // 普通
        
        var backgroundColor: Color {
            switch self {
            case .verified: return Color.theme.success.opacity(0.1)
            case .urgent: return Color.theme.error.opacity(0.1)
            case .new: return Color.theme.primary.opacity(0.1)
            case .decoration: return Color.theme.accent.opacity(0.1)
            case .feature: return Color.theme.info.opacity(0.1)
            case .plain: return Color.gray.opacity(0.1)
            }
        }
        
        var textColor: Color {
            switch self {
            case .verified: return Color.theme.success
            case .urgent: return Color.theme.error
            case .new: return Color.theme.primary
            case .decoration: return Color.theme.accent
            case .feature: return Color.theme.info
            case .plain: return Color.gray
            }
        }
    }
    
    public init(text: String, type: TagType = .plain) {
        self.text = text
        self.type = type
    }
    
    public var body: some View {
        Text(text)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(type.textColor)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(type.backgroundColor)
            .cornerRadius(4)
    }
}

// MARK: - 搜索栏
public struct SearchBar: View {
    @Binding var text: String
    let placeholder: String
    let onSearch: (() -> Void)?
    let onClear: (() -> Void)?
    
    public init(
        text: Binding<String>,
        placeholder: String = "搜索房源...",
        onSearch: (() -> Void)? = nil,
        onClear: (() -> Void)? = nil
    ) {
        self._text = text
        self.placeholder = placeholder
        self.onSearch = onSearch
        self.onClear = onClear
    }
    
    public var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.theme.textPlaceholder)
            
            TextField(placeholder, text: $text)
                .font(.subheadline)
                .submitLabel(.search)
                .onSubmit {
                    onSearch?()
                }
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                    onClear?()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.theme.textPlaceholder)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

// MARK: - 自定义文本框
public struct CustomTextField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    let isSecure: Bool
    let keyboardType: UIKeyboardType
    let errorMessage: String?
    
    public init(
        title: String,
        placeholder: String,
        text: Binding<String>,
        isSecure: Bool = false,
        keyboardType: UIKeyboardType = .default,
        errorMessage: String? = nil
    ) {
        self.title = title
        self.placeholder = placeholder
        self._text = text
        self.isSecure = isSecure
        self.keyboardType = keyboardType
        self.errorMessage = errorMessage
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.theme.textPrimary)
            
            Group {
                if isSecure {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                        .keyboardType(keyboardType)
                }
            }
            .font(.body)
            .padding(12)
            .background(Color(.systemGray6))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(errorMessage != nil ? Color.theme.error : Color.clear, lineWidth: 1)
            )
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(.theme.error)
            }
        }
    }
}

// MARK: - 主按钮
public struct PrimaryButton: View {
    let title: String
    let isLoading: Bool
    let isDisabled: Bool
    let action: () -> Void
    
    public init(
        title: String,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.isLoading = isLoading
        self.isDisabled = isDisabled
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            HStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                }
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(isDisabled ? Color.theme.primary.opacity(0.5) : Color.theme.primary)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .disabled(isDisabled || isLoading)
    }
}

// MARK: - 次要按钮
public struct SecondaryButton: View {
    let title: String
    let action: () -> Void
    
    public init(title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.clear)
                .foregroundColor(.theme.primary)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.theme.primary, lineWidth: 1)
                )
        }
    }
}

// MARK: - 导航栏返回按钮
public struct BackButton: View {
    let action: () -> Void
    
    public init(action: @escaping () -> Void) {
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            Image(systemName: "chevron.left")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.theme.textPrimary)
        }
    }
}

// MARK: - 加载更多Footer
public struct LoadMoreFooter: View {
    let hasMore: Bool
    let isLoading: Bool
    let onLoadMore: () -> Void
    
    public init(hasMore: Bool, isLoading: Bool, onLoadMore: @escaping () -> Void) {
        self.hasMore = hasMore
        self.isLoading = isLoading
        self.onLoadMore = onLoadMore
    }
    
    public var body: some View {
        Group {
            if isLoading {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                .padding()
            } else if hasMore {
                Button(action: onLoadMore) {
                    Text("加载更多")
                        .font(.subheadline)
                        .foregroundColor(.theme.primary)
                        .padding()
                }
            } else {
                Text("没有更多数据了")
                    .font(.caption)
                    .foregroundColor(.theme.textPlaceholder)
                    .padding()
            }
        }
    }
}

// MARK: - 图片轮播器
public struct ImageCarousel: View {
    let images: [String]
    @State private var currentIndex = 0
    
    public init(images: [String]) {
        self.images = images
    }
    
    public var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $currentIndex) {
                ForEach(0..<images.count, id: \.self) { index in
                    AsyncImage(url: URL(string: images[index])) { phase in
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
                    .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
            // 页码指示器
            if images.count > 1 {
                HStack(spacing: 6) {
                    ForEach(0..<images.count, id: \.self) { index in
                        Circle()
                            .fill(currentIndex == index ? Color.white : Color.white.opacity(0.5))
                            .frame(width: 6, height: 6)
                    }
                }
                .padding(.bottom, 12)
            }
            
            // 图片数量标签
            if !images.isEmpty {
                Text("\(currentIndex + 1)/\(images.count)")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.black.opacity(0.5))
                    .cornerRadius(4)
                    .padding(.trailing, 12)
                    .padding(.bottom, 12)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
    }
}

// MARK: - 卡片容器
public struct CardContainer<Content: View>: View {
    let content: Content
    let padding: CGFloat
    let cornerRadius: CGFloat
    let showShadow: Bool
    
    public init(
        padding: CGFloat = 16,
        cornerRadius: CGFloat = 12,
        showShadow: Bool = true,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.padding = padding
        self.cornerRadius = cornerRadius
        self.showShadow = showShadow
    }
    
    public var body: some View {
        content
            .padding(padding)
            .background(Color.white)
            .cornerRadius(cornerRadius)
            .shadow(
                color: showShadow ? Color.black.opacity(0.05) : Color.clear,
                radius: showShadow ? 8 : 0,
                x: 0,
                y: showShadow ? 2 : 0
            )
    }
}

// MARK: - 列表分割线
public struct ListDivider: View {
    public init() {}
    
    public var body: some View {
        Rectangle()
            .fill(Color.theme.divider)
            .frame(height: 0.5)
    }
}

// MARK: - 异步图片加载视图
public struct AsyncImageView: View {
    let url: String
    let placeholder: Image
    
    public init(url: String, placeholder: Image = Image(systemName: "photo")) {
        self.url = url
        self.placeholder = placeholder
    }
    
    public var body: some View {
        AsyncImage(url: URL(string: url)) { phase in
            switch phase {
            case .empty:
                Rectangle()
                    .fill(Color.gray.opacity(0.1))
                    .overlay(ProgressView())
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
            case .failure:
                placeholder
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.gray)
                    .padding()
            @unknown default:
                EmptyView()
            }
        }
    }
}
