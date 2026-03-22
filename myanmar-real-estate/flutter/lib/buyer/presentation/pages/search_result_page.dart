/**
 * C端 - 搜索页面 (带筛选功能)
 */
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/house.dart';
import '../../providers/house_provider.dart';
import '../../../l10n/gen/app_localizations.dart';

class SearchResultPage extends ConsumerStatefulWidget {
  final String? keyword;
  final String? transactionType; // 'sale' | 'rent'
  final bool? isNewHome;         // true=新房, false=二手房, null=不过滤
  final String? pageTitle;

  const SearchResultPage({super.key, this.keyword, this.transactionType, this.isNewHome, this.pageTitle});

  @override
  ConsumerState<SearchResultPage> createState() => _SearchResultPageState();
}

class _SearchResultPageState extends ConsumerState<SearchResultPage> {
  String _sortBy = 'default';
  final Map<String, dynamic> _filters = {};

  @override
  void initState() {
    super.initState();
    // 初始化搜索
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(houseSearchProvider.notifier).search(
            HouseSearchParams(
              keywords: widget.keyword,
              transactionType: widget.transactionType,
              isNewHome: widget.isNewHome,
              page: 1,
            ),
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final searchState = ref.watch(houseSearchProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.pageTitle ?? widget.keyword ?? l.search),
        backgroundColor: AppColors.white,
        elevation: 0.5,
        actions: [
          TextButton.icon(
            onPressed: () {
              context.push('/buyer/map');
            },
            icon: const Icon(Icons.map),
            label: const Text('地图'),
          ),
        ],
      ),
      body: Column(
        children: [
          // 筛选栏
          _buildFilterBar(context),

          // 结果列表
          Expanded(
            child: _buildResultList(context, searchState),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildFilterItem('区域', () => _showDistrictFilter(context)),
          _buildFilterItem('价格', () => _showPriceFilter(context)),
          _buildFilterItem('房型', () => _showTypeFilter(context)),
          _buildFilterItem(_getSortLabel(_sortBy), () => _showSortOptions(context)),
        ],
      ),
    );
  }

  Widget _buildFilterItem(String label, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.gray700,
              ),
            ),
            Icon(Icons.arrow_drop_down, size: 18, color: AppColors.gray500),
          ],
        ),
      ),
    );
  }

  Widget _buildResultList(BuildContext context, HouseSearchState state) {
    final l = AppLocalizations.of(context);
    if (state.isLoading && state.houses.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.houses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: AppColors.gray400),
            const SizedBox(height: 16),
            Text(state.error!, style: TextStyle(color: AppColors.gray600)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(houseSearchProvider.notifier).refresh();
              },
              child: Text(l.retry),
            ),
          ],
        ),
      );
    }

    final houses = state.houses;

    if (houses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 48, color: AppColors.gray400),
            const SizedBox(height: 16),
            Text(l.noData, style: TextStyle(color: AppColors.gray600)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: houses.length + (state.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == houses.length) {
          // 加载更多
          if (!state.isLoading) {
            ref.read(houseSearchProvider.notifier).loadMore();
          }
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          );
        }
        final house = houses[index];
        return _buildHouseListItem(context, house);
      },
    );
  }

  Widget _buildHouseListItem(BuildContext context, House house) {
    final mainImage = house.mainImage;

    return GestureDetector(
      onTap: () {
        context.push('/buyer/house/${house.houseId}');
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 图片
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 100,
                height: 75,
                color: AppColors.gray200,
                child: mainImage != null
                    ? Image.network(
                        mainImage,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(Icons.image, color: AppColors.gray400),
                      )
                    : Icon(Icons.image, color: AppColors.gray400),
              ),
            ),
            const SizedBox(width: 12),

            // 信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    house.title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${house.location?.district?.name ?? ''} · ${house.propertyType ?? ''}',
                    style: TextStyle(fontSize: 13, color: AppColors.gray600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${house.bedrooms ?? '-'}室${house.livingRooms ?? '-'}厅 · ${house.area?.toStringAsFixed(0) ?? '-'}㎡',
                    style: TextStyle(fontSize: 13, color: AppColors.gray600),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '${house.formattedPrice}万',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (house.isVerified)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.green50,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '已验真',
                            style: TextStyle(fontSize: 10, color: AppColors.green700),
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

  // 将当前 _filters + _sortBy + widget 初始参数合并，触发一次搜索
  void _triggerSearch() {
    // district label → API district_code
    const districtMap = {
      'Tamwe区': 'TAMWE',
      'Bahan区': 'BAHAN',
      'Yankin区': 'YANKIN',
      'Hlaing区': 'HLAING',
      'Thingangyun区': 'THINGANGYUN',
    };
    // price label → {min, max} in MMK
    const priceMap = {
      '5000万以下':  {'max': 50000000},
      '5000万-1亿': {'min': 50000000,  'max': 100000000},
      '1亿-2亿':    {'min': 100000000, 'max': 200000000},
      '2亿-5亿':    {'min': 200000000, 'max': 500000000},
      '5亿以上':    {'min': 500000000},
    };
    // house type display → API value
    const typeMap = {
      '公寓': 'apartment',
      '别墅': 'house',
      '联排': 'townhouse',
      '土地': 'land',
      '商业': 'commercial',
    };
    // sort label → API sort_by value
    const sortApiMap = {
      'default':    '',
      'date':       'date',
      'price_asc':  'price_asc',
      'price_desc': 'price_desc',
      'area':       'area',
    };

    final priceRange = priceMap[_filters['price']];
    final districtCode = districtMap[_filters['district']];
    final houseType = typeMap[_filters['type']];
    final sortBy = sortApiMap[_sortBy] ?? '';

    ref.read(houseSearchProvider.notifier).search(
      HouseSearchParams(
        keywords: widget.keyword,
        transactionType: widget.transactionType,
        isNewHome: widget.isNewHome,
        districtCode: districtCode,
        priceMin: priceRange?['min'],
        priceMax: priceRange?['max'],
        houseType: houseType,
        sortBy: sortBy.isEmpty ? null : sortBy,
        page: 1,
      ),
    );
  }

  String _getSortLabel(String sortBy) {
    const labels = {
      'default':    '综合排序',
      'date':       '最新发布',
      'price_asc':  '价格从低到高',
      'price_desc': '价格从高到低',
      'area':       '面积从大到小',
    };
    return labels[sortBy] ?? '综合排序';
  }

  void _showDistrictFilter(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '选择区域',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  '全部区域',
                  'Tamwe区',
                  'Bahan区',
                  'Yankin区',
                  'Hlaing区',
                  'Thingangyun区',
                ].map((district) {
                  return ListTile(
                    title: Text(district),
                    trailing: _filters['district'] == district
                        ? Icon(Icons.check, color: AppColors.primary700)
                        : null,
                    onTap: () {
                      setState(() {
                        _filters['district'] = district == '全部区域' ? null : district;
                      });
                      Navigator.pop(context);
                      _triggerSearch();
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPriceFilter(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '选择价格',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  '不限',
                  '5000万以下',
                  '5000万-1亿',
                  '1亿-2亿',
                  '2亿-5亿',
                  '5亿以上',
                ].map((price) {
                  return ListTile(
                    title: Text(price),
                    trailing: _filters['price'] == price ||
                            (price == '不限' && _filters['price'] == null)
                        ? Icon(Icons.check, color: AppColors.primary700)
                        : null,
                    onTap: () {
                      setState(() {
                        _filters['price'] = price == '不限' ? null : price;
                      });
                      Navigator.pop(context);
                      _triggerSearch();
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTypeFilter(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '选择房型',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  '全部类型',
                  '公寓',
                  '别墅',
                  '联排',
                  '土地',
                  '商业',
                ].map((type) {
                  return ListTile(
                    title: Text(type),
                    trailing: _filters['type'] == type ||
                            (type == '全部类型' && _filters['type'] == null)
                        ? Icon(Icons.check, color: AppColors.primary700)
                        : null,
                    onTap: () {
                      setState(() {
                        _filters['type'] = type == '全部类型' ? null : type;
                      });
                      Navigator.pop(context);
                      _triggerSearch();
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSortOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '排序方式',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ...[
              {'key': 'default',    'label': '综合排序'},
              {'key': 'date',       'label': '最新发布'},
              {'key': 'price_asc',  'label': '价格从低到高'},
              {'key': 'price_desc', 'label': '价格从高到低'},
              {'key': 'area',       'label': '面积从大到小'},
            ].map((option) {
              return ListTile(
                title: Text(option['label']!),
                trailing: _sortBy == option['key']
                    ? Icon(Icons.check, color: AppColors.primary700)
                    : null,
                onTap: () {
                  setState(() {
                    _sortBy = option['key']!;
                  });
                  Navigator.pop(context);
                  _triggerSearch();
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
