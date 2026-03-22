/**
 * B端 - ACN协作成交申报页
 */
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../buyer/providers/auth_provider.dart';
import '../../../l10n/gen/app_localizations.dart';

class AcnDealPage extends ConsumerStatefulWidget {
  const AcnDealPage({super.key});

  @override
  ConsumerState<AcnDealPage> createState() => _AcnDealPageState();
}

class _AcnDealPageState extends ConsumerState<AcnDealPage> {
  final _formKey = GlobalKey<FormState>();
  final _priceController = TextEditingController();
  final _commissionController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _priceController.dispose();
    _commissionController.dispose();
    super.dispose();
  }

  int _getCurrentUserId() {
    return ref.read(authProvider).user?.userId ?? 0;
  }

  List<Map<String, dynamic>> _buildRoles() {
    final currentUserId = _getCurrentUserId();
    return [
      {'role_code': 'ENTRANT', 'agent_id': 2, 'commission_ratio': 1500},
      {'role_code': 'MAINTAINER', 'agent_id': 3, 'commission_ratio': 1500},
      {'role_code': 'CLOSER', 'agent_id': currentUserId, 'commission_ratio': 4000},
    ];
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() != true) return;

    setState(() => _isSubmitting = true);
    try {
      final dio = Dio();
      final token = ref.read(authProvider).user?.token ?? '';
      final resp = await dio.post(
        '${ApiConstants.baseUrl}/v1/acn/transactions',
        data: {
          'house_id': 1,
          'transaction_amount':
              (double.tryParse(_priceController.text) ?? 0) * 10000,
          'commission_amount':
              (double.tryParse(_commissionController.text) ?? 0) * 10000,
          'roles': _buildRoles(),
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (resp.data['code'] == 0) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('成交申报已提交，等待参与方确认')),
          );
          context.pop();
        }
      } else {
        final msg = resp.data['message'] ?? '提交失败';
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('提交失败：$msg')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('提交失败：$e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).acnDeal),
        backgroundColor: AppColors.white,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 成交房源
              _buildSectionTitle('成交房源'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 80,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.gray200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.home, color: AppColors.gray400),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '仰光Tamwe区精装3室公寓',
                            style:
                                Theme.of(context).textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tamwe区 · 120㎡ · 3室2厅',
                            style: TextStyle(
                                fontSize: 13, color: AppColors.gray600),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text('更换'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 成交信息
              _buildSectionTitle('成交信息'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _priceController,
                      decoration: InputDecoration(
                        labelText: '成交价格*',
                        suffixText: '万缅币',
                        filled: true,
                        fillColor: AppColors.gray50,
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '请输入成交价格';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _commissionController,
                      decoration: InputDecoration(
                        labelText: '佣金金额*',
                        suffixText: '万缅币',
                        filled: true,
                        fillColor: AppColors.gray50,
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '请输入佣金金额';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: '成交日期*',
                        prefixIcon: const Icon(Icons.calendar_today),
                        filled: true,
                        fillColor: AppColors.gray50,
                      ),
                      readOnly: true,
                      onTap: () {},
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ACN参与方
              _buildSectionTitle('ACN参与方'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildRoleRow('房源录入人', '李经纪', '15%'),
                    const Divider(height: 24),
                    _buildRoleRow('房源维护人', '王经纪', '15%'),
                    const Divider(height: 24),
                    _buildRoleRow('客源转介绍', '选择参与人', '10%',
                        isEmpty: true),
                    const Divider(height: 24),
                    _buildRoleRow('带看人', '选择参与人', '10%', isEmpty: true),
                    const Divider(height: 24),
                    _buildRoleRow('成交人 (本人)', '张经纪', '40%',
                        isSelf: true),
                    const Divider(height: 24),
                    _buildRoleRow('平台服务费', '平台', '10%',
                        isPlatform: true),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 合同照片
              _buildSectionTitle('合同照片'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '请上传成交合同照片',
                      style: TextStyle(color: AppColors.gray600),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _buildUploadButton(),
                        _buildUploadButton(),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // 提交按钮
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('提交申报'),
                ),
              ),
            ],
          ),
        ),
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

  Widget _buildRoleRow(String role, String name, String percentage,
      {bool isEmpty = false, bool isSelf = false, bool isPlatform = false}) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(
            role,
            style: TextStyle(
              color: isPlatform ? AppColors.gray500 : AppColors.gray700,
            ),
          ),
        ),
        Expanded(
          flex: 4,
          child: Row(
            children: [
              if (!isPlatform)
                CircleAvatar(
                  radius: 12,
                  backgroundColor:
                      isEmpty ? AppColors.gray200 : AppColors.primary100,
                  child: isEmpty
                      ? Icon(Icons.add, size: 14, color: AppColors.gray500)
                      : Text(
                          name.substring(0, 1),
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.primary700,
                          ),
                        ),
                ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  name,
                  style: TextStyle(
                    color: isEmpty ? AppColors.gray500 : AppColors.gray800,
                    fontWeight:
                        isSelf ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isPlatform
                ? AppColors.gray100
                : isSelf
                    ? AppColors.primary50
                    : AppColors.green50,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            percentage,
            style: TextStyle(
              fontSize: 12,
              color: isPlatform
                  ? AppColors.gray600
                  : isSelf
                      ? AppColors.primary700
                      : AppColors.green700,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadButton() {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: AppColors.gray50,
          borderRadius: BorderRadius.circular(8),
          border:
              Border.all(color: AppColors.gray300, style: BorderStyle.solid),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt, color: AppColors.gray500),
            const SizedBox(height: 4),
            Text(
              '上传照片',
              style: TextStyle(fontSize: 11, color: AppColors.gray500),
            ),
          ],
        ),
      ),
    );
  }
}
