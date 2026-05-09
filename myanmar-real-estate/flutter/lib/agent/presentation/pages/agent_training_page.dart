/**
 * B端 - 培训学习页面
 */
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class AgentTrainingPage extends StatelessWidget {
  const AgentTrainingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('培训学习'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.gray900,
        elevation: 0.5,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildCourseItem(
            '新人入职培训',
            '了解平台规则、房源发布流程、客户服务标准',
            '12 课时',
            '已完成',
            AppColors.green500,
            Icons.check_circle,
          ),
          const SizedBox(height: 12),
          _buildCourseItem(
            '房源验真指南',
            '学习如何验真房源信息，提高房源通过率',
            '8 课时',
            '学习中',
            AppColors.orange500,
            Icons.play_circle,
          ),
          const SizedBox(height: 12),
          _buildCourseItem(
            'ACN 分佣规则',
            '掌握 ACN 网络分佣机制，合理分配佣金',
            '6 课时',
            '未开始',
            AppColors.gray400,
            Icons.lock,
          ),
          const SizedBox(height: 12),
          _buildCourseItem(
            '高效带看技巧',
            '提升带看转化率，掌握客户沟通技巧',
            '10 课时',
            '未开始',
            AppColors.gray400,
            Icons.lock,
          ),
          const SizedBox(height: 12),
          _buildCourseItem(
            '法律法规知识',
            '缅甸房产交易相关法律法规解读',
            '15 课时',
            '未开始',
            AppColors.gray400,
            Icons.lock,
          ),
        ],
      ),
    );
  }

  Widget _buildCourseItem(
    String title,
    String desc,
    String duration,
    String status,
    Color statusColor,
    IconData statusIcon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.school, color: AppColors.primary700, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: TextStyle(fontSize: 12, color: AppColors.gray500),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: AppColors.gray400),
                    const SizedBox(width: 4),
                    Text(
                      duration,
                      style: TextStyle(fontSize: 12, color: AppColors.gray500),
                    ),
                    const SizedBox(width: 16),
                    Icon(statusIcon, size: 14, color: statusColor),
                    const SizedBox(width: 4),
                    Text(
                      status,
                      style: TextStyle(fontSize: 12, color: statusColor),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
