/**
 * API接口定义 - 房源相关
 */
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/api_response.dart';
import '../models/house.dart';

part 'house_api.g.dart';

@RestApi()
abstract class HouseApi {
  factory HouseApi(Dio dio, {String baseUrl}) = _HouseApi;

  /// 首页推荐
  @GET('/houses/recommendations')
  Future<ApiResponse<PaginatedData<House>>> getRecommendations(
    @Queries() Map<String, dynamic> queries,
  );

  /// 房源搜索
  @GET('/houses/search')
  Future<ApiResponse<PaginatedData<House>>> searchHouses(
    @Queries() Map<String, dynamic> queries,
  );

  /// 获取房源详情
  @GET('/houses/{house_id}')
  Future<ApiResponse<House>> getHouseDetail(
    @Path('house_id') int houseId,
  );

  /// 获取相似房源
  @GET('/houses/{house_id}/similar')
  Future<ApiResponse<List<House>>> getSimilarHouses(
    @Path('house_id') int houseId,
  );

  /// 获取推荐房源
  @GET('/houses/suggested')
  Future<ApiResponse<List<House>>> getSuggestedHouses();

  /// 地图找房聚合
  @GET('/houses/map-aggregate')
  Future<ApiResponse<MapCluster>> getMapAggregate(
    @Queries() Map<String, dynamic> queries,
  );

  /// 地图找房列表
  @GET('/houses/map-list')
  Future<ApiResponse<PaginatedData<House>>> getMapHouses(
    @Queries() Map<String, dynamic> queries,
  );

  // ==================== 经纪人接口 ====================

  /// 获取我的房源列表
  @GET('/houses/my')
  Future<ApiResponse<PaginatedData<House>>> getMyHouses(
    @Queries() Map<String, dynamic> queries,
  );

  /// 创建房源
  @POST('/houses')
  Future<ApiResponse<House>> createHouse(
    @Body() Map<String, dynamic> body,
  );

  /// 更新房源
  @PUT('/houses/{house_id}')
  Future<ApiResponse<House>> updateHouse(
    @Path('house_id') int houseId,
    @Body() Map<String, dynamic> body,
  );

  /// 删除房源
  @DELETE('/houses/{house_id}')
  Future<ApiResponse<bool>> deleteHouse(
    @Path('house_id') int houseId,
  );

  /// 上架/下架房源
  @PUT('/houses/{house_id}/status')
  Future<ApiResponse<bool>> updateHouseStatus(
    @Path('house_id') int houseId,
    @Body() Map<String, dynamic> body,
  );

  /// 修改房源价格
  @PUT('/houses/{house_id}/price')
  Future<ApiResponse<bool>> updateHousePrice(
    @Path('house_id') int houseId,
    @Body() Map<String, dynamic> body,
  );

  /// 刷新房源
  @POST('/houses/{house_id}/refresh')
  Future<ApiResponse<bool>> refreshHouse(
    @Path('house_id') int houseId,
  );

  /// 上传房源图片
  @POST('/houses/{house_id}/images')
  @MultiPart()
  Future<ApiResponse<List<HouseImage>>> uploadHouseImages(
    @Path('house_id') int houseId,
    @Part(name: 'files') List<MultipartFile> files,
  );

  /// 删除房源图片
  @DELETE('/houses/{house_id}/images/{image_id}')
  Future<ApiResponse<bool>> deleteHouseImage(
    @Path('house_id') int houseId,
    @Path('image_id') int imageId,
  );

  /// 设置主图
  @PUT('/houses/{house_id}/images/{image_id}/main')
  Future<ApiResponse<bool>> setMainImage(
    @Path('house_id') int houseId,
    @Path('image_id') int imageId,
  );

  /// 添加收藏
  @POST('/users/me/favorites')
  Future<ApiResponse<bool>> addFavorite(
    @Body() Map<String, dynamic> body,
  );

  /// 取消收藏
  @DELETE('/users/me/favorites/{house_id}')
  Future<ApiResponse<bool>> removeFavorite(
    @Path('house_id') int houseId,
  );

  /// 检查是否已收藏
  @GET('/users/me/favorites/{house_id}/check')
  Future<ApiResponse<bool>> checkFavorite(
    @Path('house_id') int houseId,
  );
}
