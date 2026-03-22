/**
 * 快捷入口网格组件
 */
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class QuickActionGrid extends StatelessWidget {
  final List<QuickActionItem> actions;

  const QuickActionGrid({
    super.key,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.sm,
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 16,
          crossAxisSpacing: 8,
          childAspectRatio: 0.8,
        ),
        itemCount: actions.length,
        itemBuilder: (context, index) {
          return _buildActionItem(context, actions[index]);
        },
      ),
    );
  }

  Widget _buildActionItem(BuildContext context, QuickActionItem action) {
    return GestureDetector(
      onTap: action.onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: action.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              action.icon,
              color: action.color,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            action.label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.gray700,
                ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class QuickActionItem {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  QuickActionItem({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });
}
