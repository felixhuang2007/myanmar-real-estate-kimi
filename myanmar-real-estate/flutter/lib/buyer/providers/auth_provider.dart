/**
 * 认证状态管理
 */
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/dio_client.dart';
import '../../core/api/user_api.dart';
import '../../core/models/user.dart';
import '../../core/storage/local_storage.dart';
import '../../core/utils/app_utils.dart';

/// 认证状态
class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  bool get isLoggedIn => user?.isLoggedIn ?? false;
}

/// 认证Provider
class AuthNotifier extends StateNotifier<AuthState> {
  final UserApi _userApi;

  AuthNotifier(this._userApi) : super(const AuthState()) {
    _init();
  }

  /// 初始化，检查登录状态
  void _init() {
    final user = LocalStorage.getUser();
    if (user != null) {
      state = AuthState(user: user);
    }
  }

  /// 发送验证码
  Future<void> sendVerificationCode(String phone) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final response = await _userApi.sendVerificationCode({
        'phone': phone.startsWith('+95') ? phone : '+95$phone',
        'type': 'login',
      });
      
      if (!response.isSuccess) {
        throw Exception(response.message);
      }
      
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  /// 发送验证码（注册用）
  Future<void> sendRegisterCode(String phone) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final response = await _userApi.sendVerificationCode({
        'phone': phone.startsWith('+95') ? phone : '+95$phone',
        'type': 'register',
      });

      if (!response.isSuccess) {
        throw Exception(response.message);
      }

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  /// 注册
  Future<void> register({
    required String phone,
    required String code,
    required String password,
    required String name,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final formattedPhone = phone.startsWith('+95') ? phone : '+95$phone';
      final deviceId = await LocalStorage.getDeviceId();

      final response = await _userApi.register({
        'phone': formattedPhone,
        'code': code,
        'password': password,
        'name': name,
        'device_id': deviceId,
      });

      if (!response.isSuccess || response.data == null) {
        throw Exception(response.message);
      }

      final loginData = response.data!;

      // 保存Token
      await LocalStorage.setToken(loginData.token);
      if (loginData.refreshToken != null) {
        await LocalStorage.setRefreshToken(loginData.refreshToken!);
      }

      // 获取用户信息
      await _fetchUserInfo();

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  /// 登录
  Future<void> login(String phone, String code) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final formattedPhone = phone.startsWith('+95') ? phone : '+95$phone';
      final deviceId = await LocalStorage.getDeviceId();

      final response = await _userApi.login({
        'phone': formattedPhone,
        'code': code,
        'device_id': deviceId,
      });

      if (!response.isSuccess || response.data == null) {
        throw Exception(response.message);
      }

      final loginData = response.data!;

      // 保存Token
      await LocalStorage.setToken(loginData.token);
      if (loginData.refreshToken != null) {
        await LocalStorage.setRefreshToken(loginData.refreshToken!);
      }

      // 先设置一个带token的占位用户，确保isLoggedIn立即为true（触发路由跳转）
      final placeholderUser = User(
        userId: loginData.userId,
        uuid: '',
        phone: phone,
        token: loginData.token,
        expiresAt: loginData.expiresAt,
      );
      state = state.copyWith(user: placeholderUser, isLoading: false);

      // 后台获取完整用户信息（_fetchUserInfo会保留token）
      await _fetchUserInfo();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  /// 获取用户信息
  Future<void> _fetchUserInfo() async {
    try {
      final token = await LocalStorage.getToken();
      final response = await _userApi.getCurrentUser();

      if (response.isSuccess && response.data != null) {
        // 保留token，避免isLoggedIn变为false
        final user = response.data!.copyWith(token: token);
        await LocalStorage.setUser(user);
        state = state.copyWith(user: user);
      }
    } catch (e) {
      LogUtil.e('获取用户信息失败', e);
    }
  }

  /// 退出登录
  Future<void> logout() async {
    try {
      await _userApi.logout();
    } catch (e) {
      LogUtil.e('退出登录请求失败', e);
    } finally {
      await LocalStorage.clearAuth();
      DioClient.reset();
      state = const AuthState();
    }
  }

  /// 更新用户信息
  Future<void> updateProfile(Map<String, dynamic> data) async {
    try {
      state = state.copyWith(isLoading: true);
      final response = await _userApi.updateUserProfile(data);
      
      if (response.isSuccess && response.data != null) {
        final user = response.data!;
        await LocalStorage.setUser(user);
        state = state.copyWith(user: user, isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  /// 刷新用户信息
  Future<void> refreshUser() async {
    await _fetchUserInfo();
  }
}

/// 认证Provider实例
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final userApi = UserApi(DioClient.instance);
  return AuthNotifier(userApi);
});

/// 当前用户Provider
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authProvider).user;
});

/// 是否登录Provider
final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isLoggedIn;
});
