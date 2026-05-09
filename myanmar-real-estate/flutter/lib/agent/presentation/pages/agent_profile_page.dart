/**
 * B端 - 经纪人个人中心页
 */
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/api/dio_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../l10n/gen/app_localizations.dart';

class AgentProfilePage extends ConsumerStatefulWidget {
  const AgentProfilePage({super.key});

  @override
  ConsumerState<AgentProfilePage> createState() => _AgentProfilePageState();
}

class _AgentProfilePageState extends ConsumerState<AgentProfilePage> {
  bool _isLoading = true;
  String? _error;

  // 统计数据
  int _monthlyIncome = 0; // 本月收入（缅币）
  int _monthlyDeals = 0; // 本月成交
  int _monthlyViewings = 0; // 本月带看
  int _myHouses = 0; // 我的房源

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final startDateStr = _formatDate(startOfMonth);
      final endDateStr = _formatDate(now);

      final dio = DioClient.instance;

      // 并行发起4个请求
      final results = await Future.wait([
        // 1. 本月收入
        dio.get('/acn/commission/statistics'),
        // 2. 本月成交
        dio.get('/acn/transactions', queryParameters: {
          'status': 'completed',
          'startDate': startDateStr,
          'endDate': endDateStr,
          'page': 1,
          'pageSize': 1,
        }),
        // 3. 本月带看
        dio.get('/appointments', queryParameters: {
          'role': 'agent',
          'status': 'completed',
          'startDate': startDateStr,
          'endDate': endDateStr,
          'page': 1,
          'pageSize': 1,
        }),
        // 4. 我的房源
        dio.get('/houses/my', queryParameters: {
          'page': 1,
          'page_size': 1,
        }),
      ]);

      // 解析结果
      final commissionData =
          (results[0].data as Map<String, dynamic>?)?['data']
              as Map<String, dynamic>?;
      final dealsData =
          (results[1].data as Map<String, dynamic>?)?['data']
              as Map<String, dynamic>?;
      final viewingsData =
          (results[2].data as Map<String, dynamic>?)?['data']
              as Map<String, dynamic>?;
      final housesData =
          (results[3].data as Map<String, dynamic>?)?['data']
              as Map<String, dynamic>?;

      setState(() {
        _monthlyIncome = _toInt(commissionData?['this_month']);
        _monthlyDeals = _toInt(dealsData?['pagination']?['total']);
        _monthlyViewings = _toInt(viewingsData?['pagination']?['total']);
        _myHouses = _toInt(housesData?['pagination']?['total']);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  String _formatIncome(int amount) {
    if (amount >= 10000) {
      final wan = amount / 10000;
      return '${wan.toStringAsFixed(wan == wan.toInt() ? 0 : 1)}万';
    }
    return amount.toString();
  }

  @override
  Widget build(BuildContext context) {
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
                onPressed: () {
                  context.push('/agent/settings');
                },
                icon: const Icon(Icons.settings, color: AppColors.white),
              ),
              IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notifications coming soon')),
                  );
                },
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
                      padding:
                          const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(
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
                onPressed: () {
                  context.push('/agent/edit-profile');
                },
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
      {
        'value': _formatIncome(_monthlyIncome),
        'label': '本月收入',
        'route': '/agent/performance'
      },
      {
        'value': _monthlyDeals.toString(),
        'label': '本月成交',
        'route': '/agent/performance'
      },
      {
        'value': _monthlyViewings.toString(),
        'label': '本月带看',
        'route': '/agent/schedule'
      },
      {
        'value': _myHouses.toString(),
        'label': '我的房源',
        'route': '/agent/houses'
      },
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
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: stats.map((stat) {
              return GestureDetector(
                onTap: () {
                  final route = stat['route'] as String?;
                  if (route != null) {
                    context.push(route);
                  }
                },
                child: Column(
                  children: [
                    _isLoading
                        ? SizedBox(
                            width: 40,
                            height: 20,
                            child: LinearProgressIndicator(
                              backgroundColor: AppColors.gray200,
                              valueColor: AlwaysStoppedAnimation(
                                  AppColors.primary700),
                            ),
                          )
                        : Text(
                            stat['value']!,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
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
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 12, left: 16, right: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline,
                      size: 14, color: AppColors.red500),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      '数据加载失败',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.red500,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _loadStats,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      '重试',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
        ],
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
              onTap: () {
                context.push('/agent/wallet');
              },
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
              onTap: () {
                context.push('/agent/level');
              },
            ),
          ],
        ),
        _buildMenuGroup(
          context,
          items: [
            _MenuItem(
              icon: Icons.people,
              title: '我的团队',
              onTap: () {
                context.push('/agent/team');
              },
            ),
            _MenuItem(
              icon: Icons.school,
              title: '培训学习',
              onTap: () {
                context.push('/agent/training');
              },
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
              onTap: () {
                context.push('/agent/help-support');
              },
            ),
            _MenuItem(
              icon: Icons.headset_mic,
              title: '联系客服',
              onTap: () {
                context.push('/agent/customer-service');
              },
            ),
            _MenuItem(
              icon: Icons.info_outline,
              title: '关于我们',
              onTap: () {
                context.push('/agent/about-us');
              },
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

  Widget _buildMenuGroup(BuildContext context,
      {required List<_MenuItem> items}) {
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
                        style:
                            TextStyle(fontSize: 12, color: AppColors.gray500),
                      )
                    : null,
                trailing:
                    const Icon(Icons.chevron_right, color: AppColors.gray400),
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
