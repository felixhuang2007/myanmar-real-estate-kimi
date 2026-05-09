/**
 * C端 - 个人中心页
 */
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/api/dio_client.dart';
import '../../providers/auth_provider.dart';
import '../../../l10n/gen/app_localizations.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  int _favoritesCount = 0;
  int _viewsCount = 0;
  int _appointmentsCount = 0;
  bool _statsLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final favResponse = await DioClient.instance.get('/users/me/favorites?page_size=1');
      final favTotal = favResponse.data?['data']?['pagination']?['total'] ?? 0;

      final histResponse = await DioClient.instance.get('/users/me/browsing-history?page_size=1');
      final histTotal = histResponse.data?['data']?['pagination']?['total'] ?? 0;

      final apptResponse = await DioClient.instance.get('/appointments?page_size=1');
      final apptTotal = apptResponse.data?['data']?['pagination']?['total'] ?? 0;

      if (mounted) {
        setState(() {
          _favoritesCount = favTotal is int ? favTotal : 0;
          _viewsCount = histTotal is int ? histTotal : 0;
          _appointmentsCount = apptTotal is int ? apptTotal : 0;
          _statsLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _statsLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final user = ref.watch(authProvider).user;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // 顶部个人信息
          SliverToBoxAdapter(
            child: _buildHeader(context, user),
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
  Widget _buildHeader(BuildContext context, dynamic user) {
    final l = AppLocalizations.of(context);
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
          // 设置和消息按钮
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () {
                  context.push('/buyer/settings');
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
              const SizedBox(width: 16),
              
              // 信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.profile?.nickname ?? user?.phone ?? l.guestUser,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.phone, size: 14, color: AppColors.white.withOpacity(0.8)),
                        const SizedBox(width: 4),
                        Text(
                          user?.phone ?? '09***1234',
                          style: TextStyle(
                            color: AppColors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.green500,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified, size: 12, color: AppColors.white),
                          const SizedBox(width: 2),
                          Text(
                            l.verified,
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // 编辑按钮
              IconButton(
                onPressed: () {
                  context.push('/buyer/edit-profile');
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
    final l = AppLocalizations.of(context);
    final stats = [
      {'value': _statsLoading ? '...' : '$_favoritesCount', 'label': l.favorites, 'route': '/buyer/favorites'},
      {'value': _statsLoading ? '...' : '$_viewsCount', 'label': l.views, 'route': '/buyer/browsing-history'},
      {'value': _statsLoading ? '...' : '$_appointmentsCount', 'label': l.appointments, 'route': '/buyer/my-appointments'},
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
            onTap: () {
              final route = stat['route'] as String?;
              if (route != null) {
                context.push(route);
              }
            },
            child: Column(
              children: [
                Text(
                  stat['value']!,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
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
    final l = AppLocalizations.of(context);
    return Column(
      children: [
        _buildMenuGroup(
          context,
          items: [
            _MenuItem(
              icon: Icons.favorite_border,
              title: l.favorites,
              onTap: () {
                context.go('/buyer/favorites');
              },
            ),
            _MenuItem(
              icon: Icons.history,
              title: l.browsingHistory,
              onTap: () {
                context.push('/buyer/browsing-history');
              },
            ),
            _MenuItem(
              icon: Icons.calendar_today,
              title: l.myAppointments,
              onTap: () {
                context.push('/buyer/my-appointments');
              },
            ),
            _MenuItem(
              icon: Icons.home_work,
              title: l.myListings,
              onTap: () {
                context.push('/buyer/my-listings');
              },
            ),
          ],
        ),
        
        _buildMenuGroup(
          context,
          items: [
            _MenuItem(
              icon: Icons.calculate,
              title: l.mortgageCalc,
              onTap: () {
                context.push('/buyer/mortgage');
              },
            ),
            _MenuItem(
              icon: Icons.menu_book,
              title: l.buyingGuide,
              onTap: () {
                context.push('/buyer/buying-guide');
              },
            ),
            _MenuItem(
              icon: Icons.headset_mic,
              title: l.helpAndSupport,
              onTap: () {
                context.push('/buyer/help-support');
              },
            ),
          ],
        ),
        
        _buildMenuGroup(
          context,
          items: [
            _MenuItem(
              icon: Icons.info_outline,
              title: l.aboutUs,
              onTap: () {
                context.push('/buyer/about-us');
              },
            ),
            _MenuItem(
              icon: Icons.description,
              title: l.userAgreement,
              onTap: () {
                context.push('/buyer/terms');
              },
            ),
            _MenuItem(
              icon: Icons.privacy_tip,
              title: l.privacyPolicy,
              onTap: () {
                context.push('/buyer/privacy');
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
              child: Text(l.logout),
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
        content: Text(l.logoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.go(RouteNames.login);
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
  final VoidCallback onTap;

  _MenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });
}
