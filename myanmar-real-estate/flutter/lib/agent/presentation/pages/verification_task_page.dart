/**
 * B端 - 验真任务页
 */
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../buyer/providers/auth_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/gen/app_localizations.dart';

class VerificationTaskPage extends ConsumerStatefulWidget {
  const VerificationTaskPage({super.key});

  @override
  ConsumerState<VerificationTaskPage> createState() => _VerificationTaskPageState();
}

class _VerificationTaskPageState extends ConsumerState<VerificationTaskPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Real data state
  List<Map<String, dynamic>> _tasks = [];
  bool _isLoading = false;
  String? _error;

  static const _tabStatuses = ['pending', 'assigned', 'completed'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadTasks(_tabStatuses[0]);
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    _loadTasks(_tabStatuses[_tabController.index]);
  }

  Future<void> _loadTasks(String status) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final token = ref.read(authProvider).user?.token ?? '';
      final dio = Dio();
      final resp = await dio.get(
        '${ApiConstants.baseUrl}/v1/verification/my-tasks',
        queryParameters: {'status': status, 'page': 1, 'pageSize': 50},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      final rawData = resp.data['data'];
      final list = (rawData is List ? rawData : (rawData as Map?)?['list'] as List?) ?? [];
      if (!mounted) return;
      setState(() {
        _tasks = list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      final String msg;
      if (e is DioException) {
        msg = e.response?.data?['message'] as String? ?? e.message ?? 'Request failed';
      } else {
        msg = e.toString();
      }
      setState(() {
        _isLoading = false;
        _error = msg;
      });
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).verificationTask),
        backgroundColor: AppColors.white,
        elevation: 0.5,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary700,
          unselectedLabelColor: AppColors.gray600,
          indicatorColor: AppColors.primary700,
          tabs: const [
            Tab(text: '待执行'),
            Tab(text: '进行中'),
            Tab(text: '已完成'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTaskList(context, 'pending'),
          _buildTaskList(context, 'in_progress'),
          _buildTaskList(context, 'completed'),
        ],
      ),
    );
  }

  Widget _buildTaskList(BuildContext context, String status) {
    // Only show content for the currently selected tab
    if (_tabStatuses[_tabController.index] != status) {
      return _buildEmptyState(status);
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
            Text(_error!, style: TextStyle(fontSize: 12, color: AppColors.gray500)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _loadTasks(status),
              child: Text(l.retry),
            ),
          ],
        ),
      );
    }

    if (_tasks.isEmpty) {
      return _buildEmptyState(status);
    }

    return RefreshIndicator(
      onRefresh: () => _loadTasks(status),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _tasks.length,
        itemBuilder: (context, index) {
          final task = _tasks[index];
          return _buildTaskCard(context, task, status);
        },
      ),
    );
  }

  Widget _buildTaskCard(BuildContext context, Map<String, dynamic> task, String status) {
    // Map backend fields to display values
    final taskId = task['id']?.toString() ?? '';
    final taskCode = task['task_code']?.toString() ?? '';
    final houseId = task['house_id']?.toString() ?? '';
    final title = taskCode.isNotEmpty ? '验真任务 $taskCode' : '验真任务 #$houseId';
    final address = task['address']?.toString() ?? task['house_address']?.toString() ?? '地址待确认';
    final deadline = task['deadline_at']?.toString() ?? '';
    final commissionAmount = task['commission_amount'];
    final reward = commissionAmount != null ? commissionAmount.toString() : '-';
    final taskResult = task['result']?.toString() ?? '';
    final taskStatus = task['status']?.toString() ?? status;

    // Determine urgency: deadline within 24 hours counts as urgent
    bool isUrgent = false;
    String deadlineDisplay = deadline;
    if (deadline.isNotEmpty) {
      try {
        final dt = DateTime.parse(deadline);
        final diff = dt.difference(DateTime.now());
        isUrgent = diff.inHours < 24 && diff.inHours >= 0;
        if (diff.inHours < 1) {
          deadlineDisplay = '剩余 ${diff.inMinutes}分钟';
        } else if (diff.inHours < 24) {
          deadlineDisplay = '剩余 ${diff.inHours}小时';
        } else {
          deadlineDisplay = dt.toString().substring(0, 16);
        }
      } catch (_) {
        deadlineDisplay = deadline;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题行
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              if (isUrgent)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.red50,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '紧急',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.red600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),

          // 地址
          Row(
            children: [
              Icon(Icons.location_on, size: 14, color: AppColors.gray500),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  address,
                  style: TextStyle(fontSize: 13, color: AppColors.gray600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // 任务编号
          if (taskCode.isNotEmpty)
            Row(
              children: [
                Icon(Icons.tag, size: 14, color: AppColors.gray500),
                const SizedBox(width: 4),
                Text(
                  '任务编号: $taskCode',
                  style: TextStyle(fontSize: 13, color: AppColors.gray600),
                ),
              ],
            ),

          const Divider(height: 24),

          // 底部信息
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 截止时间/完成时间
              Row(
                children: [
                  Icon(
                    taskStatus == 'completed' ? Icons.check_circle : Icons.access_time,
                    size: 14,
                    color: taskStatus == 'completed' ? AppColors.green500 : AppColors.orange500,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    taskStatus == 'completed'
                        ? '已完成'
                        : deadlineDisplay.isNotEmpty
                            ? '截止: $deadlineDisplay'
                            : '截止时间待定',
                    style: TextStyle(
                      fontSize: 13,
                      color: taskStatus == 'completed' ? AppColors.green500 : AppColors.orange500,
                    ),
                  ),
                ],
              ),

              // 报酬
              Text(
                '💰 $reward 缅币',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.primary700,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 操作按钮
          if (taskStatus == 'pending')
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.push('/agent/verification/$taskId');
                },
                child: const Text('开始验真'),
              ),
            )
          else if (taskStatus == 'in_progress')
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.push('/agent/verification/$taskId');
                },
                child: const Text('继续验真'),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.green50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, size: 16, color: AppColors.green500),
                  const SizedBox(width: 4),
                  Text(
                    taskResult.isNotEmpty ? '验真$taskResult' : '验真已完成',
                    style: TextStyle(
                      color: AppColors.green500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String status) {
    final messages = {
      'pending': '暂无待执行的任务',
      'in_progress': '暂无进行中的任务',
      'completed': '暂无已完成的任务',
    };

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 64,
            color: AppColors.gray400,
          ),
          const SizedBox(height: 16),
          Text(
            messages[status] ?? '暂无任务',
            style: TextStyle(color: AppColors.gray600),
          ),
        ],
      ),
    );
  }
}
