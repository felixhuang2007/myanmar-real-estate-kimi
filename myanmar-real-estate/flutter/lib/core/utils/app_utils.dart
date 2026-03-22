/**
 * 通用工具类
 */
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../theme/app_colors.dart';

/// Toast工具
class ToastUtil {
  static void show(String message, {bool isError = false}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 2,
      backgroundColor: isError ? AppColors.error : AppColors.gray900,
      textColor: AppColors.white,
      fontSize: 14,
    );
  }

  static void showSuccess(String message) {
    show(message, isError: false);
  }

  static void showError(String message) {
    show(message, isError: true);
  }
}

/// 日志工具
class LogUtil {
  static void d(String message) {
    debugPrint('📝 DEBUG: $message');
  }

  static void i(String message) {
    debugPrint('ℹ️ INFO: $message');
  }

  static void w(String message) {
    debugPrint('⚠️ WARN: $message');
  }

  static void e(String message, [dynamic error, StackTrace? stackTrace]) {
    debugPrint('❌ ERROR: $message');
    if (error != null) {
      debugPrint('   Details: $error');
    }
    if (stackTrace != null) {
      debugPrint('   StackTrace: $stackTrace');
    }
  }
}

/// 价格格式化工具
class PriceUtil {
  /// 格式化价格显示
  static String format(int price, {String unit = 'MMK'}) {
    if (price >= 100000000) {
      return '${(price / 100000000).toStringAsFixed(1)}亿 $unit';
    } else if (price >= 10000) {
      return '${(price / 10000).toStringAsFixed(0)}万 $unit';
    }
    return '$price $unit';
  }

  /// 格式化租金 (每月)
  static String formatRent(int price, {String unit = 'MMK'}) {
    return '${format(price, unit: unit)}/月';
  }

  /// 格式化单价
  static String formatUnitPrice(double unitPrice, {String unit = 'MMK'}) {
    return '${unitPrice.toStringAsFixed(0)} $unit/㎡';
  }
}

/// 日期时间工具
class DateUtil {
  /// 格式化日期
  static String formatDate(DateTime date, {String pattern = 'yyyy-MM-dd'}) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    
    return pattern
        .replaceAll('yyyy', year)
        .replaceAll('MM', month)
        .replaceAll('dd', day);
  }

  /// 格式化时间
  static String formatTime(DateTime date, {String pattern = 'HH:mm'}) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    
    return pattern
        .replaceAll('HH', hour)
        .replaceAll('mm', minute);
  }

  /// 格式化日期时间
  static String formatDateTime(DateTime date) {
    return '${formatDate(date)} ${formatTime(date)}';
  }

  /// 获取相对时间描述
  static String getRelativeTime(String? dateTimeStr) {
    if (dateTimeStr == null) return '';
    
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays > 365) {
        return '${(difference.inDays / 365).floor()}年前';
      } else if (difference.inDays > 30) {
        return '${(difference.inDays / 30).floor()}个月前';
      } else if (difference.inDays > 0) {
        return '${difference.inDays}天前';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}小时前';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}分钟前';
      } else {
        return '刚刚';
      }
    } catch (e) {
      return dateTimeStr;
    }
  }
}

/// 验证工具
class ValidatorUtil {
  /// 验证手机号 (缅甸)
  static bool isValidPhone(String phone) {
    // 缅甸手机号格式: +95 或 09 开头
    final pattern = r'^(\+?95|0)?[0-9]{9,10}$';
    return RegExp(pattern).hasMatch(phone.replaceAll(RegExp(r'\s'), ''));
  }

  /// 验证邮箱
  static bool isValidEmail(String email) {
    final pattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
    return RegExp(pattern).hasMatch(email);
  }

  /// 验证密码 (至少6位)
  static bool isValidPassword(String password) {
    return password.length >= 6;
  }

  /// 格式化手机号
  static String formatPhone(String phone) {
    final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
    if (cleanPhone.length == 9) {
      return '${cleanPhone.substring(0, 3)} ${cleanPhone.substring(3, 6)} ${cleanPhone.substring(6)}';
    }
    return phone;
  }
}

/// 字符串工具
class StringUtil {
  /// 截取字符串
  static String ellipsis(String text, int maxLength, {String suffix = '...'}) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}$suffix';
  }

  /// 是否为空或空白
  static bool isBlank(String? text) {
    return text == null || text.trim().isEmpty;
  }

  /// 是否不为空
  static bool isNotBlank(String? text) {
    return !isBlank(text);
  }
}

/// 数字工具
class NumberUtil {
  /// 格式化数字 (千分位)
  static String formatWithComma(num number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
  }

  /// 格式化计数 (1k, 1w)
  static String formatCount(int count) {
    if (count >= 10000) {
      return '${(count / 10000).toStringAsFixed(1)}w';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return count.toString();
  }
}
