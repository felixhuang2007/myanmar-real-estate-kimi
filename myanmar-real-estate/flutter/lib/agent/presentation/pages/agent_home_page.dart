/**
 * B端 - 经纪人工作台首页
 */
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../widgets/stat_card.dart';
import '../widgets/quick_action_grid.dart';
import '../../../l10n/gen/app_localizations.dart';

class AgentHomePage extends ConsumerWidget {
  const AgentHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // 顶部用户信息
            SliverToBoxAdapter(
              child: _buildHeader(context),
            ),
            
            // 数据统计卡片
            SliverToBoxAdapter(
              child: _buildStatistics(context),
            ),
            
            // 快捷入口
            SliverToBoxAdapter(
              child: _buildQuickActions(context),
            ),
            
            // 待办事项
            SliverToBoxAdapter(
              child: _buildTodoList(context),
            ),
            
            // 底部留白
            const SliverToBoxAdapter(
              child: SizedBox(height: 24),
            ),
          ],
        ),
      ),
    );
  }

  /// 顶部头部
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary700, AppColors.primary800],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 顶部栏
          Row(
            children: [
              // 头像
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.person,
                  color: AppColors.primary700,
                ),
              ),
              const SizedBox(width: 12),
              // 用户信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '张小明',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        '高级经纪人',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // 通知
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: AppColors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // 本月业绩
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatColumn('本月业绩', '1,500万', '缅币'),
                _buildDivider(),
                _buildStatColumn('本月带看', '12', '次'),
                _buildDivider(),
                _buildStatColumn('本月成交', '3', '单'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, String unit) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.white70,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              unit,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.white70,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 30,
      color: AppColors.white.withOpacity(0.2),
    );
  }

  /// 统计数据
  Widget _buildStatistics(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: StatCard(
              title: '我的房源',
              value: '28',
              subtitle: '在售 25 | 审核中 3',
              icon: Icons.home_work,
              color: AppColors.blue500,
              onTap: () {
                context.push(RouteNames.agentHouseManage);
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: StatCard(
              title: '我的客户',
              value: '156',
              subtitle: '本月新增 12',
              icon: Icons.people,
              color: AppColors.green500,
              onTap: () {
                context.push(RouteNames.agentClients);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 快捷入口
  Widget _buildQuickActions(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '快捷入口',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          QuickActionGrid(
            actions: [
              QuickActionItem(
                icon: Icons.add_home,
                label: l.addHouse,
                color: AppColors.primary700,
                onTap: () {
                  context.push('${RouteNames.agentHouseManage}/add');
                },
              ),
              QuickActionItem(
                icon: Icons.verified,
                label: l.verificationTask,
                color: AppColors.green500,
                onTap: () {
                  context.push(RouteNames.agentVerification);
                },
              ),
              QuickActionItem(
                icon: Icons.handshake,
                label: l.acnDeal,
                color: AppColors.blue500,
                onTap: () {
                  context.push(RouteNames.agentAcn);
                },
              ),
              QuickActionItem(
                icon: Icons.trending_up,
                label: l.performance,
                color: AppColors.orange500,
                onTap: () {
                  context.push(RouteNames.agentPerformance);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 待办事项
  Widget _buildTodoList(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '待办事项',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('查看全部'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTodoItem(
            context,
            icon: Icons.calendar_today,
            title: l.todaySchedule,
            subtitle: '3个预约待确认',
            color: AppColors.orange500,
          ),
          const SizedBox(height: 8),
          _buildTodoItem(
            context,
            icon: Icons.verified_user,
            title: l.verificationTask,
            subtitle: '2个房源待验真',
            color: AppColors.green500,
          ),
          const SizedBox(height: 8),
          _buildTodoItem(
            context,
            icon: Icons.message,
            title: '客户消息',
            subtitle: '5条未读消息',
            color: AppColors.blue500,
          ),
        ],
      ),
    );
  }

  Widget _buildTodoItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.sm,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.gray600,
                      ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: AppColors.gray400,
          ),
        ],
      ),
    );
  }
}
