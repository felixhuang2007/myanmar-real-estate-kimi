/**
 * C端 - 房源详情页
 */
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/house.dart';
import '../../providers/house_provider.dart';
import '../../../core/utils/app_utils.dart';
import '../../../core/api/dio_client.dart';
import '../../../core/api/user_api.dart';
import '../../../l10n/gen/app_localizations.dart';

class HouseDetailPage extends ConsumerStatefulWidget {
  final String houseId;

  const HouseDetailPage({super.key, required this.houseId});

  @override
  ConsumerState<HouseDetailPage> createState() => _HouseDetailPageState();
}

class _HouseDetailPageState extends ConsumerState<HouseDetailPage> {
  int _currentImageIndex = 0;
  bool _isFavorite = false;
  bool _favoriteLoading = false;

  @override
  void initState() {
    super.initState();
    final houseId = int.tryParse(widget.houseId) ?? 0;
    if (houseId > 0) {
      // Load initial favorite status from provider
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await ref.read(favoriteProvider.notifier).checkFavorite(houseId);
        if (mounted) {
          setState(() {
            _isFavorite = ref.read(favoriteProvider).isFavorited(houseId);
          });
        }
      });
    }
  }

  Future<void> _toggleFavorite(int houseId) async {
    if (_favoriteLoading) return;
    setState(() => _favoriteLoading = true);
    try {
      final nowFavorited =
          await ref.read(favoriteProvider.notifier).toggleFavorite(houseId);
      if (mounted) {
        setState(() => _isFavorite = nowFavorited);
        ToastUtil.showSuccess(nowFavorited ? '已收藏' : '已取消收藏');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('操作失败: ${e.toString().replaceFirst('Exception: ', '')}'),
            backgroundColor: AppColors.red500,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _favoriteLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final houseId = int.tryParse(widget.houseId) ?? 0;
    final houseAsync = ref.watch(houseDetailProvider(houseId));

    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: houseAsync.when(
        data: (house) => _buildContent(context, house),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: AppColors.gray400),
              const SizedBox(height: 16),
              Text(l.loadFailed, style: TextStyle(color: AppColors.gray600)),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildContent(BuildContext context, House house) {
    return CustomScrollView(
      slivers: [
        // 图片轮播 + 顶部导航
        SliverToBoxAdapter(
          child: _buildImageGallery(context, house),
        ),

        // 房源基本信息
        SliverToBoxAdapter(
          child: _buildBasicInfo(context, house),
        ),

        // 房源标签
        SliverToBoxAdapter(
          child: _buildTags(context, house),
        ),

        // 基础信息网格
        SliverToBoxAdapter(
          child: _buildInfoGrid(context, house),
        ),

        // 房源描述
        SliverToBoxAdapter(
          child: _buildDescription(context, house),
        ),

        // 位置信息
        SliverToBoxAdapter(
          child: _buildLocation(context, house),
        ),

        // 验真信息
        SliverToBoxAdapter(
          child: _buildVerification(context, house),
        ),

        // 经纪人信息
        SliverToBoxAdapter(
          child: _buildAgentInfo(context, house),
        ),

        // 底部留白
        const SliverToBoxAdapter(
          child: SizedBox(height: 24),
        ),
      ],
    );
  }

  /// 图片轮播
  Widget _buildImageGallery(BuildContext context, House house) {
    final images = house.images;
    final imageUrls = images.map((img) => img.url).toList();
    if (imageUrls.isEmpty) {
      imageUrls.add('https://via.placeholder.com/400x300');
    }

    return Stack(
      children: [
        // 图片轮播
        SizedBox(
          height: 280,
          child: PageView.builder(
            itemCount: imageUrls.length,
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return Image.network(
                imageUrls[index],
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: AppColors.gray200,
                  child: Icon(Icons.image, size: 48, color: AppColors.gray400),
                ),
              );
            },
          ),
        ),

        // 渐变遮罩
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 100,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.black.withOpacity(0.5),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // 顶部导航栏
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back, color: AppColors.white),
                ),
                Row(
                  children: [
                    _favoriteLoading
                        ? const Padding(
                            padding: EdgeInsets.all(8),
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.white,
                              ),
                            ),
                          )
                        : IconButton(
                            onPressed: () {
                              final houseId =
                                  int.tryParse(widget.houseId) ?? 0;
                              if (houseId > 0) _toggleFavorite(houseId);
                            },
                            icon: Icon(
                              _isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: _isFavorite
                                  ? AppColors.red500
                                  : AppColors.white,
                            ),
                          ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.share, color: AppColors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // 图片指示器
        Positioned(
          bottom: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${_currentImageIndex + 1}/${imageUrls.length}',
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),

        // 验真标签
        if (house.isVerified)
          Positioned(
            bottom: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.green500,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.verified, size: 14, color: AppColors.white),
                  const SizedBox(width: 4),
                  Text(
                    '已验真',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  /// 基本信息
  Widget _buildBasicInfo(BuildContext context, House house) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Text(
            house.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),

          // 价格
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${house.formattedPrice}万',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.primary700,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(width: 4),
              Text(
                house.priceUnit,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.gray600,
                    ),
              ),
              const SizedBox(width: 16),
              if (house.area != null && house.area! > 0)
                Text(
                  '${(house.price / house.area!).toStringAsFixed(0)}万/㎡',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.gray500,
                      ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // 位置
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: AppColors.gray500),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${house.location?.city?.name ?? ''} ${house.location?.district?.name ?? ''} ${house.location?.address ?? ''}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.gray600,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 房源标签
  Widget _buildTags(BuildContext context, House house) {
    final tags = [
      if (house.isVerified) '已验真',
      if (house.isFavorited) '热销',
      house.propertyType ?? '住宅',
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      color: AppColors.white,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: tags.map((tag) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: tag == '已验真'
                  ? AppColors.green50
                  : tag == '热销'
                      ? AppColors.orange100
                      : AppColors.primary50,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              tag,
              style: TextStyle(
                fontSize: 12,
                color: tag == '已验真'
                    ? AppColors.green700
                    : tag == '热销'
                        ? AppColors.orange600
                        : AppColors.primary700,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// 信息网格
  Widget _buildInfoGrid(BuildContext context, House house) {
    final items = [
      {'label': '房型', 'value': house.propertyType ?? '-'},
      {'label': '面积', 'value': '${house.area?.toStringAsFixed(0) ?? '-'}㎡'},
      {'label': '户型', 'value': '${house.bedrooms ?? '-'}室${house.livingRooms ?? '-'}厅${house.bathrooms ?? '-'}卫'},
      {'label': '装修', 'value': house.decoration ?? '-'},
      {'label': '朝向', 'value': house.orientation ?? '-'},
      {'label': '楼层', 'value': house.floor ?? '-'},
    ];

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      color: AppColors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '房源信息',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 2,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['label']!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.gray500,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['value']!,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  /// 房源描述
  Widget _buildDescription(BuildContext context, House house) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      color: AppColors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '房源介绍',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            house.description ?? '暂无描述',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.gray700,
                  height: 1.6,
                ),
          ),
        ],
      ),
    );
  }

  /// 位置信息
  Widget _buildLocation(BuildContext context, House house) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      color: AppColors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '位置周边',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          // 地图占位
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: AppColors.gray200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map, size: 48, color: AppColors.gray400),
                  const SizedBox(height: 8),
                  Text(
                    '地图加载中...',
                    style: TextStyle(color: AppColors.gray500),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // 周边配套
          Row(
            children: [
              _buildFacilityItem(Icons.school, '学校', '500m'),
              _buildFacilityItem(Icons.local_hospital, '医院', '800m'),
              _buildFacilityItem(Icons.shopping_cart, '商场', '300m'),
              _buildFacilityItem(Icons.directions_subway, '地铁', '600m'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFacilityItem(IconData icon, String label, String distance) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 24, color: AppColors.gray600),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12, color: AppColors.gray600)),
          Text(distance, style: TextStyle(fontSize: 12, color: AppColors.gray500)),
        ],
      ),
    );
  }

  /// 验真信息
  Widget _buildVerification(BuildContext context, House house) {
    if (!house.isVerified) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      color: AppColors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.verified_user, color: AppColors.green500),
              const SizedBox(width: 8),
              Text(
                '房源验真',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildVerificationItem('真实存在', '经纪人实地勘察确认'),
          _buildVerificationItem('图片真实', '实拍照片，无虚假修饰'),
          _buildVerificationItem('价格真实', '报价与业主确认一致'),
          _buildVerificationItem('委托真实', '已获得业主真实委托'),
        ],
      ),
    );
  }

  Widget _buildVerificationItem(String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(Icons.check_circle, size: 16, color: AppColors.green500),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 8),
          Text(
            desc,
            style: TextStyle(fontSize: 12, color: AppColors.gray500),
          ),
        ],
      ),
    );
  }

  /// 经纪人信息
  Widget _buildAgentInfo(BuildContext context, House house) {
    final agentName = house.agent?.name ?? '张经纪';
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      color: AppColors.white,
      child: Row(
        children: [
          // 头像
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.primary100,
            backgroundImage: house.agent?.avatar != null
                ? NetworkImage(house.agent!.avatar!)
                : null,
            child: house.agent?.avatar == null
                ? Text(
                    agentName.isNotEmpty ? agentName.substring(0, 1) : 'A',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary700,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),

          // 信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  agentName,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.star, size: 14, color: AppColors.orange500),
                    Text(
                      ' ${house.agent?.rating.toStringAsFixed(1) ?? '4.9'}',
                      style: TextStyle(fontSize: 12, color: AppColors.gray600),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '成交 ${house.agent?.dealCount ?? 0} 单',
                      style: TextStyle(fontSize: 12, color: AppColors.gray600),
                    ),
                  ],
                ),
                if (house.agent?.company != null)
                  Text(
                    house.agent!.company!,
                    style: TextStyle(fontSize: 12, color: AppColors.gray500),
                  ),
              ],
            ),
          ),

          // 操作按钮
          Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.phone, color: AppColors.primary700),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.chat, color: AppColors.primary700),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 预约看房底部弹窗
  void _showAppointmentSheet(int houseId) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final noteController = TextEditingController();
    bool submitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 24,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '预约看房',
                    style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: '您的姓名 *',
                      hintText: '请输入姓名',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: '联系电话 *',
                      hintText: '请输入手机号',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: noteController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: '备注',
                      hintText: '期望看房时间等（选填）',
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: submitting
                          ? null
                          : () async {
                              final name = nameController.text.trim();
                              final phone = phoneController.text.trim();
                              if (name.isEmpty || phone.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('请填写姓名和联系电话')),
                                );
                                return;
                              }
                              setSheetState(() => submitting = true);
                              try {
                                final userApi = UserApi(DioClient.instance);
                                final response =
                                    await userApi.createAppointment({
                                  'house_id': houseId,
                                  'contact_name': name,
                                  'contact_phone': phone,
                                  'note': noteController.text.trim(),
                                });
                                if (mounted) {
                                  Navigator.of(ctx).pop();
                                  if (response.isSuccess) {
                                    ToastUtil.showSuccess('预约成功，经纪人将尽快联系您');
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content:
                                            Text(response.message ?? '预约失败'),
                                        backgroundColor: AppColors.red500,
                                      ),
                                    );
                                  }
                                }
                              } catch (e) {
                                setSheetState(() => submitting = false);
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          '预约失败: ${e.toString().replaceFirst('Exception: ', '')}'),
                                      backgroundColor: AppColors.red500,
                                    ),
                                  );
                                }
                              }
                            },
                      child: submitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.white,
                              ),
                            )
                          : const Text('确认预约'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// 底部栏
  Widget _buildBottomBar(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: Icon(Icons.chat_bubble_outline),
                label: Text(l.contactAgent),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: () {
                  final houseId = int.tryParse(widget.houseId) ?? 0;
                  if (houseId > 0) _showAppointmentSheet(houseId);
                },
                icon: const Icon(Icons.phone),
                label: Text(l.appointment),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
