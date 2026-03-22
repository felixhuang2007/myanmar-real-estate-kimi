/**
 * 应用主题配置
 * 基于缅甸房产平台设计规范
 */
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  /// 获取应用主题
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      // 颜色方案
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary700,
        onPrimary: AppColors.white,
        primaryContainer: AppColors.primary100,
        onPrimaryContainer: AppColors.primary900,
        secondary: AppColors.green700,
        onSecondary: AppColors.white,
        secondaryContainer: AppColors.green100,
        onSecondaryContainer: AppColors.green900,
        error: AppColors.error,
        onError: AppColors.white,
        surface: AppColors.surface,
        onSurface: AppColors.gray900,
        surfaceVariant: AppColors.gray100,
        onSurfaceVariant: AppColors.gray700,
        outline: AppColors.gray400,
        outlineVariant: AppColors.gray200,
      ),

      // 字体
      // fontFamily: 'NotoSans',
      
      // 文字主题
      textTheme: _buildTextTheme(),

      // 应用栏主题
      appBarTheme: _buildAppBarTheme(),

      // 底部导航栏主题
      bottomNavigationBarTheme: _buildBottomNavTheme(),

      // 卡片主题
      cardTheme: _buildCardTheme(),

      // 按钮主题
      elevatedButtonTheme: _buildElevatedButtonTheme(),
      outlinedButtonTheme: _buildOutlinedButtonTheme(),
      textButtonTheme: _buildTextButtonTheme(),

      // 输入框主题
      inputDecorationTheme: _buildInputTheme(),

      // 分割线主题
      dividerTheme: _buildDividerTheme(),

      // 底部Sheet主题
      bottomSheetTheme: _buildBottomSheetTheme(),

      // 对话框主题
      dialogTheme: _buildDialogTheme(),

      // Chip主题
      chipTheme: _buildChipTheme(),

      // 页面过渡
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),

      // Scaffold背景色
      scaffoldBackgroundColor: AppColors.background,
    );
  }

  /// 构建文字主题
  static TextTheme _buildTextTheme() {
    const baseStyle = TextStyle(
      color: AppColors.gray900,
      // fontFamily: 'NotoSans',
    );

    return TextTheme(
      displayLarge: baseStyle.copyWith(
        fontSize: AppFontSize.h1,
        fontWeight: FontWeight.bold,
        height: 1.33,
      ),
      displayMedium: baseStyle.copyWith(
        fontSize: AppFontSize.h2,
        fontWeight: FontWeight.bold,
        height: 1.4,
      ),
      displaySmall: baseStyle.copyWith(
        fontSize: AppFontSize.h3,
        fontWeight: FontWeight.w600,
        height: 1.44,
      ),
      headlineMedium: baseStyle.copyWith(
        fontSize: AppFontSize.h4,
        fontWeight: FontWeight.w600,
        height: 1.5,
      ),
      bodyLarge: baseStyle.copyWith(
        fontSize: AppFontSize.bodyLarge,
        fontWeight: FontWeight.normal,
        height: 1.5,
      ),
      bodyMedium: baseStyle.copyWith(
        fontSize: AppFontSize.bodyMedium,
        fontWeight: FontWeight.normal,
        height: 1.57,
      ),
      bodySmall: baseStyle.copyWith(
        fontSize: AppFontSize.bodySmall,
        fontWeight: FontWeight.normal,
        height: 1.5,
      ),
      labelLarge: baseStyle.copyWith(
        fontSize: AppFontSize.bodyMedium,
        fontWeight: FontWeight.w600,
      ),
      labelMedium: baseStyle.copyWith(
        fontSize: AppFontSize.bodySmall,
        fontWeight: FontWeight.w500,
      ),
      labelSmall: baseStyle.copyWith(
        fontSize: AppFontSize.caption,
        fontWeight: FontWeight.w500,
        height: 1.45,
      ),
    );
  }

  /// 构建AppBar主题
  static AppBarTheme _buildAppBarTheme() {
    return AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0.5,
      centerTitle: true,
      backgroundColor: AppColors.white,
      foregroundColor: AppColors.gray900,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      titleTextStyle: const TextStyle(
        fontSize: AppFontSize.h3,
        fontWeight: FontWeight.w600,
        color: AppColors.gray900,
        // fontFamily: 'NotoSans',
      ),
      iconTheme: const IconThemeData(
        color: AppColors.gray900,
        size: 24,
      ),
    );
  }

  /// 构建底部导航栏主题
  static BottomNavigationBarThemeData _buildBottomNavTheme() {
    return const BottomNavigationBarThemeData(
      backgroundColor: AppColors.white,
      elevation: 8,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primary700,
      unselectedItemColor: AppColors.gray500,
      selectedLabelStyle: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        // fontFamily: 'NotoSans',
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        // fontFamily: 'NotoSans',
      ),
    );
  }

  /// 构建卡片主题
  static CardTheme _buildCardTheme() {
    return CardTheme(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      color: AppColors.white,
      margin: EdgeInsets.zero,
      shadowColor: AppColors.black.withOpacity(0.08),
    );
  }

  /// 构建ElevatedButton主题
  static ElevatedButtonThemeData _buildElevatedButtonTheme() {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: AppColors.primary700,
        foregroundColor: AppColors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        minimumSize: const Size(0, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          // fontFamily: 'NotoSans',
        ),
      ),
    );
  }

  /// 构建OutlinedButton主题
  static OutlinedButtonThemeData _buildOutlinedButtonTheme() {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        elevation: 0,
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.primary700,
        side: const BorderSide(color: AppColors.primary700, width: 1),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        minimumSize: const Size(0, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          // fontFamily: 'NotoSans',
        ),
      ),
    );
  }

  /// 构建TextButton主题
  static TextButtonThemeData _buildTextButtonTheme() {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary700,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        minimumSize: const Size(0, 32),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          // fontFamily: 'NotoSans',
        ),
      ),
    );
  }

  /// 构建输入框主题
  static InputDecorationTheme _buildInputTheme() {
    return InputDecorationTheme(
      filled: true,
      fillColor: AppColors.gray50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.gray400),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.gray400),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.primary700, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
      hintStyle: const TextStyle(
        fontSize: AppFontSize.bodyMedium,
        color: AppColors.gray500,
        // fontFamily: 'NotoSans',
      ),
      labelStyle: const TextStyle(
        fontSize: AppFontSize.bodyMedium,
        color: AppColors.gray700,
        // fontFamily: 'NotoSans',
      ),
    );
  }

  /// 构建设置分割线主题
  static DividerThemeData _buildDividerTheme() {
    return const DividerThemeData(
      color: AppColors.gray200,
      thickness: 1,
      space: 1,
    );
  }

  /// 构建底部Sheet主题
  static BottomSheetThemeData _buildBottomSheetTheme() {
    return BottomSheetThemeData(
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      elevation: 8,
    );
  }

  /// 构建对话框主题
  static DialogTheme _buildDialogTheme() {
    return DialogTheme(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      elevation: 8,
      titleTextStyle: const TextStyle(
        fontSize: AppFontSize.h3,
        fontWeight: FontWeight.w600,
        color: AppColors.gray900,
        // fontFamily: 'NotoSans',
      ),
      contentTextStyle: const TextStyle(
        fontSize: AppFontSize.bodyMedium,
        color: AppColors.gray600,
        // fontFamily: 'NotoSans',
      ),
    );
  }

  /// 构建Chip主题
  static ChipThemeData _buildChipTheme() {
    return ChipThemeData(
      backgroundColor: AppColors.gray100,
      selectedColor: AppColors.primary50,
      labelStyle: const TextStyle(
        fontSize: AppFontSize.bodySmall,
        color: AppColors.gray700,
        // fontFamily: 'NotoSans',
      ),
      secondaryLabelStyle: const TextStyle(
        fontSize: AppFontSize.bodySmall,
        color: AppColors.primary700,
        fontWeight: FontWeight.w500,
        // fontFamily: 'NotoSans',
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
    );
  }
}

/// 暗色主题 (备用)
class AppDarkTheme {
  // 如需暗色主题可在此扩展
}
