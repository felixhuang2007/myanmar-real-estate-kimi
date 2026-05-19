/**
 * 房源状态管理
 */
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/dio_client.dart';
import '../../core/api/house_api.dart';
import '../../core/models/house.dart';
import '../../core/constants/app_constants.dart';
import '../../core/storage/local_storage.dart';

/// House API Provider
final houseApiProvider = Provider<HouseApi>((ref) {
  return HouseApi(DioClient.instance);
});

/// 推荐房源Provider
final recommendationsProvider = FutureProvider.autoDispose<List<House>>((ref) async {
  try {
    final houseApi = ref.watch(houseApiProvider);
    final response = await houseApi.getRecommendations({
      'page': 1,
      'page_size': 10,
    });

    debugPrint('[recommendationsProvider] response.code=${response.code}, isSuccess=${response.isSuccess}, data=${response.data}');

    if (response.isSuccess && response.data != null) {
      debugPrint('[recommendationsProvider] list length=${response.data!.list.length}');
      return response.data!.list;
    }
    throw Exception('API error: ${response.message} (code: ${response.code})');
  } catch (e, stackTrace) {
    debugPrint('[recommendationsProvider] ERROR: $e');
    debugPrint('[recommendationsProvider] STACK: $stackTrace');
    rethrow;
  }
});

/// 房源详情Provider
final houseDetailProvider = FutureProvider.family.autoDispose<House, int>((ref, houseId) async {
  try {
    final houseApi = ref.watch(houseApiProvider);
    final response = await houseApi.getHouseDetail(houseId);

    debugPrint('[houseDetailProvider] houseId=$houseId, code=${response.code}, isSuccess=${response.isSuccess}');

    if (response.isSuccess && response.data != null) {
      debugPrint('[houseDetailProvider] house=${response.data!.title}, images=${response.data!.images.length}');
      return response.data!;
    }
    throw Exception('API error: ${response.message} (code: ${response.code})');
  } catch (e, stackTrace) {
    debugPrint('[houseDetailProvider] ERROR: $e');
    debugPrint('[houseDetailProvider] STACK: $stackTrace');
    rethrow;
  }
});

/// 房源搜索状态
class HouseSearchState {
  final List<House> houses;
  final bool isLoading;
  final bool hasMore;
  final String? error;
  final HouseSearchParams params;

  HouseSearchState({
    this.houses = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.error,
    HouseSearchParams? params,
  }) : params = params ?? HouseSearchParams();

  HouseSearchState copyWith({
    List<House>? houses,
    bool? isLoading,
    bool? hasMore,
    String? error,
    HouseSearchParams? params,
  }) {
    return HouseSearchState(
      houses: houses ?? this.houses,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      error: error,
      params: params ?? this.params,
    );
  }
}

/// 房源搜索Notifier
class HouseSearchNotifier extends StateNotifier<HouseSearchState> {
  final HouseApi _houseApi;

  HouseSearchNotifier(this._houseApi) : super(HouseSearchState());

  /// 搜索房源
  Future<void> search(HouseSearchParams params) async {
    try {
      state = state.copyWith(
        isLoading: true,
        error: null,
        params: params,
      );

      final response = await _houseApi.searchHouses(params.toJson());

      if (response.isSuccess && response.data != null) {
        final data = response.data!;
        state = state.copyWith(
          houses: data.list,
          isLoading: false,
          hasMore: data.pagination.hasMore,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.message,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// 加载更多
  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;

    try {
      state = state.copyWith(isLoading: true);

      final params = state.params.copyWith(page: state.params.page + 1);
      final response = await _houseApi.searchHouses(params.toJson());

      if (response.isSuccess && response.data != null) {
        final data = response.data!;
        state = state.copyWith(
          houses: [...state.houses, ...data.list],
          isLoading: false,
          hasMore: data.pagination.hasMore,
          params: params,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  /// 刷新
  Future<void> refresh() async {
    final params = state.params.copyWith(page: 1);
    await search(params);
  }

  /// 更新搜索参数
  void updateParams(HouseSearchParams params) {
    state = state.copyWith(params: params);
  }
}

/// 房源搜索Provider
final houseSearchProvider = StateNotifierProvider.autoDispose<HouseSearchNotifier, HouseSearchState>((ref) {
  final houseApi = ref.watch(houseApiProvider);
  return HouseSearchNotifier(houseApi);
});

/// 收藏列表Provider
final favoritesProvider = FutureProvider.autoDispose<List<House>>((ref) async {
  final houseApi = ref.watch(houseApiProvider);
  final response = await houseApi.getMyHouses({
    'page': 1,
    'page_size': 100,
  });
  
  if (response.isSuccess && response.data != null) {
    return response.data!.list;
  }
  return [];
});

/// 收藏状态管理
class FavoriteState {
  final Set<int> favoriteIds;
  final bool isLoading;

  FavoriteState({
    this.favoriteIds = const {},
    this.isLoading = false,
  });

  FavoriteState copyWith({
    Set<int>? favoriteIds,
    bool? isLoading,
  }) {
    return FavoriteState(
      favoriteIds: favoriteIds ?? this.favoriteIds,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  bool isFavorited(int houseId) => favoriteIds.contains(houseId);
}

class FavoriteNotifier extends StateNotifier<FavoriteState> {
  final HouseApi _houseApi;

  FavoriteNotifier(this._houseApi) : super(FavoriteState()) {
    _loadFavoritesFromBackend();
  }

  Future<void> _loadFavoritesFromBackend() async {
    try {
      final dioResponse = await DioClient.instance.get('/users/me/favorites');
      if (dioResponse.data != null && dioResponse.data['data'] != null) {
        final data = dioResponse.data['data'] as Map<String, dynamic>;
        final list = data['list'] as List<dynamic>? ?? [];
        final ids = list.map((e) {
          if (e is int) return e;
          if (e is double) return e.toInt();
          return int.tryParse(e.toString()) ?? 0;
        }).where((id) => id > 0).toSet();
        state = state.copyWith(favoriteIds: ids);
        // Sync to local cache
        for (final id in ids) {
          await LocalStorage.cacheFavorite(id, true);
        }
      }
    } catch (e) {
      debugPrint('[_loadFavoritesFromBackend] error: $e');
      // Fallback to local cache
      final cached = LocalStorage.getCachedFavorites();
      state = state.copyWith(favoriteIds: cached);
    }
  }

  /// 切换收藏状态
  Future<bool> toggleFavorite(int houseId) async {
    try {
      final isFavorited = state.isFavorited(houseId);

      if (isFavorited) {
        // 取消收藏
        await _houseApi.removeFavorite(houseId);
        final newIds = {...state.favoriteIds}..remove(houseId);
        state = state.copyWith(favoriteIds: newIds);
        await LocalStorage.cacheFavorite(houseId, false);
        return false;
      } else {
        // 添加收藏
        await _houseApi.addFavorite({'house_id': houseId});
        final newIds = {...state.favoriteIds, houseId};
        state = state.copyWith(favoriteIds: newIds);
        await LocalStorage.cacheFavorite(houseId, true);
        return true;
      }
    } catch (e) {
      rethrow;
    }
  }

  /// 检查收藏状态
  Future<void> checkFavorite(int houseId) async {
    try {
      final response = await _houseApi.checkFavorite(houseId);
      if (response.isSuccess && response.data == true) {
        state = state.copyWith(
          favoriteIds: {...state.favoriteIds, houseId},
        );
        await LocalStorage.cacheFavorite(houseId, true);
      }
    } catch (e) {
      // 忽略错误
    }
  }

  /// 从本地缓存加载所有收藏
  void loadFromCache() {
    final cached = LocalStorage.getCachedFavorites();
    state = state.copyWith(favoriteIds: cached);
  }
}

/// 收藏Provider
final favoriteProvider = StateNotifierProvider<FavoriteNotifier, FavoriteState>((ref) {
  final houseApi = ref.watch(houseApiProvider);
  return FavoriteNotifier(houseApi);
});
