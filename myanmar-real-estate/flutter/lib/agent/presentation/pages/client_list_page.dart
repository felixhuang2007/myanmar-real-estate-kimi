/**
 * B端 - 客户管理页
 */
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../buyer/providers/auth_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/gen/app_localizations.dart';

class ClientListPage extends ConsumerStatefulWidget {
  const ClientListPage({super.key});

  @override
  ConsumerState<ClientListPage> createState() => _ClientListPageState();
}

class _ClientListPageState extends ConsumerState<ClientListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _clients = [];
  bool _isLoading = false;
  String? _error;

  static const _tabStatuses = ['all', 'new', 'following', 'high_intent', 'deal'];

  // Controllers for add-client bottom sheet
  final TextEditingController _addNameCtrl = TextEditingController();
  final TextEditingController _addPhoneCtrl = TextEditingController();
  final TextEditingController _addRemarkCtrl = TextEditingController();
  final TextEditingController _addBudgetCtrl = TextEditingController();
  final TextEditingController _addPreferAreaCtrl = TextEditingController();
  String _addSource = 'platform';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadClients(_tabStatuses[0]);
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    _loadClients(_tabStatuses[_tabController.index]);
  }

  Future<void> _loadClients(String status) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final token = ref.read(authProvider).user?.token ?? '';
      final dio = Dio();
      final params = <String, dynamic>{
        'page': 1,
        'pageSize': 50,
      };
      if (status != 'all') {
        params['status'] = status;
      }
      final search = _searchController.text.trim();
      if (search.isNotEmpty) {
        params['search'] = search;
      }

      final resp = await dio.get(
        '${ApiConstants.baseUrl}/v1/clients',
        queryParameters: params,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      final list = resp.data['data']['list'] as List? ?? [];
      if (!mounted) return;
      setState(() {
        _clients = list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _addClient() async {
    final name = _addNameCtrl.text.trim();
    final phone = _addPhoneCtrl.text.trim();
    if (name.isEmpty || phone.isEmpty) return;

    try {
      final token = ref.read(authProvider).user?.token ?? '';
      final dio = Dio();
      await dio.post(
        '${ApiConstants.baseUrl}/v1/clients',
        data: {
          'name': name,
          'phone': phone,
          'source': _addSource,
          'remark': _addRemarkCtrl.text.trim(),
          if (_addBudgetCtrl.text.trim().isNotEmpty)
            'budget': int.tryParse(_addBudgetCtrl.text.trim()) ?? 0,
          if (_addPreferAreaCtrl.text.trim().isNotEmpty)
            'prefer_area': _addPreferAreaCtrl.text.trim(),
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      // reset fields
      _addNameCtrl.clear();
      _addPhoneCtrl.clear();
      _addRemarkCtrl.clear();
      _addBudgetCtrl.clear();
      _addPreferAreaCtrl.clear();
      _addSource = 'platform';

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('客户添加成功')),
        );
        _loadClients(_tabStatuses[_tabController.index]);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('添加失败: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _searchController.dispose();
    _addNameCtrl.dispose();
    _addPhoneCtrl.dispose();
    _addRemarkCtrl.dispose();
    _addBudgetCtrl.dispose();
    _addPreferAreaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('我的客户'),
        backgroundColor: AppColors.white,
        elevation: 0.5,
        actions: [
          IconButton(
            onPressed: () {
              _showAddClientDialog(context);
            },
            icon: const Icon(Icons.person_add),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              // 搜索栏
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: '搜索客户姓名、电话...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: AppColors.gray100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onSubmitted: (_) =>
                      _loadClients(_tabStatuses[_tabController.index]),
                ),
              ),
              // Tab栏
              TabBar(
                controller: _tabController,
                labelColor: AppColors.primary700,
                unselectedLabelColor: AppColors.gray600,
                indicatorColor: AppColors.primary700,
                isScrollable: true,
                tabs: const [
                  Tab(text: '全部'),
                  Tab(text: '新客'),
                  Tab(text: '跟进中'),
                  Tab(text: '意向强'),
                  Tab(text: '已成交'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildClientList(context, 'all'),
          _buildClientList(context, 'new'),
          _buildClientList(context, 'following'),
          _buildClientList(context, 'high_intent'),
          _buildClientList(context, 'deal'),
        ],
      ),
    );
  }

  Widget _buildClientList(BuildContext context, String status) {
    // Only render content for the active tab
    if (_tabStatuses[_tabController.index] != status) {
      return _buildEmptyState();
    }

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      final l = AppLocalizations.of(context);
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: AppColors.red500),
            const SizedBox(height: 12),
            Text(l.loadFailed, style: TextStyle(color: AppColors.gray700)),
            const SizedBox(height: 4),
            Text(_error!,
                style: TextStyle(fontSize: 12, color: AppColors.gray500)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _loadClients(status),
              child: Text(l.retry),
            ),
          ],
        ),
      );
    }

    if (_clients.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () => _loadClients(status),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _clients.length,
        itemBuilder: (context, index) {
          return _buildClientCard(context, _clients[index]);
        },
      ),
    );
  }

  Widget _buildClientCard(BuildContext context, Map<String, dynamic> client) {
    final statusColors = {
      'new': AppColors.red500,
      'following': AppColors.orange500,
      'high_intent': AppColors.blue500,
      'deal': AppColors.green500,
    };

    final statusLabels = {
      'new': '新客',
      'following': '跟进中',
      'high_intent': '意向强',
      'deal': '已成交',
    };

    final clientStatus = client['status']?.toString() ?? 'new';
    final clientId = client['id']?.toString() ?? '';
    final name = client['name']?.toString() ?? '';
    final phone = client['phone']?.toString() ?? '';
    final source = client['source']?.toString() ?? '';
    final budget = client['budget'];
    final budgetMax = client['budget_max'];
    final preferArea = client['prefer_area']?.toString() ?? '';
    final houseType = client['house_type']?.toString() ?? '';
    final requirement = client['requirement']?.toString() ?? '';
    final lastFollowAt = client['last_follow_at']?.toString() ?? '';

    // Build budget display string
    String budgetDisplay = '';
    if (budget != null && budgetMax != null) {
      budgetDisplay = '$budget-$budgetMax 万';
    } else if (budget != null) {
      budgetDisplay = '$budget 万';
    }

    // Format last follow time
    String lastContactDisplay = '未联系';
    if (lastFollowAt.isNotEmpty) {
      try {
        final dt = DateTime.parse(lastFollowAt);
        final diff = DateTime.now().difference(dt);
        if (diff.inHours < 1) {
          lastContactDisplay = '${diff.inMinutes}分钟前';
        } else if (diff.inHours < 24) {
          lastContactDisplay = '${diff.inHours}小时前';
        } else {
          lastContactDisplay = '${diff.inDays}天前';
        }
      } catch (_) {
        lastContactDisplay = lastFollowAt;
      }
    }

    return GestureDetector(
      onTap: () {
        if (clientId.isNotEmpty) {
          context.push('/agent/client/$clientId');
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 头部
            Row(
              children: [
                // 头像
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primary100,
                  child: Text(
                    name.isNotEmpty ? name.substring(0, 1) : '?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // 姓名电话
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            name,
                            style:
                                Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: (statusColors[clientStatus] ??
                                      AppColors.gray500)
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              statusLabels[clientStatus] ?? clientStatus,
                              style: TextStyle(
                                fontSize: 11,
                                color: statusColors[clientStatus] ??
                                    AppColors.gray500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.phone, size: 14, color: AppColors.gray500),
                          const SizedBox(width: 4),
                          Text(
                            phone,
                            style: TextStyle(
                                fontSize: 13, color: AppColors.gray600),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // 操作按钮
                PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'call',
                      child: Row(
                        children: [
                          Icon(Icons.phone),
                          SizedBox(width: 8),
                          Text('拨打电话'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'message',
                      child: Row(
                        children: [
                          Icon(Icons.message),
                          SizedBox(width: 8),
                          Text('发送消息'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'showing',
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today),
                          SizedBox(width: 8),
                          Text('预约带看'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const Divider(height: 24),

            // 需求信息
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                      '需求',
                      requirement.isNotEmpty
                          ? requirement
                          : houseType.isNotEmpty
                              ? houseType
                              : '-'),
                ),
                Expanded(
                  child: _buildInfoItem(
                      '预算', budgetDisplay.isNotEmpty ? budgetDisplay : '-'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                      '区域', preferArea.isNotEmpty ? preferArea : '-'),
                ),
                Expanded(
                  child: _buildInfoItem(
                      '来源', source.isNotEmpty ? source : '-'),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // 最后联系时间
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '最后联系: $lastContactDisplay',
                  style: TextStyle(fontSize: 12, color: AppColors.gray500),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (clientId.isNotEmpty) {
                      context.push('/agent/client/$clientId');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(80, 32),
                    padding: EdgeInsets.zero,
                  ),
                  child: const Text('跟进'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: TextStyle(fontSize: 13, color: AppColors.gray500),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontSize: 13, color: AppColors.gray700),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: AppColors.gray400,
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context).noData,
            style: TextStyle(color: AppColors.gray600),
          ),
        ],
      ),
    );
  }

  void _showAddClientDialog(BuildContext context) {
    // Reset controllers before opening
    _addNameCtrl.clear();
    _addPhoneCtrl.clear();
    _addRemarkCtrl.clear();
    _addBudgetCtrl.clear();
    _addPreferAreaCtrl.clear();
    _addSource = 'platform';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '添加新客户',
                  style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _addNameCtrl,
                  decoration: InputDecoration(
                    labelText: '客户姓名 *',
                    filled: true,
                    fillColor: AppColors.gray50,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _addPhoneCtrl,
                  decoration: InputDecoration(
                    labelText: '手机号 *',
                    filled: true,
                    fillColor: AppColors.gray50,
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                // 来源选择
                DropdownButtonFormField<String>(
                  value: _addSource,
                  decoration: InputDecoration(
                    labelText: '客户来源',
                    filled: true,
                    fillColor: AppColors.gray50,
                  ),
                  items: const [
                    DropdownMenuItem(value: 'platform', child: Text('平台分配')),
                    DropdownMenuItem(value: 'referral', child: Text('客户推荐')),
                    DropdownMenuItem(value: 'call', child: Text('电话咨询')),
                    DropdownMenuItem(value: 'showing', child: Text('带看转化')),
                    DropdownMenuItem(value: 'other', child: Text('其他')),
                  ],
                  onChanged: (v) => setSheetState(() => _addSource = v ?? 'platform'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _addBudgetCtrl,
                  decoration: InputDecoration(
                    labelText: '预算 (万缅元，可选)',
                    filled: true,
                    fillColor: AppColors.gray50,
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _addPreferAreaCtrl,
                  decoration: InputDecoration(
                    labelText: '意向区域 (可选)',
                    filled: true,
                    fillColor: AppColors.gray50,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _addRemarkCtrl,
                  decoration: InputDecoration(
                    labelText: '需求备注',
                    filled: true,
                    fillColor: AppColors.gray50,
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _addClient,
                    child: Text(AppLocalizations.of(context).save),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
