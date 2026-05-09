/**
 * B端 - 等级权益页面
 */
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class AgentLevelPage extends StatelessWidget {
  const AgentLevelPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('等级权益'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.gray900,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 当前等级卡片
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(Icons.workspace_premium, size: 48, color: AppColors.white),
                  const SizedBox(height: 12),
                  const Text(
                    '金牌经纪人',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Lv.4 / 最高等级',
                    style: TextStyle(color: AppColors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: 1.0,
                      backgroundColor: AppColors.white.withOpacity(0.3),
                      valueColor: const AlwaysStoppedAnimation(AppColors.white),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '128 / 100 单成交（已达成）',
                    style: TextStyle(color: AppColors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // 权益列表
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
                      '当前权益',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  _buildBenefitItem(Icons.percent, '佣金加成', '成交佣金额外加成 15%'),
                  const Divider(height: 1, indent: 56),
                  _buildBenefitItem(Icons.verified_user, '优先推荐', '房源在列表中优先展示'),
                  const Divider(height: 1, indent: 56),
                  _buildBenefitItem(Icons.support_agent, '专属客服', '1对1 专属客户经理服务'),
                  const Divider(height: 1, indent: 56),
                  _buildBenefitItem(Icons.event, '活动优先', '优先参与平台推广活动'),
                  const Divider(height: 1, indent: 56),
                  _buildBenefitItem(Icons.card_giftcard, '生日礼包', '生日当月获得专属礼包'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // 等级说明
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
                      '等级说明',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  _buildLevelRow('铜牌', '0-20 单', false),
                  const Divider(height: 1, indent: 16),
                  _buildLevelRow('银牌', '21-50 单', false),
                  const Divider(height: 1, indent: 16),
                  _buildLevelRow('金牌', '51-100 单', true),
                  const Divider(height: 1, indent: 16),
                  _buildLevelRow('钻石', '100+ 单', false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitItem(IconData icon, String title, String desc) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary700),
      title: Text(title),
      subtitle: Text(desc, style: TextStyle(fontSize: 12, color: AppColors.gray500)),
    );
  }

  Widget _buildLevelRow(String name, String requirement, bool isCurrent) {
    return ListTile(
      leading: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isCurrent ? AppColors.primary100 : AppColors.gray100,
          shape: BoxShape.circle,
        ),
        child: Icon(
          isCurrent ? Icons.check : Icons.radio_button_unchecked,
          size: 16,
          color: isCurrent ? AppColors.primary700 : AppColors.gray400,
        ),
      ),
      title: Text(name),
      subtitle: Text(requirement, style: TextStyle(fontSize: 12, color: AppColors.gray500)),
      trailing: isCurrent
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary700,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '当前',
                style: TextStyle(color: AppColors.white, fontSize: 11),
              ),
            )
          : null,
    );
  }
}
