/**
 * B端 - 执行验真页
 */
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../buyer/providers/auth_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/gen/app_localizations.dart';

// ---------------------------------------------------------------------------
// Internal data model for a single check item
// ---------------------------------------------------------------------------

class _CheckItem {
  final String name;
  final String category;
  String status = 'pending'; // pending / pass / fail
  String remark = '';
  List<String> photos = []; // uploaded photo URLs

  _CheckItem({required this.name, required this.category});
}

// ---------------------------------------------------------------------------
// Page widget
// ---------------------------------------------------------------------------

class VerificationExecutePage extends ConsumerStatefulWidget {
  final int taskId;
  const VerificationExecutePage({required this.taskId, super.key});

  @override
  ConsumerState<VerificationExecutePage> createState() =>
      _VerificationExecutePageState();
}

class _VerificationExecutePageState
    extends ConsumerState<VerificationExecutePage> {
  // ── Task data ──────────────────────────────────────────────────────────────
  Map<String, dynamic>? _taskData;
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _loadError;

  // ── Form state ─────────────────────────────────────────────────────────────
  String _result = 'pass'; // pass / fail / conditional
  int _score = 80;
  final TextEditingController _reportController = TextEditingController();

  // ── 11 check items in 3 categories ────────────────────────────────────────
  final List<_CheckItem> _checkItems = [
    // basic (4)
    _CheckItem(name: '房屋位置核实', category: 'basic'),
    _CheckItem(name: '产权状态确认', category: 'basic'),
    _CheckItem(name: '房屋实际状态', category: 'basic'),
    _CheckItem(name: '业主身份核实', category: 'basic'),
    // property (4)
    _CheckItem(name: '建筑面积核实', category: 'property'),
    _CheckItem(name: '配套设施核查', category: 'property'),
    _CheckItem(name: '房屋质量评估', category: 'property'),
    _CheckItem(name: '周边环境评估', category: 'property'),
    // transaction (3)
    _CheckItem(name: '价格合理性评估', category: 'transaction'),
    _CheckItem(name: '产权清晰度评估', category: 'transaction'),
    _CheckItem(name: '交易风险评估', category: 'transaction'),
  ];

  // Remark controllers — one per check item (indexed)
  late final List<TextEditingController> _remarkControllers;

  // Expandable section state
  final Map<String, bool> _sectionExpanded = {
    'basic': true,
    'property': true,
    'transaction': true,
  };

  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _remarkControllers = List.generate(
      _checkItems.length,
      (_) => TextEditingController(),
    );
    _loadTask();
  }

  @override
  void dispose() {
    _reportController.dispose();
    for (final c in _remarkControllers) {
      c.dispose();
    }
    super.dispose();
  }

  // ── API helpers ────────────────────────────────────────────────────────────

  String get _token => ref.read(authProvider).user?.token ?? '';

  Dio get _dio => Dio();

  Future<void> _loadTask() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      final resp = await _dio.get(
        '${ApiConstants.baseUrl}/v1/verification/tasks/${widget.taskId}',
        options: Options(headers: {'Authorization': 'Bearer $_token'}),
      );
      if (!mounted) return;
      setState(() {
        _taskData = Map<String, dynamic>.from(
            resp.data['data']['task'] as Map? ?? {});
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadError = e.toString();
      });
    }
  }

  /// Upload a single image file; returns the remote URL or null on failure.
  Future<String?> _uploadImage(File file) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path,
            filename: file.path.split('/').last),
      });
      final resp = await _dio.post(
        '${ApiConstants.baseUrl}/v1/upload/image',
        data: formData,
        options: Options(headers: {'Authorization': 'Bearer $_token'}),
      );
      return resp.data['data']['url'] as String?;
    } catch (e) {
      debugPrint('Upload error: $e');
      return null;
    }
  }

  /// Pick a photo from camera, upload it, and attach the URL to the check item.
  Future<void> _pickAndUploadPhoto(int itemIndex) async {
    final XFile? picked =
        await _imagePicker.pickImage(source: ImageSource.camera);
    if (picked == null) return;

    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('上传中...')));

    final url = await _uploadImage(File(picked.path));

    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    if (url != null) {
      setState(() {
        _checkItems[itemIndex].photos.add(url);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('图片上传失败，请重试')),
      );
    }
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);

    // Build items payload
    final items = _checkItems.asMap().entries.map((e) {
      final idx = e.key;
      final item = e.value;
      return {
        'item_name': item.name,
        'status': item.status,
        'remark': _remarkControllers[idx].text.trim(),
        'photos': item.photos,
      };
    }).toList();

    try {
      await _dio.post(
        '${ApiConstants.baseUrl}/v1/verification/tasks/${widget.taskId}/submit',
        data: {
          'result': _result,
          'score': _score,
          'report': _reportController.text.trim(),
          'items': items,
        },
        options: Options(headers: {'Authorization': 'Bearer $_token'}),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('验真报告提交成功')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('提交失败: $e')),
      );
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final taskCode = _taskData?['task_code']?.toString() ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('执行验真',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            if (taskCode.isNotEmpty)
              Text(taskCode,
                  style: TextStyle(fontSize: 12, color: AppColors.gray600)),
          ],
        ),
        backgroundColor: AppColors.white,
        elevation: 0.5,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _loadError != null
              ? _buildErrorView()
              : _buildBody(),
      bottomNavigationBar: _buildSubmitBar(),
    );
  }

  Widget _buildErrorView() {
    final l = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: AppColors.red500),
          const SizedBox(height: 12),
          Text(l.loadFailed, style: TextStyle(color: AppColors.gray700)),
          const SizedBox(height: 4),
          Text(_loadError!,
              style: TextStyle(fontSize: 12, color: AppColors.gray500)),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _loadTask, child: Text(l.retry)),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTaskInfoCard(),
          const SizedBox(height: 16),
          _buildSectionHeader('基础信息核查', 'basic'),
          if (_sectionExpanded['basic']!) _buildCheckItemsForCategory('basic'),
          const SizedBox(height: 8),
          _buildSectionHeader('房产状态核查', 'property'),
          if (_sectionExpanded['property']!)
            _buildCheckItemsForCategory('property'),
          const SizedBox(height: 8),
          _buildSectionHeader('交易条件核查', 'transaction'),
          if (_sectionExpanded['transaction']!)
            _buildCheckItemsForCategory('transaction'),
          const SizedBox(height: 16),
          _buildScoreSection(),
          const SizedBox(height: 16),
          _buildResultSection(),
          const SizedBox(height: 16),
          _buildReportSection(),
          // Extra space so content is not hidden behind submit bar
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  // ── Task info card ─────────────────────────────────────────────────────────

  Widget _buildTaskInfoCard() {
    final address = _taskData?['address']?.toString() ??
        _taskData?['house_address']?.toString() ??
        '地址待确认';
    final deadline = _taskData?['deadline_at']?.toString() ?? '-';
    final commission = _taskData?['commission_amount']?.toString() ?? '-';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('任务信息',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.gray900)),
          const SizedBox(height: 12),
          _infoRow(Icons.location_on, '地址', address),
          const SizedBox(height: 8),
          _infoRow(Icons.access_time, '截止时间', deadline),
          const SizedBox(height: 8),
          _infoRow(Icons.monetization_on, '验真佣金', '$commission 缅币'),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.gray500),
        const SizedBox(width: 8),
        Text('$label: ',
            style: TextStyle(fontSize: 13, color: AppColors.gray600)),
        Expanded(
          child: Text(value,
              style: TextStyle(
                  fontSize: 13,
                  color: AppColors.gray900,
                  fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }

  // ── Expandable section header ──────────────────────────────────────────────

  Widget _buildSectionHeader(String title, String category) {
    final categoryLabels = {
      'basic': '基础信息核查 (4项)',
      'property': '房产状态核查 (4项)',
      'transaction': '交易条件核查 (3项)',
    };
    return GestureDetector(
      onTap: () {
        setState(() {
          _sectionExpanded[category] = !(_sectionExpanded[category] ?? true);
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.primary50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                categoryLabels[category] ?? title,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary900),
              ),
            ),
            Icon(
              _sectionExpanded[category] ?? true
                  ? Icons.expand_less
                  : Icons.expand_more,
              color: AppColors.primary700,
            ),
          ],
        ),
      ),
    );
  }

  // ── Check items list for a category ───────────────────────────────────────

  Widget _buildCheckItemsForCategory(String category) {
    final indices = _checkItems
        .asMap()
        .entries
        .where((e) => e.value.category == category)
        .map((e) => e.key)
        .toList();

    return Column(
      children: indices
          .map((idx) => _buildCheckItemCard(idx))
          .toList(),
    );
  }

  Widget _buildCheckItemCard(int idx) {
    final item = _checkItems[idx];
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Item name + status toggle row
          Row(
            children: [
              Expanded(
                child: Text(item.name,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.gray900)),
              ),
              _buildStatusToggle(idx),
            ],
          ),
          const SizedBox(height: 10),

          // Remark field
          TextField(
            controller: _remarkControllers[idx],
            decoration: InputDecoration(
              hintText: '备注（选填）',
              hintStyle: TextStyle(fontSize: 13, color: AppColors.gray500),
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: AppColors.gray300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: AppColors.gray300),
              ),
            ),
            style: const TextStyle(fontSize: 13),
            maxLines: 1,
            onChanged: (v) => item.remark = v,
          ),
          const SizedBox(height: 10),

          // Photos row + camera button
          Row(
            children: [
              // Existing photo thumbnails
              ...item.photos.map((url) => _buildPhotoThumb(url, idx)),
              // Add photo button
              GestureDetector(
                onTap: () => _pickAndUploadPhoto(idx),
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.gray200,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.gray300),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt,
                          size: 20, color: AppColors.gray600),
                      Text('拍照',
                          style: TextStyle(
                              fontSize: 10, color: AppColors.gray600)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoThumb(String url, int itemIdx) {
    return Container(
      width: 56,
      height: 56,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.gray300),
        image: DecorationImage(
          image: NetworkImage(url),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  // ── Status toggle: 通过 / 不通过 / 待检查 ────────────────────────────────

  Widget _buildStatusToggle(int idx) {
    final item = _checkItems[idx];
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _statusChip(idx, 'pass', '通过', AppColors.green500, AppColors.green50),
        const SizedBox(width: 4),
        _statusChip(idx, 'fail', '不通过', AppColors.red500, AppColors.red50),
        const SizedBox(width: 4),
        _statusChip(
            idx, 'pending', '待检查', AppColors.gray500, AppColors.gray200),
      ],
    );
  }

  Widget _statusChip(int idx, String value, String label, Color activeColor,
      Color activeBg) {
    final selected = _checkItems[idx].status == value;
    return GestureDetector(
      onTap: () {
        setState(() => _checkItems[idx].status = value);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? activeBg : AppColors.gray100,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
              color: selected ? activeColor : AppColors.gray300, width: 1),
        ),
        child: Text(
          label,
          style: TextStyle(
              fontSize: 11,
              color: selected ? activeColor : AppColors.gray500,
              fontWeight:
                  selected ? FontWeight.bold : FontWeight.normal),
        ),
      ),
    );
  }

  // ── Score section ──────────────────────────────────────────────────────────

  Widget _buildScoreSection() {
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
              Text('综合评分',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.gray900)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$_score 分',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.primary700,
              thumbColor: AppColors.primary700,
              inactiveTrackColor: AppColors.gray300,
              overlayColor: AppColors.primary700.withOpacity(0.2),
            ),
            child: Slider(
              value: _score.toDouble(),
              min: 0,
              max: 100,
              divisions: 100,
              onChanged: (v) => setState(() => _score = v.round()),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('0分', style: TextStyle(fontSize: 11, color: AppColors.gray500)),
              Text('50分', style: TextStyle(fontSize: 11, color: AppColors.gray500)),
              Text('100分',
                  style: TextStyle(fontSize: 11, color: AppColors.gray500)),
            ],
          ),
        ],
      ),
    );
  }

  // ── Result radio section ───────────────────────────────────────────────────

  Widget _buildResultSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('验真结论',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.gray900)),
          const SizedBox(height: 8),
          _buildResultOption('pass', '通过', Icons.check_circle,
              AppColors.green500),
          _buildResultOption('fail', '不通过', Icons.cancel, AppColors.red500),
          _buildResultOption('conditional', '有条件通过', Icons.warning,
              AppColors.orange500),
        ],
      ),
    );
  }

  Widget _buildResultOption(
      String value, String label, IconData icon, Color color) {
    final selected = _result == value;
    return GestureDetector(
      onTap: () => setState(() => _result = value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.08) : AppColors.gray100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: selected ? color : AppColors.gray300, width: 1.5),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: selected ? color : AppColors.gray400),
            const SizedBox(width: 10),
            Text(label,
                style: TextStyle(
                    fontSize: 14,
                    color: selected ? color : AppColors.gray700,
                    fontWeight:
                        selected ? FontWeight.bold : FontWeight.normal)),
            const Spacer(),
            if (selected)
              Icon(Icons.radio_button_checked, size: 18, color: color)
            else
              Icon(Icons.radio_button_unchecked,
                  size: 18, color: AppColors.gray400),
          ],
        ),
      ),
    );
  }

  // ── Report text area ───────────────────────────────────────────────────────

  Widget _buildReportSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('报告备注',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.gray900)),
          const SizedBox(height: 10),
          TextField(
            controller: _reportController,
            decoration: InputDecoration(
              hintText: '请输入验真报告备注说明...',
              hintStyle: TextStyle(fontSize: 13, color: AppColors.gray500),
              contentPadding: const EdgeInsets.all(12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.gray300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.gray300),
              ),
            ),
            style: const TextStyle(fontSize: 13),
            maxLines: 5,
            minLines: 3,
          ),
        ],
      ),
    );
  }

  // ── Submit bar ─────────────────────────────────────────────────────────────

  Widget _buildSubmitBar() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary700,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Text('提交验真报告',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}
