/**
 * C端 - 首页
 */
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../providers/house_provider.dart';
import '../widgets/house_card.dart';
import '../widgets/banner_widget.dart';
import '../../../l10n/gen/app_localizations.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final recommendations = ref.watch(recommendationsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(recommendationsProvider);
          },
          child: CustomScrollView(
            slivers: [
              // 顶部搜索栏
              SliverToBoxAdapter(
                child: _buildSearchHeader(context),
              ),

              // Banner轮播
              SliverToBoxAdapter(
                child: _buildBanner(context),
              ),

              // 快捷入口
              SliverToBoxAdapter(
                child: _buildQuickActions(context),
              ),

              // 推荐房源标题
              SliverToBoxAdapter(
                child: _buildSectionTitle(context, l.recommended, onMore: () {
                  context.push(RouteNames.houseList);
                }),
              ),

              // 推荐房源列表
              recommendations.when(
                data: (houses) => SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.68,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final house = houses[index];
                        return HouseCard(
                          house: house,
                          onTap: () {
                            context.push('/buyer/house/${house.houseId}');
                          },
                        );
                      },
                      childCount: houses.length,
                    ),
                  ),
                ),
                loading: () => const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
                error: (error, _) => SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: AppColors.gray400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l.loadFailed,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.gray600,
                                ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              ref.invalidate(recommendationsProvider);
                            },
                            child: Text(l.retry),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // 底部留白
              const SliverToBoxAdapter(
                child: SizedBox(height: 24),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 搜索栏
  Widget _buildSearchHeader(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // 位置选择
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.location_on,
                  size: 16,
                  color: AppColors.primary700,
                ),
                const SizedBox(width: 4),
                Text(
                  l.cityYangon,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.primary700,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down,
                  size: 16,
                  color: AppColors.primary700,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // 搜索框
          Expanded(
            child: GestureDetector(
              onTap: () {
                context.push(RouteNames.buyerSearch);
              },
              child: Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.gray100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.search,
                      size: 20,
                      color: AppColors.gray500,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l.searchHint,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.gray500,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // 消息
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_outlined,
              color: AppColors.gray700,
            ),
          ),
        ],
      ),
    );
  }

  /// Banner轮播
  Widget _buildBanner(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: BannerWidget(),
    );
  }

  /// 快捷入口
  Widget _buildQuickActions(BuildContext context) {
    final l = AppLocalizations.of(context);
    final actions = [
      _QuickAction(
        icon: Icons.home_work,
        label: l.buyNewHome,
        color: AppColors.blue500,
        onTap: () {
          context.push('/buyer/search-result?title=${Uri.encodeComponent(l.buyNewHome)}&transactionType=sale&isNewHome=true');
        },
      ),
      _QuickAction(
        icon: Icons.maps_home_work,
        label: l.buySecondHand,
        color: AppColors.green500,
        onTap: () {
          context.push('/buyer/search-result?title=${Uri.encodeComponent(l.buySecondHand)}&transactionType=sale&isNewHome=false');
        },
      ),
      _QuickAction(
        icon: Icons.apartment,
        label: l.rent,
        color: AppColors.orange500,
        onTap: () {
          context.push('/buyer/search-result?title=${Uri.encodeComponent(l.rent)}&transactionType=rent');
        },
      ),
      _QuickAction(
        icon: Icons.map,
        label: l.mapSearch,
        color: AppColors.primary700,
        onTap: () {
          context.push(RouteNames.buyerMap);
        },
      ),
      _QuickAction(
        icon: Icons.calculate,
        label: l.mortgageCalc,
        color: AppColors.purple,
        onTap: () {
          context.push('/buyer/mortgage');
        },
      ),
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: actions.map((action) => _buildActionItem(context, action)).toList(),
      ),
    );
  }

  Widget _buildActionItem(BuildContext context, _QuickAction action) {
    return GestureDetector(
      onTap: action.onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: action.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              action.icon,
              color: action.color,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            action.label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.gray700,
                ),
          ),
        ],
      ),
    );
  }

  /// 区块标题
  Widget _buildSectionTitle(BuildContext context, String title, {VoidCallback? onMore}) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          if (onMore != null)
            TextButton(
              onPressed: onMore,
              child: Text(l.more),
            ),
        ],
      ),
    );
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}
