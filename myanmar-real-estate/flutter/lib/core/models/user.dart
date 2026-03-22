/**
 * 用户模型
 */
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _$User {
  @HiveType(typeId: 1)
  const User._();

  const factory User({
    @HiveField(0) @JsonKey(name: 'user_id') required int userId,
    @HiveField(1) @JsonKey(name: 'uuid') required String uuid,
    @HiveField(2) @JsonKey(name: 'phone') required String phone,
    @HiveField(3) @JsonKey(name: 'email') String? email,
    @HiveField(4) @JsonKey(name: 'status') @Default('active') String status,
    @HiveField(5) @JsonKey(name: 'is_verified') @Default(false) bool isVerified,
    @HiveField(6) @JsonKey(name: 'profile') UserProfile? profile,
    @HiveField(7) @JsonKey(name: 'verification') UserVerification? verification,
    @HiveField(8) @JsonKey(name: 'agent_info') AgentInfo? agentInfo,
    @HiveField(9) @JsonKey(name: 'token') String? token,
    @HiveField(10) @JsonKey(name: 'expires_at') int? expiresAt,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  bool get isLoggedIn => token != null && token!.isNotEmpty;
  
  bool get isAgent => agentInfo != null;
}

@freezed
class UserProfile with _$UserProfile {
  @HiveType(typeId: 2)
  const factory UserProfile({
    @HiveField(0) @JsonKey(name: 'nickname') String? nickname,
    @HiveField(1) @JsonKey(name: 'avatar') String? avatar,
    @HiveField(2) @JsonKey(name: 'gender') String? gender,
    @HiveField(3) @JsonKey(name: 'birthday') String? birthday,
    @HiveField(4) @JsonKey(name: 'bio') String? bio,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);
}

@freezed
class UserVerification with _$UserVerification {
  @HiveType(typeId: 3)
  const UserVerification._();

  const factory UserVerification({
    @HiveField(0) @JsonKey(name: 'real_name') String? realName,
    @HiveField(1) @JsonKey(name: 'id_card_number') String? idCardNumber,
    @HiveField(2) @JsonKey(name: 'status') @Default('pending') String status,
    @HiveField(3) @JsonKey(name: 'verified_at') String? verifiedAt,
  }) = _UserVerification;

  factory UserVerification.fromJson(Map<String, dynamic> json) =>
      _$UserVerificationFromJson(json);

  bool get isApproved => status == 'approved';
}

@freezed
class AgentInfo with _$AgentInfo {
  @HiveType(typeId: 4)
  const factory AgentInfo({
    @HiveField(0) @JsonKey(name: 'agent_id') required int agentId,
    @HiveField(1) @JsonKey(name: 'status') @Default('active') String status,
    @HiveField(2) @JsonKey(name: 'level') @Default('junior') String level,
    @HiveField(3) @JsonKey(name: 'company') CompanyInfo? company,
    @HiveField(4) @JsonKey(name: 'work_city') String? workCity,
    @HiveField(5) @JsonKey(name: 'rating') @Default(0.0) double rating,
    @HiveField(6) @JsonKey(name: 'total_deals') @Default(0) int totalDeals,
  }) = _AgentInfo;

  factory AgentInfo.fromJson(Map<String, dynamic> json) =>
      _$AgentInfoFromJson(json);
}

@freezed
class CompanyInfo with _$CompanyInfo {
  const factory CompanyInfo({
    @JsonKey(name: 'id') required int id,
    @JsonKey(name: 'name') required String name,
  }) = _CompanyInfo;

  factory CompanyInfo.fromJson(Map<String, dynamic> json) =>
      _$CompanyInfoFromJson(json);
}

/**
 * 登录响应
 */
@freezed
class LoginResponse with _$LoginResponse {
  const factory LoginResponse({
    @JsonKey(name: 'user_id', fromJson: _userIdFromJson) required int userId,
    @JsonKey(name: 'token') required String token,
    @JsonKey(name: 'refresh_token') String? refreshToken,
    @JsonKey(name: 'expires_at', fromJson: _expiresAtFromJson) int? expiresAt,
    @JsonKey(name: 'is_new_user') @Default(false) bool isNewUser,
  }) = _LoginResponse;

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);
}

/// 处理user_id可能是int或String的情况
int _userIdFromJson(dynamic value) {
  if (value is int) return value;
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

/// 处理expires_at可能是int、String或DateTime的情况
int? _expiresAtFromJson(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is String) {
    // 尝试解析为时间戳
    final timestamp = int.tryParse(value);
    if (timestamp != null) return timestamp;
    // 尝试解析ISO 8601日期字符串
    try {
      final dateTime = DateTime.parse(value);
      return dateTime.millisecondsSinceEpoch ~/ 1000;
    } catch (_) {
      return null;
    }
  }
  return null;
}

/**
 * 发送验证码响应
 */
@freezed
class SendCodeResponse with _$SendCodeResponse {
  const factory SendCodeResponse({
    @JsonKey(name: 'code') String? code,
    @JsonKey(name: 'expired_at', fromJson: _expiredAtFromJson) required int expiredAt,
    @JsonKey(name: 'interval', fromJson: _intervalFromJson) @Default(60) int interval,
  }) = _SendCodeResponse;

  factory SendCodeResponse.fromJson(Map<String, dynamic> json) =>
      _$SendCodeResponseFromJson(json);
}

/// 处理expired_at可能是int或String的情况
int _expiredAtFromJson(dynamic value) {
  if (value is int) return value;
  if (value is String) return int.tryParse(value) ?? 300;
  return 300;
}

/// 处理interval可能是int或String的情况
int _intervalFromJson(dynamic value) {
  if (value is int) return value;
  if (value is String) return int.tryParse(value) ?? 60;
  return 60;
}
