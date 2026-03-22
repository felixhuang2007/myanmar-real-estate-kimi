/**
 * 设计系统 - 颜色定义
 * 基于缅甸房产平台设计规范
 */
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // 主色调 - 缅甸金
  static const Color primary900 = Color(0xFFB8860B);
  static const Color primary800 = Color(0xFFD4A017);
  static const Color primary700 = Color(0xFFE6B800);
  static const Color primary600 = Color(0xFFF5C942);
  static const Color primary500 = Color(0xFFFFD700);
  static const Color primary100 = Color(0xFFFFF8DC);
  static const Color primary50 = Color(0xFFFFFBEB);

  // 辅助色 - 翡翠绿
  static const Color green900 = Color(0xFF064E3B);
  static const Color green700 = Color(0xFF047857);
  static const Color green600 = Color(0xFF059669);
  static const Color green500 = Color(0xFF10B981);
  static const Color green100 = Color(0xFFD1FAE5);
  static const Color green50 = Color(0xFFECFDF5);

  // 功能色 - 勃艮第红
  static const Color red900 = Color(0xFF7F1D1D);
  static const Color red700 = Color(0xFFB91C1C);
  static const Color red600 = Color(0xFFDC2626);
  static const Color red500 = Color(0xFFEF4444);
  static const Color red100 = Color(0xFFFEE2E2);
  static const Color red50 = Color(0xFFFEF2F2);

  // 橙色系
  static const Color orange600 = Color(0xFFEA580C);
  static const Color orange500 = Color(0xFFF97316);
  static const Color orange100 = Color(0xFFFFEDD5);

  // 蓝色系
  static const Color blue700 = Color(0xFF1D4ED8);
  static const Color blue600 = Color(0xFF2563EB);
  static const Color blue500 = Color(0xFF3B82F6);
  static const Color blue100 = Color(0xFFDBEAFE);

  // 紫色系
  static const Color purple = Color(0xFF8B5CF6);

  // 金色
  static const Color gold = Color(0xFFFFD700);

  // 中性色 - 雅致灰
  static const Color gray900 = Color(0xFF1F2937);
  static const Color gray800 = Color(0xFF374151);
  static const Color gray700 = Color(0xFF4B5563);
  static const Color gray600 = Color(0xFF6B7280);
  static const Color gray500 = Color(0xFF9CA3AF);
  static const Color gray400 = Color(0xFFD1D5DB);
  static const Color gray300 = Color(0xFFE5E7EB);
  static const Color gray200 = Color(0xFFF3F4F6);
  static const Color gray100 = Color(0xFFF9FAFB);
  static const Color gray50 = Color(0xFFFAFAFA);

  // 基础色
  static const Color white = Color(0xFFFFFFFF);
  static const Color white70 = Color(0xB3FFFFFF); // 70% opacity white
  static const Color black = Color(0xFF000000);
  static const Color black54 = Colors.black54;

  // 功能颜色
  static const Color success = green700;
  static const Color warning = orange500;
  static const Color error = red600;
  static const Color info = blue600;

  // 页面背景
  static const Color background = gray100;
  static const Color surface = white;
}

/**
 * 间距系统
 */
class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
  static const double xxxl = 64;

  static const double pagePadding = 16;
  static const double cardPadding = 12;
  static const double sectionSpacing = 24;
}

/**
 * 圆角系统
 */
class AppRadius {
  AppRadius._();

  static const double none = 0;
  static const double sm = 4;
  static const double md = 8;
  static const double lg = 12;
  static const double xl = 16;
  static const double full = 9999;
}

/**
 * 字体大小
 */
class AppFontSize {
  AppFontSize._();

  static const double h1 = 24;
  static const double h2 = 20;
  static const double h3 = 18;
  static const double h4 = 16;
  static const double bodyLarge = 16;
  static const double bodyMedium = 14;
  static const double bodySmall = 12;
  static const double caption = 11;
}

/**
 * 阴影系统
 */
class AppShadows {
  AppShadows._();

  static List<BoxShadow> get sm => [
        BoxShadow(
          color: AppColors.black.withOpacity(0.05),
          blurRadius: 2,
          offset: const Offset(0, 1),
        ),
      ];

  static List<BoxShadow> get md => [
        BoxShadow(
          color: AppColors.black.withOpacity(0.07),
          blurRadius: 6,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get lg => [
        BoxShadow(
          color: AppColors.black.withOpacity(0.10),
          blurRadius: 15,
          offset: const Offset(0, 10),
        ),
      ];

  static List<BoxShadow> get xl => [
        BoxShadow(
          color: AppColors.black.withOpacity(0.10),
          blurRadius: 25,
          offset: const Offset(0, 20),
        ),
      ];
}
