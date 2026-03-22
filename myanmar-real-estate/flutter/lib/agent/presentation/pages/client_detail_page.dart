/**
 * B端 - 客户详情页（含跟进记录时间轴）
 */
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../buyer/providers/auth_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/gen/app_localizations.dart';

class ClientDetailPage extends ConsumerStatefulWidget {
  final int clientId;
  const ClientDetailPage({required this.clientId, super.key});

  @override
  ConsumerState<ClientDetailPage> createState() => _ClientDetailPageState();
}

class _ClientDetailPageState extends ConsumerState<ClientDetailPage> {
  Map<String, dynamic>? _client;
  List<Map<String, dynamic>> _followUps = [];
  bool _isLoadingClient = false;
  bool _isLoadingFollowUps = false;
  String? _clientError;
  String? _followUpsError;

  // Follow-up bottom sheet controllers
  String _fuMethod = 'call';
  final TextEditingController _fuContentCtrl = TextEditingController();
  String? _fuStatusChange;
  DateTime? _fuNextFollowAt;

  @override
  void initState() {
    super.initState();
    _loadClient();
    _loadFollowUps();
  }

  @override
  void dispose() {
    _fuContentCtrl.dispose();
    super.dispose();
  }

  String _token() => ref.read(authProvider).user?.token ?? '';

  Future<void> _loadClient() async {
    if (!mounted) return;
    setState(() {
      _isLoadingClient = true;
      _clientError = null;
    });
    try {
      final dio = Dio();
      final resp = await dio.get(
        '${ApiConstants.baseUrl}/v1/clients/${widget.clientId}',
        options: Options(headers: {'Authorization': 'Bearer ${_token()}'}),
      );
      final data = resp.data['data'];
      if (!mounted) return;
      setState(() {
        _client = data is Map ? Map<String, dynamic>.from(data) : null;
        _isLoadingClient = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingClient = false;
        _clientError = e.toString();
      });
    }
  }

  Future<void> _loadFollowUps() async {
    if (!mounted) return;
    setState(() {
      _isLoadingFollowUps = true;
      _followUpsError = null;
    });
    try {
      final dio = Dio();
      final resp = await dio.get(
        '${ApiConstants.baseUrl}/v1/clients/${widget.clientId}/followups',
        queryParameters: {'page': 1, 'pageSize': 50},
        options: Options(headers: {'Authorization': 'Bearer ${_token()}'}),
      );
      final list = resp.data['data']['list'] as List? ?? [];
      if (!mounted) return;
      setState(() {
        _followUps =
            list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        _isLoadingFollowUps = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingFollowUps = false;
        _followUpsError = e.toString();
      });
    }
  }

  Future<void> _submitFollowUp() async {
    final content = _fuContentCtrl.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请填写跟进内容')),
      );
      return;
    }
    try {
      final dio = Dio();
      final body = <String, dynamic>{
        'contact_method': _fuMethod,
        'content': content,
      };
      if (_fuStatusChange != null) body['status_change'] = _fuStatusChange;
      if (_fuNextFollowAt != null) {
        body['next_follow_at'] = _fuNextFollowAt!.toIso8601String();
      }
      await dio.post(
        '${ApiConstants.baseUrl}/v1/clients/${widget.clientId}/followups',
        data: body,
        options: Options(headers: {'Authorization': 'Bearer ${_token()}'}),
      );
      // reset fields
      _fuContentCtrl.clear();
      _fuStatusChange = null;
      _fuNextFollowAt = null;
      _fuMethod = 'call';

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('跟进记录已保存')),
        );
        _loadFollowUps();
        _loadClient(); // reload client to refresh next_follow_at
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败: $e')),
        );
      }
    }
  }

  void _showAddFollowUpSheet() {
    _fuContentCtrl.clear();
    _fuStatusChange = null;
    _fuNextFollowAt = null;
    _fuMethod = 'call';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetCtx) => StatefulBuilder(
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
                  '新增跟进记录',
                  style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 20),

                // 联系方式
                Text('联系方式',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.gray700)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    _methodChip('call', '电话', Icons.phone, setSheetState),
                    _methodChip('sms', '短信', Icons.sms, setSheetState),
                    _methodChip('visit', '上门', Icons.home, setSheetState),
                    _methodChip('wechat', '微信', Icons.chat, setSheetState),
                  ],
                ),
                const SizedBox(height: 16),

                // 内容
                TextField(
                  controller: _fuContentCtrl,
                  decoration: InputDecoration(
                    labelText: '跟进内容 *',
                    hintText: '记录本次跟进情况...',
                    filled: true,
                    fillColor: AppColors.gray50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.gray300),
                    ),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),

                // 状态变更（可选）
                Text('更新客户状态（可选）',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.gray700)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String?>(
                  value: _fuStatusChange,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.gray50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.gray300),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('不变更状态')),
                    DropdownMenuItem(value: 'new', child: Text('新客')),
                    DropdownMenuItem(value: 'following', child: Text('跟进中')),
                    DropdownMenuItem(value: 'high_intent', child: Text('意向强')),
                    DropdownMenuItem(value: 'deal', child: Text('已成交')),
                    DropdownMenuItem(value: 'lost', child: Text('已流失')),
                  ],
                  onChanged: (v) =>
                      setSheetState(() => _fuStatusChange = v),
                ),
                const SizedBox(height: 16),

                // 下次跟进时间（可选）
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _fuNextFollowAt == null
                            ? '下次跟进时间（可选）'
                            : '下次跟进: ${_fuNextFollowAt!.toString().substring(0, 10)}',
                        style: TextStyle(
                            fontSize: 13, color: AppColors.gray700),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: ctx,
                          initialDate: DateTime.now()
                              .add(const Duration(days: 1)),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now()
                              .add(const Duration(days: 365)),
                        );
                        if (picked != null) {
                          setSheetState(() => _fuNextFollowAt = picked);
                        }
                      },
                      icon: const Icon(Icons.calendar_today, size: 16),
                      label: const Text('选择日期'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _submitFollowUp,
                    child: const Text('保存跟进'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _methodChip(
      String value, String label, IconData icon, StateSetter setSheetState) {
    final isSelected = _fuMethod == value;
    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              size: 14,
              color: isSelected ? AppColors.white : AppColors.gray600),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      selected: isSelected,
      selectedColor: AppColors.primary700,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.white : AppColors.gray600,
        fontSize: 13,
      ),
      onSelected: (_) => setSheetState(() => _fuMethod = value),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusColors = {
      'new': AppColors.red500,
      'following': AppColors.orange500,
      'high_intent': AppColors.blue500,
      'deal': AppColors.green500,
      'lost': AppColors.gray500,
    };
    final statusLabels = {
      'new': '新客',
      'following': '跟进中',
      'high_intent': '意向强',
      'deal': '已成交',
      'lost': '已流失',
    };

    final clientStatus = _client?['status']?.toString() ?? 'new';
    final clientName = _client?['name']?.toString() ?? '客户详情';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Flexible(
              child: Text(
                clientName,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (_client != null) ...[
              const SizedBox(width: 8),
              Chip(
                label: Text(
                  statusLabels[clientStatus] ?? clientStatus,
                  style: TextStyle(
                    fontSize: 11,
                    color: statusColors[clientStatus] ?? AppColors.gray500,
                  ),
                ),
                backgroundColor:
                    (statusColors[clientStatus] ?? AppColors.gray500)
                        .withOpacity(0.1),
                padding: EdgeInsets.zero,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ],
          ],
        ),
        backgroundColor: AppColors.white,
        elevation: 0.5,
      ),
      body: _isLoadingClient
          ? const Center(child: CircularProgressIndicator())
          : _clientError != null
              ? Center(
                  child: Builder(builder: (ctx) {
                    final l = AppLocalizations.of(ctx);
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline,
                            size: 48, color: AppColors.red500),
                        const SizedBox(height: 12),
                        Text(l.loadFailed,
                            style: TextStyle(color: AppColors.gray700)),
                        const SizedBox(height: 4),
                        Text(_clientError!,
                            style: TextStyle(
                                fontSize: 12, color: AppColors.gray500)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadClient,
                          child: Text(l.retry),
                        ),
                      ],
                    );
                  }),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    await _loadClient();
                    await _loadFollowUps();
                  },
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildBasicInfoCard(context),
                      const SizedBox(height: 16),
                      _buildNextFollowCard(context),
                      const SizedBox(height: 16),
                      _buildFollowUpsSection(context),
                    ],
                  ),
                ),
    );
  }

  Widget _buildBasicInfoCard(BuildContext context) {
    final client = _client ?? {};
    final name = client['name']?.toString() ?? '-';
    final phone = client['phone']?.toString() ?? '-';
    final source = client['source']?.toString() ?? '-';
    final budget = client['budget'];
    final budgetMax = client['budget_max'];
    final requirement = client['requirement']?.toString() ?? '';
    final preferArea = client['prefer_area']?.toString() ?? '-';
    final houseType = client['house_type']?.toString() ?? '-';
    final tags = client['tags'];

    String budgetDisplay = '-';
    if (budget != null && budgetMax != null) {
      budgetDisplay = '$budget - $budgetMax 万';
    } else if (budget != null) {
      budgetDisplay = '$budget 万';
    }

    List<String> tagList = [];
    if (tags is List) {
      tagList = tags.map((t) => t.toString()).toList();
    } else if (tags is String && tags.isNotEmpty) {
      tagList = tags.split(',').map((t) => t.trim()).toList();
    }

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
            '基本信息',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const Divider(height: 20),
          _detailRow(Icons.person, '姓名', name),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () {
              // Could launch phone dialer
            },
            child: _detailRow(Icons.phone, '电话', phone,
                trailing: Icon(Icons.call, size: 18, color: AppColors.primary700)),
          ),
          const SizedBox(height: 10),
          _detailRow(Icons.source, '来源', source),
          const SizedBox(height: 10),
          _detailRow(Icons.attach_money, '预算', budgetDisplay),
          const SizedBox(height: 10),
          _detailRow(Icons.location_city, '意向区域', preferArea),
          const SizedBox(height: 10),
          _detailRow(Icons.home_work, '房型', houseType),
          if (requirement.isNotEmpty) ...[
            const SizedBox(height: 10),
            _detailRow(Icons.notes, '需求', requirement),
          ],
          if (tagList.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: tagList
                  .map((t) => Chip(
                        label: Text(t,
                            style: TextStyle(
                                fontSize: 12, color: AppColors.primary700)),
                        backgroundColor: AppColors.primary100,
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value,
      {Widget? trailing}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.gray500),
        const SizedBox(width: 8),
        Text('$label: ',
            style: TextStyle(fontSize: 13, color: AppColors.gray500)),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontSize: 13, color: AppColors.gray800),
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  Widget _buildNextFollowCard(BuildContext context) {
    final nextFollowAt = _client?['next_follow_at']?.toString() ?? '';
    String display = '未设置';
    Color displayColor = AppColors.gray500;

    if (nextFollowAt.isNotEmpty) {
      try {
        final dt = DateTime.parse(nextFollowAt);
        final diff = dt.difference(DateTime.now());
        if (diff.isNegative) {
          display = '已过期: ${nextFollowAt.substring(0, 10)}';
          displayColor = AppColors.red500;
        } else if (diff.inHours < 24) {
          display = '今天 ${nextFollowAt.substring(11, 16)}';
          displayColor = AppColors.orange500;
        } else {
          display = nextFollowAt.substring(0, 10);
          displayColor = AppColors.green500;
        }
      } catch (_) {
        display = nextFollowAt;
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.alarm, color: displayColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '下次跟进提醒',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.gray700),
                ),
                const SizedBox(height: 2),
                Text(
                  display,
                  style: TextStyle(fontSize: 14, color: displayColor),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: _showAddFollowUpSheet,
            icon: const Icon(Icons.add, size: 16),
            label: const Text('新增跟进'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(0, 36),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFollowUpsSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '跟进记录',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              TextButton.icon(
                onPressed: _showAddFollowUpSheet,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('新增跟进'),
              ),
            ],
          ),
          const Divider(height: 20),
          if (_isLoadingFollowUps)
            const Center(
                child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ))
          else if (_followUpsError != null)
            Center(
              child: Builder(builder: (ctx) {
                final l = AppLocalizations.of(ctx);
                return Column(
                  children: [
                    const SizedBox(height: 12),
                    Text(l.loadFailed,
                        style: TextStyle(color: AppColors.gray700)),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _loadFollowUps,
                      child: Text(l.retry),
                    ),
                  ],
                );
              }),
            )
          else if (_followUps.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  '暂无跟进记录，点击右上角"新增跟进"开始记录',
                  style: TextStyle(color: AppColors.gray500, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else
            _buildTimeline(context),
        ],
      ),
    );
  }

  Widget _buildTimeline(BuildContext context) {
    return Column(
      children: List.generate(_followUps.length, (index) {
        final fu = _followUps[index];
        final isLast = index == _followUps.length - 1;
        return _buildTimelineItem(context, fu, isLast);
      }),
    );
  }

  Widget _buildTimelineItem(
      BuildContext context, Map<String, dynamic> fu, bool isLast) {
    final methodIcons = {
      'call': Icons.phone,
      'sms': Icons.sms,
      'visit': Icons.home,
      'wechat': Icons.chat,
    };
    final methodLabels = {
      'call': '电话',
      'sms': '短信',
      'visit': '上门',
      'wechat': '微信',
    };
    final statusColors = {
      'new': AppColors.red500,
      'following': AppColors.orange500,
      'high_intent': AppColors.blue500,
      'deal': AppColors.green500,
      'lost': AppColors.gray500,
    };
    final statusLabels = {
      'new': '→新客',
      'following': '→跟进中',
      'high_intent': '→意向强',
      'deal': '→已成交',
      'lost': '→已流失',
    };

    final method = fu['contact_method']?.toString() ?? 'call';
    final content = fu['content']?.toString() ?? '';
    final statusChange = fu['status_change']?.toString() ?? '';
    final nextFollowAt = fu['next_follow_at']?.toString() ?? '';
    final createdAt = fu['created_at']?.toString() ?? '';

    String createdDisplay = createdAt;
    if (createdAt.isNotEmpty) {
      try {
        final dt = DateTime.parse(createdAt);
        createdDisplay = '${dt.month}-${dt.day} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      } catch (_) {}
    }

    String nextDisplay = '';
    if (nextFollowAt.isNotEmpty) {
      try {
        nextDisplay = '下次跟进: ${DateTime.parse(nextFollowAt).toString().substring(0, 10)}';
      } catch (_) {
        nextDisplay = '下次跟进: $nextFollowAt';
      }
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 时间轴竖线 + 圆点
          SizedBox(
            width: 24,
            child: Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppColors.primary700,
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: AppColors.gray300,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // 内容卡片
          Expanded(
            child: Container(
              margin: EdgeInsets.only(bottom: isLast ? 0 : 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.gray50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.gray200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 方式 + 时间戳
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(methodIcons[method] ?? Icons.chat,
                              size: 14, color: AppColors.primary700),
                          const SizedBox(width: 4),
                          Text(
                            methodLabels[method] ?? method,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary700,
                            ),
                          ),
                          if (statusChange.isNotEmpty &&
                              statusLabels.containsKey(statusChange)) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: (statusColors[statusChange] ??
                                        AppColors.gray500)
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                statusLabels[statusChange]!,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: statusColors[statusChange] ??
                                      AppColors.gray500,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        createdDisplay,
                        style: TextStyle(
                            fontSize: 11, color: AppColors.gray500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // 内容
                  Text(
                    content,
                    style: TextStyle(
                        fontSize: 13, color: AppColors.gray700),
                  ),
                  // 下次跟进提示
                  if (nextDisplay.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.alarm,
                            size: 12, color: AppColors.orange500),
                        const SizedBox(width: 4),
                        Text(
                          nextDisplay,
                          style: TextStyle(
                              fontSize: 11, color: AppColors.orange500),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
