/**
 * B端APP路由配置 (经纪人)
 */
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_constants.dart';
import '../../agent/presentation/pages/agent_main_page.dart';
import '../../agent/presentation/pages/agent_home_page.dart';
import '../../agent/presentation/pages/agent_house_manage_page.dart';
import '../../agent/presentation/pages/agent_house_add_page.dart';
import '../../agent/presentation/pages/verification_task_page.dart';
import '../../agent/presentation/pages/verification_execute_page.dart';
import '../../agent/presentation/pages/client_list_page.dart';
import '../../agent/presentation/pages/client_detail_page.dart';
import '../../agent/presentation/pages/showing_schedule_page.dart';
import '../../agent/presentation/pages/acn_deal_page.dart';
import '../../agent/presentation/pages/acn_confirm_page.dart';
import '../../agent/presentation/pages/performance_page.dart';
import '../../agent/presentation/pages/agent_profile_page.dart';
import '../../agent/presentation/pages/agent_login_page.dart';
import '../../agent/presentation/pages/promoter_page.dart';
import '../../buyer/presentation/pages/chat_page.dart';
import '../../buyer/providers/auth_provider.dart';
import '../../shared/pages/language_selection_page.dart';
import '../storage/local_storage.dart';

/// 监听认证状态变化，通知GoRouter重新评估redirect
class _AgentAuthListenable extends ChangeNotifier {
  _AgentAuthListenable(Ref ref) {
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (previous?.isLoggedIn != next.isLoggedIn) {
        notifyListeners();
      }
    });
  }
}

/// 经纪人路由配置Provider
final agentRouterProvider = Provider<GoRouter>((ref) {
  final authListenable = _AgentAuthListenable(ref);

  final router = GoRouter(
    initialLocation: RouteNames.agentLogin,
    debugLogDiagnostics: true,
    refreshListenable: authListenable,
    redirect: (context, state) async {
      final isLoggedIn = ref.read(authProvider).isLoggedIn;
      final isLogin          = state.matchedLocation == RouteNames.agentLogin;
      final isLanguageSelect = state.matchedLocation == RouteNames.languageSelect;

      if (isLanguageSelect) return null;

      if (isLogin && !isLoggedIn) {
        final isFirst = await LocalStorage.isFirstLaunch();
        if (isFirst) return RouteNames.languageSelect;
        return null;
      }

      if (!isLoggedIn) {
        return isLogin ? null : RouteNames.agentLogin;
      } else {
        return isLogin ? RouteNames.agentHome : null;
      }
    },
    routes: [
      // 语言选择页
      GoRoute(
        path: RouteNames.languageSelect,
        builder: (context, state) => const LanguageSelectionPage(
          nextRoute: RouteNames.agentLogin,
        ),
      ),

      // 经纪人登录
      GoRoute(
        path: RouteNames.agentLogin,
        builder: (context, state) => const AgentLoginPage(),
      ),

      // 主页面 (带底部导航)
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AgentMainPage(navigationShell: navigationShell);
        },
        branches: [
          // 工作台首页
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.agentHome,
                builder: (context, state) => const AgentHomePage(),
              ),
            ],
          ),

          // 房源管理
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.agentHouseManage,
                builder: (context, state) => const AgentHouseManagePage(),
                routes: [
                  // 添加房源
                  GoRoute(
                    path: 'add',
                    builder: (context, state) => const AgentHouseAddPage(),
                  ),
                ],
              ),
            ],
          ),

          // 客户管理
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/agent/clients',
                builder: (context, state) => const ClientListPage(),
              ),
            ],
          ),

          // 我的
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/agent/profile',
                builder: (context, state) => const AgentProfilePage(),
              ),
            ],
          ),
        ],
      ),

      // 验真任务列表
      GoRoute(
        path: '/agent/verification',
        builder: (context, state) => const VerificationTaskPage(),
      ),

      // 执行验真 (specific task by ID)
      GoRoute(
        path: '/agent/verification/:id',
        builder: (context, state) {
          final id =
              int.tryParse(state.pathParameters['id'] ?? '0') ?? 0;
          return VerificationExecutePage(taskId: id);
        },
      ),

      // 带看日程
      GoRoute(
        path: '/agent/schedule',
        builder: (context, state) => const ShowingSchedulePage(),
      ),

      // ACN成交申报
      GoRoute(
        path: '/agent/acn-deal',
        builder: (context, state) => const AcnDealPage(),
      ),

      // ACN成交确认
      GoRoute(
        path: '/agent/acn-confirm/:id',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '0') ?? 0;
          return AcnConfirmPage(transactionId: id);
        },
      ),

      // 业绩统计
      GoRoute(
        path: '/agent/performance',
        builder: (context, state) => const PerformancePage(),
      ),

      // 客户详情
      GoRoute(
        path: '/agent/client/:id',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '0') ?? 0;
          return ClientDetailPage(clientId: id);
        },
      ),

      // 地推中心
      GoRoute(
        path: '/agent/promoter',
        builder: (context, state) => const PromoterPage(),
      ),

      // 聊天 (经纪人侧，通过conversationId进入)
      GoRoute(
        path: '/agent/chat/:conversationId',
        builder: (context, state) {
          final convIdStr = state.pathParameters['conversationId'] ?? '0';
          final convId = int.tryParse(convIdStr) ?? 0;
          return ChatPage(
            targetId: convIdStr,
            conversationId: convId,
          );
        },
      ),
    ],
  );

  return router;
});
