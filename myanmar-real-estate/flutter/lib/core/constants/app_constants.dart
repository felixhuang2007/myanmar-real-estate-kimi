/**
 * 常量定义
 */

/// API常量
class ApiConstants {
  ApiConstants._();

  // 基础URL (本地开发环境)
  // Windows PC测试使用本机IP，不要用localhost
  static const String baseUrl = 'http://localhost:8080';
  static const String apiVersion = 'v1';
  static const String baseApiUrl = '$baseUrl/$apiVersion';

  // 超时配置
  static const int connectTimeout = 15000;
  static const int receiveTimeout = 15000;
  static const int sendTimeout = 15000;

  // 分页配置
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
}

/// 存储Key常量
class StorageKeys {
  StorageKeys._();

  static const String token = 'token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';
  static const String userInfo = 'user_info';
  static const String agentInfo = 'agent_info';
  static const String appSettings = 'app_settings';
  static const String searchHistory = 'search_history';
  static const String browsingHistory = 'browsing_history';
  static const String favorites = 'favorites';
  static const String firstLaunch = 'first_launch';
  static const String locale = 'locale';
  static const String deviceId = 'device_id';
}

/// 路由名称常量
class RouteNames {
  RouteNames._();

  // 通用
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String webView = '/webview';
  static const String languageSelect = '/language-select';

  // C端
  static const String buyerHome = '/buyer/home';
  static const String buyerSearch = '/buyer/search';
  static const String buyerMap = '/buyer/map';
  static const String buyerFavorites = '/buyer/favorites';
  static const String buyerProfile = '/buyer/profile';
  static const String houseDetail = '/buyer/house/:id';
  static const String houseList = '/buyer/houses';
  static const String appointment = '/buyer/appointment';
  static const String chat = '/buyer/chat/:id';
  static const String chatList = '/buyer/chats';
  static const String mortgageCalc = '/buyer/mortgage';

  // B端
  static const String agentHome = '/agent/home';
  static const String agentLogin = '/agent/login';
  static const String agentHouseManage = '/agent/houses';
  static const String agentHouseAdd = '/agent/houses/add';
  static const String agentHouseEdit = '/agent/houses/edit/:id';
  static const String agentClients = '/agent/clients';
  static const String agentAppointments = '/agent/appointments';
  static const String agentSchedule = '/agent/schedule';
  static const String agentVerification = '/agent/verification';
  static const String agentAcn = '/agent/acn';
  static const String agentPerformance = '/agent/performance';
  static const String agentSettings = '/agent/settings';
}

/// 城市代码
class CityCodes {
  CityCodes._();

  static const String yangon = 'YGN';
  static const String mandalay = 'MDY';
  static const String naypyitaw = 'NPT';

}

/// 镇区代码 (仰光主要镇区)
class DistrictCodes {
  DistrictCodes._();

  static const String tamwe = 'TAMWE';
  static const String bahan = 'BAHAN';
  static const String yankin = 'YANKIN';
  static const String mayangone = 'MAYANGONE';
  static const String kamayut = 'KAMAYUT';
  static const String thingangyun = 'THINGANGYUN';
  static const String southOkkalapa = 'SOUTH_OKKALAPA';
  static const String northOkkalapa = 'NORTH_OKKALAPA';
  static const String insein = 'INSEIN';
  static const String hlaing = 'HLAING';

  static const Map<String, String> districtNames = {
    tamwe: 'Tamwe',
    bahan: 'Bahan',
    yankin: 'Yankin',
    mayangone: 'Mayangone',
    kamayut: 'Kamayut',
    thingangyun: 'Thingangyun',
    southOkkalapa: 'South Okkalapa',
    northOkkalapa: 'North Okkalapa',
    insein: 'Insein',
    hlaing: 'Hlaing',
  };
}

/// 房源类型
class HouseTypes {
  HouseTypes._();

  static const String apartment = 'apartment';
  static const String house = 'house';
  static const String townhouse = 'townhouse';
  static const String land = 'land';
  static const String commercial = 'commercial';

}

/// 交易类型
class TransactionTypes {
  TransactionTypes._();

  static const String sale = 'sale';
  static const String rent = 'rent';

}

/// 装修类型
class DecorationTypes {
  DecorationTypes._();

  static const String rough = 'rough';
  static const String simple = 'simple';
  static const String fine = 'fine';
  static const String luxury = 'luxury';

}

/// 房源状态
class HouseStatus {
  HouseStatus._();

  static const String pending = 'pending';
  static const String verifying = 'verifying';
  static const String online = 'online';
  static const String offline = 'offline';
  static const String sold = 'sold';
  static const String rejected = 'rejected';

  static const Map<String, String> statusColors = {
    pending: 'orange',
    verifying: 'blue',
    online: 'green',
    offline: 'gray',
    sold: 'red',
    rejected: 'red',
  };
}

/// 预约状态
class AppointmentStatus {
  AppointmentStatus._();

  static const String pending = 'pending';
  static const String confirmed = 'confirmed';
  static const String rejected = 'rejected';
  static const String cancelled = 'cancelled';
  static const String completed = 'completed';
  static const String noShow = 'no_show';

}

/// ACN角色
class AcnRoles {
  AcnRoles._();

  static const String entrant = 'ENTRANT';
  static const String maintainer = 'MAINTAINER';
  static const String introducer = 'INTRODUCER';
  static const String accompanier = 'ACCOMPANIER';
  static const String closer = 'CLOSER';

  static const Map<String, double> defaultRatios = {
    entrant: 0.15,
    maintainer: 0.15,
    introducer: 0.10,
    accompanier: 0.10,
    closer: 0.40,
  };
}
