/**
 * 房源模型
 */
import 'package:freezed_annotation/freezed_annotation.dart';

part 'house.freezed.dart';
part 'house.g.dart';

@freezed
class House with _$House {
  const House._();

  const factory House({
    @JsonKey(name: 'house_id') required int houseId,
    @JsonKey(name: 'house_code') String? houseCode,
    @JsonKey(name: 'title') required String title,
    @JsonKey(name: 'title_my') String? titleMy,
    @JsonKey(name: 'transaction_type') required String transactionType,
    @JsonKey(name: 'price') required int price,
    @JsonKey(name: 'price_unit') @Default('MMK') String priceUnit,
    @JsonKey(name: 'price_note') String? priceNote,
    @JsonKey(name: 'house_type') required String houseType,
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
    @JsonKey(name: 'images') @Default([]) List<HouseImage> images,
    @JsonKey(name: 'agent') AgentBrief? agent,
    @JsonKey(name: 'stats') HouseStats? stats,
    @JsonKey(name: 'is_favorited') @Default(false) bool isFavorited,
    @JsonKey(name: 'status') @Default('online') String status,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'published_at') String? publishedAt,
  }) = _House;

  factory House.fromJson(Map<String, dynamic> json) => _$HouseFromJson(json);

  /// 获取格式化的价格
  String get formattedPrice {
    if (price >= 100000000) {
      return '${(price / 100000000).toStringAsFixed(1)}亿';
    } else if (price >= 10000) {
      return '${(price / 10000).toStringAsFixed(0)}万';
    }
    return price.toString();
  }

  /// 获取主图
  String? get mainImage {
    final main = images.where((img) => img.isMain).firstOrNull;
    return main?.url ?? images.firstOrNull?.url;
  }

  /// 是否已验真
  bool get isVerified => verification?.status == 'verified';
}

@freezed
class HouseLocation with _$HouseLocation {
  const factory HouseLocation({
    @JsonKey(name: 'city') CityInfo? city,
    @JsonKey(name: 'district') DistrictInfo? district,
    @JsonKey(name: 'community') CommunityInfo? community,
    @JsonKey(name: 'address') String? address,
    @JsonKey(name: 'lat') double? lat,
    @JsonKey(name: 'lng') double? lng,
  }) = _HouseLocation;

  factory HouseLocation.fromJson(Map<String, dynamic> json) =>
      _$HouseLocationFromJson(json);
}

@freezed
class CityInfo with _$CityInfo {
  const factory CityInfo({
    @JsonKey(name: 'code') required String code,
    @JsonKey(name: 'name') required String name,
  }) = _CityInfo;

  factory CityInfo.fromJson(Map<String, dynamic> json) =>
      _$CityInfoFromJson(json);
}

@freezed
class DistrictInfo with _$DistrictInfo {
  const factory DistrictInfo({
    @JsonKey(name: 'code') required String code,
    @JsonKey(name: 'name') required String name,
  }) = _DistrictInfo;

  factory DistrictInfo.fromJson(Map<String, dynamic> json) =>
      _$DistrictInfoFromJson(json);
}

@freezed
class CommunityInfo with _$CommunityInfo {
  const factory CommunityInfo({
    @JsonKey(name: 'id') required int id,
    @JsonKey(name: 'name') required String name,
  }) = _CommunityInfo;

  factory CommunityInfo.fromJson(Map<String, dynamic> json) =>
      _$CommunityInfoFromJson(json);
}

@freezed
class PropertyInfo with _$PropertyInfo {
  const factory PropertyInfo({
    @JsonKey(name: 'property_type') String? propertyType,
    @JsonKey(name: 'ownership') String? ownership,
    @JsonKey(name: 'has_loan') @Default(false) bool hasLoan,
    @JsonKey(name: 'property_certificate_no') String? propertyCertificateNo,
  }) = _PropertyInfo;

  factory PropertyInfo.fromJson(Map<String, dynamic> json) =>
      _$PropertyInfoFromJson(json);
}

@freezed
class VerificationInfo with _$VerificationInfo {
  const factory VerificationInfo({
    @JsonKey(name: 'status') @Default('pending') String status,
    @JsonKey(name: 'verified_at') String? verifiedAt,
    @JsonKey(name: 'verified_by') String? verifiedBy,
    @JsonKey(name: 'report_url') String? reportUrl,
  }) = _VerificationInfo;

  factory VerificationInfo.fromJson(Map<String, dynamic> json) =>
      _$VerificationInfoFromJson(json);
}

@freezed
class HouseImage with _$HouseImage {
  const factory HouseImage({
    @JsonKey(name: 'id') required int id,
    @JsonKey(name: 'url') required String url,
    @JsonKey(name: 'type') @Default('interior') String type,
    @JsonKey(name: 'is_main') @Default(false) bool isMain,
  }) = _HouseImage;

  factory HouseImage.fromJson(Map<String, dynamic> json) =>
      _$HouseImageFromJson(json);
}

@freezed
class AgentBrief with _$AgentBrief {
  const factory AgentBrief({
    @JsonKey(name: 'agent_id') required int agentId,
    @JsonKey(name: 'name') required String name,
    @JsonKey(name: 'avatar') String? avatar,
    @JsonKey(name: 'company') String? company,
    @JsonKey(name: 'rating') @Default(0.0) double rating,
    @JsonKey(name: 'deal_count') @Default(0) int dealCount,
    @JsonKey(name: 'phone') String? phone,
  }) = _AgentBrief;

  factory AgentBrief.fromJson(Map<String, dynamic> json) =>
      _$AgentBriefFromJson(json);
}

@freezed
class HouseStats with _$HouseStats {
  const factory HouseStats({
    @JsonKey(name: 'view_count') @Default(0) int viewCount,
    @JsonKey(name: 'favorite_count') @Default(0) int favoriteCount,
    @JsonKey(name: 'inquiry_count') @Default(0) int inquiryCount,
  }) = _HouseStats;

  factory HouseStats.fromJson(Map<String, dynamic> json) =>
      _$HouseStatsFromJson(json);
}

/**
 * 地图聚合数据
 */
@freezed
class MapCluster with _$MapCluster {
  const factory MapCluster({
    @JsonKey(name: 'id') required String id,
    @JsonKey(name: 'name') required String name,
    @JsonKey(name: 'lat') required double lat,
    @JsonKey(name: 'lng') required double lng,
    @JsonKey(name: 'avg_price') int? avgPrice,
    @JsonKey(name: 'total_count') required int totalCount,
    @JsonKey(name: 'bounds') MapBounds? bounds,
  }) = _MapCluster;

  factory MapCluster.fromJson(Map<String, dynamic> json) =>
      _$MapClusterFromJson(json);
}

@freezed
class MapBounds with _$MapBounds {
  const factory MapBounds({
    @JsonKey(name: 'sw_lat') required double swLat,
    @JsonKey(name: 'sw_lng') required double swLng,
    @JsonKey(name: 'ne_lat') required double neLat,
    @JsonKey(name: 'ne_lng') required double neLng,
  }) = _MapBounds;

  factory MapBounds.fromJson(Map<String, dynamic> json) =>
      _$MapBoundsFromJson(json);
}

/**
 * 房源搜索参数
 */
const _sentinel = Object();

class HouseSearchParams {
  String? transactionType;
  bool? isNewHome; // true=新房, false=二手房, null=不过滤
  String? cityCode;
  String? districtCode;
  int? communityId;
  int? priceMin;
  int? priceMax;
  int? areaMin;
  int? areaMax;
  String? houseType;
  String? rooms;
  String? decoration;
  String? keywords;
  String? sortBy;
  int page;
  int pageSize;

  HouseSearchParams({
    this.transactionType,
    this.isNewHome,
    this.cityCode,
    this.districtCode,
    this.communityId,
    this.priceMin,
    this.priceMax,
    this.areaMin,
    this.areaMax,
    this.houseType,
    this.rooms,
    this.decoration,
    this.keywords,
    this.sortBy,
    this.page = 1,
    this.pageSize = 20,
  });

  Map<String, dynamic> toJson() {
    return {
      if (transactionType != null) 'transaction_type': transactionType,
      if (isNewHome != null) 'is_new_home': isNewHome,
      if (cityCode != null) 'city_code': cityCode,
      if (districtCode != null) 'district_code': districtCode,
      if (communityId != null) 'community_id': communityId,
      if (priceMin != null) 'price_min': priceMin,
      if (priceMax != null) 'price_max': priceMax,
      if (areaMin != null) 'area_min': areaMin,
      if (areaMax != null) 'area_max': areaMax,
      if (houseType != null) 'house_type': houseType,
      if (rooms != null) 'rooms': rooms,
      if (decoration != null) 'decoration': decoration,
      if (keywords != null) 'keywords': keywords,
      if (sortBy != null) 'sort_by': sortBy,
      'page': page,
      'page_size': pageSize,
    };
  }

  HouseSearchParams copyWith({
    String? transactionType,
    Object? isNewHome = _sentinel,
    String? cityCode,
    String? districtCode,
    int? communityId,
    int? priceMin,
    int? priceMax,
    int? areaMin,
    int? areaMax,
    String? houseType,
    String? rooms,
    String? decoration,
    String? keywords,
    String? sortBy,
    int? page,
    int? pageSize,
  }) {
    return HouseSearchParams(
      transactionType: transactionType ?? this.transactionType,
      isNewHome: isNewHome == _sentinel ? this.isNewHome : isNewHome as bool?,
      cityCode: cityCode ?? this.cityCode,
      districtCode: districtCode ?? this.districtCode,
      communityId: communityId ?? this.communityId,
      priceMin: priceMin ?? this.priceMin,
      priceMax: priceMax ?? this.priceMax,
      areaMin: areaMin ?? this.areaMin,
      areaMax: areaMax ?? this.areaMax,
      houseType: houseType ?? this.houseType,
      rooms: rooms ?? this.rooms,
      decoration: decoration ?? this.decoration,
      keywords: keywords ?? this.keywords,
      sortBy: sortBy ?? this.sortBy,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
    );
  }
}
