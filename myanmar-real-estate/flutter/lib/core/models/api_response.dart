/**
 * API响应基类
 */
import 'package:freezed_annotation/freezed_annotation.dart';

part 'api_response.freezed.dart';
part 'api_response.g.dart';

@Freezed(genericArgumentFactories: true)
class ApiResponse<T> with _$ApiResponse<T> {
  const ApiResponse._();

  const factory ApiResponse({
    required int code,
    required String message,
    T? data,
    int? timestamp,
    String? requestId,
  }) = _ApiResponse;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
  ) =>
      _$ApiResponseFromJson<T>(json, fromJsonT);

  bool get isSuccess => code == 200;
}

/**
 * 分页数据包装类
 */
@Freezed(genericArgumentFactories: true)
class PaginatedData<T> with _$PaginatedData<T> {
  const factory PaginatedData({
    required List<T> list,
    required PaginationInfo pagination,
  }) = _PaginatedData;

  factory PaginatedData.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
  ) =>
      _$PaginatedDataFromJson<T>(json, fromJsonT);
}

/**
 * 分页信息
 */
@freezed
class PaginationInfo with _$PaginationInfo {
  const factory PaginationInfo({
    @JsonKey(name: 'page') @Default(1) int page,
    @JsonKey(name: 'page_size') @Default(20) int pageSize,
    @JsonKey(name: 'total') @Default(0) int total,
    @JsonKey(name: 'has_more') @Default(false) bool hasMore,
    @JsonKey(name: 'next_cursor') String? nextCursor,
  }) = _PaginationInfo;

  factory PaginationInfo.fromJson(Map<String, dynamic> json) =>
      _$PaginationInfoFromJson(json);
}

/**
 * API异常类
 */
class ApiException implements Exception {
  final int code;
  final String message;
  final String? requestId;

  const ApiException({
    required this.code,
    required this.message,
    this.requestId,
  });

  @override
  String toString() => 'ApiException(code: $code, message: $message, requestId: $requestId)';
}
