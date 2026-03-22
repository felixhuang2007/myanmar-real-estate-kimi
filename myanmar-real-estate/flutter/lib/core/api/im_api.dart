/**
 * IM即时通讯 API
 */
import 'package:dio/dio.dart';
import '../constants/app_constants.dart';

class ImApi {
  final Dio _dio;

  ImApi(this._dio);

  /// 获取或创建会话 (POST /v1/im/conversations)
  Future<Map<String, dynamic>> getOrCreateConversation({
    required int agentId,
    int? houseId,
    required String token,
  }) async {
    final resp = await _dio.post(
      '${ApiConstants.baseApiUrl}/im/conversations',
      data: {
        'agent_id': agentId,
        if (houseId != null) 'house_id': houseId,
      },
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return resp.data as Map<String, dynamic>;
  }

  /// 获取会话列表 (GET /v1/im/conversations)
  Future<Map<String, dynamic>> getConversations({
    required String userType,
    required String token,
    int page = 1,
    int pageSize = 20,
  }) async {
    final resp = await _dio.get(
      '${ApiConstants.baseApiUrl}/im/conversations',
      queryParameters: {
        'user_type': userType,
        'page': page,
        'pageSize': pageSize,
      },
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return resp.data as Map<String, dynamic>;
  }

  /// 获取消息历史 (GET /v1/im/messages)
  Future<Map<String, dynamic>> getMessages({
    required int conversationId,
    required String token,
    int? beforeId,
    int limit = 20,
  }) async {
    final resp = await _dio.get(
      '${ApiConstants.baseApiUrl}/im/messages',
      queryParameters: {
        'conversationId': conversationId,
        if (beforeId != null) 'beforeId': beforeId,
        'limit': limit,
      },
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return resp.data as Map<String, dynamic>;
  }

  /// 发送消息 (POST /v1/im/messages)
  Future<Map<String, dynamic>> sendMessage({
    required int conversationId,
    required String messageType,
    required String content,
    required String token,
  }) async {
    final resp = await _dio.post(
      '${ApiConstants.baseApiUrl}/im/messages',
      data: {
        'conversation_id': conversationId,
        'message_type': messageType,
        'content': content,
      },
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return resp.data as Map<String, dynamic>;
  }

  /// 标记会话为已读 (POST /v1/im/conversations/:id/read)
  Future<void> markAsRead({
    required int conversationId,
    required String token,
  }) async {
    await _dio.post(
      '${ApiConstants.baseApiUrl}/im/conversations/$conversationId/read',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }
}
