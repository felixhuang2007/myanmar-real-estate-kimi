/**
 * C端 - 搜索页面
 */
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/storage/local_storage.dart';
import '../../providers/house_provider.dart';
import '../widgets/house_card.dart';
import '../../../l10n/gen/app_localizations.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final _searchController = TextEditingController();
  List<String> _searchHistory = [];

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
  }

  Future<void> _loadSearchHistory() async {
    final history = await LocalStorage.getSearchHistory();
    setState(() {
      _searchHistory = history;
    });
  }

  void _search(String keyword) async {
    if (keyword.trim().isEmpty) return;
    
    await LocalStorage.addSearchHistory(keyword);
    
    if (mounted) {
      context.push(RouteNames.houseList, extra: {'keywords': keyword});
    }
  }

  void _clearHistory() async {
    await LocalStorage.clearSearchHistory();
    setState(() {
      _searchHistory = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // 搜索栏
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: l.searchHint,
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {});
                                },
                                icon: const Icon(Icons.clear),
                              )
                            : null,
                      ),
                      onChanged: (_) => setState(() {}),
                      onSubmitted: _search,
                    ),
                  ),
                  TextButton(
                    onPressed: () => _search(_searchController.text),
                    child: Text(l.search),
                  ),
                ],
              ),
            ),
            
            // 搜索历史
            if (_searchHistory.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '搜索历史',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    TextButton(
                      onPressed: _clearHistory,
                      child: const Text('清除'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _searchHistory.map((keyword) {
                    return ActionChip(
                      label: Text(keyword),
                      onPressed: () => _search(keyword),
                      avatar: const Icon(Icons.history, size: 16),
                    );
                  }).toList(),
                ),
              ),
            ],
            
            // 热门搜索
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '热门搜索',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      'Tamwe区',
                      'Bahan区',
                      '精装修',
                      '学区房',
                      '近地铁',
                      '别墅',
                    ].map((tag) {
                      return ActionChip(
                        label: Text(tag),
                        onPressed: () => _search(tag),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
