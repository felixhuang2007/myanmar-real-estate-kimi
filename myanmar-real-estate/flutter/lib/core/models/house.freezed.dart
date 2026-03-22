// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'house.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

House _$HouseFromJson(Map<String, dynamic> json) {
  return _House.fromJson(json);
}

/// @nodoc
mixin _$House {
  @JsonKey(name: 'house_id')
  int get houseId => throw _privateConstructorUsedError;
  @JsonKey(name: 'house_code')
  String? get houseCode => throw _privateConstructorUsedError;
  @JsonKey(name: 'title')
  String get title => throw _privateConstructorUsedError;
  @JsonKey(name: 'title_my')
  String? get titleMy => throw _privateConstructorUsedError;
  @JsonKey(name: 'transaction_type')
  String get transactionType => throw _privateConstructorUsedError;
  @JsonKey(name: 'price')
  int get price => throw _privateConstructorUsedError;
  @JsonKey(name: 'price_unit')
  String get priceUnit => throw _privateConstructorUsedError;
  @JsonKey(name: 'price_note')
  String? get priceNote => throw _privateConstructorUsedError;
  @JsonKey(name: 'house_type')
  String get houseType => throw _privateConstructorUsedError;
  @JsonKey(name: 'property_type')
  String? get propertyType => throw _privateConstructorUsedError;
  @JsonKey(name: 'area')
  double? get area => throw _privateConstructorUsedError;
  @JsonKey(name: 'usable_area')
  double? get usableArea => throw _privateConstructorUsedError;
  @JsonKey(name: 'rooms')
  String? get rooms => throw _privateConstructorUsedError;
  @JsonKey(name: 'bedrooms')
  int? get bedrooms => throw _privateConstructorUsedError;
  @JsonKey(name: 'living_rooms')
  int? get livingRooms => throw _privateConstructorUsedError;
  @JsonKey(name: 'bathrooms')
  int? get bathrooms => throw _privateConstructorUsedError;
  @JsonKey(name: 'floor')
  String? get floor => throw _privateConstructorUsedError;
  @JsonKey(name: 'decoration')
  String? get decoration => throw _privateConstructorUsedError;
  @JsonKey(name: 'orientation')
  String? get orientation => throw _privateConstructorUsedError;
  @JsonKey(name: 'build_year')
  int? get buildYear => throw _privateConstructorUsedError;
  @JsonKey(name: 'location')
  HouseLocation? get location => throw _privateConstructorUsedError;
  @JsonKey(name: 'description')
  String? get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'highlights')
  List<String>? get highlights => throw _privateConstructorUsedError;
  @JsonKey(name: 'facilities')
  List<String>? get facilities => throw _privateConstructorUsedError;
  @JsonKey(name: 'property')
  PropertyInfo? get property => throw _privateConstructorUsedError;
  @JsonKey(name: 'verification')
  VerificationInfo? get verification => throw _privateConstructorUsedError;
  @JsonKey(name: 'images')
  List<HouseImage> get images => throw _privateConstructorUsedError;
  @JsonKey(name: 'agent')
  AgentBrief? get agent => throw _privateConstructorUsedError;
  @JsonKey(name: 'stats')
  HouseStats? get stats => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_favorited')
  bool get isFavorited => throw _privateConstructorUsedError;
  @JsonKey(name: 'status')
  String get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  String? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'published_at')
  String? get publishedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $HouseCopyWith<House> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HouseCopyWith<$Res> {
  factory $HouseCopyWith(House value, $Res Function(House) then) =
      _$HouseCopyWithImpl<$Res, House>;
  @useResult
  $Res call(
      {@JsonKey(name: 'house_id') int houseId,
      @JsonKey(name: 'house_code') String? houseCode,
      @JsonKey(name: 'title') String title,
      @JsonKey(name: 'title_my') String? titleMy,
      @JsonKey(name: 'transaction_type') String transactionType,
      @JsonKey(name: 'price') int price,
      @JsonKey(name: 'price_unit') String priceUnit,
      @JsonKey(name: 'price_note') String? priceNote,
      @JsonKey(name: 'house_type') String houseType,
      @JsonKey(name: 'property_type') String? propertyType,
      @JsonKey(name: 'area') double? area,
      @JsonKey(name: 'usable_area') double? usableArea,
      @JsonKey(name: 'rooms') String? rooms,
      @JsonKey(name: 'bedrooms') int? bedrooms,
      @JsonKey(name: 'living_rooms') int? livingRooms,
      @JsonKey(name: 'bathrooms') int? bathrooms,
      @JsonKey(name: 'floor') String? floor,
      @JsonKey(name: 'decoration') String? decoration,
      @JsonKey(name: 'orientation') String? orientation,
      @JsonKey(name: 'build_year') int? buildYear,
      @JsonKey(name: 'location') HouseLocation? location,
      @JsonKey(name: 'description') String? description,
      @JsonKey(name: 'highlights') List<String>? highlights,
      @JsonKey(name: 'facilities') List<String>? facilities,
      @JsonKey(name: 'property') PropertyInfo? property,
      @JsonKey(name: 'verification') VerificationInfo? verification,
      @JsonKey(name: 'images') List<HouseImage> images,
      @JsonKey(name: 'agent') AgentBrief? agent,
      @JsonKey(name: 'stats') HouseStats? stats,
      @JsonKey(name: 'is_favorited') bool isFavorited,
      @JsonKey(name: 'status') String status,
      @JsonKey(name: 'created_at') String? createdAt,
      @JsonKey(name: 'published_at') String? publishedAt});

  $HouseLocationCopyWith<$Res>? get location;
  $PropertyInfoCopyWith<$Res>? get property;
  $VerificationInfoCopyWith<$Res>? get verification;
  $AgentBriefCopyWith<$Res>? get agent;
  $HouseStatsCopyWith<$Res>? get stats;
}

/// @nodoc
class _$HouseCopyWithImpl<$Res, $Val extends House>
    implements $HouseCopyWith<$Res> {
  _$HouseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? houseId = null,
    Object? houseCode = freezed,
    Object? title = null,
    Object? titleMy = freezed,
    Object? transactionType = null,
    Object? price = null,
    Object? priceUnit = null,
    Object? priceNote = freezed,
    Object? houseType = null,
    Object? propertyType = freezed,
    Object? area = freezed,
    Object? usableArea = freezed,
    Object? rooms = freezed,
    Object? bedrooms = freezed,
    Object? livingRooms = freezed,
    Object? bathrooms = freezed,
    Object? floor = freezed,
    Object? decoration = freezed,
    Object? orientation = freezed,
    Object? buildYear = freezed,
    Object? location = freezed,
    Object? description = freezed,
    Object? highlights = freezed,
    Object? facilities = freezed,
    Object? property = freezed,
    Object? verification = freezed,
    Object? images = null,
    Object? agent = freezed,
    Object? stats = freezed,
    Object? isFavorited = null,
    Object? status = null,
    Object? createdAt = freezed,
    Object? publishedAt = freezed,
  }) {
    return _then(_value.copyWith(
      houseId: null == houseId
          ? _value.houseId
          : houseId // ignore: cast_nullable_to_non_nullable
              as int,
      houseCode: freezed == houseCode
          ? _value.houseCode
          : houseCode // ignore: cast_nullable_to_non_nullable
              as String?,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      titleMy: freezed == titleMy
          ? _value.titleMy
          : titleMy // ignore: cast_nullable_to_non_nullable
              as String?,
      transactionType: null == transactionType
          ? _value.transactionType
          : transactionType // ignore: cast_nullable_to_non_nullable
              as String,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as int,
      priceUnit: null == priceUnit
          ? _value.priceUnit
          : priceUnit // ignore: cast_nullable_to_non_nullable
              as String,
      priceNote: freezed == priceNote
          ? _value.priceNote
          : priceNote // ignore: cast_nullable_to_non_nullable
              as String?,
      houseType: null == houseType
          ? _value.houseType
          : houseType // ignore: cast_nullable_to_non_nullable
              as String,
      propertyType: freezed == propertyType
          ? _value.propertyType
          : propertyType // ignore: cast_nullable_to_non_nullable
              as String?,
      area: freezed == area
          ? _value.area
          : area // ignore: cast_nullable_to_non_nullable
              as double?,
      usableArea: freezed == usableArea
          ? _value.usableArea
          : usableArea // ignore: cast_nullable_to_non_nullable
              as double?,
      rooms: freezed == rooms
          ? _value.rooms
          : rooms // ignore: cast_nullable_to_non_nullable
              as String?,
      bedrooms: freezed == bedrooms
          ? _value.bedrooms
          : bedrooms // ignore: cast_nullable_to_non_nullable
              as int?,
      livingRooms: freezed == livingRooms
          ? _value.livingRooms
          : livingRooms // ignore: cast_nullable_to_non_nullable
              as int?,
      bathrooms: freezed == bathrooms
          ? _value.bathrooms
          : bathrooms // ignore: cast_nullable_to_non_nullable
              as int?,
      floor: freezed == floor
          ? _value.floor
          : floor // ignore: cast_nullable_to_non_nullable
              as String?,
      decoration: freezed == decoration
          ? _value.decoration
          : decoration // ignore: cast_nullable_to_non_nullable
              as String?,
      orientation: freezed == orientation
          ? _value.orientation
          : orientation // ignore: cast_nullable_to_non_nullable
              as String?,
      buildYear: freezed == buildYear
          ? _value.buildYear
          : buildYear // ignore: cast_nullable_to_non_nullable
              as int?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as HouseLocation?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      highlights: freezed == highlights
          ? _value.highlights
          : highlights // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      facilities: freezed == facilities
          ? _value.facilities
          : facilities // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      property: freezed == property
          ? _value.property
          : property // ignore: cast_nullable_to_non_nullable
              as PropertyInfo?,
      verification: freezed == verification
          ? _value.verification
          : verification // ignore: cast_nullable_to_non_nullable
              as VerificationInfo?,
      images: null == images
          ? _value.images
          : images // ignore: cast_nullable_to_non_nullable
              as List<HouseImage>,
      agent: freezed == agent
          ? _value.agent
          : agent // ignore: cast_nullable_to_non_nullable
              as AgentBrief?,
      stats: freezed == stats
          ? _value.stats
          : stats // ignore: cast_nullable_to_non_nullable
              as HouseStats?,
      isFavorited: null == isFavorited
          ? _value.isFavorited
          : isFavorited // ignore: cast_nullable_to_non_nullable
              as bool,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
      publishedAt: freezed == publishedAt
          ? _value.publishedAt
          : publishedAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $HouseLocationCopyWith<$Res>? get location {
    if (_value.location == null) {
      return null;
    }

    return $HouseLocationCopyWith<$Res>(_value.location!, (value) {
      return _then(_value.copyWith(location: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $PropertyInfoCopyWith<$Res>? get property {
    if (_value.property == null) {
      return null;
    }

    return $PropertyInfoCopyWith<$Res>(_value.property!, (value) {
      return _then(_value.copyWith(property: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $VerificationInfoCopyWith<$Res>? get verification {
    if (_value.verification == null) {
      return null;
    }

    return $VerificationInfoCopyWith<$Res>(_value.verification!, (value) {
      return _then(_value.copyWith(verification: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $AgentBriefCopyWith<$Res>? get agent {
    if (_value.agent == null) {
      return null;
    }

    return $AgentBriefCopyWith<$Res>(_value.agent!, (value) {
      return _then(_value.copyWith(agent: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $HouseStatsCopyWith<$Res>? get stats {
    if (_value.stats == null) {
      return null;
    }

    return $HouseStatsCopyWith<$Res>(_value.stats!, (value) {
      return _then(_value.copyWith(stats: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$HouseImplCopyWith<$Res> implements $HouseCopyWith<$Res> {
  factory _$$HouseImplCopyWith(
          _$HouseImpl value, $Res Function(_$HouseImpl) then) =
      __$$HouseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'house_id') int houseId,
      @JsonKey(name: 'house_code') String? houseCode,
      @JsonKey(name: 'title') String title,
      @JsonKey(name: 'title_my') String? titleMy,
      @JsonKey(name: 'transaction_type') String transactionType,
      @JsonKey(name: 'price') int price,
      @JsonKey(name: 'price_unit') String priceUnit,
      @JsonKey(name: 'price_note') String? priceNote,
      @JsonKey(name: 'house_type') String houseType,
      @JsonKey(name: 'property_type') String? propertyType,
      @JsonKey(name: 'area') double? area,
      @JsonKey(name: 'usable_area') double? usableArea,
      @JsonKey(name: 'rooms') String? rooms,
      @JsonKey(name: 'bedrooms') int? bedrooms,
      @JsonKey(name: 'living_rooms') int? livingRooms,
      @JsonKey(name: 'bathrooms') int? bathrooms,
      @JsonKey(name: 'floor') String? floor,
      @JsonKey(name: 'decoration') String? decoration,
      @JsonKey(name: 'orientation') String? orientation,
      @JsonKey(name: 'build_year') int? buildYear,
      @JsonKey(name: 'location') HouseLocation? location,
      @JsonKey(name: 'description') String? description,
      @JsonKey(name: 'highlights') List<String>? highlights,
      @JsonKey(name: 'facilities') List<String>? facilities,
      @JsonKey(name: 'property') PropertyInfo? property,
      @JsonKey(name: 'verification') VerificationInfo? verification,
      @JsonKey(name: 'images') List<HouseImage> images,
      @JsonKey(name: 'agent') AgentBrief? agent,
      @JsonKey(name: 'stats') HouseStats? stats,
      @JsonKey(name: 'is_favorited') bool isFavorited,
      @JsonKey(name: 'status') String status,
      @JsonKey(name: 'created_at') String? createdAt,
      @JsonKey(name: 'published_at') String? publishedAt});

  @override
  $HouseLocationCopyWith<$Res>? get location;
  @override
  $PropertyInfoCopyWith<$Res>? get property;
  @override
  $VerificationInfoCopyWith<$Res>? get verification;
  @override
  $AgentBriefCopyWith<$Res>? get agent;
  @override
  $HouseStatsCopyWith<$Res>? get stats;
}

/// @nodoc
class __$$HouseImplCopyWithImpl<$Res>
    extends _$HouseCopyWithImpl<$Res, _$HouseImpl>
    implements _$$HouseImplCopyWith<$Res> {
  __$$HouseImplCopyWithImpl(
      _$HouseImpl _value, $Res Function(_$HouseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? houseId = null,
    Object? houseCode = freezed,
    Object? title = null,
    Object? titleMy = freezed,
    Object? transactionType = null,
    Object? price = null,
    Object? priceUnit = null,
    Object? priceNote = freezed,
    Object? houseType = null,
    Object? propertyType = freezed,
    Object? area = freezed,
    Object? usableArea = freezed,
    Object? rooms = freezed,
    Object? bedrooms = freezed,
    Object? livingRooms = freezed,
    Object? bathrooms = freezed,
    Object? floor = freezed,
    Object? decoration = freezed,
    Object? orientation = freezed,
    Object? buildYear = freezed,
    Object? location = freezed,
    Object? description = freezed,
    Object? highlights = freezed,
    Object? facilities = freezed,
    Object? property = freezed,
    Object? verification = freezed,
    Object? images = null,
    Object? agent = freezed,
    Object? stats = freezed,
    Object? isFavorited = null,
    Object? status = null,
    Object? createdAt = freezed,
    Object? publishedAt = freezed,
  }) {
    return _then(_$HouseImpl(
      houseId: null == houseId
          ? _value.houseId
          : houseId // ignore: cast_nullable_to_non_nullable
              as int,
      houseCode: freezed == houseCode
          ? _value.houseCode
          : houseCode // ignore: cast_nullable_to_non_nullable
              as String?,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      titleMy: freezed == titleMy
          ? _value.titleMy
          : titleMy // ignore: cast_nullable_to_non_nullable
              as String?,
      transactionType: null == transactionType
          ? _value.transactionType
          : transactionType // ignore: cast_nullable_to_non_nullable
              as String,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as int,
      priceUnit: null == priceUnit
          ? _value.priceUnit
          : priceUnit // ignore: cast_nullable_to_non_nullable
              as String,
      priceNote: freezed == priceNote
          ? _value.priceNote
          : priceNote // ignore: cast_nullable_to_non_nullable
              as String?,
      houseType: null == houseType
          ? _value.houseType
          : houseType // ignore: cast_nullable_to_non_nullable
              as String,
      propertyType: freezed == propertyType
          ? _value.propertyType
          : propertyType // ignore: cast_nullable_to_non_nullable
              as String?,
      area: freezed == area
          ? _value.area
          : area // ignore: cast_nullable_to_non_nullable
              as double?,
      usableArea: freezed == usableArea
          ? _value.usableArea
          : usableArea // ignore: cast_nullable_to_non_nullable
              as double?,
      rooms: freezed == rooms
          ? _value.rooms
          : rooms // ignore: cast_nullable_to_non_nullable
              as String?,
      bedrooms: freezed == bedrooms
          ? _value.bedrooms
          : bedrooms // ignore: cast_nullable_to_non_nullable
              as int?,
      livingRooms: freezed == livingRooms
          ? _value.livingRooms
          : livingRooms // ignore: cast_nullable_to_non_nullable
              as int?,
      bathrooms: freezed == bathrooms
          ? _value.bathrooms
          : bathrooms // ignore: cast_nullable_to_non_nullable
              as int?,
      floor: freezed == floor
          ? _value.floor
          : floor // ignore: cast_nullable_to_non_nullable
              as String?,
      decoration: freezed == decoration
          ? _value.decoration
          : decoration // ignore: cast_nullable_to_non_nullable
              as String?,
      orientation: freezed == orientation
          ? _value.orientation
          : orientation // ignore: cast_nullable_to_non_nullable
              as String?,
      buildYear: freezed == buildYear
          ? _value.buildYear
          : buildYear // ignore: cast_nullable_to_non_nullable
              as int?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as HouseLocation?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      highlights: freezed == highlights
          ? _value._highlights
          : highlights // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      facilities: freezed == facilities
          ? _value._facilities
          : facilities // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      property: freezed == property
          ? _value.property
          : property // ignore: cast_nullable_to_non_nullable
              as PropertyInfo?,
      verification: freezed == verification
          ? _value.verification
          : verification // ignore: cast_nullable_to_non_nullable
              as VerificationInfo?,
      images: null == images
          ? _value._images
          : images // ignore: cast_nullable_to_non_nullable
              as List<HouseImage>,
      agent: freezed == agent
          ? _value.agent
          : agent // ignore: cast_nullable_to_non_nullable
              as AgentBrief?,
      stats: freezed == stats
          ? _value.stats
          : stats // ignore: cast_nullable_to_non_nullable
              as HouseStats?,
      isFavorited: null == isFavorited
          ? _value.isFavorited
          : isFavorited // ignore: cast_nullable_to_non_nullable
              as bool,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
      publishedAt: freezed == publishedAt
          ? _value.publishedAt
          : publishedAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$HouseImpl extends _House {
  const _$HouseImpl(
      {@JsonKey(name: 'house_id') required this.houseId,
      @JsonKey(name: 'house_code') this.houseCode,
      @JsonKey(name: 'title') required this.title,
      @JsonKey(name: 'title_my') this.titleMy,
      @JsonKey(name: 'transaction_type') required this.transactionType,
      @JsonKey(name: 'price') required this.price,
      @JsonKey(name: 'price_unit') this.priceUnit = 'MMK',
      @JsonKey(name: 'price_note') this.priceNote,
      @JsonKey(name: 'house_type') required this.houseType,
      @JsonKey(name: 'property_type') this.propertyType,
      @JsonKey(name: 'area') this.area,
      @JsonKey(name: 'usable_area') this.usableArea,
      @JsonKey(name: 'rooms') this.rooms,
      @JsonKey(name: 'bedrooms') this.bedrooms,
      @JsonKey(name: 'living_rooms') this.livingRooms,
      @JsonKey(name: 'bathrooms') this.bathrooms,
      @JsonKey(name: 'floor') this.floor,
      @JsonKey(name: 'decoration') this.decoration,
      @JsonKey(name: 'orientation') this.orientation,
      @JsonKey(name: 'build_year') this.buildYear,
      @JsonKey(name: 'location') this.location,
      @JsonKey(name: 'description') this.description,
      @JsonKey(name: 'highlights') final List<String>? highlights,
      @JsonKey(name: 'facilities') final List<String>? facilities,
      @JsonKey(name: 'property') this.property,
      @JsonKey(name: 'verification') this.verification,
      @JsonKey(name: 'images') final List<HouseImage> images = const [],
      @JsonKey(name: 'agent') this.agent,
      @JsonKey(name: 'stats') this.stats,
      @JsonKey(name: 'is_favorited') this.isFavorited = false,
      @JsonKey(name: 'status') this.status = 'online',
      @JsonKey(name: 'created_at') this.createdAt,
      @JsonKey(name: 'published_at') this.publishedAt})
      : _highlights = highlights,
        _facilities = facilities,
        _images = images,
        super._();

  factory _$HouseImpl.fromJson(Map<String, dynamic> json) =>
      _$$HouseImplFromJson(json);

  @override
  @JsonKey(name: 'house_id')
  final int houseId;
  @override
  @JsonKey(name: 'house_code')
  final String? houseCode;
  @override
  @JsonKey(name: 'title')
  final String title;
  @override
  @JsonKey(name: 'title_my')
  final String? titleMy;
  @override
  @JsonKey(name: 'transaction_type')
  final String transactionType;
  @override
  @JsonKey(name: 'price')
  final int price;
  @override
  @JsonKey(name: 'price_unit')
  final String priceUnit;
  @override
  @JsonKey(name: 'price_note')
  final String? priceNote;
  @override
  @JsonKey(name: 'house_type')
  final String houseType;
  @override
  @JsonKey(name: 'property_type')
  final String? propertyType;
  @override
  @JsonKey(name: 'area')
  final double? area;
  @override
  @JsonKey(name: 'usable_area')
  final double? usableArea;
  @override
  @JsonKey(name: 'rooms')
  final String? rooms;
  @override
  @JsonKey(name: 'bedrooms')
  final int? bedrooms;
  @override
  @JsonKey(name: 'living_rooms')
  final int? livingRooms;
  @override
  @JsonKey(name: 'bathrooms')
  final int? bathrooms;
  @override
  @JsonKey(name: 'floor')
  final String? floor;
  @override
  @JsonKey(name: 'decoration')
  final String? decoration;
  @override
  @JsonKey(name: 'orientation')
  final String? orientation;
  @override
  @JsonKey(name: 'build_year')
  final int? buildYear;
  @override
  @JsonKey(name: 'location')
  final HouseLocation? location;
  @override
  @JsonKey(name: 'description')
  final String? description;
  final List<String>? _highlights;
  @override
  @JsonKey(name: 'highlights')
  List<String>? get highlights {
    final value = _highlights;
    if (value == null) return null;
    if (_highlights is EqualUnmodifiableListView) return _highlights;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<String>? _facilities;
  @override
  @JsonKey(name: 'facilities')
  List<String>? get facilities {
    final value = _facilities;
    if (value == null) return null;
    if (_facilities is EqualUnmodifiableListView) return _facilities;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey(name: 'property')
  final PropertyInfo? property;
  @override
  @JsonKey(name: 'verification')
  final VerificationInfo? verification;
  final List<HouseImage> _images;
  @override
  @JsonKey(name: 'images')
  List<HouseImage> get images {
    if (_images is EqualUnmodifiableListView) return _images;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_images);
  }

  @override
  @JsonKey(name: 'agent')
  final AgentBrief? agent;
  @override
  @JsonKey(name: 'stats')
  final HouseStats? stats;
  @override
  @JsonKey(name: 'is_favorited')
  final bool isFavorited;
  @override
  @JsonKey(name: 'status')
  final String status;
  @override
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @override
  @JsonKey(name: 'published_at')
  final String? publishedAt;

  @override
  String toString() {
    return 'House(houseId: $houseId, houseCode: $houseCode, title: $title, titleMy: $titleMy, transactionType: $transactionType, price: $price, priceUnit: $priceUnit, priceNote: $priceNote, houseType: $houseType, propertyType: $propertyType, area: $area, usableArea: $usableArea, rooms: $rooms, bedrooms: $bedrooms, livingRooms: $livingRooms, bathrooms: $bathrooms, floor: $floor, decoration: $decoration, orientation: $orientation, buildYear: $buildYear, location: $location, description: $description, highlights: $highlights, facilities: $facilities, property: $property, verification: $verification, images: $images, agent: $agent, stats: $stats, isFavorited: $isFavorited, status: $status, createdAt: $createdAt, publishedAt: $publishedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HouseImpl &&
            (identical(other.houseId, houseId) || other.houseId == houseId) &&
            (identical(other.houseCode, houseCode) ||
                other.houseCode == houseCode) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.titleMy, titleMy) || other.titleMy == titleMy) &&
            (identical(other.transactionType, transactionType) ||
                other.transactionType == transactionType) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.priceUnit, priceUnit) ||
                other.priceUnit == priceUnit) &&
            (identical(other.priceNote, priceNote) ||
                other.priceNote == priceNote) &&
            (identical(other.houseType, houseType) ||
                other.houseType == houseType) &&
            (identical(other.propertyType, propertyType) ||
                other.propertyType == propertyType) &&
            (identical(other.area, area) || other.area == area) &&
            (identical(other.usableArea, usableArea) ||
                other.usableArea == usableArea) &&
            (identical(other.rooms, rooms) || other.rooms == rooms) &&
            (identical(other.bedrooms, bedrooms) ||
                other.bedrooms == bedrooms) &&
            (identical(other.livingRooms, livingRooms) ||
                other.livingRooms == livingRooms) &&
            (identical(other.bathrooms, bathrooms) ||
                other.bathrooms == bathrooms) &&
            (identical(other.floor, floor) || other.floor == floor) &&
            (identical(other.decoration, decoration) ||
                other.decoration == decoration) &&
            (identical(other.orientation, orientation) ||
                other.orientation == orientation) &&
            (identical(other.buildYear, buildYear) ||
                other.buildYear == buildYear) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality()
                .equals(other._highlights, _highlights) &&
            const DeepCollectionEquality()
                .equals(other._facilities, _facilities) &&
            (identical(other.property, property) ||
                other.property == property) &&
            (identical(other.verification, verification) ||
                other.verification == verification) &&
            const DeepCollectionEquality().equals(other._images, _images) &&
            (identical(other.agent, agent) || other.agent == agent) &&
            (identical(other.stats, stats) || other.stats == stats) &&
            (identical(other.isFavorited, isFavorited) ||
                other.isFavorited == isFavorited) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.publishedAt, publishedAt) ||
                other.publishedAt == publishedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        houseId,
        houseCode,
        title,
        titleMy,
        transactionType,
        price,
        priceUnit,
        priceNote,
        houseType,
        propertyType,
        area,
        usableArea,
        rooms,
        bedrooms,
        livingRooms,
        bathrooms,
        floor,
        decoration,
        orientation,
        buildYear,
        location,
        description,
        const DeepCollectionEquality().hash(_highlights),
        const DeepCollectionEquality().hash(_facilities),
        property,
        verification,
        const DeepCollectionEquality().hash(_images),
        agent,
        stats,
        isFavorited,
        status,
        createdAt,
        publishedAt
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$HouseImplCopyWith<_$HouseImpl> get copyWith =>
      __$$HouseImplCopyWithImpl<_$HouseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HouseImplToJson(
      this,
    );
  }
}

abstract class _House extends House {
  const factory _House(
      {@JsonKey(name: 'house_id') required final int houseId,
      @JsonKey(name: 'house_code') final String? houseCode,
      @JsonKey(name: 'title') required final String title,
      @JsonKey(name: 'title_my') final String? titleMy,
      @JsonKey(name: 'transaction_type') required final String transactionType,
      @JsonKey(name: 'price') required final int price,
      @JsonKey(name: 'price_unit') final String priceUnit,
      @JsonKey(name: 'price_note') final String? priceNote,
      @JsonKey(name: 'house_type') required final String houseType,
      @JsonKey(name: 'property_type') final String? propertyType,
      @JsonKey(name: 'area') final double? area,
      @JsonKey(name: 'usable_area') final double? usableArea,
      @JsonKey(name: 'rooms') final String? rooms,
      @JsonKey(name: 'bedrooms') final int? bedrooms,
      @JsonKey(name: 'living_rooms') final int? livingRooms,
      @JsonKey(name: 'bathrooms') final int? bathrooms,
      @JsonKey(name: 'floor') final String? floor,
      @JsonKey(name: 'decoration') final String? decoration,
      @JsonKey(name: 'orientation') final String? orientation,
      @JsonKey(name: 'build_year') final int? buildYear,
      @JsonKey(name: 'location') final HouseLocation? location,
      @JsonKey(name: 'description') final String? description,
      @JsonKey(name: 'highlights') final List<String>? highlights,
      @JsonKey(name: 'facilities') final List<String>? facilities,
      @JsonKey(name: 'property') final PropertyInfo? property,
      @JsonKey(name: 'verification') final VerificationInfo? verification,
      @JsonKey(name: 'images') final List<HouseImage> images,
      @JsonKey(name: 'agent') final AgentBrief? agent,
      @JsonKey(name: 'stats') final HouseStats? stats,
      @JsonKey(name: 'is_favorited') final bool isFavorited,
      @JsonKey(name: 'status') final String status,
      @JsonKey(name: 'created_at') final String? createdAt,
      @JsonKey(name: 'published_at') final String? publishedAt}) = _$HouseImpl;
  const _House._() : super._();

  factory _House.fromJson(Map<String, dynamic> json) = _$HouseImpl.fromJson;

  @override
  @JsonKey(name: 'house_id')
  int get houseId;
  @override
  @JsonKey(name: 'house_code')
  String? get houseCode;
  @override
  @JsonKey(name: 'title')
  String get title;
  @override
  @JsonKey(name: 'title_my')
  String? get titleMy;
  @override
  @JsonKey(name: 'transaction_type')
  String get transactionType;
  @override
  @JsonKey(name: 'price')
  int get price;
  @override
  @JsonKey(name: 'price_unit')
  String get priceUnit;
  @override
  @JsonKey(name: 'price_note')
  String? get priceNote;
  @override
  @JsonKey(name: 'house_type')
  String get houseType;
  @override
  @JsonKey(name: 'property_type')
  String? get propertyType;
  @override
  @JsonKey(name: 'area')
  double? get area;
  @override
  @JsonKey(name: 'usable_area')
  double? get usableArea;
  @override
  @JsonKey(name: 'rooms')
  String? get rooms;
  @override
  @JsonKey(name: 'bedrooms')
  int? get bedrooms;
  @override
  @JsonKey(name: 'living_rooms')
  int? get livingRooms;
  @override
  @JsonKey(name: 'bathrooms')
  int? get bathrooms;
  @override
  @JsonKey(name: 'floor')
  String? get floor;
  @override
  @JsonKey(name: 'decoration')
  String? get decoration;
  @override
  @JsonKey(name: 'orientation')
  String? get orientation;
  @override
  @JsonKey(name: 'build_year')
  int? get buildYear;
  @override
  @JsonKey(name: 'location')
  HouseLocation? get location;
  @override
  @JsonKey(name: 'description')
  String? get description;
  @override
  @JsonKey(name: 'highlights')
  List<String>? get highlights;
  @override
  @JsonKey(name: 'facilities')
  List<String>? get facilities;
  @override
  @JsonKey(name: 'property')
  PropertyInfo? get property;
  @override
  @JsonKey(name: 'verification')
  VerificationInfo? get verification;
  @override
  @JsonKey(name: 'images')
  List<HouseImage> get images;
  @override
  @JsonKey(name: 'agent')
  AgentBrief? get agent;
  @override
  @JsonKey(name: 'stats')
  HouseStats? get stats;
  @override
  @JsonKey(name: 'is_favorited')
  bool get isFavorited;
  @override
  @JsonKey(name: 'status')
  String get status;
  @override
  @JsonKey(name: 'created_at')
  String? get createdAt;
  @override
  @JsonKey(name: 'published_at')
  String? get publishedAt;
  @override
  @JsonKey(ignore: true)
  _$$HouseImplCopyWith<_$HouseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

HouseLocation _$HouseLocationFromJson(Map<String, dynamic> json) {
  return _HouseLocation.fromJson(json);
}

/// @nodoc
mixin _$HouseLocation {
  @JsonKey(name: 'city')
  CityInfo? get city => throw _privateConstructorUsedError;
  @JsonKey(name: 'district')
  DistrictInfo? get district => throw _privateConstructorUsedError;
  @JsonKey(name: 'community')
  CommunityInfo? get community => throw _privateConstructorUsedError;
  @JsonKey(name: 'address')
  String? get address => throw _privateConstructorUsedError;
  @JsonKey(name: 'lat')
  double? get lat => throw _privateConstructorUsedError;
  @JsonKey(name: 'lng')
  double? get lng => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $HouseLocationCopyWith<HouseLocation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HouseLocationCopyWith<$Res> {
  factory $HouseLocationCopyWith(
          HouseLocation value, $Res Function(HouseLocation) then) =
      _$HouseLocationCopyWithImpl<$Res, HouseLocation>;
  @useResult
  $Res call(
      {@JsonKey(name: 'city') CityInfo? city,
      @JsonKey(name: 'district') DistrictInfo? district,
      @JsonKey(name: 'community') CommunityInfo? community,
      @JsonKey(name: 'address') String? address,
      @JsonKey(name: 'lat') double? lat,
      @JsonKey(name: 'lng') double? lng});

  $CityInfoCopyWith<$Res>? get city;
  $DistrictInfoCopyWith<$Res>? get district;
  $CommunityInfoCopyWith<$Res>? get community;
}

/// @nodoc
class _$HouseLocationCopyWithImpl<$Res, $Val extends HouseLocation>
    implements $HouseLocationCopyWith<$Res> {
  _$HouseLocationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? city = freezed,
    Object? district = freezed,
    Object? community = freezed,
    Object? address = freezed,
    Object? lat = freezed,
    Object? lng = freezed,
  }) {
    return _then(_value.copyWith(
      city: freezed == city
          ? _value.city
          : city // ignore: cast_nullable_to_non_nullable
              as CityInfo?,
      district: freezed == district
          ? _value.district
          : district // ignore: cast_nullable_to_non_nullable
              as DistrictInfo?,
      community: freezed == community
          ? _value.community
          : community // ignore: cast_nullable_to_non_nullable
              as CommunityInfo?,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      lat: freezed == lat
          ? _value.lat
          : lat // ignore: cast_nullable_to_non_nullable
              as double?,
      lng: freezed == lng
          ? _value.lng
          : lng // ignore: cast_nullable_to_non_nullable
              as double?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $CityInfoCopyWith<$Res>? get city {
    if (_value.city == null) {
      return null;
    }

    return $CityInfoCopyWith<$Res>(_value.city!, (value) {
      return _then(_value.copyWith(city: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $DistrictInfoCopyWith<$Res>? get district {
    if (_value.district == null) {
      return null;
    }

    return $DistrictInfoCopyWith<$Res>(_value.district!, (value) {
      return _then(_value.copyWith(district: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $CommunityInfoCopyWith<$Res>? get community {
    if (_value.community == null) {
      return null;
    }

    return $CommunityInfoCopyWith<$Res>(_value.community!, (value) {
      return _then(_value.copyWith(community: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$HouseLocationImplCopyWith<$Res>
    implements $HouseLocationCopyWith<$Res> {
  factory _$$HouseLocationImplCopyWith(
          _$HouseLocationImpl value, $Res Function(_$HouseLocationImpl) then) =
      __$$HouseLocationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'city') CityInfo? city,
      @JsonKey(name: 'district') DistrictInfo? district,
      @JsonKey(name: 'community') CommunityInfo? community,
      @JsonKey(name: 'address') String? address,
      @JsonKey(name: 'lat') double? lat,
      @JsonKey(name: 'lng') double? lng});

  @override
  $CityInfoCopyWith<$Res>? get city;
  @override
  $DistrictInfoCopyWith<$Res>? get district;
  @override
  $CommunityInfoCopyWith<$Res>? get community;
}

/// @nodoc
class __$$HouseLocationImplCopyWithImpl<$Res>
    extends _$HouseLocationCopyWithImpl<$Res, _$HouseLocationImpl>
    implements _$$HouseLocationImplCopyWith<$Res> {
  __$$HouseLocationImplCopyWithImpl(
      _$HouseLocationImpl _value, $Res Function(_$HouseLocationImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? city = freezed,
    Object? district = freezed,
    Object? community = freezed,
    Object? address = freezed,
    Object? lat = freezed,
    Object? lng = freezed,
  }) {
    return _then(_$HouseLocationImpl(
      city: freezed == city
          ? _value.city
          : city // ignore: cast_nullable_to_non_nullable
              as CityInfo?,
      district: freezed == district
          ? _value.district
          : district // ignore: cast_nullable_to_non_nullable
              as DistrictInfo?,
      community: freezed == community
          ? _value.community
          : community // ignore: cast_nullable_to_non_nullable
              as CommunityInfo?,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      lat: freezed == lat
          ? _value.lat
          : lat // ignore: cast_nullable_to_non_nullable
              as double?,
      lng: freezed == lng
          ? _value.lng
          : lng // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$HouseLocationImpl implements _HouseLocation {
  const _$HouseLocationImpl(
      {@JsonKey(name: 'city') this.city,
      @JsonKey(name: 'district') this.district,
      @JsonKey(name: 'community') this.community,
      @JsonKey(name: 'address') this.address,
      @JsonKey(name: 'lat') this.lat,
      @JsonKey(name: 'lng') this.lng});

  factory _$HouseLocationImpl.fromJson(Map<String, dynamic> json) =>
      _$$HouseLocationImplFromJson(json);

  @override
  @JsonKey(name: 'city')
  final CityInfo? city;
  @override
  @JsonKey(name: 'district')
  final DistrictInfo? district;
  @override
  @JsonKey(name: 'community')
  final CommunityInfo? community;
  @override
  @JsonKey(name: 'address')
  final String? address;
  @override
  @JsonKey(name: 'lat')
  final double? lat;
  @override
  @JsonKey(name: 'lng')
  final double? lng;

  @override
  String toString() {
    return 'HouseLocation(city: $city, district: $district, community: $community, address: $address, lat: $lat, lng: $lng)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HouseLocationImpl &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.district, district) ||
                other.district == district) &&
            (identical(other.community, community) ||
                other.community == community) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.lat, lat) || other.lat == lat) &&
            (identical(other.lng, lng) || other.lng == lng));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, city, district, community, address, lat, lng);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$HouseLocationImplCopyWith<_$HouseLocationImpl> get copyWith =>
      __$$HouseLocationImplCopyWithImpl<_$HouseLocationImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HouseLocationImplToJson(
      this,
    );
  }
}

abstract class _HouseLocation implements HouseLocation {
  const factory _HouseLocation(
      {@JsonKey(name: 'city') final CityInfo? city,
      @JsonKey(name: 'district') final DistrictInfo? district,
      @JsonKey(name: 'community') final CommunityInfo? community,
      @JsonKey(name: 'address') final String? address,
      @JsonKey(name: 'lat') final double? lat,
      @JsonKey(name: 'lng') final double? lng}) = _$HouseLocationImpl;

  factory _HouseLocation.fromJson(Map<String, dynamic> json) =
      _$HouseLocationImpl.fromJson;

  @override
  @JsonKey(name: 'city')
  CityInfo? get city;
  @override
  @JsonKey(name: 'district')
  DistrictInfo? get district;
  @override
  @JsonKey(name: 'community')
  CommunityInfo? get community;
  @override
  @JsonKey(name: 'address')
  String? get address;
  @override
  @JsonKey(name: 'lat')
  double? get lat;
  @override
  @JsonKey(name: 'lng')
  double? get lng;
  @override
  @JsonKey(ignore: true)
  _$$HouseLocationImplCopyWith<_$HouseLocationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CityInfo _$CityInfoFromJson(Map<String, dynamic> json) {
  return _CityInfo.fromJson(json);
}

/// @nodoc
mixin _$CityInfo {
  @JsonKey(name: 'code')
  String get code => throw _privateConstructorUsedError;
  @JsonKey(name: 'name')
  String get name => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CityInfoCopyWith<CityInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CityInfoCopyWith<$Res> {
  factory $CityInfoCopyWith(CityInfo value, $Res Function(CityInfo) then) =
      _$CityInfoCopyWithImpl<$Res, CityInfo>;
  @useResult
  $Res call(
      {@JsonKey(name: 'code') String code, @JsonKey(name: 'name') String name});
}

/// @nodoc
class _$CityInfoCopyWithImpl<$Res, $Val extends CityInfo>
    implements $CityInfoCopyWith<$Res> {
  _$CityInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? name = null,
  }) {
    return _then(_value.copyWith(
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CityInfoImplCopyWith<$Res>
    implements $CityInfoCopyWith<$Res> {
  factory _$$CityInfoImplCopyWith(
          _$CityInfoImpl value, $Res Function(_$CityInfoImpl) then) =
      __$$CityInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'code') String code, @JsonKey(name: 'name') String name});
}

/// @nodoc
class __$$CityInfoImplCopyWithImpl<$Res>
    extends _$CityInfoCopyWithImpl<$Res, _$CityInfoImpl>
    implements _$$CityInfoImplCopyWith<$Res> {
  __$$CityInfoImplCopyWithImpl(
      _$CityInfoImpl _value, $Res Function(_$CityInfoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? name = null,
  }) {
    return _then(_$CityInfoImpl(
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CityInfoImpl implements _CityInfo {
  const _$CityInfoImpl(
      {@JsonKey(name: 'code') required this.code,
      @JsonKey(name: 'name') required this.name});

  factory _$CityInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$CityInfoImplFromJson(json);

  @override
  @JsonKey(name: 'code')
  final String code;
  @override
  @JsonKey(name: 'name')
  final String name;

  @override
  String toString() {
    return 'CityInfo(code: $code, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CityInfoImpl &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.name, name) || other.name == name));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, code, name);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CityInfoImplCopyWith<_$CityInfoImpl> get copyWith =>
      __$$CityInfoImplCopyWithImpl<_$CityInfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CityInfoImplToJson(
      this,
    );
  }
}

abstract class _CityInfo implements CityInfo {
  const factory _CityInfo(
      {@JsonKey(name: 'code') required final String code,
      @JsonKey(name: 'name') required final String name}) = _$CityInfoImpl;

  factory _CityInfo.fromJson(Map<String, dynamic> json) =
      _$CityInfoImpl.fromJson;

  @override
  @JsonKey(name: 'code')
  String get code;
  @override
  @JsonKey(name: 'name')
  String get name;
  @override
  @JsonKey(ignore: true)
  _$$CityInfoImplCopyWith<_$CityInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DistrictInfo _$DistrictInfoFromJson(Map<String, dynamic> json) {
  return _DistrictInfo.fromJson(json);
}

/// @nodoc
mixin _$DistrictInfo {
  @JsonKey(name: 'code')
  String get code => throw _privateConstructorUsedError;
  @JsonKey(name: 'name')
  String get name => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DistrictInfoCopyWith<DistrictInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DistrictInfoCopyWith<$Res> {
  factory $DistrictInfoCopyWith(
          DistrictInfo value, $Res Function(DistrictInfo) then) =
      _$DistrictInfoCopyWithImpl<$Res, DistrictInfo>;
  @useResult
  $Res call(
      {@JsonKey(name: 'code') String code, @JsonKey(name: 'name') String name});
}

/// @nodoc
class _$DistrictInfoCopyWithImpl<$Res, $Val extends DistrictInfo>
    implements $DistrictInfoCopyWith<$Res> {
  _$DistrictInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? name = null,
  }) {
    return _then(_value.copyWith(
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DistrictInfoImplCopyWith<$Res>
    implements $DistrictInfoCopyWith<$Res> {
  factory _$$DistrictInfoImplCopyWith(
          _$DistrictInfoImpl value, $Res Function(_$DistrictInfoImpl) then) =
      __$$DistrictInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'code') String code, @JsonKey(name: 'name') String name});
}

/// @nodoc
class __$$DistrictInfoImplCopyWithImpl<$Res>
    extends _$DistrictInfoCopyWithImpl<$Res, _$DistrictInfoImpl>
    implements _$$DistrictInfoImplCopyWith<$Res> {
  __$$DistrictInfoImplCopyWithImpl(
      _$DistrictInfoImpl _value, $Res Function(_$DistrictInfoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? name = null,
  }) {
    return _then(_$DistrictInfoImpl(
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DistrictInfoImpl implements _DistrictInfo {
  const _$DistrictInfoImpl(
      {@JsonKey(name: 'code') required this.code,
      @JsonKey(name: 'name') required this.name});

  factory _$DistrictInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$DistrictInfoImplFromJson(json);

  @override
  @JsonKey(name: 'code')
  final String code;
  @override
  @JsonKey(name: 'name')
  final String name;

  @override
  String toString() {
    return 'DistrictInfo(code: $code, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DistrictInfoImpl &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.name, name) || other.name == name));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, code, name);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DistrictInfoImplCopyWith<_$DistrictInfoImpl> get copyWith =>
      __$$DistrictInfoImplCopyWithImpl<_$DistrictInfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DistrictInfoImplToJson(
      this,
    );
  }
}

abstract class _DistrictInfo implements DistrictInfo {
  const factory _DistrictInfo(
      {@JsonKey(name: 'code') required final String code,
      @JsonKey(name: 'name') required final String name}) = _$DistrictInfoImpl;

  factory _DistrictInfo.fromJson(Map<String, dynamic> json) =
      _$DistrictInfoImpl.fromJson;

  @override
  @JsonKey(name: 'code')
  String get code;
  @override
  @JsonKey(name: 'name')
  String get name;
  @override
  @JsonKey(ignore: true)
  _$$DistrictInfoImplCopyWith<_$DistrictInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CommunityInfo _$CommunityInfoFromJson(Map<String, dynamic> json) {
  return _CommunityInfo.fromJson(json);
}

/// @nodoc
mixin _$CommunityInfo {
  @JsonKey(name: 'id')
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'name')
  String get name => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CommunityInfoCopyWith<CommunityInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommunityInfoCopyWith<$Res> {
  factory $CommunityInfoCopyWith(
          CommunityInfo value, $Res Function(CommunityInfo) then) =
      _$CommunityInfoCopyWithImpl<$Res, CommunityInfo>;
  @useResult
  $Res call({@JsonKey(name: 'id') int id, @JsonKey(name: 'name') String name});
}

/// @nodoc
class _$CommunityInfoCopyWithImpl<$Res, $Val extends CommunityInfo>
    implements $CommunityInfoCopyWith<$Res> {
  _$CommunityInfoCopyWithImpl(this._value, this._then);

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
abstract class _$$CommunityInfoImplCopyWith<$Res>
    implements $CommunityInfoCopyWith<$Res> {
  factory _$$CommunityInfoImplCopyWith(
          _$CommunityInfoImpl value, $Res Function(_$CommunityInfoImpl) then) =
      __$$CommunityInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({@JsonKey(name: 'id') int id, @JsonKey(name: 'name') String name});
}

/// @nodoc
class __$$CommunityInfoImplCopyWithImpl<$Res>
    extends _$CommunityInfoCopyWithImpl<$Res, _$CommunityInfoImpl>
    implements _$$CommunityInfoImplCopyWith<$Res> {
  __$$CommunityInfoImplCopyWithImpl(
      _$CommunityInfoImpl _value, $Res Function(_$CommunityInfoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
  }) {
    return _then(_$CommunityInfoImpl(
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
class _$CommunityInfoImpl implements _CommunityInfo {
  const _$CommunityInfoImpl(
      {@JsonKey(name: 'id') required this.id,
      @JsonKey(name: 'name') required this.name});

  factory _$CommunityInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$CommunityInfoImplFromJson(json);

  @override
  @JsonKey(name: 'id')
  final int id;
  @override
  @JsonKey(name: 'name')
  final String name;

  @override
  String toString() {
    return 'CommunityInfo(id: $id, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommunityInfoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, name);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CommunityInfoImplCopyWith<_$CommunityInfoImpl> get copyWith =>
      __$$CommunityInfoImplCopyWithImpl<_$CommunityInfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CommunityInfoImplToJson(
      this,
    );
  }
}

abstract class _CommunityInfo implements CommunityInfo {
  const factory _CommunityInfo(
      {@JsonKey(name: 'id') required final int id,
      @JsonKey(name: 'name') required final String name}) = _$CommunityInfoImpl;

  factory _CommunityInfo.fromJson(Map<String, dynamic> json) =
      _$CommunityInfoImpl.fromJson;

  @override
  @JsonKey(name: 'id')
  int get id;
  @override
  @JsonKey(name: 'name')
  String get name;
  @override
  @JsonKey(ignore: true)
  _$$CommunityInfoImplCopyWith<_$CommunityInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PropertyInfo _$PropertyInfoFromJson(Map<String, dynamic> json) {
  return _PropertyInfo.fromJson(json);
}

/// @nodoc
mixin _$PropertyInfo {
  @JsonKey(name: 'property_type')
  String? get propertyType => throw _privateConstructorUsedError;
  @JsonKey(name: 'ownership')
  String? get ownership => throw _privateConstructorUsedError;
  @JsonKey(name: 'has_loan')
  bool get hasLoan => throw _privateConstructorUsedError;
  @JsonKey(name: 'property_certificate_no')
  String? get propertyCertificateNo => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PropertyInfoCopyWith<PropertyInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PropertyInfoCopyWith<$Res> {
  factory $PropertyInfoCopyWith(
          PropertyInfo value, $Res Function(PropertyInfo) then) =
      _$PropertyInfoCopyWithImpl<$Res, PropertyInfo>;
  @useResult
  $Res call(
      {@JsonKey(name: 'property_type') String? propertyType,
      @JsonKey(name: 'ownership') String? ownership,
      @JsonKey(name: 'has_loan') bool hasLoan,
      @JsonKey(name: 'property_certificate_no') String? propertyCertificateNo});
}

/// @nodoc
class _$PropertyInfoCopyWithImpl<$Res, $Val extends PropertyInfo>
    implements $PropertyInfoCopyWith<$Res> {
  _$PropertyInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? propertyType = freezed,
    Object? ownership = freezed,
    Object? hasLoan = null,
    Object? propertyCertificateNo = freezed,
  }) {
    return _then(_value.copyWith(
      propertyType: freezed == propertyType
          ? _value.propertyType
          : propertyType // ignore: cast_nullable_to_non_nullable
              as String?,
      ownership: freezed == ownership
          ? _value.ownership
          : ownership // ignore: cast_nullable_to_non_nullable
              as String?,
      hasLoan: null == hasLoan
          ? _value.hasLoan
          : hasLoan // ignore: cast_nullable_to_non_nullable
              as bool,
      propertyCertificateNo: freezed == propertyCertificateNo
          ? _value.propertyCertificateNo
          : propertyCertificateNo // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PropertyInfoImplCopyWith<$Res>
    implements $PropertyInfoCopyWith<$Res> {
  factory _$$PropertyInfoImplCopyWith(
          _$PropertyInfoImpl value, $Res Function(_$PropertyInfoImpl) then) =
      __$$PropertyInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'property_type') String? propertyType,
      @JsonKey(name: 'ownership') String? ownership,
      @JsonKey(name: 'has_loan') bool hasLoan,
      @JsonKey(name: 'property_certificate_no') String? propertyCertificateNo});
}

/// @nodoc
class __$$PropertyInfoImplCopyWithImpl<$Res>
    extends _$PropertyInfoCopyWithImpl<$Res, _$PropertyInfoImpl>
    implements _$$PropertyInfoImplCopyWith<$Res> {
  __$$PropertyInfoImplCopyWithImpl(
      _$PropertyInfoImpl _value, $Res Function(_$PropertyInfoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? propertyType = freezed,
    Object? ownership = freezed,
    Object? hasLoan = null,
    Object? propertyCertificateNo = freezed,
  }) {
    return _then(_$PropertyInfoImpl(
      propertyType: freezed == propertyType
          ? _value.propertyType
          : propertyType // ignore: cast_nullable_to_non_nullable
              as String?,
      ownership: freezed == ownership
          ? _value.ownership
          : ownership // ignore: cast_nullable_to_non_nullable
              as String?,
      hasLoan: null == hasLoan
          ? _value.hasLoan
          : hasLoan // ignore: cast_nullable_to_non_nullable
              as bool,
      propertyCertificateNo: freezed == propertyCertificateNo
          ? _value.propertyCertificateNo
          : propertyCertificateNo // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PropertyInfoImpl implements _PropertyInfo {
  const _$PropertyInfoImpl(
      {@JsonKey(name: 'property_type') this.propertyType,
      @JsonKey(name: 'ownership') this.ownership,
      @JsonKey(name: 'has_loan') this.hasLoan = false,
      @JsonKey(name: 'property_certificate_no') this.propertyCertificateNo});

  factory _$PropertyInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$PropertyInfoImplFromJson(json);

  @override
  @JsonKey(name: 'property_type')
  final String? propertyType;
  @override
  @JsonKey(name: 'ownership')
  final String? ownership;
  @override
  @JsonKey(name: 'has_loan')
  final bool hasLoan;
  @override
  @JsonKey(name: 'property_certificate_no')
  final String? propertyCertificateNo;

  @override
  String toString() {
    return 'PropertyInfo(propertyType: $propertyType, ownership: $ownership, hasLoan: $hasLoan, propertyCertificateNo: $propertyCertificateNo)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PropertyInfoImpl &&
            (identical(other.propertyType, propertyType) ||
                other.propertyType == propertyType) &&
            (identical(other.ownership, ownership) ||
                other.ownership == ownership) &&
            (identical(other.hasLoan, hasLoan) || other.hasLoan == hasLoan) &&
            (identical(other.propertyCertificateNo, propertyCertificateNo) ||
                other.propertyCertificateNo == propertyCertificateNo));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, propertyType, ownership, hasLoan, propertyCertificateNo);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PropertyInfoImplCopyWith<_$PropertyInfoImpl> get copyWith =>
      __$$PropertyInfoImplCopyWithImpl<_$PropertyInfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PropertyInfoImplToJson(
      this,
    );
  }
}

abstract class _PropertyInfo implements PropertyInfo {
  const factory _PropertyInfo(
      {@JsonKey(name: 'property_type') final String? propertyType,
      @JsonKey(name: 'ownership') final String? ownership,
      @JsonKey(name: 'has_loan') final bool hasLoan,
      @JsonKey(name: 'property_certificate_no')
      final String? propertyCertificateNo}) = _$PropertyInfoImpl;

  factory _PropertyInfo.fromJson(Map<String, dynamic> json) =
      _$PropertyInfoImpl.fromJson;

  @override
  @JsonKey(name: 'property_type')
  String? get propertyType;
  @override
  @JsonKey(name: 'ownership')
  String? get ownership;
  @override
  @JsonKey(name: 'has_loan')
  bool get hasLoan;
  @override
  @JsonKey(name: 'property_certificate_no')
  String? get propertyCertificateNo;
  @override
  @JsonKey(ignore: true)
  _$$PropertyInfoImplCopyWith<_$PropertyInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

VerificationInfo _$VerificationInfoFromJson(Map<String, dynamic> json) {
  return _VerificationInfo.fromJson(json);
}

/// @nodoc
mixin _$VerificationInfo {
  @JsonKey(name: 'status')
  String get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'verified_at')
  String? get verifiedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'verified_by')
  String? get verifiedBy => throw _privateConstructorUsedError;
  @JsonKey(name: 'report_url')
  String? get reportUrl => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $VerificationInfoCopyWith<VerificationInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VerificationInfoCopyWith<$Res> {
  factory $VerificationInfoCopyWith(
          VerificationInfo value, $Res Function(VerificationInfo) then) =
      _$VerificationInfoCopyWithImpl<$Res, VerificationInfo>;
  @useResult
  $Res call(
      {@JsonKey(name: 'status') String status,
      @JsonKey(name: 'verified_at') String? verifiedAt,
      @JsonKey(name: 'verified_by') String? verifiedBy,
      @JsonKey(name: 'report_url') String? reportUrl});
}

/// @nodoc
class _$VerificationInfoCopyWithImpl<$Res, $Val extends VerificationInfo>
    implements $VerificationInfoCopyWith<$Res> {
  _$VerificationInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? verifiedAt = freezed,
    Object? verifiedBy = freezed,
    Object? reportUrl = freezed,
  }) {
    return _then(_value.copyWith(
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      verifiedAt: freezed == verifiedAt
          ? _value.verifiedAt
          : verifiedAt // ignore: cast_nullable_to_non_nullable
              as String?,
      verifiedBy: freezed == verifiedBy
          ? _value.verifiedBy
          : verifiedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      reportUrl: freezed == reportUrl
          ? _value.reportUrl
          : reportUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$VerificationInfoImplCopyWith<$Res>
    implements $VerificationInfoCopyWith<$Res> {
  factory _$$VerificationInfoImplCopyWith(_$VerificationInfoImpl value,
          $Res Function(_$VerificationInfoImpl) then) =
      __$$VerificationInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'status') String status,
      @JsonKey(name: 'verified_at') String? verifiedAt,
      @JsonKey(name: 'verified_by') String? verifiedBy,
      @JsonKey(name: 'report_url') String? reportUrl});
}

/// @nodoc
class __$$VerificationInfoImplCopyWithImpl<$Res>
    extends _$VerificationInfoCopyWithImpl<$Res, _$VerificationInfoImpl>
    implements _$$VerificationInfoImplCopyWith<$Res> {
  __$$VerificationInfoImplCopyWithImpl(_$VerificationInfoImpl _value,
      $Res Function(_$VerificationInfoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? verifiedAt = freezed,
    Object? verifiedBy = freezed,
    Object? reportUrl = freezed,
  }) {
    return _then(_$VerificationInfoImpl(
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      verifiedAt: freezed == verifiedAt
          ? _value.verifiedAt
          : verifiedAt // ignore: cast_nullable_to_non_nullable
              as String?,
      verifiedBy: freezed == verifiedBy
          ? _value.verifiedBy
          : verifiedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      reportUrl: freezed == reportUrl
          ? _value.reportUrl
          : reportUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$VerificationInfoImpl implements _VerificationInfo {
  const _$VerificationInfoImpl(
      {@JsonKey(name: 'status') this.status = 'pending',
      @JsonKey(name: 'verified_at') this.verifiedAt,
      @JsonKey(name: 'verified_by') this.verifiedBy,
      @JsonKey(name: 'report_url') this.reportUrl});

  factory _$VerificationInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$VerificationInfoImplFromJson(json);

  @override
  @JsonKey(name: 'status')
  final String status;
  @override
  @JsonKey(name: 'verified_at')
  final String? verifiedAt;
  @override
  @JsonKey(name: 'verified_by')
  final String? verifiedBy;
  @override
  @JsonKey(name: 'report_url')
  final String? reportUrl;

  @override
  String toString() {
    return 'VerificationInfo(status: $status, verifiedAt: $verifiedAt, verifiedBy: $verifiedBy, reportUrl: $reportUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VerificationInfoImpl &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.verifiedAt, verifiedAt) ||
                other.verifiedAt == verifiedAt) &&
            (identical(other.verifiedBy, verifiedBy) ||
                other.verifiedBy == verifiedBy) &&
            (identical(other.reportUrl, reportUrl) ||
                other.reportUrl == reportUrl));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, status, verifiedAt, verifiedBy, reportUrl);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$VerificationInfoImplCopyWith<_$VerificationInfoImpl> get copyWith =>
      __$$VerificationInfoImplCopyWithImpl<_$VerificationInfoImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VerificationInfoImplToJson(
      this,
    );
  }
}

abstract class _VerificationInfo implements VerificationInfo {
  const factory _VerificationInfo(
          {@JsonKey(name: 'status') final String status,
          @JsonKey(name: 'verified_at') final String? verifiedAt,
          @JsonKey(name: 'verified_by') final String? verifiedBy,
          @JsonKey(name: 'report_url') final String? reportUrl}) =
      _$VerificationInfoImpl;

  factory _VerificationInfo.fromJson(Map<String, dynamic> json) =
      _$VerificationInfoImpl.fromJson;

  @override
  @JsonKey(name: 'status')
  String get status;
  @override
  @JsonKey(name: 'verified_at')
  String? get verifiedAt;
  @override
  @JsonKey(name: 'verified_by')
  String? get verifiedBy;
  @override
  @JsonKey(name: 'report_url')
  String? get reportUrl;
  @override
  @JsonKey(ignore: true)
  _$$VerificationInfoImplCopyWith<_$VerificationInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

HouseImage _$HouseImageFromJson(Map<String, dynamic> json) {
  return _HouseImage.fromJson(json);
}

/// @nodoc
mixin _$HouseImage {
  @JsonKey(name: 'id')
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'url')
  String get url => throw _privateConstructorUsedError;
  @JsonKey(name: 'type')
  String get type => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_main')
  bool get isMain => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $HouseImageCopyWith<HouseImage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HouseImageCopyWith<$Res> {
  factory $HouseImageCopyWith(
          HouseImage value, $Res Function(HouseImage) then) =
      _$HouseImageCopyWithImpl<$Res, HouseImage>;
  @useResult
  $Res call(
      {@JsonKey(name: 'id') int id,
      @JsonKey(name: 'url') String url,
      @JsonKey(name: 'type') String type,
      @JsonKey(name: 'is_main') bool isMain});
}

/// @nodoc
class _$HouseImageCopyWithImpl<$Res, $Val extends HouseImage>
    implements $HouseImageCopyWith<$Res> {
  _$HouseImageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? url = null,
    Object? type = null,
    Object? isMain = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      isMain: null == isMain
          ? _value.isMain
          : isMain // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$HouseImageImplCopyWith<$Res>
    implements $HouseImageCopyWith<$Res> {
  factory _$$HouseImageImplCopyWith(
          _$HouseImageImpl value, $Res Function(_$HouseImageImpl) then) =
      __$$HouseImageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'id') int id,
      @JsonKey(name: 'url') String url,
      @JsonKey(name: 'type') String type,
      @JsonKey(name: 'is_main') bool isMain});
}

/// @nodoc
class __$$HouseImageImplCopyWithImpl<$Res>
    extends _$HouseImageCopyWithImpl<$Res, _$HouseImageImpl>
    implements _$$HouseImageImplCopyWith<$Res> {
  __$$HouseImageImplCopyWithImpl(
      _$HouseImageImpl _value, $Res Function(_$HouseImageImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? url = null,
    Object? type = null,
    Object? isMain = null,
  }) {
    return _then(_$HouseImageImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      isMain: null == isMain
          ? _value.isMain
          : isMain // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$HouseImageImpl implements _HouseImage {
  const _$HouseImageImpl(
      {@JsonKey(name: 'id') required this.id,
      @JsonKey(name: 'url') required this.url,
      @JsonKey(name: 'type') this.type = 'interior',
      @JsonKey(name: 'is_main') this.isMain = false});

  factory _$HouseImageImpl.fromJson(Map<String, dynamic> json) =>
      _$$HouseImageImplFromJson(json);

  @override
  @JsonKey(name: 'id')
  final int id;
  @override
  @JsonKey(name: 'url')
  final String url;
  @override
  @JsonKey(name: 'type')
  final String type;
  @override
  @JsonKey(name: 'is_main')
  final bool isMain;

  @override
  String toString() {
    return 'HouseImage(id: $id, url: $url, type: $type, isMain: $isMain)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HouseImageImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.isMain, isMain) || other.isMain == isMain));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, url, type, isMain);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$HouseImageImplCopyWith<_$HouseImageImpl> get copyWith =>
      __$$HouseImageImplCopyWithImpl<_$HouseImageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HouseImageImplToJson(
      this,
    );
  }
}

abstract class _HouseImage implements HouseImage {
  const factory _HouseImage(
      {@JsonKey(name: 'id') required final int id,
      @JsonKey(name: 'url') required final String url,
      @JsonKey(name: 'type') final String type,
      @JsonKey(name: 'is_main') final bool isMain}) = _$HouseImageImpl;

  factory _HouseImage.fromJson(Map<String, dynamic> json) =
      _$HouseImageImpl.fromJson;

  @override
  @JsonKey(name: 'id')
  int get id;
  @override
  @JsonKey(name: 'url')
  String get url;
  @override
  @JsonKey(name: 'type')
  String get type;
  @override
  @JsonKey(name: 'is_main')
  bool get isMain;
  @override
  @JsonKey(ignore: true)
  _$$HouseImageImplCopyWith<_$HouseImageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AgentBrief _$AgentBriefFromJson(Map<String, dynamic> json) {
  return _AgentBrief.fromJson(json);
}

/// @nodoc
mixin _$AgentBrief {
  @JsonKey(name: 'agent_id')
  int get agentId => throw _privateConstructorUsedError;
  @JsonKey(name: 'name')
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'avatar')
  String? get avatar => throw _privateConstructorUsedError;
  @JsonKey(name: 'company')
  String? get company => throw _privateConstructorUsedError;
  @JsonKey(name: 'rating')
  double get rating => throw _privateConstructorUsedError;
  @JsonKey(name: 'deal_count')
  int get dealCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'phone')
  String? get phone => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AgentBriefCopyWith<AgentBrief> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AgentBriefCopyWith<$Res> {
  factory $AgentBriefCopyWith(
          AgentBrief value, $Res Function(AgentBrief) then) =
      _$AgentBriefCopyWithImpl<$Res, AgentBrief>;
  @useResult
  $Res call(
      {@JsonKey(name: 'agent_id') int agentId,
      @JsonKey(name: 'name') String name,
      @JsonKey(name: 'avatar') String? avatar,
      @JsonKey(name: 'company') String? company,
      @JsonKey(name: 'rating') double rating,
      @JsonKey(name: 'deal_count') int dealCount,
      @JsonKey(name: 'phone') String? phone});
}

/// @nodoc
class _$AgentBriefCopyWithImpl<$Res, $Val extends AgentBrief>
    implements $AgentBriefCopyWith<$Res> {
  _$AgentBriefCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? agentId = null,
    Object? name = null,
    Object? avatar = freezed,
    Object? company = freezed,
    Object? rating = null,
    Object? dealCount = null,
    Object? phone = freezed,
  }) {
    return _then(_value.copyWith(
      agentId: null == agentId
          ? _value.agentId
          : agentId // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      avatar: freezed == avatar
          ? _value.avatar
          : avatar // ignore: cast_nullable_to_non_nullable
              as String?,
      company: freezed == company
          ? _value.company
          : company // ignore: cast_nullable_to_non_nullable
              as String?,
      rating: null == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as double,
      dealCount: null == dealCount
          ? _value.dealCount
          : dealCount // ignore: cast_nullable_to_non_nullable
              as int,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AgentBriefImplCopyWith<$Res>
    implements $AgentBriefCopyWith<$Res> {
  factory _$$AgentBriefImplCopyWith(
          _$AgentBriefImpl value, $Res Function(_$AgentBriefImpl) then) =
      __$$AgentBriefImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'agent_id') int agentId,
      @JsonKey(name: 'name') String name,
      @JsonKey(name: 'avatar') String? avatar,
      @JsonKey(name: 'company') String? company,
      @JsonKey(name: 'rating') double rating,
      @JsonKey(name: 'deal_count') int dealCount,
      @JsonKey(name: 'phone') String? phone});
}

/// @nodoc
class __$$AgentBriefImplCopyWithImpl<$Res>
    extends _$AgentBriefCopyWithImpl<$Res, _$AgentBriefImpl>
    implements _$$AgentBriefImplCopyWith<$Res> {
  __$$AgentBriefImplCopyWithImpl(
      _$AgentBriefImpl _value, $Res Function(_$AgentBriefImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? agentId = null,
    Object? name = null,
    Object? avatar = freezed,
    Object? company = freezed,
    Object? rating = null,
    Object? dealCount = null,
    Object? phone = freezed,
  }) {
    return _then(_$AgentBriefImpl(
      agentId: null == agentId
          ? _value.agentId
          : agentId // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      avatar: freezed == avatar
          ? _value.avatar
          : avatar // ignore: cast_nullable_to_non_nullable
              as String?,
      company: freezed == company
          ? _value.company
          : company // ignore: cast_nullable_to_non_nullable
              as String?,
      rating: null == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as double,
      dealCount: null == dealCount
          ? _value.dealCount
          : dealCount // ignore: cast_nullable_to_non_nullable
              as int,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AgentBriefImpl implements _AgentBrief {
  const _$AgentBriefImpl(
      {@JsonKey(name: 'agent_id') required this.agentId,
      @JsonKey(name: 'name') required this.name,
      @JsonKey(name: 'avatar') this.avatar,
      @JsonKey(name: 'company') this.company,
      @JsonKey(name: 'rating') this.rating = 0.0,
      @JsonKey(name: 'deal_count') this.dealCount = 0,
      @JsonKey(name: 'phone') this.phone});

  factory _$AgentBriefImpl.fromJson(Map<String, dynamic> json) =>
      _$$AgentBriefImplFromJson(json);

  @override
  @JsonKey(name: 'agent_id')
  final int agentId;
  @override
  @JsonKey(name: 'name')
  final String name;
  @override
  @JsonKey(name: 'avatar')
  final String? avatar;
  @override
  @JsonKey(name: 'company')
  final String? company;
  @override
  @JsonKey(name: 'rating')
  final double rating;
  @override
  @JsonKey(name: 'deal_count')
  final int dealCount;
  @override
  @JsonKey(name: 'phone')
  final String? phone;

  @override
  String toString() {
    return 'AgentBrief(agentId: $agentId, name: $name, avatar: $avatar, company: $company, rating: $rating, dealCount: $dealCount, phone: $phone)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AgentBriefImpl &&
            (identical(other.agentId, agentId) || other.agentId == agentId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.avatar, avatar) || other.avatar == avatar) &&
            (identical(other.company, company) || other.company == company) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.dealCount, dealCount) ||
                other.dealCount == dealCount) &&
            (identical(other.phone, phone) || other.phone == phone));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, agentId, name, avatar, company, rating, dealCount, phone);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AgentBriefImplCopyWith<_$AgentBriefImpl> get copyWith =>
      __$$AgentBriefImplCopyWithImpl<_$AgentBriefImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AgentBriefImplToJson(
      this,
    );
  }
}

abstract class _AgentBrief implements AgentBrief {
  const factory _AgentBrief(
      {@JsonKey(name: 'agent_id') required final int agentId,
      @JsonKey(name: 'name') required final String name,
      @JsonKey(name: 'avatar') final String? avatar,
      @JsonKey(name: 'company') final String? company,
      @JsonKey(name: 'rating') final double rating,
      @JsonKey(name: 'deal_count') final int dealCount,
      @JsonKey(name: 'phone') final String? phone}) = _$AgentBriefImpl;

  factory _AgentBrief.fromJson(Map<String, dynamic> json) =
      _$AgentBriefImpl.fromJson;

  @override
  @JsonKey(name: 'agent_id')
  int get agentId;
  @override
  @JsonKey(name: 'name')
  String get name;
  @override
  @JsonKey(name: 'avatar')
  String? get avatar;
  @override
  @JsonKey(name: 'company')
  String? get company;
  @override
  @JsonKey(name: 'rating')
  double get rating;
  @override
  @JsonKey(name: 'deal_count')
  int get dealCount;
  @override
  @JsonKey(name: 'phone')
  String? get phone;
  @override
  @JsonKey(ignore: true)
  _$$AgentBriefImplCopyWith<_$AgentBriefImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

HouseStats _$HouseStatsFromJson(Map<String, dynamic> json) {
  return _HouseStats.fromJson(json);
}

/// @nodoc
mixin _$HouseStats {
  @JsonKey(name: 'view_count')
  int get viewCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'favorite_count')
  int get favoriteCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'inquiry_count')
  int get inquiryCount => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $HouseStatsCopyWith<HouseStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HouseStatsCopyWith<$Res> {
  factory $HouseStatsCopyWith(
          HouseStats value, $Res Function(HouseStats) then) =
      _$HouseStatsCopyWithImpl<$Res, HouseStats>;
  @useResult
  $Res call(
      {@JsonKey(name: 'view_count') int viewCount,
      @JsonKey(name: 'favorite_count') int favoriteCount,
      @JsonKey(name: 'inquiry_count') int inquiryCount});
}

/// @nodoc
class _$HouseStatsCopyWithImpl<$Res, $Val extends HouseStats>
    implements $HouseStatsCopyWith<$Res> {
  _$HouseStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? viewCount = null,
    Object? favoriteCount = null,
    Object? inquiryCount = null,
  }) {
    return _then(_value.copyWith(
      viewCount: null == viewCount
          ? _value.viewCount
          : viewCount // ignore: cast_nullable_to_non_nullable
              as int,
      favoriteCount: null == favoriteCount
          ? _value.favoriteCount
          : favoriteCount // ignore: cast_nullable_to_non_nullable
              as int,
      inquiryCount: null == inquiryCount
          ? _value.inquiryCount
          : inquiryCount // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$HouseStatsImplCopyWith<$Res>
    implements $HouseStatsCopyWith<$Res> {
  factory _$$HouseStatsImplCopyWith(
          _$HouseStatsImpl value, $Res Function(_$HouseStatsImpl) then) =
      __$$HouseStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'view_count') int viewCount,
      @JsonKey(name: 'favorite_count') int favoriteCount,
      @JsonKey(name: 'inquiry_count') int inquiryCount});
}

/// @nodoc
class __$$HouseStatsImplCopyWithImpl<$Res>
    extends _$HouseStatsCopyWithImpl<$Res, _$HouseStatsImpl>
    implements _$$HouseStatsImplCopyWith<$Res> {
  __$$HouseStatsImplCopyWithImpl(
      _$HouseStatsImpl _value, $Res Function(_$HouseStatsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? viewCount = null,
    Object? favoriteCount = null,
    Object? inquiryCount = null,
  }) {
    return _then(_$HouseStatsImpl(
      viewCount: null == viewCount
          ? _value.viewCount
          : viewCount // ignore: cast_nullable_to_non_nullable
              as int,
      favoriteCount: null == favoriteCount
          ? _value.favoriteCount
          : favoriteCount // ignore: cast_nullable_to_non_nullable
              as int,
      inquiryCount: null == inquiryCount
          ? _value.inquiryCount
          : inquiryCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$HouseStatsImpl implements _HouseStats {
  const _$HouseStatsImpl(
      {@JsonKey(name: 'view_count') this.viewCount = 0,
      @JsonKey(name: 'favorite_count') this.favoriteCount = 0,
      @JsonKey(name: 'inquiry_count') this.inquiryCount = 0});

  factory _$HouseStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$HouseStatsImplFromJson(json);

  @override
  @JsonKey(name: 'view_count')
  final int viewCount;
  @override
  @JsonKey(name: 'favorite_count')
  final int favoriteCount;
  @override
  @JsonKey(name: 'inquiry_count')
  final int inquiryCount;

  @override
  String toString() {
    return 'HouseStats(viewCount: $viewCount, favoriteCount: $favoriteCount, inquiryCount: $inquiryCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HouseStatsImpl &&
            (identical(other.viewCount, viewCount) ||
                other.viewCount == viewCount) &&
            (identical(other.favoriteCount, favoriteCount) ||
                other.favoriteCount == favoriteCount) &&
            (identical(other.inquiryCount, inquiryCount) ||
                other.inquiryCount == inquiryCount));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, viewCount, favoriteCount, inquiryCount);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$HouseStatsImplCopyWith<_$HouseStatsImpl> get copyWith =>
      __$$HouseStatsImplCopyWithImpl<_$HouseStatsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HouseStatsImplToJson(
      this,
    );
  }
}

abstract class _HouseStats implements HouseStats {
  const factory _HouseStats(
          {@JsonKey(name: 'view_count') final int viewCount,
          @JsonKey(name: 'favorite_count') final int favoriteCount,
          @JsonKey(name: 'inquiry_count') final int inquiryCount}) =
      _$HouseStatsImpl;

  factory _HouseStats.fromJson(Map<String, dynamic> json) =
      _$HouseStatsImpl.fromJson;

  @override
  @JsonKey(name: 'view_count')
  int get viewCount;
  @override
  @JsonKey(name: 'favorite_count')
  int get favoriteCount;
  @override
  @JsonKey(name: 'inquiry_count')
  int get inquiryCount;
  @override
  @JsonKey(ignore: true)
  _$$HouseStatsImplCopyWith<_$HouseStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MapCluster _$MapClusterFromJson(Map<String, dynamic> json) {
  return _MapCluster.fromJson(json);
}

/// @nodoc
mixin _$MapCluster {
  @JsonKey(name: 'id')
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'name')
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'lat')
  double get lat => throw _privateConstructorUsedError;
  @JsonKey(name: 'lng')
  double get lng => throw _privateConstructorUsedError;
  @JsonKey(name: 'avg_price')
  int? get avgPrice => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_count')
  int get totalCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'bounds')
  MapBounds? get bounds => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $MapClusterCopyWith<MapCluster> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MapClusterCopyWith<$Res> {
  factory $MapClusterCopyWith(
          MapCluster value, $Res Function(MapCluster) then) =
      _$MapClusterCopyWithImpl<$Res, MapCluster>;
  @useResult
  $Res call(
      {@JsonKey(name: 'id') String id,
      @JsonKey(name: 'name') String name,
      @JsonKey(name: 'lat') double lat,
      @JsonKey(name: 'lng') double lng,
      @JsonKey(name: 'avg_price') int? avgPrice,
      @JsonKey(name: 'total_count') int totalCount,
      @JsonKey(name: 'bounds') MapBounds? bounds});

  $MapBoundsCopyWith<$Res>? get bounds;
}

/// @nodoc
class _$MapClusterCopyWithImpl<$Res, $Val extends MapCluster>
    implements $MapClusterCopyWith<$Res> {
  _$MapClusterCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? lat = null,
    Object? lng = null,
    Object? avgPrice = freezed,
    Object? totalCount = null,
    Object? bounds = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      lat: null == lat
          ? _value.lat
          : lat // ignore: cast_nullable_to_non_nullable
              as double,
      lng: null == lng
          ? _value.lng
          : lng // ignore: cast_nullable_to_non_nullable
              as double,
      avgPrice: freezed == avgPrice
          ? _value.avgPrice
          : avgPrice // ignore: cast_nullable_to_non_nullable
              as int?,
      totalCount: null == totalCount
          ? _value.totalCount
          : totalCount // ignore: cast_nullable_to_non_nullable
              as int,
      bounds: freezed == bounds
          ? _value.bounds
          : bounds // ignore: cast_nullable_to_non_nullable
              as MapBounds?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $MapBoundsCopyWith<$Res>? get bounds {
    if (_value.bounds == null) {
      return null;
    }

    return $MapBoundsCopyWith<$Res>(_value.bounds!, (value) {
      return _then(_value.copyWith(bounds: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$MapClusterImplCopyWith<$Res>
    implements $MapClusterCopyWith<$Res> {
  factory _$$MapClusterImplCopyWith(
          _$MapClusterImpl value, $Res Function(_$MapClusterImpl) then) =
      __$$MapClusterImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'id') String id,
      @JsonKey(name: 'name') String name,
      @JsonKey(name: 'lat') double lat,
      @JsonKey(name: 'lng') double lng,
      @JsonKey(name: 'avg_price') int? avgPrice,
      @JsonKey(name: 'total_count') int totalCount,
      @JsonKey(name: 'bounds') MapBounds? bounds});

  @override
  $MapBoundsCopyWith<$Res>? get bounds;
}

/// @nodoc
class __$$MapClusterImplCopyWithImpl<$Res>
    extends _$MapClusterCopyWithImpl<$Res, _$MapClusterImpl>
    implements _$$MapClusterImplCopyWith<$Res> {
  __$$MapClusterImplCopyWithImpl(
      _$MapClusterImpl _value, $Res Function(_$MapClusterImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? lat = null,
    Object? lng = null,
    Object? avgPrice = freezed,
    Object? totalCount = null,
    Object? bounds = freezed,
  }) {
    return _then(_$MapClusterImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      lat: null == lat
          ? _value.lat
          : lat // ignore: cast_nullable_to_non_nullable
              as double,
      lng: null == lng
          ? _value.lng
          : lng // ignore: cast_nullable_to_non_nullable
              as double,
      avgPrice: freezed == avgPrice
          ? _value.avgPrice
          : avgPrice // ignore: cast_nullable_to_non_nullable
              as int?,
      totalCount: null == totalCount
          ? _value.totalCount
          : totalCount // ignore: cast_nullable_to_non_nullable
              as int,
      bounds: freezed == bounds
          ? _value.bounds
          : bounds // ignore: cast_nullable_to_non_nullable
              as MapBounds?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MapClusterImpl implements _MapCluster {
  const _$MapClusterImpl(
      {@JsonKey(name: 'id') required this.id,
      @JsonKey(name: 'name') required this.name,
      @JsonKey(name: 'lat') required this.lat,
      @JsonKey(name: 'lng') required this.lng,
      @JsonKey(name: 'avg_price') this.avgPrice,
      @JsonKey(name: 'total_count') required this.totalCount,
      @JsonKey(name: 'bounds') this.bounds});

  factory _$MapClusterImpl.fromJson(Map<String, dynamic> json) =>
      _$$MapClusterImplFromJson(json);

  @override
  @JsonKey(name: 'id')
  final String id;
  @override
  @JsonKey(name: 'name')
  final String name;
  @override
  @JsonKey(name: 'lat')
  final double lat;
  @override
  @JsonKey(name: 'lng')
  final double lng;
  @override
  @JsonKey(name: 'avg_price')
  final int? avgPrice;
  @override
  @JsonKey(name: 'total_count')
  final int totalCount;
  @override
  @JsonKey(name: 'bounds')
  final MapBounds? bounds;

  @override
  String toString() {
    return 'MapCluster(id: $id, name: $name, lat: $lat, lng: $lng, avgPrice: $avgPrice, totalCount: $totalCount, bounds: $bounds)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MapClusterImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.lat, lat) || other.lat == lat) &&
            (identical(other.lng, lng) || other.lng == lng) &&
            (identical(other.avgPrice, avgPrice) ||
                other.avgPrice == avgPrice) &&
            (identical(other.totalCount, totalCount) ||
                other.totalCount == totalCount) &&
            (identical(other.bounds, bounds) || other.bounds == bounds));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, name, lat, lng, avgPrice, totalCount, bounds);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MapClusterImplCopyWith<_$MapClusterImpl> get copyWith =>
      __$$MapClusterImplCopyWithImpl<_$MapClusterImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MapClusterImplToJson(
      this,
    );
  }
}

abstract class _MapCluster implements MapCluster {
  const factory _MapCluster(
      {@JsonKey(name: 'id') required final String id,
      @JsonKey(name: 'name') required final String name,
      @JsonKey(name: 'lat') required final double lat,
      @JsonKey(name: 'lng') required final double lng,
      @JsonKey(name: 'avg_price') final int? avgPrice,
      @JsonKey(name: 'total_count') required final int totalCount,
      @JsonKey(name: 'bounds') final MapBounds? bounds}) = _$MapClusterImpl;

  factory _MapCluster.fromJson(Map<String, dynamic> json) =
      _$MapClusterImpl.fromJson;

  @override
  @JsonKey(name: 'id')
  String get id;
  @override
  @JsonKey(name: 'name')
  String get name;
  @override
  @JsonKey(name: 'lat')
  double get lat;
  @override
  @JsonKey(name: 'lng')
  double get lng;
  @override
  @JsonKey(name: 'avg_price')
  int? get avgPrice;
  @override
  @JsonKey(name: 'total_count')
  int get totalCount;
  @override
  @JsonKey(name: 'bounds')
  MapBounds? get bounds;
  @override
  @JsonKey(ignore: true)
  _$$MapClusterImplCopyWith<_$MapClusterImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MapBounds _$MapBoundsFromJson(Map<String, dynamic> json) {
  return _MapBounds.fromJson(json);
}

/// @nodoc
mixin _$MapBounds {
  @JsonKey(name: 'sw_lat')
  double get swLat => throw _privateConstructorUsedError;
  @JsonKey(name: 'sw_lng')
  double get swLng => throw _privateConstructorUsedError;
  @JsonKey(name: 'ne_lat')
  double get neLat => throw _privateConstructorUsedError;
  @JsonKey(name: 'ne_lng')
  double get neLng => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $MapBoundsCopyWith<MapBounds> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MapBoundsCopyWith<$Res> {
  factory $MapBoundsCopyWith(MapBounds value, $Res Function(MapBounds) then) =
      _$MapBoundsCopyWithImpl<$Res, MapBounds>;
  @useResult
  $Res call(
      {@JsonKey(name: 'sw_lat') double swLat,
      @JsonKey(name: 'sw_lng') double swLng,
      @JsonKey(name: 'ne_lat') double neLat,
      @JsonKey(name: 'ne_lng') double neLng});
}

/// @nodoc
class _$MapBoundsCopyWithImpl<$Res, $Val extends MapBounds>
    implements $MapBoundsCopyWith<$Res> {
  _$MapBoundsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? swLat = null,
    Object? swLng = null,
    Object? neLat = null,
    Object? neLng = null,
  }) {
    return _then(_value.copyWith(
      swLat: null == swLat
          ? _value.swLat
          : swLat // ignore: cast_nullable_to_non_nullable
              as double,
      swLng: null == swLng
          ? _value.swLng
          : swLng // ignore: cast_nullable_to_non_nullable
              as double,
      neLat: null == neLat
          ? _value.neLat
          : neLat // ignore: cast_nullable_to_non_nullable
              as double,
      neLng: null == neLng
          ? _value.neLng
          : neLng // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MapBoundsImplCopyWith<$Res>
    implements $MapBoundsCopyWith<$Res> {
  factory _$$MapBoundsImplCopyWith(
          _$MapBoundsImpl value, $Res Function(_$MapBoundsImpl) then) =
      __$$MapBoundsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'sw_lat') double swLat,
      @JsonKey(name: 'sw_lng') double swLng,
      @JsonKey(name: 'ne_lat') double neLat,
      @JsonKey(name: 'ne_lng') double neLng});
}

/// @nodoc
class __$$MapBoundsImplCopyWithImpl<$Res>
    extends _$MapBoundsCopyWithImpl<$Res, _$MapBoundsImpl>
    implements _$$MapBoundsImplCopyWith<$Res> {
  __$$MapBoundsImplCopyWithImpl(
      _$MapBoundsImpl _value, $Res Function(_$MapBoundsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? swLat = null,
    Object? swLng = null,
    Object? neLat = null,
    Object? neLng = null,
  }) {
    return _then(_$MapBoundsImpl(
      swLat: null == swLat
          ? _value.swLat
          : swLat // ignore: cast_nullable_to_non_nullable
              as double,
      swLng: null == swLng
          ? _value.swLng
          : swLng // ignore: cast_nullable_to_non_nullable
              as double,
      neLat: null == neLat
          ? _value.neLat
          : neLat // ignore: cast_nullable_to_non_nullable
              as double,
      neLng: null == neLng
          ? _value.neLng
          : neLng // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MapBoundsImpl implements _MapBounds {
  const _$MapBoundsImpl(
      {@JsonKey(name: 'sw_lat') required this.swLat,
      @JsonKey(name: 'sw_lng') required this.swLng,
      @JsonKey(name: 'ne_lat') required this.neLat,
      @JsonKey(name: 'ne_lng') required this.neLng});

  factory _$MapBoundsImpl.fromJson(Map<String, dynamic> json) =>
      _$$MapBoundsImplFromJson(json);

  @override
  @JsonKey(name: 'sw_lat')
  final double swLat;
  @override
  @JsonKey(name: 'sw_lng')
  final double swLng;
  @override
  @JsonKey(name: 'ne_lat')
  final double neLat;
  @override
  @JsonKey(name: 'ne_lng')
  final double neLng;

  @override
  String toString() {
    return 'MapBounds(swLat: $swLat, swLng: $swLng, neLat: $neLat, neLng: $neLng)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MapBoundsImpl &&
            (identical(other.swLat, swLat) || other.swLat == swLat) &&
            (identical(other.swLng, swLng) || other.swLng == swLng) &&
            (identical(other.neLat, neLat) || other.neLat == neLat) &&
            (identical(other.neLng, neLng) || other.neLng == neLng));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, swLat, swLng, neLat, neLng);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MapBoundsImplCopyWith<_$MapBoundsImpl> get copyWith =>
      __$$MapBoundsImplCopyWithImpl<_$MapBoundsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MapBoundsImplToJson(
      this,
    );
  }
}

abstract class _MapBounds implements MapBounds {
  const factory _MapBounds(
      {@JsonKey(name: 'sw_lat') required final double swLat,
      @JsonKey(name: 'sw_lng') required final double swLng,
      @JsonKey(name: 'ne_lat') required final double neLat,
      @JsonKey(name: 'ne_lng') required final double neLng}) = _$MapBoundsImpl;

  factory _MapBounds.fromJson(Map<String, dynamic> json) =
      _$MapBoundsImpl.fromJson;

  @override
  @JsonKey(name: 'sw_lat')
  double get swLat;
  @override
  @JsonKey(name: 'sw_lng')
  double get swLng;
  @override
  @JsonKey(name: 'ne_lat')
  double get neLat;
  @override
  @JsonKey(name: 'ne_lng')
  double get neLng;
  @override
  @JsonKey(ignore: true)
  _$$MapBoundsImplCopyWith<_$MapBoundsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
