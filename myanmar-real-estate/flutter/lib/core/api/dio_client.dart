/**
 * Dio HTTP客户端配置
 */
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';
import '../storage/local_storage.dart';

class DioClient {
  static Dio? _dio;

  static Dio get instance {
    _dio ??= _createDio();
    return _dio!;
  }

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseApiUrl,
        connectTimeout: const Duration(milliseconds: ApiConstants.connectTimeout),
        receiveTimeout: const Duration(milliseconds: ApiConstants.receiveTimeout),
        sendTimeout: const Duration(milliseconds: ApiConstants.sendTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // 添加拦截器
    dio.interceptors.addAll([
      _AuthInterceptor(),
      _LogInterceptor(),
      _ErrorInterceptor(),
    ]);

    return dio;
  }

  static void reset() {
    _dio = null;
  }
}

/// 认证拦截器
class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // 添加Token
    final token = await LocalStorage.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    // 添加设备信息
    final deviceId = await LocalStorage.getDeviceId();
    if (deviceId != null) {
      options.headers['X-Device-ID'] = deviceId;
    }

    // 添加请求ID
    options.headers['X-Request-ID'] = _generateRequestId();

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    handler.next(response);
  }

  String _generateRequestId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${(1000 + (DateTime.now().microsecond % 9000))}';
  }
}

/// 日志拦截器
class _LogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('┌──────────────────────────────────────────');
      debugPrint('│ 🚀 REQUEST: ${options.method} ${options.path}');
      debugPrint('│ Headers: ${options.headers}');
      if (options.queryParameters.isNotEmpty) {
        debugPrint('│ Query: ${options.queryParameters}');
      }
      if (options.data != null) {
        debugPrint('│ Body: ${options.data}');
      }
      debugPrint('└──────────────────────────────────────────');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('┌──────────────────────────────────────────');
      debugPrint('│ ✅ RESPONSE: ${response.statusCode} ${response.requestOptions.path}');
      debugPrint('│ Data: ${response.data}');
      debugPrint('└──────────────────────────────────────────');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('┌──────────────────────────────────────────');
      debugPrint('│ ❌ ERROR: ${err.type} ${err.requestOptions.path}');
      debugPrint('│ Message: ${err.message}');
      debugPrint('│ Response: ${err.response?.data}');
      debugPrint('└──────────────────────────────────────────');
    }
    handler.next(err);
  }
}

/// 错误处理拦截器
class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        err = err.copyWith(
          message: '连接超时，请检查网络后重试',
        );
        break;
      case DioExceptionType.connectionError:
        err = err.copyWith(
          message: '网络连接失败，请检查网络设置',
        );
        break;
      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode;
        final data = err.response?.data;
        
        if (statusCode == 401) {
          // Token过期，清除登录状态
          LocalStorage.clearAuth();
          err = err.copyWith(
            message: data?['message'] ?? '登录已过期，请重新登录',
          );
        } else if (statusCode == 403) {
          err = err.copyWith(
            message: data?['message'] ?? '没有权限执行此操作',
          );
        } else if (statusCode == 404) {
          err = err.copyWith(
            message: data?['message'] ?? '请求的资源不存在',
          );
        } else if (statusCode != null && statusCode >= 500) {
          err = err.copyWith(
            message: '服务器繁忙，请稍后重试',
          );
        } else {
          err = err.copyWith(
            message: data?['message'] ?? '请求失败，请重试',
          );
        }
        break;
      default:
        err = err.copyWith(
          message: '网络异常，请稍后重试',
        );
    }
    
    handler.next(err);
  }
}
