/**
 * B端 - 房源状态管理
 */
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/dio_client.dart';
import '../../core/api/house_api.dart';
import '../../core/models/house.dart';

/// House API Provider (agent side reuses the same HouseApi)
final agentHouseApiProvider = Provider<HouseApi>((ref) {
  return HouseApi(DioClient.instance);
});

// ==================== 我的房源列表 ====================

/// 我的房源列表状态
class AgentHouseListState {
  final List<House> houses;
  final bool isLoading;
  final bool hasMore;
  final String? error;
  final int page;

  const AgentHouseListState({
    this.houses = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.error,
    this.page = 1,
  });

  AgentHouseListState copyWith({
    List<House>? houses,
    bool? isLoading,
    bool? hasMore,
    String? error,
    int? page,
  }) {
    return AgentHouseListState(
      houses: houses ?? this.houses,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      error: error,
      page: page ?? this.page,
    );
  }
}

class AgentHouseListNotifier extends StateNotifier<AgentHouseListState> {
  final HouseApi _houseApi;

  AgentHouseListNotifier(this._houseApi) : super(const AgentHouseListState());

  Future<void> load({bool refresh = false}) async {
    if (state.isLoading) return;
    final page = refresh ? 1 : state.page;

    try {
      state = state.copyWith(isLoading: true, error: null);
      final response = await _houseApi.getMyHouses({
        'page': page,
        'page_size': 20,
      });

      if (response.isSuccess && response.data != null) {
        final data = response.data!;
        final houses = refresh ? data.list : [...state.houses, ...data.list];
        state = state.copyWith(
          houses: houses,
          isLoading: false,
          hasMore: data.pagination.hasMore,
          page: page + 1,
        );
      } else {
        state = state.copyWith(isLoading: false, error: response.message);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() => load(refresh: true);
}

final agentHouseListProvider =
    StateNotifierProvider<AgentHouseListNotifier, AgentHouseListState>((ref) {
  final api = ref.watch(agentHouseApiProvider);
  return AgentHouseListNotifier(api);
});

// ==================== 创建房源 ====================

/// 创建房源状态
class CreateHouseState {
  final bool isLoading;
  final String? error;
  final House? createdHouse;

  const CreateHouseState({
    this.isLoading = false,
    this.error,
    this.createdHouse,
  });

  CreateHouseState copyWith({
    bool? isLoading,
    String? error,
    House? createdHouse,
  }) {
    return CreateHouseState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      createdHouse: createdHouse ?? this.createdHouse,
    );
  }
}

class CreateHouseNotifier extends StateNotifier<CreateHouseState> {
  final HouseApi _houseApi;

  CreateHouseNotifier(this._houseApi) : super(const CreateHouseState());

  /// 提交新房源，返回创建后的 House 对象
  Future<House> createHouse(Map<String, dynamic> body) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _houseApi.createHouse(body);
      if (response.isSuccess && response.data != null) {
        final house = response.data!;
        state = state.copyWith(isLoading: false, createdHouse: house);
        return house;
      } else {
        final msg = response.message ?? '提交失败';
        state = state.copyWith(isLoading: false, error: msg);
        throw Exception(msg);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }
}

final createHouseProvider =
    StateNotifierProvider<CreateHouseNotifier, CreateHouseState>((ref) {
  final api = ref.watch(agentHouseApiProvider);
  return CreateHouseNotifier(api);
});
