/**
 * B端 - 联系客服页面
 */
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class AgentCustomerServicePage extends StatelessWidget {
  const AgentCustomerServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('联系客服'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.gray900,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 客服热线
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Icon(Icons.headset_mic, size: 48, color: AppColors.primary700),
                  const SizedBox(height: 12),
                  const Text(
                    '客服热线',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '+95 9 123 456 789',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '服务时间：周一至周五 9:00 - 18:00',
                    style: TextStyle(fontSize: 12, color: AppColors.gray500),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('电话拨打功能即将开放')),
                        );
                      },
                      icon: const Icon(Icons.phone),
                      label: const Text('立即拨打'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary700,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // 其他联系方式
            Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildContactItem(
                    icon: Icons.email,
                    title: '邮箱',
                    value: 'support@myanmarhome.com',
                    color: AppColors.blue500,
                  ),
                  const Divider(height: 1, indent: 56),
                  _buildContactItem(
                    icon: Icons.message,
                    title: '微信',
                    value: 'MyanmarHome_Support',
                    color: AppColors.green500,
                  ),
                  const Divider(height: 1, indent: 56),
                  _buildContactItem(
                    icon: Icons.location_on,
                    title: '办公地址',
                    value: 'Yangon, Myanmar',
                    color: AppColors.red500,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // 常见问题
            Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      '常见问题',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  _buildFaqItem('如何发布房源？'),
                  const Divider(height: 1, indent: 16),
                  _buildFaqItem('佣金如何结算？'),
                  const Divider(height: 1, indent: 16),
                  _buildFaqItem('如何申请提现？'),
                  const Divider(height: 1, indent: 16),
                  _buildFaqItem('账号被封怎么办？'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(title),
      subtitle: Text(value, style: TextStyle(fontSize: 13, color: AppColors.gray600)),
    );
  }

  Widget _buildFaqItem(String question) {
    return ListTile(
      title: Text(question, style: const TextStyle(fontSize: 14)),
      trailing: const Icon(Icons.chevron_right, color: AppColors.gray400),
      onTap: () {
        // FAQ detail
      },
    );
  }
}
