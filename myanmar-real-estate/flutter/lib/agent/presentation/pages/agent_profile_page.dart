/**
 * B端 - 经纪人个人中心页
 */
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../l10n/gen/app_localizations.dart';

class AgentProfilePage extends ConsumerWidget {
  const AgentProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // 顶部个人信息
          SliverToBoxAdapter(
            child: _buildHeader(context),
          ),
          
          // 数据统计
          SliverToBoxAdapter(
            child: _buildStats(context),
          ),
          
          // 功能列表
          SliverToBoxAdapter(
            child: _buildMenuSection(context),
          ),
          
          // 底部留白
          const SliverToBoxAdapter(
            child: SizedBox(height: 32),
          ),
        ],
      ),
    );
  }

  /// 顶部信息
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 60, 16, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary700,
            AppColors.primary900,
          ],
        ),
      ),
      child: Column(
        children: [
          // 设置按钮
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.settings, color: AppColors.white),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications, color: AppColors.white),
              ),
            ],
          ),
          
          // 用户信息
          Row(
            children: [
              // 头像
              Stack(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.white, width: 3),
                    ),
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: AppColors.primary700,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.gold,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.white, width: 2),
                      ),
                      child: Text(
                        '金牌',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              
              // 信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '张经纪',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Shwe Property 房产',
                      style: TextStyle(
                        color: AppColors.white.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.star, size: 16, color: AppColors.gold),
                        const SizedBox(width: 4),
                        Text(
                          '4.9',
                          style: TextStyle(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          '成交 128 单',
                          style: TextStyle(
                            color: AppColors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // 编辑按钮
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.edit, color: AppColors.white.withOpacity(0.8)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 统计数据
  Widget _buildStats(BuildContext context) {
    final stats = [
      {'value': '1,280万', 'label': '本月收入'},
      {'value': '3', 'label': '本月成交'},
      {'value': '5', 'label': '本月带看'},
      {'value': '156', 'label': '我的房源'},
    ];

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: stats.map((stat) {
          return GestureDetector(
            onTap: () {},
            child: Column(
              children: [
                Text(
                  stat['value']!,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  stat['label']!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.gray600,
                      ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  /// 菜单区块
  Widget _buildMenuSection(BuildContext context) {
    return Column(
      children: [
        _buildMenuGroup(
          context,
          items: [
            _MenuItem(
              icon: Icons.account_balance_wallet,
              title: '我的钱包',
              subtitle: '可提现: 500万缅币',
              onTap: () {},
            ),
            _MenuItem(
              icon: Icons.assessment,
              title: '业绩统计',
              onTap: () {
                context.push('/agent/performance');
              },
            ),
            _MenuItem(
              icon: Icons.group_add,
              title: '地推中心',
              subtitle: '推广码 · 佣金 · 提现',
              onTap: () {
                context.push('/agent/promoter');
              },
            ),
            _MenuItem(
              icon: Icons.workspace_premium,
              title: '等级权益',
              subtitle: '金牌经纪人',
              onTap: () {},
            ),
          ],
        ),
        
        _buildMenuGroup(
          context,
          items: [
            _MenuItem(
              icon: Icons.people,
              title: '我的团队',
              onTap: () {},
            ),
            _MenuItem(
              icon: Icons.school,
              title: '培训学习',
              onTap: () {},
            ),
            _MenuItem(
              icon: Icons.card_giftcard,
              title: '邀请有奖',
              onTap: () {
                context.push('/agent/promoter');
              },
            ),
          ],
        ),
        
        _buildMenuGroup(
          context,
          items: [
            _MenuItem(
              icon: Icons.help_outline,
              title: '帮助中心',
              onTap: () {},
            ),
            _MenuItem(
              icon: Icons.headset_mic,
              title: '联系客服',
              onTap: () {},
            ),
            _MenuItem(
              icon: Icons.info_outline,
              title: '关于我们',
              onTap: () {},
            ),
          ],
        ),
        
        // 退出登录
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: () {
                _showLogoutConfirm(context);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.red600,
                side: BorderSide(color: AppColors.red600),
              ),
              child: Text(AppLocalizations.of(context).logout),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuGroup(BuildContext context, {required List<_MenuItem> items}) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Column(
            children: [
              ListTile(
                leading: Icon(item.icon, color: AppColors.gray700),
                title: Text(item.title),
                subtitle: item.subtitle != null
                    ? Text(
                        item.subtitle!,
                        style: TextStyle(fontSize: 12, color: AppColors.gray500),
                      )
                    : null,
                trailing: const Icon(Icons.chevron_right, color: AppColors.gray400),
                onTap: item.onTap,
              ),
              if (index < items.length - 1)
                Divider(height: 1, indent: 56, color: AppColors.gray200),
            ],
          );
        }).toList(),
      ),
    );
  }

  void _showLogoutConfirm(BuildContext context) {
    final l = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.logout),
        content: const Text('确定要退出登录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.go(RouteNames.agentLogin);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.red600),
            child: Text(l.logout),
          ),
        ],
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  _MenuItem({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });
}
