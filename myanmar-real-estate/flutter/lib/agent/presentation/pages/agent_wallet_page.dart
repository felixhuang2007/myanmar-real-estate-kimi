/**
 * B端 - 我的钱包页面
 */
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/gen/app_localizations.dart';

class AgentWalletPage extends StatelessWidget {
  const AgentWalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('我的钱包'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.gray900,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 余额卡片
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary700, AppColors.primary900],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '可提现余额',
                    style: TextStyle(color: AppColors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'MMK 5,000,000',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildBalanceItem('累计收入', 'MMK 12,800,000'),
                      ),
                      Expanded(
                        child: _buildBalanceItem('已提现', 'MMK 7,800,000'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // 操作按钮
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('提现功能即将开放')),
                      );
                    },
                    icon: const Icon(Icons.account_balance_wallet),
                    label: const Text('申请提现'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary700,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // 交易记录
            Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      '近期交易',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  _buildTransactionItem('房源成交佣金', '+MMK 500,000', '2026-05-08', AppColors.green500),
                  const Divider(height: 1, indent: 16),
                  _buildTransactionItem('地推推荐奖励', '+MMK 200,000', '2026-05-07', AppColors.green500),
                  const Divider(height: 1, indent: 16),
                  _buildTransactionItem('提现申请', '-MMK 1,000,000', '2026-05-05', AppColors.red500),
                  const Divider(height: 1, indent: 16),
                  _buildTransactionItem('房源成交佣金', '+MMK 800,000', '2026-05-03', AppColors.green500),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.white70, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionItem(String title, String amount, String date, Color color) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.1),
        child: Icon(
          amount.startsWith('+') ? Icons.arrow_downward : Icons.arrow_upward,
          color: color,
          size: 18,
        ),
      ),
      title: Text(title),
      subtitle: Text(date, style: TextStyle(fontSize: 12, color: AppColors.gray500)),
      trailing: Text(
        amount,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
    );
  }
}
