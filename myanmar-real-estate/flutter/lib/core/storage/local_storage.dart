/**
 * 本地存储管理
 * 使用SharedPreferences和Hive，JWT Token使用flutter_secure_storage加密存储
 */
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../models/user.dart';

class LocalStorage {
  static SharedPreferences? _prefs;
  static Box<User>? _userBox;
  static Box<dynamic>? _cacheBox;
  static const _secureStorage = FlutterSecureStorage();

  /// 初始化存储
  static Future<void> init() async {
    await Hive.initFlutter();
    
    // 注册适配器
    Hive.registerAdapter(UserAdapter());
    Hive.registerAdapter(UserProfileAdapter());
    Hive.registerAdapter(UserVerificationAdapter());
    Hive.registerAdapter(AgentInfoAdapter());
    
    // 打开Box
    _userBox = await Hive.openBox<User>('user');
    _cacheBox = await Hive.openBox('cache');
    _prefs = await SharedPreferences.getInstance();
  }

  // ==================== Token相关（使用flutter_secure_storage加密存储）====================

  static Future<void> setToken(String token) async {
    await _secureStorage.write(key: 'auth_token', value: token);
  }

  static Future<String?> getToken() async {
    return await _secureStorage.read(key: 'auth_token');
  }

  static Future<void> setRefreshToken(String token) async {
    await _secureStorage.write(key: 'auth_refresh_token', value: token);
  }

  static Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: 'auth_refresh_token');
  }

  // ==================== 用户信息 ====================

  static Future<void> setUser(User user) async {
    await _userBox?.put('current', user);
  }

  static User? getUser() {
    return _userBox?.get('current');
  }

  static Future<void> clearUser() async {
    await _userBox?.delete('current');
  }

  // ==================== 认证信息清除 ====================

  static Future<void> clearAuth() async {
    await _secureStorage.delete(key: 'auth_token');
    await _secureStorage.delete(key: 'auth_refresh_token');
    await clearUser();
  }

  // ==================== 设备ID ====================

  static Future<String?> getDeviceId() async {
    String? deviceId = _prefs?.getString(StorageKeys.deviceId);
    if (deviceId == null || deviceId.isEmpty) {
      deviceId = 'device_${DateTime.now().millisecondsSinceEpoch}_${(1000 + DateTime.now().microsecond % 9000)}';
      await _prefs?.setString(StorageKeys.deviceId, deviceId);
    }
    return deviceId;
  }

  // ==================== 首次启动 ====================

  static Future<bool> isFirstLaunch() async {
    return _prefs?.getBool(StorageKeys.firstLaunch) ?? true;
  }

  static Future<void> setFirstLaunch(bool value) async {
    await _prefs?.setBool(StorageKeys.firstLaunch, value);
  }

  // ==================== 语言设置 ====================

  static String? getLocale() {
    return _prefs?.getString(StorageKeys.locale);
  }

  static Future<void> saveLocale(String languageCode) async {
    await _prefs?.setString(StorageKeys.locale, languageCode);
  }

  // ==================== 搜索历史 ====================

  static Future<List<String>> getSearchHistory() async {
    final json = _prefs?.getString(StorageKeys.searchHistory);
    if (json != null) {
      final list = jsonDecode(json) as List;
      return list.cast<String>();
    }
    return [];
  }

  static Future<void> addSearchHistory(String keyword) async {
    final history = await getSearchHistory();
    // 移除重复的
    history.remove(keyword);
    // 添加到开头
    history.insert(0, keyword);
    // 只保留最近20条
    if (history.length > 20) {
      history.removeLast();
    }
    await _prefs?.setString(StorageKeys.searchHistory, jsonEncode(history));
  }

  static Future<void> clearSearchHistory() async {
    await _prefs?.remove(StorageKeys.searchHistory);
  }

  // ==================== 收藏缓存 ====================

  static Future<void> cacheFavorite(int houseId, bool isFavorited) async {
    final favorites = _cacheBox?.get('favorites') as Map? ?? {};
    favorites[houseId.toString()] = isFavorited;
    await _cacheBox?.put('favorites', favorites);
  }

  static bool? getCachedFavorite(int houseId) {
    final favorites = _cacheBox?.get('favorites') as Map?;
    return favorites?[houseId.toString()] as bool?;
  }

  // ==================== 通用缓存 ====================

  static Future<void> setCache(String key, dynamic value) async {
    await _cacheBox?.put(key, value);
  }

  static T? getCache<T>(String key) {
    return _cacheBox?.get(key) as T?;
  }

  static Future<void> removeCache(String key) async {
    await _cacheBox?.delete(key);
  }

  // ==================== 设置 ====================

  static Future<void> setSetting(String key, dynamic value) async {
    if (value is String) {
      await _prefs?.setString('setting_$key', value);
    } else if (value is int) {
      await _prefs?.setInt('setting_$key', value);
    } else if (value is bool) {
      await _prefs?.setBool('setting_$key', value);
    } else if (value is double) {
      await _prefs?.setDouble('setting_$key', value);
    }
  }

  static T? getSetting<T>(String key) {
    return _prefs?.get('setting_$key') as T?;
  }
}

// ==================== Hive适配器 ====================

class UserAdapter extends TypeAdapter<User> {
  @override
  final typeId = 1;

  @override
  User read(BinaryReader reader) {
    return User(
      userId: reader.readInt(),
      uuid: reader.readString(),
      phone: reader.readString(),
      email: reader.readString(),
      status: reader.readString(),
      isVerified: reader.readBool(),
      profile: reader.read(),
      verification: reader.read(),
      agentInfo: reader.read(),
      token: reader.readString(),
      expiresAt: reader.readInt(),
    );
  }

  @override
  void write(BinaryWriter writer, User obj) {
    writer.writeInt(obj.userId);
    writer.writeString(obj.uuid);
    writer.writeString(obj.phone);
    writer.writeString(obj.email ?? '');
    writer.writeString(obj.status);
    writer.writeBool(obj.isVerified);
    writer.write(obj.profile);
    writer.write(obj.verification);
    writer.write(obj.agentInfo);
    writer.writeString(obj.token ?? '');
    writer.writeInt(obj.expiresAt ?? 0);
  }
}

class UserProfileAdapter extends TypeAdapter<UserProfile> {
  @override
  final typeId = 2;

  @override
  UserProfile read(BinaryReader reader) {
    return UserProfile(
      nickname: reader.readString(),
      avatar: reader.readString(),
      gender: reader.readString(),
      birthday: reader.readString(),
      bio: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, UserProfile obj) {
    writer.writeString(obj.nickname ?? '');
    writer.writeString(obj.avatar ?? '');
    writer.writeString(obj.gender ?? '');
    writer.writeString(obj.birthday ?? '');
    writer.writeString(obj.bio ?? '');
  }
}

class UserVerificationAdapter extends TypeAdapter<UserVerification> {
  @override
  final typeId = 3;

  @override
  UserVerification read(BinaryReader reader) {
    return UserVerification(
      realName: reader.readString(),
      idCardNumber: reader.readString(),
      status: reader.readString(),
      verifiedAt: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, UserVerification obj) {
    writer.writeString(obj.realName ?? '');
    writer.writeString(obj.idCardNumber ?? '');
    writer.writeString(obj.status);
    writer.writeString(obj.verifiedAt ?? '');
  }
}

class AgentInfoAdapter extends TypeAdapter<AgentInfo> {
  @override
  final typeId = 4;

  @override
  AgentInfo read(BinaryReader reader) {
    return AgentInfo(
      agentId: reader.readInt(),
      status: reader.readString(),
      level: reader.readString(),
      company: reader.read(),
      workCity: reader.readString(),
      rating: reader.readDouble(),
      totalDeals: reader.readInt(),
    );
  }

  @override
  void write(BinaryWriter writer, AgentInfo obj) {
    writer.writeInt(obj.agentId);
    writer.writeString(obj.status);
    writer.writeString(obj.level);
    writer.write(obj.company);
    writer.writeString(obj.workCity ?? '');
    writer.writeDouble(obj.rating);
    writer.writeInt(obj.totalDeals);
  }
}
