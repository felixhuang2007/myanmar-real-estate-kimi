/**
 * B端 - ACN成交确认页
 * 参与方查看成交单并确认或拒绝
 */
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../buyer/providers/auth_provider.dart';
import '../../../l10n/gen/app_localizations.dart';

class AcnConfirmPage extends ConsumerStatefulWidget {
  final int transactionId;
  const AcnConfirmPage({required this.transactionId, super.key});

  @override
  ConsumerState<AcnConfirmPage> createState() => _AcnConfirmPageState();
}

class _AcnConfirmPageState extends ConsumerState<AcnConfirmPage> {
  Map<String, dynamic>? _transaction;
  bool _isLoading = true;
  String? _error;
  bool _isConfirming = false;
  bool _isRejecting = false;

  @override
  void initState() {
    super.initState();
    _loadTransaction();
  }

  Future<void> _loadTransaction() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final dio = Dio();
      final token = ref.read(authProvider).user?.token ?? '';
      final resp = await dio.get(
        '${ApiConstants.baseUrl}/v1/acn/transactions/${widget.transactionId}',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (resp.data['code'] == 0) {
        setState(() {
          _transaction = resp.data['data'] as Map<String, dynamic>?;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = resp.data['message'] ?? '加载失败';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _confirm() async {
    setState(() => _isConfirming = true);
    try {
      final dio = Dio();
      final token = ref.read(authProvider).user?.token ?? '';
      final resp = await dio.post(
        '${ApiConstants.baseUrl}/v1/acn/transactions/${widget.transactionId}/confirm',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (resp.data['code'] == 0) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('已确认成交')),
          );
          context.pop();
        }
      } else {
        final msg = resp.data['message'] ?? '确认失败';
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('确认失败：$msg')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('确认失败：$e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isConfirming = false);
    }
  }

  Future<void> _showRejectDialog() async {
    final l = AppLocalizations.of(context);
    final reasonController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('拒绝成交'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            labelText: '拒绝原因',
            hintText: '请输入拒绝原因',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.confirm),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _reject(reasonController.text);
    }
    reasonController.dispose();
  }

  Future<void> _reject(String reason) async {
    setState(() => _isRejecting = true);
    try {
      final dio = Dio();
      final token = ref.read(authProvider).user?.token ?? '';
      final resp = await dio.post(
        '${ApiConstants.baseUrl}/v1/acn/transactions/${widget.transactionId}/reject',
        data: {'reason': reason},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (resp.data['code'] == 0) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('已拒绝成交')),
          );
          context.pop();
        }
      } else {
        final msg = resp.data['message'] ?? '拒绝失败';
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('拒绝失败：$msg')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('拒绝失败：$e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isRejecting = false);
    }
  }

  Color _statusColor(String? status) {
    switch (status) {
      case 'confirmed':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return AppColors.gray500;
    }
  }

  String _statusLabel(String? status) {
    switch (status) {
      case 'confirmed':
        return '已确认';
      case 'rejected':
        return '已拒绝';
      case 'pending':
        return '待确认';
      default:
        return status ?? '未知';
    }
  }

  String _roleLabel(String? roleCode) {
    switch (roleCode) {
      case 'ENTRANT':
        return '房源录入人';
      case 'MAINTAINER':
        return '房源维护人';
      case 'INTRODUCER':
        return '客源转介绍';
      case 'ACCOMPANIER':
        return '带看人';
      case 'CLOSER':
        return '成交人';
      default:
        return roleCode ?? '未知角色';
    }
  }

  String _formatAmount(dynamic value) {
    if (value == null) return '--';
    final num = double.tryParse(value.toString()) ?? 0;
    final wan = num / 10000;
    return '${wan.toStringAsFixed(0)}万';
  }

  String _formatRatio(dynamic bps) {
    if (bps == null) return '--';
    final v = (double.tryParse(bps.toString()) ?? 0) / 100;
    return '${v.toStringAsFixed(0)}%';
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = ref.read(authProvider).user?.userId;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).confirm),
        backgroundColor: AppColors.white,
        elevation: 0.5,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Builder(builder: (ctx) {
                    final l = AppLocalizations.of(ctx);
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('${l.loadFailed}：$_error',
                            style: TextStyle(color: AppColors.gray600)),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _loadTransaction,
                          child: Text(l.retry),
                        ),
                      ],
                    );
                  }),
                )
              : Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 成交单信息
                            _buildSectionTitle('成交单信息'),
                            const SizedBox(height: 12),
                            _buildTransactionInfo(),

                            const SizedBox(height: 24),

                            // 参与方列表
                            _buildSectionTitle('参与方列表'),
                            const SizedBox(height: 12),
                            _buildParticipantList(currentUserId),

                            const SizedBox(height: 24),

                            // 我的角色
                            _buildSectionTitle('我的角色'),
                            const SizedBox(height: 12),
                            _buildMyRole(currentUserId),
                          ],
                        ),
                      ),
                    ),
                    // 底部按钮
                    _buildBottomButtons(),
                  ],
                ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildTransactionInfo() {
    final t = _transaction;
    final status = t?['status'] as String?;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildInfoRow('成交单号', t?['transaction_code']?.toString() ?? '--'),
          const Divider(height: 20),
          _buildInfoRow(
              '房源信息',
              t?['house']?['title']?.toString() ??
                  '房源 #${t?['house_id'] ?? '--'}'),
          const Divider(height: 20),
          _buildInfoRow('成交金额', _formatAmount(t?['transaction_amount'])),
          const Divider(height: 20),
          _buildInfoRow('佣金总额', _formatAmount(t?['commission_amount'])),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('状态', style: TextStyle(color: AppColors.gray600)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor(status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _statusLabel(status),
                  style: TextStyle(
                    color: _statusColor(status),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: AppColors.gray600)),
        Text(
          value,
          style: TextStyle(
              fontWeight: FontWeight.w500, color: AppColors.gray800),
        ),
      ],
    );
  }

  Widget _buildParticipantList(int? currentUserId) {
    final roles = (_transaction?['roles'] as List<dynamic>?) ?? [];

    if (roles.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          '暂无参与方信息',
          style: TextStyle(color: AppColors.gray500),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: roles.asMap().entries.map((entry) {
          final i = entry.key;
          final role = entry.value as Map<String, dynamic>;
          final agentId = role['agent_id'];
          final isSelf = agentId != null && agentId == currentUserId;

          return Column(
            children: [
              if (i > 0) const Divider(height: 20),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      _roleLabel(role['role_code']?.toString()),
                      style: TextStyle(color: AppColors.gray700),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: isSelf
                              ? AppColors.primary100
                              : AppColors.gray200,
                          child: Text(
                            isSelf ? '我' : (agentId?.toString() ?? '-'),
                            style: TextStyle(
                              fontSize: 9,
                              color: isSelf
                                  ? AppColors.primary700
                                  : AppColors.gray600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            isSelf
                                ? '本人'
                                : (role['agent_name']?.toString() ??
                                    '经纪人 #$agentId'),
                            style: TextStyle(
                              color: AppColors.gray800,
                              fontWeight: isSelf
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isSelf
                          ? AppColors.primary50
                          : AppColors.green50,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _formatRatio(role['commission_ratio']),
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelf
                            ? AppColors.primary700
                            : AppColors.green700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMyRole(int? currentUserId) {
    final roles = (_transaction?['roles'] as List<dynamic>?) ?? [];
    final myRole = roles.cast<Map<String, dynamic>>().where((r) {
      return r['agent_id'] == currentUserId;
    }).firstOrNull;

    if (myRole == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          '您不在此成交单的参与方中',
          style: TextStyle(color: AppColors.gray500),
        ),
      );
    }

    final commissionAmount =
        (double.tryParse(_transaction?['commission_amount']?.toString() ?? '0') ??
                0) *
            (double.tryParse(myRole['commission_ratio']?.toString() ?? '0') ??
                    0) /
            10000;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary100),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '我的角色',
                style: TextStyle(
                    color: AppColors.primary700, fontWeight: FontWeight.bold),
              ),
              Text(
                _roleLabel(myRole['role_code']?.toString()),
                style: TextStyle(
                    color: AppColors.primary700, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('佣金比例', style: TextStyle(color: AppColors.gray600)),
              Text(
                _formatRatio(myRole['commission_ratio']),
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: AppColors.primary700),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('预计佣金', style: TextStyle(color: AppColors.gray600)),
              Text(
                '${(commissionAmount / 10000).toStringAsFixed(0)}万 缅币',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary700,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.gray200)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                foregroundColor: Colors.red,
                minimumSize: const Size(0, 48),
              ),
              onPressed:
                  (_isRejecting || _isConfirming) ? null : _showRejectDialog,
              child: _isRejecting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.red)),
                    )
                  : Text(AppLocalizations.of(context).cancel),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(0, 48),
              ),
              onPressed: (_isConfirming || _isRejecting) ? null : _confirm,
              child: _isConfirming
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white)),
                    )
                  : Text(AppLocalizations.of(context).confirm),
            ),
          ),
        ],
      ),
    );
  }
}
