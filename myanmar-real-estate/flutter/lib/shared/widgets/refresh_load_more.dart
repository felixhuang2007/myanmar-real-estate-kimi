/**
 * 公共组件 - 下拉刷新/上拉加载更多
 */
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class RefreshLoadMore extends StatefulWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final Future<void> Function()? onLoadMore;
  final bool hasMore;
  final bool isLoading;

  const RefreshLoadMore({
    super.key,
    required this.child,
    required this.onRefresh,
    this.onLoadMore,
    this.hasMore = true,
    this.isLoading = false,
  });

  @override
  State<RefreshLoadMore> createState() => _RefreshLoadMoreState();
}

class _RefreshLoadMoreState extends State<RefreshLoadMore> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 100 &&
        !_isLoadingMore &&
        widget.hasMore &&
        widget.onLoadMore != null) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    setState(() {
      _isLoadingMore = true;
    });

    await widget.onLoadMore!();

    if (mounted) {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: widget.child,
          ),
          if (_isLoadingMore || widget.isLoading)
            SliverToBoxAdapter(
              child: _buildLoadingIndicator(),
            ),
          if (!widget.hasMore)
            SliverToBoxAdapter(
              child: _buildNoMoreIndicator(),
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(AppColors.primary700),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '加载中...',
            style: TextStyle(color: AppColors.gray600),
          ),
        ],
      ),
    );
  }

  Widget _buildNoMoreIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      alignment: Alignment.center,
      child: Text(
        '没有更多了',
        style: TextStyle(color: AppColors.gray500, fontSize: 13),
      ),
    );
  }
}

/**
 * 列表刷新加载控制器
 */
class RefreshLoadMoreList<T> extends StatelessWidget {
  final List<T> items;
  final Widget Function(BuildContext, T) itemBuilder;
  final Future<void> Function() onRefresh;
  final Future<void> Function()? onLoadMore;
  final bool hasMore;
  final bool isLoading;
  final EdgeInsets padding;
  final ScrollController? scrollController;

  const RefreshLoadMoreList({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.onRefresh,
    this.onLoadMore,
    this.hasMore = true,
    this.isLoading = false,
    this.padding = const EdgeInsets.all(16),
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return _RefreshLoadMoreWrapper(
      onRefresh: onRefresh,
      onLoadMore: onLoadMore,
      hasMore: hasMore,
      isLoading: isLoading,
      scrollController: scrollController,
      child: ListView.builder(
        padding: padding,
        itemCount: items.length,
        itemBuilder: (context, index) {
          return itemBuilder(context, items[index]);
        },
      ),
    );
  }
}

class _RefreshLoadMoreWrapper extends StatefulWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final Future<void> Function()? onLoadMore;
  final bool hasMore;
  final bool isLoading;
  final ScrollController? scrollController;

  const _RefreshLoadMoreWrapper({
    required this.child,
    required this.onRefresh,
    this.onLoadMore,
    this.hasMore = true,
    this.isLoading = false,
    this.scrollController,
  });

  @override
  State<_RefreshLoadMoreWrapper> createState() => _RefreshLoadMoreWrapperState();
}

class _RefreshLoadMoreWrapperState extends State<_RefreshLoadMoreWrapper> {
  late ScrollController _scrollController;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    if (widget.scrollController == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 100 &&
        !_isLoadingMore &&
        widget.hasMore &&
        widget.onLoadMore != null) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    setState(() {
      _isLoadingMore = true;
    });

    await widget.onLoadMore!();

    if (mounted) {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: Column(
        children: [
          Expanded(
            child: widget.child,
          ),
          if (_isLoadingMore || widget.isLoading)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(AppColors.primary700),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '加载中...',
                    style: TextStyle(color: AppColors.gray600),
                  ),
                ],
              ),
            ),
          if (!widget.hasMore && !_isLoadingMore && !widget.isLoading)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              alignment: Alignment.center,
              child: Text(
                '没有更多了',
                style: TextStyle(color: AppColors.gray500, fontSize: 13),
              ),
            ),
        ],
      ),
    );
  }
}
