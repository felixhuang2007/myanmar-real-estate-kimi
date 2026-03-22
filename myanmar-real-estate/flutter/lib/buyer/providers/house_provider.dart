/**
 * 房源状态管理
 */
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/dio_client.dart';
import '../../core/api/house_api.dart';
import '../../core/models/house.dart';
import '../../core/constants/app_constants.dart';

/// House API Provider
final houseApiProvider = Provider<HouseApi>((ref) {
  return HouseApi(DioClient.instance);
});

/// 推荐房源Provider
final recommendationsProvider = FutureProvider.autoDispose<List<House>>((ref) async {
  final houseApi = ref.watch(houseApiProvider);
  final response = await houseApi.getRecommendations({
    'page': 1,
    'page_size': 10,
  });
  
  if (response.isSuccess && response.data != null) {
    return response.data!.list;
  }
  throw Exception(response.message);
});

/// 房源详情Provider
final houseDetailProvider = FutureProvider.family.autoDispose<House, int>((ref, houseId) async {
  final houseApi = ref.watch(houseApiProvider);
  final response = await houseApi.getHouseDetail(houseId);
  
  if (response.isSuccess && response.data != null) {
    return response.data!;
  }
  throw Exception(response.message);
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

  FavoriteNotifier(this._houseApi) : super(FavoriteState());

  /// 切换收藏状态
  Future<bool> toggleFavorite(int houseId) async {
    try {
      final isFavorited = state.isFavorited(houseId);
      
      if (isFavorited) {
        // 取消收藏
        await _houseApi.removeFavorite(houseId);
        state = state.copyWith(
          favoriteIds: {...state.favoriteIds}..remove(houseId),
        );
        return false;
      } else {
        // 添加收藏
        await _houseApi.addFavorite({'house_id': houseId});
        state = state.copyWith(
          favoriteIds: {...state.favoriteIds, houseId},
        );
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
      }
    } catch (e) {
      // 忽略错误
    }
  }
}

/// 收藏Provider
final favoriteProvider = StateNotifierProvider<FavoriteNotifier, FavoriteState>((ref) {
  final houseApi = ref.watch(houseApiProvider);
  return FavoriteNotifier(houseApi);
});
