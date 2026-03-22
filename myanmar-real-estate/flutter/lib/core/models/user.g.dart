// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserProfileImplAdapter extends TypeAdapter<_$UserProfileImpl> {
  @override
  final int typeId = 2;

  @override
  _$UserProfileImpl read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return _$UserProfileImpl(
      nickname: fields[0] as String?,
      avatar: fields[1] as String?,
      gender: fields[2] as String?,
      birthday: fields[3] as String?,
      bio: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, _$UserProfileImpl obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.nickname)
      ..writeByte(1)
      ..write(obj.avatar)
      ..writeByte(2)
      ..write(obj.gender)
      ..writeByte(3)
      ..write(obj.birthday)
      ..writeByte(4)
      ..write(obj.bio);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfileImplAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AgentInfoImplAdapter extends TypeAdapter<_$AgentInfoImpl> {
  @override
  final int typeId = 4;

  @override
  _$AgentInfoImpl read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return _$AgentInfoImpl(
      agentId: fields[0] as int,
      status: fields[1] as String,
      level: fields[2] as String,
      company: fields[3] as CompanyInfo?,
      workCity: fields[4] as String?,
      rating: fields[5] as double,
      totalDeals: fields[6] as int,
    );
  }

  @override
  void write(BinaryWriter writer, _$AgentInfoImpl obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.agentId)
      ..writeByte(1)
      ..write(obj.status)
      ..writeByte(2)
      ..write(obj.level)
      ..writeByte(3)
      ..write(obj.company)
      ..writeByte(4)
      ..write(obj.workCity)
      ..writeByte(5)
      ..write(obj.rating)
      ..writeByte(6)
      ..write(obj.totalDeals);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AgentInfoImplAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserImpl _$$UserImplFromJson(Map<String, dynamic> json) => _$UserImpl(
      userId: (json['user_id'] as num).toInt(),
      uuid: json['uuid'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String?,
      status: json['status'] as String? ?? 'active',
      isVerified: json['is_verified'] as bool? ?? false,
      profile: json['profile'] == null
          ? null
          : UserProfile.fromJson(json['profile'] as Map<String, dynamic>),
      verification: json['verification'] == null
          ? null
          : UserVerification.fromJson(
              json['verification'] as Map<String, dynamic>),
      agentInfo: json['agent_info'] == null
          ? null
          : AgentInfo.fromJson(json['agent_info'] as Map<String, dynamic>),
      token: json['token'] as String?,
      expiresAt: (json['expires_at'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$UserImplToJson(_$UserImpl instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'uuid': instance.uuid,
      'phone': instance.phone,
      'email': instance.email,
      'status': instance.status,
      'is_verified': instance.isVerified,
      'profile': instance.profile,
      'verification': instance.verification,
      'agent_info': instance.agentInfo,
      'token': instance.token,
      'expires_at': instance.expiresAt,
    };

_$UserProfileImpl _$$UserProfileImplFromJson(Map<String, dynamic> json) =>
    _$UserProfileImpl(
      nickname: json['nickname'] as String?,
      avatar: json['avatar'] as String?,
      gender: json['gender'] as String?,
      birthday: json['birthday'] as String?,
      bio: json['bio'] as String?,
    );

Map<String, dynamic> _$$UserProfileImplToJson(_$UserProfileImpl instance) =>
    <String, dynamic>{
      'nickname': instance.nickname,
      'avatar': instance.avatar,
      'gender': instance.gender,
      'birthday': instance.birthday,
      'bio': instance.bio,
    };

_$UserVerificationImpl _$$UserVerificationImplFromJson(
        Map<String, dynamic> json) =>
    _$UserVerificationImpl(
      realName: json['real_name'] as String?,
      idCardNumber: json['id_card_number'] as String?,
      status: json['status'] as String? ?? 'pending',
      verifiedAt: json['verified_at'] as String?,
    );

Map<String, dynamic> _$$UserVerificationImplToJson(
        _$UserVerificationImpl instance) =>
    <String, dynamic>{
      'real_name': instance.realName,
      'id_card_number': instance.idCardNumber,
      'status': instance.status,
      'verified_at': instance.verifiedAt,
    };

_$AgentInfoImpl _$$AgentInfoImplFromJson(Map<String, dynamic> json) =>
    _$AgentInfoImpl(
      agentId: (json['agent_id'] as num).toInt(),
      status: json['status'] as String? ?? 'active',
      level: json['level'] as String? ?? 'junior',
      company: json['company'] == null
          ? null
          : CompanyInfo.fromJson(json['company'] as Map<String, dynamic>),
      workCity: json['work_city'] as String?,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      totalDeals: (json['total_deals'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$AgentInfoImplToJson(_$AgentInfoImpl instance) =>
    <String, dynamic>{
      'agent_id': instance.agentId,
      'status': instance.status,
      'level': instance.level,
      'company': instance.company,
      'work_city': instance.workCity,
      'rating': instance.rating,
      'total_deals': instance.totalDeals,
    };

_$CompanyInfoImpl _$$CompanyInfoImplFromJson(Map<String, dynamic> json) =>
    _$CompanyInfoImpl(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
    );

Map<String, dynamic> _$$CompanyInfoImplToJson(_$CompanyInfoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
    };

_$LoginResponseImpl _$$LoginResponseImplFromJson(Map<String, dynamic> json) =>
    _$LoginResponseImpl(
      userId: _userIdFromJson(json['user_id']),
      token: json['token'] as String,
      refreshToken: json['refresh_token'] as String?,
      expiresAt: _expiresAtFromJson(json['expires_at']),
      isNewUser: json['is_new_user'] as bool? ?? false,
    );

Map<String, dynamic> _$$LoginResponseImplToJson(_$LoginResponseImpl instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'token': instance.token,
      'refresh_token': instance.refreshToken,
      'expires_at': instance.expiresAt,
      'is_new_user': instance.isNewUser,
    };

_$SendCodeResponseImpl _$$SendCodeResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$SendCodeResponseImpl(
      code: json['code'] as String?,
      expiredAt: _expiredAtFromJson(json['expired_at']),
      interval:
          json['interval'] == null ? 60 : _intervalFromJson(json['interval']),
    );

Map<String, dynamic> _$$SendCodeResponseImplToJson(
        _$SendCodeResponseImpl instance) =>
    <String, dynamic>{
      'code': instance.code,
      'expired_at': instance.expiredAt,
      'interval': instance.interval,
    };
