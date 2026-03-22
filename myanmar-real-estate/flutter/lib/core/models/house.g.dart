// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'house.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$HouseImpl _$$HouseImplFromJson(Map<String, dynamic> json) => _$HouseImpl(
      houseId: (json['house_id'] as num).toInt(),
      houseCode: json['house_code'] as String?,
      title: json['title'] as String,
      titleMy: json['title_my'] as String?,
      transactionType: json['transaction_type'] as String,
      price: (json['price'] as num).toInt(),
      priceUnit: json['price_unit'] as String? ?? 'MMK',
      priceNote: json['price_note'] as String?,
      houseType: json['house_type'] as String,
      propertyType: json['property_type'] as String?,
      area: (json['area'] as num?)?.toDouble(),
      usableArea: (json['usable_area'] as num?)?.toDouble(),
      rooms: json['rooms'] as String?,
      bedrooms: (json['bedrooms'] as num?)?.toInt(),
      livingRooms: (json['living_rooms'] as num?)?.toInt(),
      bathrooms: (json['bathrooms'] as num?)?.toInt(),
      floor: json['floor'] as String?,
      decoration: json['decoration'] as String?,
      orientation: json['orientation'] as String?,
      buildYear: (json['build_year'] as num?)?.toInt(),
      location: json['location'] == null
          ? null
          : HouseLocation.fromJson(json['location'] as Map<String, dynamic>),
      description: json['description'] as String?,
      highlights: (json['highlights'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      facilities: (json['facilities'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      property: json['property'] == null
          ? null
          : PropertyInfo.fromJson(json['property'] as Map<String, dynamic>),
      verification: json['verification'] == null
          ? null
          : VerificationInfo.fromJson(
              json['verification'] as Map<String, dynamic>),
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => HouseImage.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      agent: json['agent'] == null
          ? null
          : AgentBrief.fromJson(json['agent'] as Map<String, dynamic>),
      stats: json['stats'] == null
          ? null
          : HouseStats.fromJson(json['stats'] as Map<String, dynamic>),
      isFavorited: json['is_favorited'] as bool? ?? false,
      status: json['status'] as String? ?? 'online',
      createdAt: json['created_at'] as String?,
      publishedAt: json['published_at'] as String?,
    );

Map<String, dynamic> _$$HouseImplToJson(_$HouseImpl instance) =>
    <String, dynamic>{
      'house_id': instance.houseId,
      'house_code': instance.houseCode,
      'title': instance.title,
      'title_my': instance.titleMy,
      'transaction_type': instance.transactionType,
      'price': instance.price,
      'price_unit': instance.priceUnit,
      'price_note': instance.priceNote,
      'house_type': instance.houseType,
      'property_type': instance.propertyType,
      'area': instance.area,
      'usable_area': instance.usableArea,
      'rooms': instance.rooms,
      'bedrooms': instance.bedrooms,
      'living_rooms': instance.livingRooms,
      'bathrooms': instance.bathrooms,
      'floor': instance.floor,
      'decoration': instance.decoration,
      'orientation': instance.orientation,
      'build_year': instance.buildYear,
      'location': instance.location,
      'description': instance.description,
      'highlights': instance.highlights,
      'facilities': instance.facilities,
      'property': instance.property,
      'verification': instance.verification,
      'images': instance.images,
      'agent': instance.agent,
      'stats': instance.stats,
      'is_favorited': instance.isFavorited,
      'status': instance.status,
      'created_at': instance.createdAt,
      'published_at': instance.publishedAt,
    };

_$HouseLocationImpl _$$HouseLocationImplFromJson(Map<String, dynamic> json) =>
    _$HouseLocationImpl(
      city: json['city'] == null
          ? null
          : CityInfo.fromJson(json['city'] as Map<String, dynamic>),
      district: json['district'] == null
          ? null
          : DistrictInfo.fromJson(json['district'] as Map<String, dynamic>),
      community: json['community'] == null
          ? null
          : CommunityInfo.fromJson(json['community'] as Map<String, dynamic>),
      address: json['address'] as String?,
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$HouseLocationImplToJson(_$HouseLocationImpl instance) =>
    <String, dynamic>{
      'city': instance.city,
      'district': instance.district,
      'community': instance.community,
      'address': instance.address,
      'lat': instance.lat,
      'lng': instance.lng,
    };

_$CityInfoImpl _$$CityInfoImplFromJson(Map<String, dynamic> json) =>
    _$CityInfoImpl(
      code: json['code'] as String,
      name: json['name'] as String,
    );

Map<String, dynamic> _$$CityInfoImplToJson(_$CityInfoImpl instance) =>
    <String, dynamic>{
      'code': instance.code,
      'name': instance.name,
    };

_$DistrictInfoImpl _$$DistrictInfoImplFromJson(Map<String, dynamic> json) =>
    _$DistrictInfoImpl(
      code: json['code'] as String,
      name: json['name'] as String,
    );

Map<String, dynamic> _$$DistrictInfoImplToJson(_$DistrictInfoImpl instance) =>
    <String, dynamic>{
      'code': instance.code,
      'name': instance.name,
    };

_$CommunityInfoImpl _$$CommunityInfoImplFromJson(Map<String, dynamic> json) =>
    _$CommunityInfoImpl(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
    );

Map<String, dynamic> _$$CommunityInfoImplToJson(_$CommunityInfoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
    };

_$PropertyInfoImpl _$$PropertyInfoImplFromJson(Map<String, dynamic> json) =>
    _$PropertyInfoImpl(
      propertyType: json['property_type'] as String?,
      ownership: json['ownership'] as String?,
      hasLoan: json['has_loan'] as bool? ?? false,
      propertyCertificateNo: json['property_certificate_no'] as String?,
    );

Map<String, dynamic> _$$PropertyInfoImplToJson(_$PropertyInfoImpl instance) =>
    <String, dynamic>{
      'property_type': instance.propertyType,
      'ownership': instance.ownership,
      'has_loan': instance.hasLoan,
      'property_certificate_no': instance.propertyCertificateNo,
    };

_$VerificationInfoImpl _$$VerificationInfoImplFromJson(
        Map<String, dynamic> json) =>
    _$VerificationInfoImpl(
      status: json['status'] as String? ?? 'pending',
      verifiedAt: json['verified_at'] as String?,
      verifiedBy: json['verified_by'] as String?,
      reportUrl: json['report_url'] as String?,
    );

Map<String, dynamic> _$$VerificationInfoImplToJson(
        _$VerificationInfoImpl instance) =>
    <String, dynamic>{
      'status': instance.status,
      'verified_at': instance.verifiedAt,
      'verified_by': instance.verifiedBy,
      'report_url': instance.reportUrl,
    };

_$HouseImageImpl _$$HouseImageImplFromJson(Map<String, dynamic> json) =>
    _$HouseImageImpl(
      id: (json['id'] as num).toInt(),
      url: json['url'] as String,
      type: json['type'] as String? ?? 'interior',
      isMain: json['is_main'] as bool? ?? false,
    );

Map<String, dynamic> _$$HouseImageImplToJson(_$HouseImageImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'url': instance.url,
      'type': instance.type,
      'is_main': instance.isMain,
    };

_$AgentBriefImpl _$$AgentBriefImplFromJson(Map<String, dynamic> json) =>
    _$AgentBriefImpl(
      agentId: (json['agent_id'] as num).toInt(),
      name: json['name'] as String,
      avatar: json['avatar'] as String?,
      company: json['company'] as String?,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      dealCount: (json['deal_count'] as num?)?.toInt() ?? 0,
      phone: json['phone'] as String?,
    );

Map<String, dynamic> _$$AgentBriefImplToJson(_$AgentBriefImpl instance) =>
    <String, dynamic>{
      'agent_id': instance.agentId,
      'name': instance.name,
      'avatar': instance.avatar,
      'company': instance.company,
      'rating': instance.rating,
      'deal_count': instance.dealCount,
      'phone': instance.phone,
    };

_$HouseStatsImpl _$$HouseStatsImplFromJson(Map<String, dynamic> json) =>
    _$HouseStatsImpl(
      viewCount: (json['view_count'] as num?)?.toInt() ?? 0,
      favoriteCount: (json['favorite_count'] as num?)?.toInt() ?? 0,
      inquiryCount: (json['inquiry_count'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$HouseStatsImplToJson(_$HouseStatsImpl instance) =>
    <String, dynamic>{
      'view_count': instance.viewCount,
      'favorite_count': instance.favoriteCount,
      'inquiry_count': instance.inquiryCount,
    };

_$MapClusterImpl _$$MapClusterImplFromJson(Map<String, dynamic> json) =>
    _$MapClusterImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      avgPrice: (json['avg_price'] as num?)?.toInt(),
      totalCount: (json['total_count'] as num).toInt(),
      bounds: json['bounds'] == null
          ? null
          : MapBounds.fromJson(json['bounds'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$MapClusterImplToJson(_$MapClusterImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'lat': instance.lat,
      'lng': instance.lng,
      'avg_price': instance.avgPrice,
      'total_count': instance.totalCount,
      'bounds': instance.bounds,
    };

_$MapBoundsImpl _$$MapBoundsImplFromJson(Map<String, dynamic> json) =>
    _$MapBoundsImpl(
      swLat: (json['sw_lat'] as num).toDouble(),
      swLng: (json['sw_lng'] as num).toDouble(),
      neLat: (json['ne_lat'] as num).toDouble(),
      neLng: (json['ne_lng'] as num).toDouble(),
    );

Map<String, dynamic> _$$MapBoundsImplToJson(_$MapBoundsImpl instance) =>
    <String, dynamic>{
      'sw_lat': instance.swLat,
      'sw_lng': instance.swLng,
      'ne_lat': instance.neLat,
      'ne_lng': instance.neLng,
    };
