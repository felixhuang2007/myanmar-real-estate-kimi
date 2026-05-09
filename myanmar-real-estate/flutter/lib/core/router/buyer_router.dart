/**
 * C端APP路由配置
 */
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_constants.dart';
import '../../buyer/presentation/pages/splash_page.dart';
import '../../buyer/presentation/pages/onboarding_page.dart';
import '../../buyer/presentation/pages/login_page.dart';
import '../../buyer/presentation/pages/register_page.dart';
import '../../buyer/presentation/pages/main_page.dart';
import '../../buyer/presentation/pages/home_page.dart';
import '../../buyer/presentation/pages/search_page.dart';
import '../../buyer/presentation/pages/search_result_page.dart';
import '../../buyer/presentation/pages/map_search_page.dart';
import '../../buyer/presentation/pages/house_detail_page.dart';
import '../../buyer/presentation/pages/profile_page.dart';
import '../../buyer/presentation/pages/favorites_page.dart';
import '../../buyer/presentation/pages/chat_page.dart';
import '../../buyer/presentation/pages/chat_list_page.dart';
import '../../buyer/presentation/pages/mortgage_calc_page.dart';
import '../../buyer/presentation/pages/settings_page.dart';
import '../../buyer/presentation/pages/browsing_history_page.dart';
import '../../buyer/presentation/pages/my_appointments_page.dart';
import '../../buyer/presentation/pages/static_content_page.dart';
import '../../buyer/presentation/pages/edit_profile_page.dart';
import '../../buyer/presentation/pages/my_listings_page.dart';
import '../../buyer/providers/auth_provider.dart';
import '../../shared/pages/language_selection_page.dart';
import '../storage/local_storage.dart';
import '../../l10n/gen/app_localizations.dart';

/// 监听认证状态变化，通知GoRouter重新评估redirect
class _BuyerAuthListenable extends ChangeNotifier {
  _BuyerAuthListenable(Ref ref) {
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (previous?.isLoggedIn != next.isLoggedIn) {
        notifyListeners();
      }
    });
  }
}

/// 路由配置Provider
final buyerRouterProvider = Provider<GoRouter>((ref) {
  final authListenable = _BuyerAuthListenable(ref);

  return GoRouter(
    initialLocation: RouteNames.splash,
    debugLogDiagnostics: true,
    refreshListenable: authListenable,
    redirect: (context, state) async {
      try {
        final isLoggedIn = ref.read(authProvider).isLoggedIn;

        final isSplash         = state.matchedLocation == RouteNames.splash;
        final isLanguageSelect = state.matchedLocation == RouteNames.languageSelect;
        final isOnboarding     = state.matchedLocation == RouteNames.onboarding;
        final isLogin          = state.matchedLocation == RouteNames.login ||
                                  state.matchedLocation == RouteNames.register;

        if (isSplash) {
          final isFirst = await LocalStorage.isFirstLaunch();
          if (isFirst) return RouteNames.languageSelect;
          return isLoggedIn ? RouteNames.buyerHome : RouteNames.login;
        }

        if (isLanguageSelect) return null;

        if (isOnboarding || isLogin) {
          return isLoggedIn ? RouteNames.buyerHome : null;
        }

        if (!isLoggedIn) return RouteNames.login;

        return null;
      } catch (e) {
        // redirect 出错时安全降级到登录页
        return RouteNames.login;
      }
    },
    routes: [
      // 语言选择页
      GoRoute(
        path: RouteNames.languageSelect,
        builder: (context, state) => const LanguageSelectionPage(
          nextRoute: RouteNames.login,
        ),
      ),

      // 启动页
      GoRoute(
        path: RouteNames.splash,
        builder: (context, state) => const SplashPage(),
      ),

      // 引导页
      GoRoute(
        path: RouteNames.onboarding,
        builder: (context, state) => const OnboardingPage(),
      ),

      // 登录
      GoRoute(
        path: RouteNames.login,
        builder: (context, state) => const LoginPage(),
      ),

      // 注册
      GoRoute(
        path: RouteNames.register,
        builder: (context, state) => const RegisterPage(),
      ),

      // 主页面 (带底部导航)
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainPage(navigationShell: navigationShell);
        },
        branches: [
          // 首页
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.buyerHome,
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),

          // 找房 (搜索)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.buyerSearch,
                builder: (context, state) => const SearchPage(),
              ),
            ],
          ),

          // 收藏
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/buyer/favorites',
                builder: (context, state) => const FavoritesPage(),
              ),
            ],
          ),

          // 我的
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.buyerProfile,
                builder: (context, state) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),

      // 地图找房
      GoRoute(
        path: RouteNames.buyerMap,
        builder: (context, state) => const MapSearchPage(),
      ),

      // 房源列表（查看更多）
      GoRoute(
        path: '/buyer/houses',
        builder: (context, state) => const SearchResultPage(),
      ),

      // 搜索结果
      GoRoute(
        path: '/buyer/search-result',
        builder: (context, state) {
          final keyword = state.uri.queryParameters['keyword'];
          final transactionType = state.uri.queryParameters['transactionType'];
          final pageTitle = state.uri.queryParameters['title'];
          final isNewHomeStr = state.uri.queryParameters['isNewHome'];
          final bool? isNewHome = isNewHomeStr == null ? null : isNewHomeStr == 'true';
          return SearchResultPage(
            keyword: keyword,
            transactionType: transactionType,
            isNewHome: isNewHome,
            pageTitle: pageTitle,
          );
        },
      ),

      // 房贷计算器
      GoRoute(
        path: '/buyer/mortgage',
        builder: (context, state) => const MortgageCalcPage(),
      ),

      // 房源详情
      GoRoute(
        path: '/buyer/house/:id',
        builder: (context, state) {
          final houseId = state.pathParameters['id'] ?? '';
          return HouseDetailPage(houseId: houseId);
        },
      ),

      // 消息列表
      GoRoute(
        path: '/buyer/chats',
        builder: (context, state) => const ChatListPage(),
      ),

      // 聊天
      GoRoute(
        path: '/buyer/chat/:targetId',
        builder: (context, state) {
          final targetId = state.pathParameters['targetId'] ?? '';
          final agentId = int.tryParse(targetId);
          // extra may carry a pre-known conversationId from ChatListPage
          final extra = state.extra as Map<String, dynamic>?;
          final conversationId = extra?['conversationId'] as int?;
          return ChatPage(
            targetId: targetId,
            agentId: agentId,
            conversationId: conversationId,
          );
        },
      ),

      // 设置
      GoRoute(
        path: '/buyer/settings',
        builder: (context, state) => const SettingsPage(),
      ),

      // 浏览历史
      GoRoute(
        path: '/buyer/browsing-history',
        builder: (context, state) => const BrowsingHistoryPage(),
      ),

      // 我的预约
      GoRoute(
        path: '/buyer/my-appointments',
        builder: (context, state) => const MyAppointmentsPage(),
      ),

      // 购房指南
      GoRoute(
        path: '/buyer/buying-guide',
        builder: (context, state) {
          final l = AppLocalizations.of(context);
          return StaticContentPage(
            title: l.buyingGuide,
            contentType: 'buying-guide',
          );
        },
      ),

      // 帮助与客服
      GoRoute(
        path: '/buyer/help-support',
        builder: (context, state) {
          final l = AppLocalizations.of(context);
          return StaticContentPage(
            title: l.helpAndSupport,
            contentType: 'help-support',
          );
        },
      ),

      // 关于我们
      GoRoute(
        path: '/buyer/about-us',
        builder: (context, state) {
          final l = AppLocalizations.of(context);
          return StaticContentPage(
            title: l.aboutUs,
            contentType: 'about-us',
          );
        },
      ),

      // 用户协议
      GoRoute(
        path: '/buyer/terms',
        builder: (context, state) {
          final l = AppLocalizations.of(context);
          return StaticContentPage(
            title: l.userAgreement,
            contentType: 'terms',
          );
        },
      ),

      // 隐私政策
      GoRoute(
        path: '/buyer/privacy',
        builder: (context, state) {
          final l = AppLocalizations.of(context);
          return StaticContentPage(
            title: l.privacyPolicy,
            contentType: 'privacy',
          );
        },
      ),

      // 我的发布
      GoRoute(
        path: '/buyer/my-listings',
        builder: (context, state) => const MyListingsPage(),
      ),

      // 编辑资料
      GoRoute(
        path: '/buyer/edit-profile',
        builder: (context, state) => const EditProfilePage(),
      ),
    ],
  );
});
