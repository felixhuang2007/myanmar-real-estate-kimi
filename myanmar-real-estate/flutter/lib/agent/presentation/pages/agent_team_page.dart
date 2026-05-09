/**
 * B端 - 我的团队页面
 */
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class AgentTeamPage extends StatelessWidget {
  const AgentTeamPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('我的团队'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.gray900,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 团队统计
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('团队成员', '12', Icons.people),
                  _buildStatItem('本月新增', '3', Icons.person_add),
                  _buildStatItem('团队成交', '28', Icons.check_circle),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // 成员列表
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
                      '团队成员',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  _buildMemberItem('李经纪', '银牌经纪人', '本月成交 5 单', AppColors.blue500),
                  const Divider(height: 1, indent: 72),
                  _buildMemberItem('王经纪', '铜牌经纪人', '本月成交 3 单', AppColors.orange500),
                  const Divider(height: 1, indent: 72),
                  _buildMemberItem('陈经纪', '金牌经纪人', '本月成交 8 单', AppColors.green500),
                  const Divider(height: 1, indent: 72),
                  _buildMemberItem('赵经纪', '铜牌经纪人', '本月成交 2 单', AppColors.orange500),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary700, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primary700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: AppColors.gray500),
        ),
      ],
    );
  }

  Widget _buildMemberItem(String name, String level, String subtitle, Color levelColor) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.primary100,
        child: Text(
          name.substring(0, 1),
          style: TextStyle(color: AppColors.primary700, fontWeight: FontWeight.bold),
        ),
      ),
      title: Row(
        children: [
          Text(name),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: levelColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              level,
              style: TextStyle(fontSize: 10, color: levelColor),
            ),
          ),
        ],
      ),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: AppColors.gray500)),
      trailing: const Icon(Icons.chevron_right, color: AppColors.gray400),
    );
  }
}
