/**
 * C端 - 房贷计算器
 */
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';

class MortgageCalcPage extends StatefulWidget {
  const MortgageCalcPage({super.key});

  @override
  State<MortgageCalcPage> createState() => _MortgageCalcPageState();
}

class _MortgageCalcPageState extends State<MortgageCalcPage> {
  final _loanController = TextEditingController(text: '100');
  final _rateController = TextEditingController(text: '6.5');
  final _yearsController = TextEditingController(text: '20');

  double? _monthlyPayment;
  double? _totalPayment;
  double? _totalInterest;

  @override
  void dispose() {
    _loanController.dispose();
    _rateController.dispose();
    _yearsController.dispose();
    super.dispose();
  }

  void _calculate() {
    final loanWan = double.tryParse(_loanController.text);
    final annualRate = double.tryParse(_rateController.text);
    final years = int.tryParse(_yearsController.text);

    if (loanWan == null || annualRate == null || years == null ||
        loanWan <= 0 || annualRate <= 0 || years <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请填写正确的数值')),
      );
      return;
    }

    // 等额还款公式：月供 = 贷款额 × 月利率 × (1+月利率)^还款月数 / ((1+月利率)^还款月数 - 1)
    final principal = loanWan * 10000; // 万元转元
    final monthlyRate = annualRate / 100 / 12;
    final months = years * 12;
    final factor = pow(1 + monthlyRate, months);
    final monthly = principal * monthlyRate * factor / (factor - 1);
    final total = monthly * months;

    setState(() {
      _monthlyPayment = monthly;
      _totalPayment = total;
      _totalInterest = total - principal;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('房贷计算器'),
        backgroundColor: AppColors.white,
        elevation: 0.5,
        foregroundColor: AppColors.gray900,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 输入卡片
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '贷款信息',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 20),
                  _buildInputRow('贷款金额', _loanController, '万元'),
                  const SizedBox(height: 16),
                  _buildInputRow('年利率', _rateController, '%'),
                  const SizedBox(height: 16),
                  _buildInputRow('贷款年限', _yearsController, '年'),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _calculate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary700,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('开始计算', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),

            // 结果卡片
            if (_monthlyPayment != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '计算结果（等额还款）',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 20),
                    // 月供高亮
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '每月还款',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.gray600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${(_monthlyPayment! / 10000).toStringAsFixed(2)} 万元',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary700,
                            ),
                          ),
                          Text(
                            '(${_monthlyPayment!.toStringAsFixed(0)} 元)',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.gray500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildResultRow('还款总额', '${(_totalPayment! / 10000).toStringAsFixed(2)} 万元'),
                    const Divider(height: 24),
                    _buildResultRow('支付利息', '${(_totalInterest! / 10000).toStringAsFixed(2)} 万元'),
                  ],
                ),
              ),

              // 提示
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  '* 以上结果仅供参考，实际还款金额以银行审批为准',
                  style: TextStyle(fontSize: 12, color: AppColors.gray500),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInputRow(String label, TextEditingController controller, String unit) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(fontSize: 15, color: AppColors.gray700),
          ),
        ),
        Expanded(
          child: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.gray200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.gray200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.primary700),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(unit, style: TextStyle(fontSize: 14, color: AppColors.gray600)),
      ],
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 15, color: AppColors.gray600)),
        Text(
          value,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
