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
import '../../buyer/presentation/pages/chat_page.dart';
import '../../buyer/presentation/pages/chat_list_page.dart';
import '../../buyer/presentation/pages/mortgage_calc_page.dart';
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

          // 收藏 (占位)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/buyer/favorites',
                builder: (context, state) => Scaffold(
                  body: Center(child: Text(AppLocalizations.of(context).favorites)),
                ),
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
    ],
  );
});
