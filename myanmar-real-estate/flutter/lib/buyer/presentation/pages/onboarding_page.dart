/**
 * C端 - 引导页/首次启动页
 */
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/storage/local_storage.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingItem> _items = [
    const OnboardingItem(
      icon: Icons.home_work_rounded,
      title: '海量真实房源',
      description: '覆盖缅甸主要城市，所有房源均经过严格验真，让您放心选房',
    ),
    const OnboardingItem(
      icon: Icons.map_rounded,
      title: '地图找房',
      description: '支持地图模式浏览房源，直观查看周边配套，位置一目了然',
    ),
    const OnboardingItem(
      icon: Icons.verified_user_rounded,
      title: '专业经纪人服务',
      description: '平台认证专业经纪人，一对一贴心服务，全程陪同看房签约',
    ),
    const OnboardingItem(
      icon: Icons.chat_bubble_rounded,
      title: '在线沟通',
      description: '内置即时通讯功能，随时与经纪人沟通，快速获取房源信息',
    ),
  ];

  void _onNext() {
    if (_currentPage < _items.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _finishOnboarding() async {
    await LocalStorage.setFirstLaunch(false);
    if (mounted) {
      context.go(RouteNames.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 跳过按钮
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextButton(
                  onPressed: _finishOnboarding,
                  child: Text(
                    '跳过',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.gray600,
                        ),
                  ),
                ),
              ),
            ),
            
            // 页面内容
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _items.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return _buildPage(_items[index]);
                },
              ),
            ),
            
            // 指示器
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _items.length,
                  (index) => Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index == _currentPage
                          ? AppColors.primary700
                          : AppColors.gray300,
                    ),
                  ),
                ),
              ),
            ),
            
            // 下一步按钮
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _onNext,
                  child: Text(
                    _currentPage == _items.length - 1 ? '开始使用' : '下一步',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingItem item) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 图标
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.primary50,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              item.icon,
              size: 56,
              color: AppColors.primary700,
            ),
          ),
          const SizedBox(height: 48),
          // 标题
          Text(
            item.title,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          // 描述
          Text(
            item.description,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.gray600,
                ),
          ),
        ],
      ),
    );
  }
}

class OnboardingItem {
  final IconData icon;
  final String title;
  final String description;

  const OnboardingItem({
    required this.icon,
    required this.title,
    required this.description,
  });
}
