/**
 * 房源卡片组件
 */
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/house.dart';
import '../../../core/utils/app_utils.dart';
import '../../../l10n/gen/app_localizations.dart';

class HouseCard extends StatelessWidget {
  final House house;
  final VoidCallback? onTap;
  final bool showStatus;

  const HouseCard({
    super.key,
    required this.house,
    this.onTap,
    this.showStatus = false,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: AppShadows.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 图片区域
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppRadius.lg),
              ),
              child: AspectRatio(
                aspectRatio: 16 / 10,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // 图片
                    _buildImage(),
                    // 验真标签
                    if (house.isVerified)
                      Positioned(
                        left: 8,
                        top: 8,
                        child: _buildTag(
                          icon: Icons.verified,
                          label: '已验真',
                          backgroundColor: AppColors.green500,
                        ),
                      ),
                    // 收藏按钮
                    Positioned(
                      right: 8,
                      top: 8,
                      child: _buildFavoriteButton(),
                    ),
                    // 状态标签
                    if (showStatus && house.status != 'online')
                      Positioned(
                        left: 8,
                        bottom: 8,
                        child: _buildStatusTag(context, house.status, l),
                      ),
                  ],
                ),
              ),
            ),
            // 内容区域
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 标题
                  Text(
                    house.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.gray900,
                        ),
                  ),
                  const SizedBox(height: 4),
                  // 区域信息
                  Text(
                    '${house.location?.district?.name ?? ''} · ${house.location?.community?.name ?? ''}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.gray600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  // 房源规格
                  Row(
                    children: [
                      if (house.rooms != null)
                        _buildSpecText(house.rooms!),
                      if (house.area != null) ...[
                        if (house.rooms != null)
                          _buildDot(),
                        _buildSpecText('${house.area!.toInt()}㎡'),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  // 价格
                  Row(
                    children: [
                      Text(
                        house.formattedPrice,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppColors.primary700,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        house.priceUnit,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.primary700,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (house.mainImage != null) {
      return Image.network(
        house.mainImage!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder();
        },
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.gray100,
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: 40,
          color: AppColors.gray400,
        ),
      ),
    );
  }

  Widget _buildTag({
    required IconData icon,
    required String label,
    required Color backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 10,
            color: AppColors.white,
          ),
          const SizedBox(width: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTag(BuildContext context, String status, AppLocalizations l) {
    Color color;
    String label;

    switch (status) {
      case 'pending':
        color = AppColors.orange500;
        label = l.statusPending;
        break;
      case 'verifying':
        color = AppColors.blue500;
        label = l.statusVerifying;
        break;
      case 'sold':
        color = AppColors.gray500;
        label = l.statusSold;
        break;
      default:
        color = AppColors.gray500;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          color: AppColors.white,
        ),
      ),
    );
  }

  Widget _buildFavoriteButton() {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Icon(
        house.isFavorited ? Icons.favorite : Icons.favorite_border,
        size: 16,
        color: house.isFavorited ? AppColors.red500 : AppColors.gray600,
      ),
    );
  }

  Widget _buildSpecText(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        color: AppColors.gray700,
      ),
    );
  }

  Widget _buildDot() {
    return Container(
      width: 4,
      height: 4,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: AppColors.gray400,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
    );
  }
}
