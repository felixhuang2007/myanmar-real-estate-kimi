/**
 * API接口定义 - 用户相关
 */
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/api_response.dart';
import '../models/user.dart';
import '../models/house.dart';

part 'user_api.g.dart';

@RestApi()
abstract class UserApi {
  factory UserApi(Dio dio, {String baseUrl}) = _UserApi;

  /// 发送验证码
  @POST('/auth/send-verification-code')
  Future<ApiResponse<SendCodeResponse>> sendVerificationCode(
    @Body() Map<String, dynamic> body,
  );

  /// 手机号注册
  @POST('/auth/register')
  Future<ApiResponse<LoginResponse>> register(
    @Body() Map<String, dynamic> body,
  );

  /// 手机号登录
  @POST('/auth/login')
  Future<ApiResponse<LoginResponse>> login(
    @Body() Map<String, dynamic> body,
  );

  /// 密码登录
  @POST('/auth/login-with-password')
  Future<ApiResponse<LoginResponse>> loginWithPassword(
    @Body() Map<String, dynamic> body,
  );

  /// 刷新Token
  @POST('/auth/refresh-token')
  Future<ApiResponse<LoginResponse>> refreshToken(
    @Body() Map<String, dynamic> body,
  );

  /// 退出登录
  @POST('/auth/logout')
  Future<ApiResponse<bool>> logout();

  /// 获取当前用户信息
  @GET('/users/me')
  Future<ApiResponse<User>> getCurrentUser();

  /// 更新用户资料
  @PUT('/users/me')
  Future<ApiResponse<User>> updateUserProfile(
    @Body() Map<String, dynamic> body,
  );

  /// 上传头像
  @POST('/users/me/avatar')
  @MultiPart()
  Future<ApiResponse<String>> uploadAvatar(
    @Part(name: 'file') List<int> file,
  );

  /// 获取收藏列表
  @GET('/users/me/favorites')
  Future<ApiResponse<PaginatedData<House>>> getFavorites(
    @Queries() Map<String, dynamic> queries,
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

  /// 获取浏览历史
  @GET('/users/me/browsing-history')
  Future<ApiResponse<PaginatedData<House>>> getBrowsingHistory(
    @Queries() Map<String, dynamic> queries,
  );

  /// 清除浏览历史
  @DELETE('/users/me/browsing-history')
  Future<ApiResponse<bool>> clearBrowsingHistory();

  /// 创建预约看房
  @POST('/appointments')
  Future<ApiResponse<bool>> createAppointment(
    @Body() Map<String, dynamic> body,
  );
}
