/**
 * B端 - 地推中心页
 * 地推员可查看推广码、推荐记录、提现记录，并申请提现
 */
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../buyer/providers/auth_provider.dart';
import '../../../l10n/gen/app_localizations.dart';

class PromoterPage extends ConsumerStatefulWidget {
  const PromoterPage({super.key});

  @override
  ConsumerState<PromoterPage> createState() => _PromoterPageState();
}

class _PromoterPageState extends ConsumerState<PromoterPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // 地推员信息
  Map<String, dynamic>? _promoterInfo;
  bool _infoLoading = false;
  String? _infoError;

  // 推荐记录
  List<Map<String, dynamic>> _referrals = [];
  bool _referralsLoading = false;
  int _referralsPage = 1;

  // 提现记录
  List<Map<String, dynamic>> _withdrawals = [];
  bool _withdrawalsLoading = false;
  int _withdrawalsPage = 1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    _registerOrFetchPromoter();
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    switch (_tabController.index) {
      case 1:
        if (_referrals.isEmpty) _loadReferrals(refresh: true);
        break;
      case 2:
        if (_withdrawals.isEmpty) _loadWithdrawals(refresh: true);
        break;
    }
  }

  String _token() => ref.read(authProvider).user?.token ?? '';

  /// POST /v1/promoter/register — 幂等注册，首次调用创建，后续返回已有记录
  Future<void> _registerOrFetchPromoter() async {
    if (_infoLoading) return;
    setState(() {
      _infoLoading = true;
      _infoError = null;
    });
    try {
      final dio = Dio();
      // 先尝试 GET /v1/promoter/me
      Response response;
      try {
        response = await dio.get(
          '${ApiConstants.baseUrl}/v1/promoter/me',
          options: Options(
            headers: {'Authorization': 'Bearer ${_token()}'},
          ),
        );
      } catch (_) {
        // 若 me 接口报错则尝试注册
        response = await dio.post(
          '${ApiConstants.baseUrl}/v1/promoter/register',
          options: Options(
            headers: {'Authorization': 'Bearer ${_token()}'},
          ),
        );
      }

      final body = response.data as Map<String, dynamic>;
      final code = body['code'] as int? ?? -1;
      if (code == 0 && body['data'] != null) {
        if (mounted) {
          setState(() {
            _promoterInfo = body['data'] as Map<String, dynamic>;
            _infoLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _infoError = body['message']?.toString() ?? '获取地推信息失败';
            _infoLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _infoError = e.toString();
          _infoLoading = false;
        });
      }
    }
  }

  Future<void> _loadReferrals({bool refresh = false}) async {
    if (_referralsLoading) return;
    final page = refresh ? 1 : _referralsPage;
    setState(() => _referralsLoading = true);
    try {
      final dio = Dio();
      final response = await dio.get(
        '${ApiConstants.baseUrl}/v1/promoter/referrals',
        queryParameters: {'page': page, 'pageSize': 20},
        options: Options(
          headers: {'Authorization': 'Bearer ${_token()}'},
        ),
      );
      final body = response.data as Map<String, dynamic>;
      if (body['code'] == 0) {
        final list = (body['data']?['list'] as List<dynamic>? ?? [])
            .cast<Map<String, dynamic>>();
        if (mounted) {
          setState(() {
            if (refresh) {
              _referrals = list;
              _referralsPage = 2;
            } else {
              _referrals.addAll(list);
              _referralsPage = page + 1;
            }
            _referralsLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _referralsLoading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _referralsLoading = false);
    }
  }

  Future<void> _loadWithdrawals({bool refresh = false}) async {
    if (_withdrawalsLoading) return;
    final page = refresh ? 1 : _withdrawalsPage;
    setState(() => _withdrawalsLoading = true);
    try {
      final dio = Dio();
      final response = await dio.get(
        '${ApiConstants.baseUrl}/v1/promoter/withdrawals',
        queryParameters: {'page': page, 'pageSize': 20},
        options: Options(
          headers: {'Authorization': 'Bearer ${_token()}'},
        ),
      );
      final body = response.data as Map<String, dynamic>;
      if (body['code'] == 0) {
        final list = (body['data']?['list'] as List<dynamic>? ?? [])
            .cast<Map<String, dynamic>>();
        if (mounted) {
          setState(() {
            if (refresh) {
              _withdrawals = list;
              _withdrawalsPage = 2;
            } else {
              _withdrawals.addAll(list);
              _withdrawalsPage = page + 1;
            }
            _withdrawalsLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _withdrawalsLoading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _withdrawalsLoading = false);
    }
  }

  // ── 工具方法 ──────────────────────────────────────────────────────────────

  String _formatMmk(dynamic raw) {
    final amount = double.tryParse(raw?.toString() ?? '0') ?? 0;
    final intVal = amount.toInt();
    final formatted = intVal
        .toString()
        .replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (m) => '${m[0]},',
        );
    return 'MMK $formatted';
  }

  String _maskPhone(String? phone) {
    if (phone == null || phone.length < 8) return phone ?? '--';
    return '${phone.substring(0, 2)}****${phone.substring(phone.length - 4)}';
  }

  String _formatDate(dynamic raw) {
    final s = raw?.toString() ?? '';
    if (s.length >= 10) return s.substring(0, 10);
    return s.isEmpty ? '--' : s;
  }

  // ── 提现弹窗 ──────────────────────────────────────────────────────────────

  void _showWithdrawSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _WithdrawSheet(
        token: _token(),
        pendingAmount: _promoterInfo?['pending_withdrawal'],
        onSuccess: () {
          _loadWithdrawals(refresh: true);
          _registerOrFetchPromoter();
        },
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('地推中心'),
        backgroundColor: AppColors.white,
        elevation: 0.5,
        actions: [
          TextButton.icon(
            onPressed: _showWithdrawSheet,
            icon: const Icon(Icons.account_balance_wallet_outlined, size: 18),
            label: const Text('申请提现'),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary700,
          unselectedLabelColor: AppColors.gray600,
          indicatorColor: AppColors.primary700,
          tabs: const [
            Tab(text: '推广码'),
            Tab(text: '推荐记录'),
            Tab(text: '提现记录'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildQrTab(),
          _buildReferralsTab(),
          _buildWithdrawalsTab(),
        ],
      ),
    );
  }

  // ── Tab 1: 推广码 ─────────────────────────────────────────────────────────

  Widget _buildQrTab() {
    if (_infoLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_infoError != null) {
      final l = AppLocalizations.of(context);
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: AppColors.red500, size: 48),
            const SizedBox(height: 12),
            Text(_infoError!, style: TextStyle(color: AppColors.gray600)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _registerOrFetchPromoter,
              child: Text(l.retry),
            ),
          ],
        ),
      );
    }

    final info = _promoterInfo;
    final code = info?['code']?.toString() ?? '--';
    final status = info?['status']?.toString() ?? 'inactive';
    final validReferrals = info?['valid_referrals'] ?? 0;
    final totalCommission = info?['total_commission'];
    final pendingWithdrawal = info?['pending_withdrawal'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 状态徽章
          _buildStatusBadge(status),
          const SizedBox(height: 16),

          // 推广码展示卡片
          _buildCodeCard(code),
          const SizedBox(height: 16),

          // 统计数据
          _buildStatsRow(
            validReferrals: validReferrals,
            totalCommission: totalCommission,
            pendingWithdrawal: pendingWithdrawal,
          ),
          const SizedBox(height: 16),

          // 使用说明
          _buildUsageGuide(),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final isActive = status == 'active';
    final color = isActive ? AppColors.green500 : AppColors.orange500;
    final label = isActive ? '已激活' : '待激活';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            '地推员状态：$label',
            style: TextStyle(
              fontSize: 13,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeCard(String code) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            '我的推广码',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.gray600,
            ),
          ),
          const SizedBox(height: 16),

          // 大字显示推广码
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.primary50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary600.withOpacity(0.3)),
            ),
            child: Text(
              code,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.primary900,
                letterSpacing: 4,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 复制按钮
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _copyCode(code),
              icon: const Icon(Icons.copy, size: 18),
              label: const Text('复制推广码'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary700,
                side: BorderSide(color: AppColors.primary700),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '将推广码分享给新用户，注册时填入即可',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.gray500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _copyCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('推广码已复制到剪贴板'),
        backgroundColor: AppColors.green500,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildStatsRow({
    required dynamic validReferrals,
    required dynamic totalCommission,
    required dynamic pendingWithdrawal,
  }) {
    final items = [
      {
        'label': '有效推荐',
        'value': '${validReferrals ?? 0} 人',
        'color': AppColors.primary700,
        'icon': Icons.people,
      },
      {
        'label': '总佣金',
        'value': _formatMmk(totalCommission),
        'color': AppColors.green500,
        'icon': Icons.monetization_on,
      },
      {
        'label': '待提现',
        'value': _formatMmk(pendingWithdrawal),
        'color': AppColors.orange500,
        'icon': Icons.account_balance_wallet,
      },
    ];

    return Row(
      children: items.map((item) {
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(
                  item['icon'] as IconData,
                  color: item['color'] as Color,
                  size: 22,
                ),
                const SizedBox(height: 8),
                Text(
                  item['value'] as String,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: item['color'] as Color,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  item['label'] as String,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.gray600,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildUsageGuide() {
    final steps = [
      {'icon': Icons.share, 'text': '复制推广码或邀请链接，分享给潜在用户'},
      {'icon': Icons.person_add, 'text': '新用户注册时填写你的推广码'},
      {'icon': Icons.check_circle, 'text': '用户完成实名认证后计为有效推荐'},
      {'icon': Icons.monetization_on, 'text': '每次有效推荐可获得佣金奖励'},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '如何推广',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.gray800,
            ),
          ),
          const SizedBox(height: 12),
          ...steps.asMap().entries.map((e) {
            final index = e.key;
            final step = e.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.primary50,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      step['text'] as String,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.gray700,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ── Tab 2: 推荐记录 ───────────────────────────────────────────────────────

  Widget _buildReferralsTab() {
    return RefreshIndicator(
      onRefresh: () => _loadReferrals(refresh: true),
      child: _referralsLoading && _referrals.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _referrals.isEmpty
              ? _buildEmptyState('暂无推荐记录', Icons.people_outline)
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _referrals.length,
                  itemBuilder: (ctx, i) => _buildReferralItem(_referrals[i]),
                ),
    );
  }

  Widget _buildReferralItem(Map<String, dynamic> item) {
    final phone = item['phone']?.toString() ?? item['user']?['phone']?.toString();
    final commission = item['commission']?.toString() ?? item['commission_amount'];
    final status = item['status']?.toString() ?? 'pending';
    final date = _formatDate(item['created_at'] ?? item['date']);

    final statusColor = status == 'confirmed' ? AppColors.green500 : AppColors.orange500;
    final statusLabel = status == 'confirmed' ? '已确认' : '待确认';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary50,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person, color: AppColors.primary700, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _maskPhone(phone),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  date,
                  style: TextStyle(fontSize: 12, color: AppColors.gray500),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatMmk(commission),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary700,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: 11,
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Tab 3: 提现记录 ───────────────────────────────────────────────────────

  Widget _buildWithdrawalsTab() {
    return RefreshIndicator(
      onRefresh: () => _loadWithdrawals(refresh: true),
      child: _withdrawalsLoading && _withdrawals.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _withdrawals.isEmpty
              ? _buildEmptyState('暂无提现记录', Icons.account_balance_wallet_outlined)
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _withdrawals.length,
                  itemBuilder: (ctx, i) =>
                      _buildWithdrawalItem(_withdrawals[i]),
                ),
    );
  }

  Widget _buildWithdrawalItem(Map<String, dynamic> item) {
    final amount = item['amount'];
    final method = item['method']?.toString() ?? '';
    final status = item['status']?.toString() ?? 'pending';
    final date = _formatDate(item['created_at'] ?? item['date']);

    Color statusColor;
    String statusLabel;
    switch (status) {
      case 'completed':
        statusColor = AppColors.green500;
        statusLabel = '已完成';
        break;
      case 'processing':
        statusColor = AppColors.blue500;
        statusLabel = '处理中';
        break;
      case 'failed':
        statusColor = AppColors.red500;
        statusLabel = '失败';
        break;
      case 'pending':
      default:
        statusColor = AppColors.orange500;
        statusLabel = '待处理';
    }

    final methodLabel = _methodLabel(method);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.green50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.account_balance_wallet,
              color: AppColors.green500,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatMmk(amount),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    _buildMethodBadge(methodLabel),
                    const SizedBox(width: 8),
                    Text(
                      date,
                      style:
                          TextStyle(fontSize: 12, color: AppColors.gray500),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              statusLabel,
              style: TextStyle(
                fontSize: 11,
                color: statusColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _methodLabel(String method) {
    switch (method.toLowerCase()) {
      case 'kbzpay':
        return 'KBZPay';
      case 'wavepay':
        return 'WavePay';
      case 'bank':
      case 'bank_transfer':
        return '银行转账';
      default:
        return method.isEmpty ? '--' : method;
    }
  }

  Widget _buildMethodBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.blue100,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, color: AppColors.blue700),
      ),
    );
  }

  // ── 通用空状态 ────────────────────────────────────────────────────────────

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: AppColors.gray400),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(fontSize: 15, color: AppColors.gray500),
          ),
        ],
      ),
    );
  }
}

// ── 提现底部弹窗 ──────────────────────────────────────────────────────────────

class _WithdrawSheet extends StatefulWidget {
  final String token;
  final dynamic pendingAmount;
  final VoidCallback onSuccess;

  const _WithdrawSheet({
    required this.token,
    required this.pendingAmount,
    required this.onSuccess,
  });

  @override
  State<_WithdrawSheet> createState() => _WithdrawSheetState();
}

class _WithdrawSheetState extends State<_WithdrawSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _accountCtrl = TextEditingController();

  String _selectedMethod = 'kbzpay';
  bool _submitting = false;

  static const _methods = [
    {'value': 'kbzpay', 'label': 'KBZPay'},
    {'value': 'wavepay', 'label': 'WavePay'},
    {'value': 'bank_transfer', 'label': '银行转账'},
  ];

  @override
  void dispose() {
    _amountCtrl.dispose();
    _accountCtrl.dispose();
    super.dispose();
  }

  String _formatAvailable() {
    final raw = widget.pendingAmount;
    final amount = double.tryParse(raw?.toString() ?? '0') ?? 0;
    final intVal = amount.toInt();
    final formatted = intVal
        .toString()
        .replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (m) => '${m[0]},',
        );
    return 'MMK $formatted';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      final dio = Dio();
      final response = await dio.post(
        '${ApiConstants.baseUrl}/v1/promoter/withdraw',
        data: {
          'amount': int.parse(_amountCtrl.text.trim()),
          'method': _selectedMethod,
          'account_info': _accountCtrl.text.trim(),
        },
        options: Options(
          headers: {'Authorization': 'Bearer ${widget.token}'},
        ),
      );

      final body = response.data as Map<String, dynamic>;
      if (body['code'] == 0) {
        if (mounted) {
          Navigator.of(context).pop();
          widget.onSuccess();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('提现申请已提交'),
              backgroundColor: AppColors.green500,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(body['message']?.toString() ?? '提现失败，请重试'),
              backgroundColor: AppColors.red500,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('网络错误：${e.toString()}'),
            backgroundColor: AppColors.red500,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题行
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '申请提现',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),

          // 可提现余额
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primary50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(Icons.account_balance_wallet,
                    color: AppColors.primary700, size: 20),
                const SizedBox(width: 8),
                Text(
                  '可提现余额：',
                  style: TextStyle(color: AppColors.gray600, fontSize: 14),
                ),
                Text(
                  _formatAvailable(),
                  style: TextStyle(
                    color: AppColors.primary900,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Form(
            key: _formKey,
            child: Column(
              children: [
                // 提现金额
                TextFormField(
                  controller: _amountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: '提现金额 (MMK)',
                    hintText: '最低 10,000 MMK',
                    prefixIcon: Icon(Icons.monetization_on_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    final val = int.tryParse(v?.trim() ?? '');
                    if (val == null) return '请输入有效金额';
                    if (val < 10000) return '最低提现金额为 10,000 MMK';
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // 提现方式
                DropdownButtonFormField<String>(
                  value: _selectedMethod,
                  decoration: const InputDecoration(
                    labelText: '提现方式',
                    prefixIcon: Icon(Icons.payment),
                    border: OutlineInputBorder(),
                  ),
                  items: _methods
                      .map((m) => DropdownMenuItem(
                            value: m['value'],
                            child: Text(m['label']!),
                          ))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _selectedMethod = v);
                  },
                ),
                const SizedBox(height: 14),

                // 账号信息
                TextFormField(
                  controller: _accountCtrl,
                  decoration: const InputDecoration(
                    labelText: '账号信息',
                    hintText: '手机号或银行账号',
                    prefixIcon: Icon(Icons.phone_android),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return '请填写账号信息';
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // 提交
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _submitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary700,
                      foregroundColor: AppColors.white,
                    ),
                    child: _submitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: AppColors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            '确认提现',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
