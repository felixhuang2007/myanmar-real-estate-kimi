/**
 * B端 - 房源管理页面
 */
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/house.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../providers/house_provider.dart';

class AgentHouseManagePage extends ConsumerStatefulWidget {
  const AgentHouseManagePage({super.key});

  @override
  ConsumerState<AgentHouseManagePage> createState() => _AgentHouseManagePageState();
}

class _AgentHouseManagePageState extends ConsumerState<AgentHouseManagePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    // 加载房源数据
    Future.microtask(() => ref.read(agentHouseListProvider.notifier).load(refresh: true));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l.houseManage),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: '全部'),
            Tab(text: '在售'),
            Tab(text: '审核中'),
            Tab(text: '已下架'),
            Tab(text: '草稿'),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              // 搜索
            },
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildHouseList(null),
          _buildHouseList('online'),
          _buildHouseList('pending'),
          _buildHouseList('offline'),
          _buildHouseList('draft'),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('${RouteNames.agentHouseManage}/add');
        },
        backgroundColor: AppColors.primary700,
        icon: const Icon(Icons.add),
        label: Text(l.addHouse),
      ),
    );
  }

  Widget _buildHouseList(String? statusFilter) {
    final houseState = ref.watch(agentHouseListProvider);

    if (houseState.isLoading && houseState.houses.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (houseState.error != null && houseState.houses.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(houseState.error!, style: const TextStyle(color: AppColors.gray600)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => ref.read(agentHouseListProvider.notifier).refresh(),
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    final houses = statusFilter == null
        ? houseState.houses
        : houseState.houses.where((h) => h.status == statusFilter).toList();

    if (houses.isEmpty) {
      return const Center(child: Text('暂无房源', style: TextStyle(color: AppColors.gray500)));
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(agentHouseListProvider.notifier).refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: houses.length,
        itemBuilder: (context, index) {
          return _buildHouseCard(context, houses[index]);
        },
      ),
    );
  }

  Widget _buildHouseCard(BuildContext context, House house) {
    Color statusColor;
    String statusText;

    switch (house.status) {
      case 'online':
        statusColor = AppColors.green500;
        statusText = '在售';
        break;
      case 'pending':
        statusColor = AppColors.orange500;
        statusText = '审核中';
        break;
      case 'offline':
        statusColor = AppColors.gray500;
        statusText = '已下架';
        break;
      case 'draft':
        statusColor = AppColors.gray400;
        statusText = '草稿';
        break;
      default:
        statusColor = AppColors.gray500;
        statusText = house.status;
    }

    final stats = house.stats;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // 图片
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: house.mainImage != null
                    ? Image.network(
                        house.mainImage!,
                        width: 100,
                        height: 75,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _imagePlaceholder(),
                      )
                    : _imagePlaceholder(),
              ),
              const SizedBox(width: 12),
              // 信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      house.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${house.area != null ? "${house.area}㎡" : ""} · ${house.rooms ?? ""}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.gray600,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          house.formattedPrice,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppColors.primary700,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            statusText,
                            style: TextStyle(
                              fontSize: 12,
                              color: statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          // 数据统计
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStat('浏览', stats?.viewCount.toString() ?? '0'),
              _buildStat('咨询', stats?.inquiryCount.toString() ?? '0'),
              _buildStat('收藏', stats?.favoriteCount.toString() ?? '0'),
            ],
          ),
          const Divider(height: 24),
          // 操作按钮
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  child: Text(AppLocalizations.of(context).edit),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  child: const Text('刷新'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  child: const Text('推广'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      width: 100,
      height: 75,
      color: AppColors.gray200,
      child: const Icon(Icons.image, color: AppColors.gray400),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.gray900,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.gray600,
          ),
        ),
      ],
    );
  }
}
