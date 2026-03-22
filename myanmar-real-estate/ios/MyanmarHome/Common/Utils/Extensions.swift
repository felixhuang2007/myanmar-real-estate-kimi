import Foundation
import UIKit
import SwiftUI

// MARK: - 字符串扩展
public extension String {
    /// 验证缅甸手机号格式
    var isValidMyanmarPhone: Bool {
        // 缅甸手机号格式: +95 9xxx xxx xxx 或 09xxx xxx xxx
        let pattern = "^(\\+95|0)?9\\d{7,9}$"
        return NSPredicate(format: "SELF MATCHES %@", pattern).evaluate(with: self)
    }
    
    /// 格式化手机号显示
    var formattedPhone: String {
        let digits = self.filter { $0.isNumber }
        if digits.hasPrefix("959") && digits.count >= 10 {
            let start = digits.index(digits.startIndex, offsetBy: 3)
            return "+95 \(digits[start...])"
        }
        return self
    }
    
    /// 脱敏手机号显示
    var maskedPhone: String {
        guard self.count >= 7 else { return self }
        let prefix = self.prefix(3)
        let suffix = self.suffix(4)
        return "\(prefix)****\(suffix)"
    }
    
    /// 验证密码强度（最少6位）
    var isValidPassword: Bool {
        return self.count >= 6
    }
    
    /// 格式化价格显示（缅币）
    var formattedPrice: String {
        guard let price = Double(self) else { return self }
        return price.formattedPrice
    }
    
    /// 计算字符串高度
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(
            with: constraintRect,
            options: .usesLineFragmentOrigin,
            attributes: [.font: font],
            context: nil
        )
        return ceil(boundingBox.height)
    }
}

// MARK: - Double扩展
public extension Double {
    /// 格式化价格显示（缅币）
    var formattedPrice: String {
        if self >= 10000 {
            // 1亿以上显示为"X亿"
            return String(format: "%.1f亿", self / 10000)
        } else if self >= 1000 {
            // 1000万以上显示为"X千万"
            return String(format: "%.1f千万", self / 1000)
        } else {
            return String(format: "%.0f万", self)
        }
    }
    
    /// 格式化面积显示
    var formattedArea: String {
        return String(format: "%.0f㎡", self)
    }
    
    /// 格式化数字（带千分位）
    var formattedNumber: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        return formatter.string(from: NSNumber(value: self)) ?? String(self)
    }
}

// MARK: - Date扩展
public extension Date {
    /// 格式化为相对时间（如"3小时前"）
    var relativeTimeString: String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: self,
            to: now
        )
        
        if let year = components.year, year > 0 {
            return "\(year)年前"
        } else if let month = components.month, month > 0 {
            return "\(month)个月前"
        } else if let day = components.day, day > 0 {
            if day == 1 {
                return "昨天"
            } else if day < 7 {
                return "\(day)天前"
            } else {
                return "\(day / 7)周前"
            }
        } else if let hour = components.hour, hour > 0 {
            return "\(hour)小时前"
        } else if let minute = components.minute, minute > 0 {
            return "\(minute)分钟前"
        } else {
            return "刚刚"
        }
    }
    
    /// 格式化为日期字符串
    func formattedString(format: String = "yyyy-MM-dd") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
    /// 格式化为时间字符串
    func formattedTimeString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: self)
    }
    
    /// 是否是今天
    var isToday: Bool {
        return Calendar.current.isDateInToday(self)
    }
    
    /// 是否是昨天
    var isYesterday: Bool {
        return Calendar.current.isDateInYesterday(self)
    }
}

// MARK: - String to Date
public extension String {
    /// 转换为日期
    func toDate(format: String = "yyyy-MM-dd HH:mm:ss") -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.date(from: self)
    }
    
    /// 转换为相对时间字符串
    var toRelativeTime: String {
        guard let date = toDate() else { return self }
        return date.relativeTimeString
    }
}

// MARK: - Color扩展
public extension Color {
    /// 主题色
    static let theme = ColorTheme()
    
    /// 初始化十六进制颜色
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - 主题色
public struct ColorTheme {
    /// 主品牌色
    public let primary = Color(hex: "#2196F3")
    /// 主品牌色（深色）
    public let primaryDark = Color(hex: "#1976D2")
    /// 主品牌色（浅色）
    public let primaryLight = Color(hex: "#BBDEFB")
    
    /// 强调色
    public let accent = Color(hex: "#FF9800")
    /// 强调色（深色）
    public let accentDark = Color(hex: "#F57C00")
    
    /// 成功色
    public let success = Color(hex: "#4CAF50")
    /// 警告色
    public let warning = Color(hex: "#FFC107")
    /// 错误色
    public let error = Color(hex: "#F44336")
    /// 信息色
    public let info = Color(hex: "#2196F3")
    
    /// 背景色
    public let background = Color(hex: "#F5F5F5")
    /// 卡片背景色
    public let cardBackground = Color.white
    /// 分割线颜色
    public let divider = Color(hex: "#E0E0E0")
    
    /// 主要文字颜色
    public let textPrimary = Color(hex: "#212121")
    /// 次要文字颜色
    public let textSecondary = Color(hex: "#757575")
    /// 占位文字颜色
    public let textPlaceholder = Color(hex: "#BDBDBD")
}

// MARK: - View扩展
public extension View {
    /// 添加圆角
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
    
    /// 隐藏键盘
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    /// 添加阴影
    func cardShadow() -> some View {
        self.shadow(
            color: Color.black.opacity(0.08),
            radius: 8,
            x: 0,
            y: 2
        )
    }
}

// MARK: - 圆角形状
public struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    public func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - 加载状态
public enum LoadingState<T> {
    case idle
    case loading
    case success(T)
    case failure(Error)
}

// MARK: - 日志工具
public struct Logger {
    public static func debug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        #if DEBUG
        let fileName = (file as NSString).lastPathComponent
        print("[DEBUG] [\(fileName):\(line)] \(function) - \(message)")
        #endif
    }
    
    public static func info(_ message: String) {
        #if DEBUG
        print("[INFO] \(message)")
        #endif
    }
    
    public static func error(_ message: String, error: Error? = nil) {
        let errorMessage = error?.localizedDescription ?? ""
        print("[ERROR] \(message) \(errorMessage)")
    }
}

// MARK: - 验证工具
public struct Validator {
    /// 验证手机号
    public static func validatePhone(_ phone: String) -> Bool {
        return phone.isValidMyanmarPhone
    }
    
    /// 验证验证码（6位数字）
    public static func validateVerifyCode(_ code: String) -> Bool {
        let pattern = "^\\d{6}$"
        return NSPredicate(format: "SELF MATCHES %@", pattern).evaluate(with: code)
    }
    
    /// 验证密码
    public static func validatePassword(_ password: String) -> Bool {
        return password.isValidPassword
    }
    
    /// 验证身份证号（缅甸）
    public static func validateIDCard(_ idCard: String) -> Bool {
        // 缅甸身份证格式较灵活，这里做基础长度验证
        return idCard.count >= 6
    }
    
    /// 验证邮箱
    public static func validateEmail(_ email: String) -> Bool {
        let pattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return NSPredicate(format: "SELF MATCHES %@", pattern).evaluate(with: email)
    }
}

// MARK: - 图片缓存管理
public class ImageCache {
    public static let shared = ImageCache()
    
    private let cache = NSCache<NSString, UIImage>()
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    
    private init() {
        cache.countLimit = 100 // 内存缓存最大数量
        cache.totalCostLimit = 50 * 1024 * 1024 // 50MB
        
        let urls = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        cacheDirectory = urls[0].appendingPathComponent("ImageCache")
        
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
    
    /// 从缓存获取图片
    public func getImage(forKey key: String) -> UIImage? {
        // 先查内存缓存
        if let image = cache.object(forKey: key as NSString) {
            return image
        }
        
        // 再查磁盘缓存
        let fileURL = cacheDirectory.appendingPathComponent(key.md5)
        if let data = try? Data(contentsOf: fileURL),
           let image = UIImage(data: data) {
            // 存入内存缓存
            cache.setObject(image, forKey: key as NSString)
            return image
        }
        
        return nil
    }
    
    /// 保存图片到缓存
    public func setImage(_ image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString)
        
        // 异步保存到磁盘
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self,
                  let data = image.jpegData(compressionQuality: 0.8) else { return }
            
            let fileURL = self.cacheDirectory.appendingPathComponent(key.md5)
            try? data.write(to: fileURL)
        }
    }
    
    /// 清除缓存
    public func clearCache() {
        cache.removeAllObjects()
        
        try? fileManager.removeItem(at: cacheDirectory)
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
}

// MARK: - String MD5扩展（用于缓存文件名）
extension String {
    var md5: String {
        // 简化实现，实际项目中需要引入CryptoKit或使用CommonCrypto
        // 这里返回原字符串的base64编码作为替代
        return Data(self.utf8).base64EncodedString()
    }
}

// MARK: - 设备信息
public struct DeviceInfo {
    /// 设备型号
    public static var model: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }
    
    /// 系统版本
    public static var systemVersion: String {
        return UIDevice.current.systemVersion
    }
    
    /// APP版本
    public static var appVersion: String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
    
    /// 构建版本
    public static var buildVersion: String {
        return Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
}

// MARK: - 震动反馈
public struct HapticFeedback {
    public static func light() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    public static func medium() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    public static func heavy() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }
    
    public static func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    public static func error() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
    
    public static func warning() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }
}
