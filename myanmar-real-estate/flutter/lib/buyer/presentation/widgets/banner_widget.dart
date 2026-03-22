/**
 * Banner轮播组件
 */
import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import '../../../core/theme/app_colors.dart';

class BannerWidget extends StatefulWidget {
  const BannerWidget({super.key});

  @override
  State<BannerWidget> createState() => _BannerWidgetState();
}

class _BannerWidgetState extends State<BannerWidget> {
  int _currentIndex = 0;

  // 模拟Banner数据
  final List<BannerItem> _banners = [
    BannerItem(
      imageUrl: 'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=800',
      title: '仰光优质公寓',
      subtitle: '精选好房，品质生活',
    ),
    BannerItem(
      imageUrl: 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=800',
      title: '曼德勒别墅区',
      subtitle: '舒适生活，从此开始',
    ),
    BannerItem(
      imageUrl: 'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=800',
      title: '新房开盘',
      subtitle: '限时优惠，先到先得',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: FlutterCarousel(
            options: CarouselOptions(
              height: 160,
              viewportFraction: 1.0,
              enableInfiniteScroll: true,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 4),
              autoPlayAnimationDuration: const Duration(milliseconds: 800),
              onPageChanged: (index, reason) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
            items: _banners.map((banner) => _buildBannerItem(banner)).toList(),
          ),
        ),
        const SizedBox(height: 12),
        // 指示器
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _banners.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: index == _currentIndex ? 16 : 6,
              height: 6,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                color: index == _currentIndex
                    ? AppColors.primary700
                    : AppColors.gray300,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBannerItem(BannerItem banner) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // 背景图片
        Image.network(
          banner.imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: AppColors.gray200,
              child: const Center(
                child: Icon(Icons.image, color: AppColors.gray400),
              ),
            );
          },
        ),
        // 渐变遮罩
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.black.withOpacity(0.1),
                AppColors.black.withOpacity(0.4),
              ],
            ),
          ),
        ),
        // 文字内容
        Positioned(
          left: 16,
          bottom: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                banner.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 3,
                      color: AppColors.black54,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                banner.subtitle,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.white,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 3,
                      color: AppColors.black54,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class BannerItem {
  final String imageUrl;
  final String title;
  final String subtitle;

  BannerItem({
    required this.imageUrl,
    required this.title,
    required this.subtitle,
  });
}
