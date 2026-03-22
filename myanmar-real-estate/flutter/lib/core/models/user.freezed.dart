// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

User _$UserFromJson(Map<String, dynamic> json) {
  return _User.fromJson(json);
}

/// @nodoc
mixin _$User {
  @HiveField(0)
  @JsonKey(name: 'user_id')
  int get userId => throw _privateConstructorUsedError;
  @HiveField(1)
  @JsonKey(name: 'uuid')
  String get uuid => throw _privateConstructorUsedError;
  @HiveField(2)
  @JsonKey(name: 'phone')
  String get phone => throw _privateConstructorUsedError;
  @HiveField(3)
  @JsonKey(name: 'email')
  String? get email => throw _privateConstructorUsedError;
  @HiveField(4)
  @JsonKey(name: 'status')
  String get status => throw _privateConstructorUsedError;
  @HiveField(5)
  @JsonKey(name: 'is_verified')
  bool get isVerified => throw _privateConstructorUsedError;
  @HiveField(6)
  @JsonKey(name: 'profile')
  UserProfile? get profile => throw _privateConstructorUsedError;
  @HiveField(7)
  @JsonKey(name: 'verification')
  UserVerification? get verification => throw _privateConstructorUsedError;
  @HiveField(8)
  @JsonKey(name: 'agent_info')
  AgentInfo? get agentInfo => throw _privateConstructorUsedError;
  @HiveField(9)
  @JsonKey(name: 'token')
  String? get token => throw _privateConstructorUsedError;
  @HiveField(10)
  @JsonKey(name: 'expires_at')
  int? get expiresAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $UserCopyWith<User> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserCopyWith<$Res> {
  factory $UserCopyWith(User value, $Res Function(User) then) =
      _$UserCopyWithImpl<$Res, User>;
  @useResult
  $Res call(
      {@HiveField(0) @JsonKey(name: 'user_id') int userId,
      @HiveField(1) @JsonKey(name: 'uuid') String uuid,
      @HiveField(2) @JsonKey(name: 'phone') String phone,
      @HiveField(3) @JsonKey(name: 'email') String? email,
      @HiveField(4) @JsonKey(name: 'status') String status,
      @HiveField(5) @JsonKey(name: 'is_verified') bool isVerified,
      @HiveField(6) @JsonKey(name: 'profile') UserProfile? profile,
      @HiveField(7)
      @JsonKey(name: 'verification')
      UserVerification? verification,
      @HiveField(8) @JsonKey(name: 'agent_info') AgentInfo? agentInfo,
      @HiveField(9) @JsonKey(name: 'token') String? token,
      @HiveField(10) @JsonKey(name: 'expires_at') int? expiresAt});

  $UserProfileCopyWith<$Res>? get profile;
  $UserVerificationCopyWith<$Res>? get verification;
  $AgentInfoCopyWith<$Res>? get agentInfo;
}

/// @nodoc
class _$UserCopyWithImpl<$Res, $Val extends User>
    implements $UserCopyWith<$Res> {
  _$UserCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? uuid = null,
    Object? phone = null,
    Object? email = freezed,
    Object? status = null,
    Object? isVerified = null,
    Object? profile = freezed,
    Object? verification = freezed,
    Object? agentInfo = freezed,
    Object? token = freezed,
    Object? expiresAt = freezed,
  }) {
    return _then(_value.copyWith(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as int,
      uuid: null == uuid
          ? _value.uuid
          : uuid // ignore: cast_nullable_to_non_nullable
              as String,
      phone: null == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      isVerified: null == isVerified
          ? _value.isVerified
          : isVerified // ignore: cast_nullable_to_non_nullable
              as bool,
      profile: freezed == profile
          ? _value.profile
          : profile // ignore: cast_nullable_to_non_nullable
              as UserProfile?,
      verification: freezed == verification
          ? _value.verification
          : verification // ignore: cast_nullable_to_non_nullable
              as UserVerification?,
      agentInfo: freezed == agentInfo
          ? _value.agentInfo
          : agentInfo // ignore: cast_nullable_to_non_nullable
              as AgentInfo?,
      token: freezed == token
          ? _value.token
          : token // ignore: cast_nullable_to_non_nullable
              as String?,
      expiresAt: freezed == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $UserProfileCopyWith<$Res>? get profile {
    if (_value.profile == null) {
      return null;
    }

    return $UserProfileCopyWith<$Res>(_value.profile!, (value) {
      return _then(_value.copyWith(profile: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $UserVerificationCopyWith<$Res>? get verification {
    if (_value.verification == null) {
      return null;
    }

    return $UserVerificationCopyWith<$Res>(_value.verification!, (value) {
      return _then(_value.copyWith(verification: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $AgentInfoCopyWith<$Res>? get agentInfo {
    if (_value.agentInfo == null) {
      return null;
    }

    return $AgentInfoCopyWith<$Res>(_value.agentInfo!, (value) {
      return _then(_value.copyWith(agentInfo: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$UserImplCopyWith<$Res> implements $UserCopyWith<$Res> {
  factory _$$UserImplCopyWith(
          _$UserImpl value, $Res Function(_$UserImpl) then) =
      __$$UserImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@HiveField(0) @JsonKey(name: 'user_id') int userId,
      @HiveField(1) @JsonKey(name: 'uuid') String uuid,
      @HiveField(2) @JsonKey(name: 'phone') String phone,
      @HiveField(3) @JsonKey(name: 'email') String? email,
      @HiveField(4) @JsonKey(name: 'status') String status,
      @HiveField(5) @JsonKey(name: 'is_verified') bool isVerified,
      @HiveField(6) @JsonKey(name: 'profile') UserProfile? profile,
      @HiveField(7)
      @JsonKey(name: 'verification')
      UserVerification? verification,
      @HiveField(8) @JsonKey(name: 'agent_info') AgentInfo? agentInfo,
      @HiveField(9) @JsonKey(name: 'token') String? token,
      @HiveField(10) @JsonKey(name: 'expires_at') int? expiresAt});

  @override
  $UserProfileCopyWith<$Res>? get profile;
  @override
  $UserVerificationCopyWith<$Res>? get verification;
  @override
  $AgentInfoCopyWith<$Res>? get agentInfo;
}

/// @nodoc
class __$$UserImplCopyWithImpl<$Res>
    extends _$UserCopyWithImpl<$Res, _$UserImpl>
    implements _$$UserImplCopyWith<$Res> {
  __$$UserImplCopyWithImpl(_$UserImpl _value, $Res Function(_$UserImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? uuid = null,
    Object? phone = null,
    Object? email = freezed,
    Object? status = null,
    Object? isVerified = null,
    Object? profile = freezed,
    Object? verification = freezed,
    Object? agentInfo = freezed,
    Object? token = freezed,
    Object? expiresAt = freezed,
  }) {
    return _then(_$UserImpl(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as int,
      uuid: null == uuid
          ? _value.uuid
          : uuid // ignore: cast_nullable_to_non_nullable
              as String,
      phone: null == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      isVerified: null == isVerified
          ? _value.isVerified
          : isVerified // ignore: cast_nullable_to_non_nullable
              as bool,
      profile: freezed == profile
          ? _value.profile
          : profile // ignore: cast_nullable_to_non_nullable
              as UserProfile?,
      verification: freezed == verification
          ? _value.verification
          : verification // ignore: cast_nullable_to_non_nullable
              as UserVerification?,
      agentInfo: freezed == agentInfo
          ? _value.agentInfo
          : agentInfo // ignore: cast_nullable_to_non_nullable
              as AgentInfo?,
      token: freezed == token
          ? _value.token
          : token // ignore: cast_nullable_to_non_nullable
              as String?,
      expiresAt: freezed == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserImpl extends _User {
  const _$UserImpl(
      {@HiveField(0) @JsonKey(name: 'user_id') required this.userId,
      @HiveField(1) @JsonKey(name: 'uuid') required this.uuid,
      @HiveField(2) @JsonKey(name: 'phone') required this.phone,
      @HiveField(3) @JsonKey(name: 'email') this.email,
      @HiveField(4) @JsonKey(name: 'status') this.status = 'active',
      @HiveField(5) @JsonKey(name: 'is_verified') this.isVerified = false,
      @HiveField(6) @JsonKey(name: 'profile') this.profile,
      @HiveField(7) @JsonKey(name: 'verification') this.verification,
      @HiveField(8) @JsonKey(name: 'agent_info') this.agentInfo,
      @HiveField(9) @JsonKey(name: 'token') this.token,
      @HiveField(10) @JsonKey(name: 'expires_at') this.expiresAt})
      : super._();

  factory _$UserImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserImplFromJson(json);

  @override
  @HiveField(0)
  @JsonKey(name: 'user_id')
  final int userId;
  @override
  @HiveField(1)
  @JsonKey(name: 'uuid')
  final String uuid;
  @override
  @HiveField(2)
  @JsonKey(name: 'phone')
  final String phone;
  @override
  @HiveField(3)
  @JsonKey(name: 'email')
  final String? email;
  @override
  @HiveField(4)
  @JsonKey(name: 'status')
  final String status;
  @override
  @HiveField(5)
  @JsonKey(name: 'is_verified')
  final bool isVerified;
  @override
  @HiveField(6)
  @JsonKey(name: 'profile')
  final UserProfile? profile;
  @override
  @HiveField(7)
  @JsonKey(name: 'verification')
  final UserVerification? verification;
  @override
  @HiveField(8)
  @JsonKey(name: 'agent_info')
  final AgentInfo? agentInfo;
  @override
  @HiveField(9)
  @JsonKey(name: 'token')
  final String? token;
  @override
  @HiveField(10)
  @JsonKey(name: 'expires_at')
  final int? expiresAt;

  @override
  String toString() {
    return 'User(userId: $userId, uuid: $uuid, phone: $phone, email: $email, status: $status, isVerified: $isVerified, profile: $profile, verification: $verification, agentInfo: $agentInfo, token: $token, expiresAt: $expiresAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.uuid, uuid) || other.uuid == uuid) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.isVerified, isVerified) ||
                other.isVerified == isVerified) &&
            (identical(other.profile, profile) || other.profile == profile) &&
            (identical(other.verification, verification) ||
                other.verification == verification) &&
            (identical(other.agentInfo, agentInfo) ||
                other.agentInfo == agentInfo) &&
            (identical(other.token, token) || other.token == token) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, userId, uuid, phone, email,
      status, isVerified, profile, verification, agentInfo, token, expiresAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UserImplCopyWith<_$UserImpl> get copyWith =>
      __$$UserImplCopyWithImpl<_$UserImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserImplToJson(
      this,
    );
  }
}

abstract class _User extends User {
  const factory _User(
          {@HiveField(0) @JsonKey(name: 'user_id') required final int userId,
          @HiveField(1) @JsonKey(name: 'uuid') required final String uuid,
          @HiveField(2) @JsonKey(name: 'phone') required final String phone,
          @HiveField(3) @JsonKey(name: 'email') final String? email,
          @HiveField(4) @JsonKey(name: 'status') final String status,
          @HiveField(5) @JsonKey(name: 'is_verified') final bool isVerified,
          @HiveField(6) @JsonKey(name: 'profile') final UserProfile? profile,
          @HiveField(7)
          @JsonKey(name: 'verification')
          final UserVerification? verification,
          @HiveField(8) @JsonKey(name: 'agent_info') final AgentInfo? agentInfo,
          @HiveField(9) @JsonKey(name: 'token') final String? token,
          @HiveField(10) @JsonKey(name: 'expires_at') final int? expiresAt}) =
      _$UserImpl;
  const _User._() : super._();

  factory _User.fromJson(Map<String, dynamic> json) = _$UserImpl.fromJson;

  @override
  @HiveField(0)
  @JsonKey(name: 'user_id')
  int get userId;
  @override
  @HiveField(1)
  @JsonKey(name: 'uuid')
  String get uuid;
  @override
  @HiveField(2)
  @JsonKey(name: 'phone')
  String get phone;
  @override
  @HiveField(3)
  @JsonKey(name: 'email')
  String? get email;
  @override
  @HiveField(4)
  @JsonKey(name: 'status')
  String get status;
  @override
  @HiveField(5)
  @JsonKey(name: 'is_verified')
  bool get isVerified;
  @override
  @HiveField(6)
  @JsonKey(name: 'profile')
  UserProfile? get profile;
  @override
  @HiveField(7)
  @JsonKey(name: 'verification')
  UserVerification? get verification;
  @override
  @HiveField(8)
  @JsonKey(name: 'agent_info')
  AgentInfo? get agentInfo;
  @override
  @HiveField(9)
  @JsonKey(name: 'token')
  String? get token;
  @override
  @HiveField(10)
  @JsonKey(name: 'expires_at')
  int? get expiresAt;
  @override
  @JsonKey(ignore: true)
  _$$UserImplCopyWith<_$UserImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UserProfile _$UserProfileFromJson(Map<String, dynamic> json) {
  return _UserProfile.fromJson(json);
}

/// @nodoc
mixin _$UserProfile {
  @HiveField(0)
  @JsonKey(name: 'nickname')
  String? get nickname => throw _privateConstructorUsedError;
  @HiveField(1)
  @JsonKey(name: 'avatar')
  String? get avatar => throw _privateConstructorUsedError;
  @HiveField(2)
  @JsonKey(name: 'gender')
  String? get gender => throw _privateConstructorUsedError;
  @HiveField(3)
  @JsonKey(name: 'birthday')
  String? get birthday => throw _privateConstructorUsedError;
  @HiveField(4)
  @JsonKey(name: 'bio')
  String? get bio => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $UserProfileCopyWith<UserProfile> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserProfileCopyWith<$Res> {
  factory $UserProfileCopyWith(
          UserProfile value, $Res Function(UserProfile) then) =
      _$UserProfileCopyWithImpl<$Res, UserProfile>;
  @useResult
  $Res call(
      {@HiveField(0) @JsonKey(name: 'nickname') String? nickname,
      @HiveField(1) @JsonKey(name: 'avatar') String? avatar,
      @HiveField(2) @JsonKey(name: 'gender') String? gender,
      @HiveField(3) @JsonKey(name: 'birthday') String? birthday,
      @HiveField(4) @JsonKey(name: 'bio') String? bio});
}

/// @nodoc
class _$UserProfileCopyWithImpl<$Res, $Val extends UserProfile>
    implements $UserProfileCopyWith<$Res> {
  _$UserProfileCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? nickname = freezed,
    Object? avatar = freezed,
    Object? gender = freezed,
    Object? birthday = freezed,
    Object? bio = freezed,
  }) {
    return _then(_value.copyWith(
      nickname: freezed == nickname
          ? _value.nickname
          : nickname // ignore: cast_nullable_to_non_nullable
              as String?,
      avatar: freezed == avatar
          ? _value.avatar
          : avatar // ignore: cast_nullable_to_non_nullable
              as String?,
      gender: freezed == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as String?,
      birthday: freezed == birthday
          ? _value.birthday
          : birthday // ignore: cast_nullable_to_non_nullable
              as String?,
      bio: freezed == bio
          ? _value.bio
          : bio // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserProfileImplCopyWith<$Res>
    implements $UserProfileCopyWith<$Res> {
  factory _$$UserProfileImplCopyWith(
          _$UserProfileImpl value, $Res Function(_$UserProfileImpl) then) =
      __$$UserProfileImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@HiveField(0) @JsonKey(name: 'nickname') String? nickname,
      @HiveField(1) @JsonKey(name: 'avatar') String? avatar,
      @HiveField(2) @JsonKey(name: 'gender') String? gender,
      @HiveField(3) @JsonKey(name: 'birthday') String? birthday,
      @HiveField(4) @JsonKey(name: 'bio') String? bio});
}

/// @nodoc
class __$$UserProfileImplCopyWithImpl<$Res>
    extends _$UserProfileCopyWithImpl<$Res, _$UserProfileImpl>
    implements _$$UserProfileImplCopyWith<$Res> {
  __$$UserProfileImplCopyWithImpl(
      _$UserProfileImpl _value, $Res Function(_$UserProfileImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? nickname = freezed,
    Object? avatar = freezed,
    Object? gender = freezed,
    Object? birthday = freezed,
    Object? bio = freezed,
  }) {
    return _then(_$UserProfileImpl(
      nickname: freezed == nickname
          ? _value.nickname
          : nickname // ignore: cast_nullable_to_non_nullable
              as String?,
      avatar: freezed == avatar
          ? _value.avatar
          : avatar // ignore: cast_nullable_to_non_nullable
              as String?,
      gender: freezed == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as String?,
      birthday: freezed == birthday
          ? _value.birthday
          : birthday // ignore: cast_nullable_to_non_nullable
              as String?,
      bio: freezed == bio
          ? _value.bio
          : bio // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
@HiveType(typeId: 2)
class _$UserProfileImpl implements _UserProfile {
  const _$UserProfileImpl(
      {@HiveField(0) @JsonKey(name: 'nickname') this.nickname,
      @HiveField(1) @JsonKey(name: 'avatar') this.avatar,
      @HiveField(2) @JsonKey(name: 'gender') this.gender,
      @HiveField(3) @JsonKey(name: 'birthday') this.birthday,
      @HiveField(4) @JsonKey(name: 'bio') this.bio});

  factory _$UserProfileImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserProfileImplFromJson(json);

  @override
  @HiveField(0)
  @JsonKey(name: 'nickname')
  final String? nickname;
  @override
  @HiveField(1)
  @JsonKey(name: 'avatar')
  final String? avatar;
  @override
  @HiveField(2)
  @JsonKey(name: 'gender')
  final String? gender;
  @override
  @HiveField(3)
  @JsonKey(name: 'birthday')
  final String? birthday;
  @override
  @HiveField(4)
  @JsonKey(name: 'bio')
  final String? bio;

  @override
  String toString() {
    return 'UserProfile(nickname: $nickname, avatar: $avatar, gender: $gender, birthday: $birthday, bio: $bio)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserProfileImpl &&
            (identical(other.nickname, nickname) ||
                other.nickname == nickname) &&
            (identical(other.avatar, avatar) || other.avatar == avatar) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.birthday, birthday) ||
                other.birthday == birthday) &&
            (identical(other.bio, bio) || other.bio == bio));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, nickname, avatar, gender, birthday, bio);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UserProfileImplCopyWith<_$UserProfileImpl> get copyWith =>
      __$$UserProfileImplCopyWithImpl<_$UserProfileImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserProfileImplToJson(
      this,
    );
  }
}

abstract class _UserProfile implements UserProfile {
  const factory _UserProfile(
          {@HiveField(0) @JsonKey(name: 'nickname') final String? nickname,
          @HiveField(1) @JsonKey(name: 'avatar') final String? avatar,
          @HiveField(2) @JsonKey(name: 'gender') final String? gender,
          @HiveField(3) @JsonKey(name: 'birthday') final String? birthday,
          @HiveField(4) @JsonKey(name: 'bio') final String? bio}) =
      _$UserProfileImpl;

  factory _UserProfile.fromJson(Map<String, dynamic> json) =
      _$UserProfileImpl.fromJson;

  @override
  @HiveField(0)
  @JsonKey(name: 'nickname')
  String? get nickname;
  @override
  @HiveField(1)
  @JsonKey(name: 'avatar')
  String? get avatar;
  @override
  @HiveField(2)
  @JsonKey(name: 'gender')
  String? get gender;
  @override
  @HiveField(3)
  @JsonKey(name: 'birthday')
  String? get birthday;
  @override
  @HiveField(4)
  @JsonKey(name: 'bio')
  String? get bio;
  @override
  @JsonKey(ignore: true)
  _$$UserProfileImplCopyWith<_$UserProfileImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UserVerification _$UserVerificationFromJson(Map<String, dynamic> json) {
  return _UserVerification.fromJson(json);
}

/// @nodoc
mixin _$UserVerification {
  @HiveField(0)
  @JsonKey(name: 'real_name')
  String? get realName => throw _privateConstructorUsedError;
  @HiveField(1)
  @JsonKey(name: 'id_card_number')
  String? get idCardNumber => throw _privateConstructorUsedError;
  @HiveField(2)
  @JsonKey(name: 'status')
  String get status => throw _privateConstructorUsedError;
  @HiveField(3)
  @JsonKey(name: 'verified_at')
  String? get verifiedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $UserVerificationCopyWith<UserVerification> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserVerificationCopyWith<$Res> {
  factory $UserVerificationCopyWith(
          UserVerification value, $Res Function(UserVerification) then) =
      _$UserVerificationCopyWithImpl<$Res, UserVerification>;
  @useResult
  $Res call(
      {@HiveField(0) @JsonKey(name: 'real_name') String? realName,
      @HiveField(1) @JsonKey(name: 'id_card_number') String? idCardNumber,
      @HiveField(2) @JsonKey(name: 'status') String status,
      @HiveField(3) @JsonKey(name: 'verified_at') String? verifiedAt});
}

/// @nodoc
class _$UserVerificationCopyWithImpl<$Res, $Val extends UserVerification>
    implements $UserVerificationCopyWith<$Res> {
  _$UserVerificationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? realName = freezed,
    Object? idCardNumber = freezed,
    Object? status = null,
    Object? verifiedAt = freezed,
  }) {
    return _then(_value.copyWith(
      realName: freezed == realName
          ? _value.realName
          : realName // ignore: cast_nullable_to_non_nullable
              as String?,
      idCardNumber: freezed == idCardNumber
          ? _value.idCardNumber
          : idCardNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      verifiedAt: freezed == verifiedAt
          ? _value.verifiedAt
          : verifiedAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserVerificationImplCopyWith<$Res>
    implements $UserVerificationCopyWith<$Res> {
  factory _$$UserVerificationImplCopyWith(_$UserVerificationImpl value,
          $Res Function(_$UserVerificationImpl) then) =
      __$$UserVerificationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@HiveField(0) @JsonKey(name: 'real_name') String? realName,
      @HiveField(1) @JsonKey(name: 'id_card_number') String? idCardNumber,
      @HiveField(2) @JsonKey(name: 'status') String status,
      @HiveField(3) @JsonKey(name: 'verified_at') String? verifiedAt});
}

/// @nodoc
class __$$UserVerificationImplCopyWithImpl<$Res>
    extends _$UserVerificationCopyWithImpl<$Res, _$UserVerificationImpl>
    implements _$$UserVerificationImplCopyWith<$Res> {
  __$$UserVerificationImplCopyWithImpl(_$UserVerificationImpl _value,
      $Res Function(_$UserVerificationImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? realName = freezed,
    Object? idCardNumber = freezed,
    Object? status = null,
    Object? verifiedAt = freezed,
  }) {
    return _then(_$UserVerificationImpl(
      realName: freezed == realName
          ? _value.realName
          : realName // ignore: cast_nullable_to_non_nullable
              as String?,
      idCardNumber: freezed == idCardNumber
          ? _value.idCardNumber
          : idCardNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      verifiedAt: freezed == verifiedAt
          ? _value.verifiedAt
          : verifiedAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserVerificationImpl extends _UserVerification {
  const _$UserVerificationImpl(
      {@HiveField(0) @JsonKey(name: 'real_name') this.realName,
      @HiveField(1) @JsonKey(name: 'id_card_number') this.idCardNumber,
      @HiveField(2) @JsonKey(name: 'status') this.status = 'pending',
      @HiveField(3) @JsonKey(name: 'verified_at') this.verifiedAt})
      : super._();

  factory _$UserVerificationImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserVerificationImplFromJson(json);

  @override
  @HiveField(0)
  @JsonKey(name: 'real_name')
  final String? realName;
  @override
  @HiveField(1)
  @JsonKey(name: 'id_card_number')
  final String? idCardNumber;
  @override
  @HiveField(2)
  @JsonKey(name: 'status')
  final String status;
  @override
  @HiveField(3)
  @JsonKey(name: 'verified_at')
  final String? verifiedAt;

  @override
  String toString() {
    return 'UserVerification(realName: $realName, idCardNumber: $idCardNumber, status: $status, verifiedAt: $verifiedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserVerificationImpl &&
            (identical(other.realName, realName) ||
                other.realName == realName) &&
            (identical(other.idCardNumber, idCardNumber) ||
                other.idCardNumber == idCardNumber) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.verifiedAt, verifiedAt) ||
                other.verifiedAt == verifiedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, realName, idCardNumber, status, verifiedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UserVerificationImplCopyWith<_$UserVerificationImpl> get copyWith =>
      __$$UserVerificationImplCopyWithImpl<_$UserVerificationImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserVerificationImplToJson(
      this,
    );
  }
}

abstract class _UserVerification extends UserVerification {
  const factory _UserVerification(
      {@HiveField(0) @JsonKey(name: 'real_name') final String? realName,
      @HiveField(1) @JsonKey(name: 'id_card_number') final String? idCardNumber,
      @HiveField(2) @JsonKey(name: 'status') final String status,
      @HiveField(3)
      @JsonKey(name: 'verified_at')
      final String? verifiedAt}) = _$UserVerificationImpl;
  const _UserVerification._() : super._();

  factory _UserVerification.fromJson(Map<String, dynamic> json) =
      _$UserVerificationImpl.fromJson;

  @override
  @HiveField(0)
  @JsonKey(name: 'real_name')
  String? get realName;
  @override
  @HiveField(1)
  @JsonKey(name: 'id_card_number')
  String? get idCardNumber;
  @override
  @HiveField(2)
  @JsonKey(name: 'status')
  String get status;
  @override
  @HiveField(3)
  @JsonKey(name: 'verified_at')
  String? get verifiedAt;
  @override
  @JsonKey(ignore: true)
  _$$UserVerificationImplCopyWith<_$UserVerificationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AgentInfo _$AgentInfoFromJson(Map<String, dynamic> json) {
  return _AgentInfo.fromJson(json);
}

/// @nodoc
mixin _$AgentInfo {
  @HiveField(0)
  @JsonKey(name: 'agent_id')
  int get agentId => throw _privateConstructorUsedError;
  @HiveField(1)
  @JsonKey(name: 'status')
  String get status => throw _privateConstructorUsedError;
  @HiveField(2)
  @JsonKey(name: 'level')
  String get level => throw _privateConstructorUsedError;
  @HiveField(3)
  @JsonKey(name: 'company')
  CompanyInfo? get company => throw _privateConstructorUsedError;
  @HiveField(4)
  @JsonKey(name: 'work_city')
  String? get workCity => throw _privateConstructorUsedError;
  @HiveField(5)
  @JsonKey(name: 'rating')
  double get rating => throw _privateConstructorUsedError;
  @HiveField(6)
  @JsonKey(name: 'total_deals')
  int get totalDeals => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AgentInfoCopyWith<AgentInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AgentInfoCopyWith<$Res> {
  factory $AgentInfoCopyWith(AgentInfo value, $Res Function(AgentInfo) then) =
      _$AgentInfoCopyWithImpl<$Res, AgentInfo>;
  @useResult
  $Res call(
      {@HiveField(0) @JsonKey(name: 'agent_id') int agentId,
      @HiveField(1) @JsonKey(name: 'status') String status,
      @HiveField(2) @JsonKey(name: 'level') String level,
      @HiveField(3) @JsonKey(name: 'company') CompanyInfo? company,
      @HiveField(4) @JsonKey(name: 'work_city') String? workCity,
      @HiveField(5) @JsonKey(name: 'rating') double rating,
      @HiveField(6) @JsonKey(name: 'total_deals') int totalDeals});

  $CompanyInfoCopyWith<$Res>? get company;
}

/// @nodoc
class _$AgentInfoCopyWithImpl<$Res, $Val extends AgentInfo>
    implements $AgentInfoCopyWith<$Res> {
  _$AgentInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? agentId = null,
    Object? status = null,
    Object? level = null,
    Object? company = freezed,
    Object? workCity = freezed,
    Object? rating = null,
    Object? totalDeals = null,
  }) {
    return _then(_value.copyWith(
      agentId: null == agentId
          ? _value.agentId
          : agentId // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      level: null == level
          ? _value.level
          : level // ignore: cast_nullable_to_non_nullable
              as String,
      company: freezed == company
          ? _value.company
          : company // ignore: cast_nullable_to_non_nullable
              as CompanyInfo?,
      workCity: freezed == workCity
          ? _value.workCity
          : workCity // ignore: cast_nullable_to_non_nullable
              as String?,
      rating: null == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as double,
      totalDeals: null == totalDeals
          ? _value.totalDeals
          : totalDeals // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $CompanyInfoCopyWith<$Res>? get company {
    if (_value.company == null) {
      return null;
    }

    return $CompanyInfoCopyWith<$Res>(_value.company!, (value) {
      return _then(_value.copyWith(company: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AgentInfoImplCopyWith<$Res>
    implements $AgentInfoCopyWith<$Res> {
  factory _$$AgentInfoImplCopyWith(
          _$AgentInfoImpl value, $Res Function(_$AgentInfoImpl) then) =
      __$$AgentInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@HiveField(0) @JsonKey(name: 'agent_id') int agentId,
      @HiveField(1) @JsonKey(name: 'status') String status,
      @HiveField(2) @JsonKey(name: 'level') String level,
      @HiveField(3) @JsonKey(name: 'company') CompanyInfo? company,
      @HiveField(4) @JsonKey(name: 'work_city') String? workCity,
      @HiveField(5) @JsonKey(name: 'rating') double rating,
      @HiveField(6) @JsonKey(name: 'total_deals') int totalDeals});

  @override
  $CompanyInfoCopyWith<$Res>? get company;
}

/// @nodoc
class __$$AgentInfoImplCopyWithImpl<$Res>
    extends _$AgentInfoCopyWithImpl<$Res, _$AgentInfoImpl>
    implements _$$AgentInfoImplCopyWith<$Res> {
  __$$AgentInfoImplCopyWithImpl(
      _$AgentInfoImpl _value, $Res Function(_$AgentInfoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? agentId = null,
    Object? status = null,
    Object? level = null,
    Object? company = freezed,
    Object? workCity = freezed,
    Object? rating = null,
    Object? totalDeals = null,
  }) {
    return _then(_$AgentInfoImpl(
      agentId: null == agentId
          ? _value.agentId
          : agentId // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      level: null == level
          ? _value.level
          : level // ignore: cast_nullable_to_non_nullable
              as String,
      company: freezed == company
          ? _value.company
          : company // ignore: cast_nullable_to_non_nullable
              as CompanyInfo?,
      workCity: freezed == workCity
          ? _value.workCity
          : workCity // ignore: cast_nullable_to_non_nullable
              as String?,
      rating: null == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as double,
      totalDeals: null == totalDeals
          ? _value.totalDeals
          : totalDeals // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
@HiveType(typeId: 4)
class _$AgentInfoImpl implements _AgentInfo {
  const _$AgentInfoImpl(
      {@HiveField(0) @JsonKey(name: 'agent_id') required this.agentId,
      @HiveField(1) @JsonKey(name: 'status') this.status = 'active',
      @HiveField(2) @JsonKey(name: 'level') this.level = 'junior',
      @HiveField(3) @JsonKey(name: 'company') this.company,
      @HiveField(4) @JsonKey(name: 'work_city') this.workCity,
      @HiveField(5) @JsonKey(name: 'rating') this.rating = 0.0,
      @HiveField(6) @JsonKey(name: 'total_deals') this.totalDeals = 0});

  factory _$AgentInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$AgentInfoImplFromJson(json);

  @override
  @HiveField(0)
  @JsonKey(name: 'agent_id')
  final int agentId;
  @override
  @HiveField(1)
  @JsonKey(name: 'status')
  final String status;
  @override
  @HiveField(2)
  @JsonKey(name: 'level')
  final String level;
  @override
  @HiveField(3)
  @JsonKey(name: 'company')
  final CompanyInfo? company;
  @override
  @HiveField(4)
  @JsonKey(name: 'work_city')
  final String? workCity;
  @override
  @HiveField(5)
  @JsonKey(name: 'rating')
  final double rating;
  @override
  @HiveField(6)
  @JsonKey(name: 'total_deals')
  final int totalDeals;

  @override
  String toString() {
    return 'AgentInfo(agentId: $agentId, status: $status, level: $level, company: $company, workCity: $workCity, rating: $rating, totalDeals: $totalDeals)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AgentInfoImpl &&
            (identical(other.agentId, agentId) || other.agentId == agentId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.level, level) || other.level == level) &&
            (identical(other.company, company) || other.company == company) &&
            (identical(other.workCity, workCity) ||
                other.workCity == workCity) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.totalDeals, totalDeals) ||
                other.totalDeals == totalDeals));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, agentId, status, level, company,
      workCity, rating, totalDeals);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AgentInfoImplCopyWith<_$AgentInfoImpl> get copyWith =>
      __$$AgentInfoImplCopyWithImpl<_$AgentInfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AgentInfoImplToJson(
      this,
    );
  }
}

abstract class _AgentInfo implements AgentInfo {
  const factory _AgentInfo(
          {@HiveField(0) @JsonKey(name: 'agent_id') required final int agentId,
          @HiveField(1) @JsonKey(name: 'status') final String status,
          @HiveField(2) @JsonKey(name: 'level') final String level,
          @HiveField(3) @JsonKey(name: 'company') final CompanyInfo? company,
          @HiveField(4) @JsonKey(name: 'work_city') final String? workCity,
          @HiveField(5) @JsonKey(name: 'rating') final double rating,
          @HiveField(6) @JsonKey(name: 'total_deals') final int totalDeals}) =
      _$AgentInfoImpl;

  factory _AgentInfo.fromJson(Map<String, dynamic> json) =
      _$AgentInfoImpl.fromJson;

  @override
  @HiveField(0)
  @JsonKey(name: 'agent_id')
  int get agentId;
  @override
  @HiveField(1)
  @JsonKey(name: 'status')
  String get status;
  @override
  @HiveField(2)
  @JsonKey(name: 'level')
  String get level;
  @override
  @HiveField(3)
  @JsonKey(name: 'company')
  CompanyInfo? get company;
  @override
  @HiveField(4)
  @JsonKey(name: 'work_city')
  String? get workCity;
  @override
  @HiveField(5)
  @JsonKey(name: 'rating')
  double get rating;
  @override
  @HiveField(6)
  @JsonKey(name: 'total_deals')
  int get totalDeals;
  @override
  @JsonKey(ignore: true)
  _$$AgentInfoImplCopyWith<_$AgentInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CompanyInfo _$CompanyInfoFromJson(Map<String, dynamic> json) {
  return _CompanyInfo.fromJson(json);
}

/// @nodoc
mixin _$CompanyInfo {
  @JsonKey(name: 'id')
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'name')
  String get name => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CompanyInfoCopyWith<CompanyInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CompanyInfoCopyWith<$Res> {
  factory $CompanyInfoCopyWith(
          CompanyInfo value, $Res Function(CompanyInfo) then) =
      _$CompanyInfoCopyWithImpl<$Res, CompanyInfo>;
  @useResult
  $Res call({@JsonKey(name: 'id') int id, @JsonKey(name: 'name') String name});
}

/// @nodoc
class _$CompanyInfoCopyWithImpl<$Res, $Val extends CompanyInfo>
    implements $CompanyInfoCopyWith<$Res> {
  _$CompanyInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CompanyInfoImplCopyWith<$Res>
    implements $CompanyInfoCopyWith<$Res> {
  factory _$$CompanyInfoImplCopyWith(
          _$CompanyInfoImpl value, $Res Function(_$CompanyInfoImpl) then) =
      __$$CompanyInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({@JsonKey(name: 'id') int id, @JsonKey(name: 'name') String name});
}

/// @nodoc
class __$$CompanyInfoImplCopyWithImpl<$Res>
    extends _$CompanyInfoCopyWithImpl<$Res, _$CompanyInfoImpl>
    implements _$$CompanyInfoImplCopyWith<$Res> {
  __$$CompanyInfoImplCopyWithImpl(
      _$CompanyInfoImpl _value, $Res Function(_$CompanyInfoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
  }) {
    return _then(_$CompanyInfoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CompanyInfoImpl implements _CompanyInfo {
  const _$CompanyInfoImpl(
      {@JsonKey(name: 'id') required this.id,
      @JsonKey(name: 'name') required this.name});

  factory _$CompanyInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$CompanyInfoImplFromJson(json);

  @override
  @JsonKey(name: 'id')
  final int id;
  @override
  @JsonKey(name: 'name')
  final String name;

  @override
  String toString() {
    return 'CompanyInfo(id: $id, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CompanyInfoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, name);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CompanyInfoImplCopyWith<_$CompanyInfoImpl> get copyWith =>
      __$$CompanyInfoImplCopyWithImpl<_$CompanyInfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CompanyInfoImplToJson(
      this,
    );
  }
}

abstract class _CompanyInfo implements CompanyInfo {
  const factory _CompanyInfo(
      {@JsonKey(name: 'id') required final int id,
      @JsonKey(name: 'name') required final String name}) = _$CompanyInfoImpl;

  factory _CompanyInfo.fromJson(Map<String, dynamic> json) =
      _$CompanyInfoImpl.fromJson;

  @override
  @JsonKey(name: 'id')
  int get id;
  @override
  @JsonKey(name: 'name')
  String get name;
  @override
  @JsonKey(ignore: true)
  _$$CompanyInfoImplCopyWith<_$CompanyInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LoginResponse _$LoginResponseFromJson(Map<String, dynamic> json) {
  return _LoginResponse.fromJson(json);
}

/// @nodoc
mixin _$LoginResponse {
  @JsonKey(name: 'user_id', fromJson: _userIdFromJson)
  int get userId => throw _privateConstructorUsedError;
  @JsonKey(name: 'token')
  String get token => throw _privateConstructorUsedError;
  @JsonKey(name: 'refresh_token')
  String? get refreshToken => throw _privateConstructorUsedError;
  @JsonKey(name: 'expires_at', fromJson: _expiresAtFromJson)
  int? get expiresAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_new_user')
  bool get isNewUser => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $LoginResponseCopyWith<LoginResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LoginResponseCopyWith<$Res> {
  factory $LoginResponseCopyWith(
          LoginResponse value, $Res Function(LoginResponse) then) =
      _$LoginResponseCopyWithImpl<$Res, LoginResponse>;
  @useResult
  $Res call(
      {@JsonKey(name: 'user_id', fromJson: _userIdFromJson) int userId,
      @JsonKey(name: 'token') String token,
      @JsonKey(name: 'refresh_token') String? refreshToken,
      @JsonKey(name: 'expires_at', fromJson: _expiresAtFromJson) int? expiresAt,
      @JsonKey(name: 'is_new_user') bool isNewUser});
}

/// @nodoc
class _$LoginResponseCopyWithImpl<$Res, $Val extends LoginResponse>
    implements $LoginResponseCopyWith<$Res> {
  _$LoginResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? token = null,
    Object? refreshToken = freezed,
    Object? expiresAt = freezed,
    Object? isNewUser = null,
  }) {
    return _then(_value.copyWith(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as int,
      token: null == token
          ? _value.token
          : token // ignore: cast_nullable_to_non_nullable
              as String,
      refreshToken: freezed == refreshToken
          ? _value.refreshToken
          : refreshToken // ignore: cast_nullable_to_non_nullable
              as String?,
      expiresAt: freezed == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as int?,
      isNewUser: null == isNewUser
          ? _value.isNewUser
          : isNewUser // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LoginResponseImplCopyWith<$Res>
    implements $LoginResponseCopyWith<$Res> {
  factory _$$LoginResponseImplCopyWith(
          _$LoginResponseImpl value, $Res Function(_$LoginResponseImpl) then) =
      __$$LoginResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'user_id', fromJson: _userIdFromJson) int userId,
      @JsonKey(name: 'token') String token,
      @JsonKey(name: 'refresh_token') String? refreshToken,
      @JsonKey(name: 'expires_at', fromJson: _expiresAtFromJson) int? expiresAt,
      @JsonKey(name: 'is_new_user') bool isNewUser});
}

/// @nodoc
class __$$LoginResponseImplCopyWithImpl<$Res>
    extends _$LoginResponseCopyWithImpl<$Res, _$LoginResponseImpl>
    implements _$$LoginResponseImplCopyWith<$Res> {
  __$$LoginResponseImplCopyWithImpl(
      _$LoginResponseImpl _value, $Res Function(_$LoginResponseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? token = null,
    Object? refreshToken = freezed,
    Object? expiresAt = freezed,
    Object? isNewUser = null,
  }) {
    return _then(_$LoginResponseImpl(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as int,
      token: null == token
          ? _value.token
          : token // ignore: cast_nullable_to_non_nullable
              as String,
      refreshToken: freezed == refreshToken
          ? _value.refreshToken
          : refreshToken // ignore: cast_nullable_to_non_nullable
              as String?,
      expiresAt: freezed == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as int?,
      isNewUser: null == isNewUser
          ? _value.isNewUser
          : isNewUser // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LoginResponseImpl implements _LoginResponse {
  const _$LoginResponseImpl(
      {@JsonKey(name: 'user_id', fromJson: _userIdFromJson)
      required this.userId,
      @JsonKey(name: 'token') required this.token,
      @JsonKey(name: 'refresh_token') this.refreshToken,
      @JsonKey(name: 'expires_at', fromJson: _expiresAtFromJson) this.expiresAt,
      @JsonKey(name: 'is_new_user') this.isNewUser = false});

  factory _$LoginResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$LoginResponseImplFromJson(json);

  @override
  @JsonKey(name: 'user_id', fromJson: _userIdFromJson)
  final int userId;
  @override
  @JsonKey(name: 'token')
  final String token;
  @override
  @JsonKey(name: 'refresh_token')
  final String? refreshToken;
  @override
  @JsonKey(name: 'expires_at', fromJson: _expiresAtFromJson)
  final int? expiresAt;
  @override
  @JsonKey(name: 'is_new_user')
  final bool isNewUser;

  @override
  String toString() {
    return 'LoginResponse(userId: $userId, token: $token, refreshToken: $refreshToken, expiresAt: $expiresAt, isNewUser: $isNewUser)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoginResponseImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.token, token) || other.token == token) &&
            (identical(other.refreshToken, refreshToken) ||
                other.refreshToken == refreshToken) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            (identical(other.isNewUser, isNewUser) ||
                other.isNewUser == isNewUser));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, userId, token, refreshToken, expiresAt, isNewUser);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LoginResponseImplCopyWith<_$LoginResponseImpl> get copyWith =>
      __$$LoginResponseImplCopyWithImpl<_$LoginResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LoginResponseImplToJson(
      this,
    );
  }
}

abstract class _LoginResponse implements LoginResponse {
  const factory _LoginResponse(
          {@JsonKey(name: 'user_id', fromJson: _userIdFromJson)
          required final int userId,
          @JsonKey(name: 'token') required final String token,
          @JsonKey(name: 'refresh_token') final String? refreshToken,
          @JsonKey(name: 'expires_at', fromJson: _expiresAtFromJson)
          final int? expiresAt,
          @JsonKey(name: 'is_new_user') final bool isNewUser}) =
      _$LoginResponseImpl;

  factory _LoginResponse.fromJson(Map<String, dynamic> json) =
      _$LoginResponseImpl.fromJson;

  @override
  @JsonKey(name: 'user_id', fromJson: _userIdFromJson)
  int get userId;
  @override
  @JsonKey(name: 'token')
  String get token;
  @override
  @JsonKey(name: 'refresh_token')
  String? get refreshToken;
  @override
  @JsonKey(name: 'expires_at', fromJson: _expiresAtFromJson)
  int? get expiresAt;
  @override
  @JsonKey(name: 'is_new_user')
  bool get isNewUser;
  @override
  @JsonKey(ignore: true)
  _$$LoginResponseImplCopyWith<_$LoginResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SendCodeResponse _$SendCodeResponseFromJson(Map<String, dynamic> json) {
  return _SendCodeResponse.fromJson(json);
}

/// @nodoc
mixin _$SendCodeResponse {
  @JsonKey(name: 'code')
  String? get code => throw _privateConstructorUsedError;
  @JsonKey(name: 'expired_at', fromJson: _expiredAtFromJson)
  int get expiredAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'interval', fromJson: _intervalFromJson)
  int get interval => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SendCodeResponseCopyWith<SendCodeResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SendCodeResponseCopyWith<$Res> {
  factory $SendCodeResponseCopyWith(
          SendCodeResponse value, $Res Function(SendCodeResponse) then) =
      _$SendCodeResponseCopyWithImpl<$Res, SendCodeResponse>;
  @useResult
  $Res call(
      {@JsonKey(name: 'code') String? code,
      @JsonKey(name: 'expired_at', fromJson: _expiredAtFromJson) int expiredAt,
      @JsonKey(name: 'interval', fromJson: _intervalFromJson) int interval});
}

/// @nodoc
class _$SendCodeResponseCopyWithImpl<$Res, $Val extends SendCodeResponse>
    implements $SendCodeResponseCopyWith<$Res> {
  _$SendCodeResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = freezed,
    Object? expiredAt = null,
    Object? interval = null,
  }) {
    return _then(_value.copyWith(
      code: freezed == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String?,
      expiredAt: null == expiredAt
          ? _value.expiredAt
          : expiredAt // ignore: cast_nullable_to_non_nullable
              as int,
      interval: null == interval
          ? _value.interval
          : interval // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SendCodeResponseImplCopyWith<$Res>
    implements $SendCodeResponseCopyWith<$Res> {
  factory _$$SendCodeResponseImplCopyWith(_$SendCodeResponseImpl value,
          $Res Function(_$SendCodeResponseImpl) then) =
      __$$SendCodeResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'code') String? code,
      @JsonKey(name: 'expired_at', fromJson: _expiredAtFromJson) int expiredAt,
      @JsonKey(name: 'interval', fromJson: _intervalFromJson) int interval});
}

/// @nodoc
class __$$SendCodeResponseImplCopyWithImpl<$Res>
    extends _$SendCodeResponseCopyWithImpl<$Res, _$SendCodeResponseImpl>
    implements _$$SendCodeResponseImplCopyWith<$Res> {
  __$$SendCodeResponseImplCopyWithImpl(_$SendCodeResponseImpl _value,
      $Res Function(_$SendCodeResponseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = freezed,
    Object? expiredAt = null,
    Object? interval = null,
  }) {
    return _then(_$SendCodeResponseImpl(
      code: freezed == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String?,
      expiredAt: null == expiredAt
          ? _value.expiredAt
          : expiredAt // ignore: cast_nullable_to_non_nullable
              as int,
      interval: null == interval
          ? _value.interval
          : interval // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SendCodeResponseImpl implements _SendCodeResponse {
  const _$SendCodeResponseImpl(
      {@JsonKey(name: 'code') this.code,
      @JsonKey(name: 'expired_at', fromJson: _expiredAtFromJson)
      required this.expiredAt,
      @JsonKey(name: 'interval', fromJson: _intervalFromJson)
      this.interval = 60});

  factory _$SendCodeResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$SendCodeResponseImplFromJson(json);

  @override
  @JsonKey(name: 'code')
  final String? code;
  @override
  @JsonKey(name: 'expired_at', fromJson: _expiredAtFromJson)
  final int expiredAt;
  @override
  @JsonKey(name: 'interval', fromJson: _intervalFromJson)
  final int interval;

  @override
  String toString() {
    return 'SendCodeResponse(code: $code, expiredAt: $expiredAt, interval: $interval)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SendCodeResponseImpl &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.expiredAt, expiredAt) ||
                other.expiredAt == expiredAt) &&
            (identical(other.interval, interval) ||
                other.interval == interval));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, code, expiredAt, interval);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SendCodeResponseImplCopyWith<_$SendCodeResponseImpl> get copyWith =>
      __$$SendCodeResponseImplCopyWithImpl<_$SendCodeResponseImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SendCodeResponseImplToJson(
      this,
    );
  }
}

abstract class _SendCodeResponse implements SendCodeResponse {
  const factory _SendCodeResponse(
      {@JsonKey(name: 'code') final String? code,
      @JsonKey(name: 'expired_at', fromJson: _expiredAtFromJson)
      required final int expiredAt,
      @JsonKey(name: 'interval', fromJson: _intervalFromJson)
      final int interval}) = _$SendCodeResponseImpl;

  factory _SendCodeResponse.fromJson(Map<String, dynamic> json) =
      _$SendCodeResponseImpl.fromJson;

  @override
  @JsonKey(name: 'code')
  String? get code;
  @override
  @JsonKey(name: 'expired_at', fromJson: _expiredAtFromJson)
  int get expiredAt;
  @override
  @JsonKey(name: 'interval', fromJson: _intervalFromJson)
  int get interval;
  @override
  @JsonKey(ignore: true)
  _$$SendCodeResponseImplCopyWith<_$SendCodeResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
