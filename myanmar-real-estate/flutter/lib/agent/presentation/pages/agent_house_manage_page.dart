/**
 * B端 - 房源管理页面
 */
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../l10n/gen/app_localizations.dart';

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
          _buildHouseList('all'),
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

  Widget _buildHouseList(String status) {
    // 模拟数据
    final mockHouses = [
      {
        'title': '仰光Tamwe区精装3室公寓',
        'price': '15,000万',
        'area': '120㎡',
        'rooms': '3室2厅',
        'status': 'online',
        'views': 328,
        'inquiries': 12,
      },
      {
        'title': 'Bahan区别墅带花园',
        'price': '35,000万',
        'area': '280㎡',
        'rooms': '5室3厅',
        'status': 'verifying',
        'views': 156,
        'inquiries': 5,
      },
      {
        'title': 'Yankin区单身公寓',
        'price': '8,000万',
        'area': '65㎡',
        'rooms': '1室1厅',
        'status': 'offline',
        'views': 89,
        'inquiries': 2,
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: mockHouses.length,
      itemBuilder: (context, index) {
        return _buildHouseCard(context, mockHouses[index]);
      },
    );
  }

  Widget _buildHouseCard(BuildContext context, Map<String, dynamic> house) {
    Color statusColor;
    String statusText;
    
    switch (house['status']) {
      case 'online':
        statusColor = AppColors.green500;
        statusText = '在售';
        break;
      case 'verifying':
        statusColor = AppColors.orange500;
        statusText = '审核中';
        break;
      case 'offline':
        statusColor = AppColors.gray500;
        statusText = '已下架';
        break;
      default:
        statusColor = AppColors.gray500;
        statusText = '未知';
    }

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
                child: Container(
                  width: 100,
                  height: 75,
                  color: AppColors.gray200,
                  child: const Icon(Icons.image, color: AppColors.gray400),
                ),
              ),
              const SizedBox(width: 12),
              // 信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      house['title'],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${house['area']} · ${house['rooms']}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.gray600,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          house['price'],
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
              _buildStat('浏览', house['views'].toString()),
              _buildStat('咨询', house['inquiries'].toString()),
              _buildStat('收藏', '12'),
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
