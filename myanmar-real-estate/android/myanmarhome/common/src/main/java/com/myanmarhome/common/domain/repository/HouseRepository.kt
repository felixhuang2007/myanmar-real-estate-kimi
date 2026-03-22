package com.myanmarhome.common.domain.repository

import com.myanmarhome.common.domain.model.City
import com.myanmarhome.common.domain.model.District
import com.myanmarhome.common.domain.model.HomeData
import com.myanmarhome.common.domain.model.House
import com.myanmarhome.common.domain.model.HouseFilter
import com.myanmarhome.common.domain.model.MapBounds
import com.myanmarhome.common.domain.model.MapCluster
import com.myanmarhome.common.domain.model.PagedData
import kotlinx.coroutines.flow.Flow

interface HomeRepository {
    suspend fun getHomeData(cityCode: String?): Result<HomeData>
    suspend fun getCities(): Result<List<City>>
    suspend fun getDistricts(cityCode: String): Result<List<District>>
}

interface HouseRepository {
    suspend fun searchHouses(filter: HouseFilter, page: Int, pageSize: Int): Result<PagedData<House>>
    suspend fun getHouseDetail(houseId: String): Result<House>
    suspend fun getRecommendHouses(cityCode: String?, limit: Int): Result<List<House>>
    
    suspend fun getMapClusters(bounds: MapBounds, zoom: Int, filter: HouseFilter): Result<List<MapCluster>>
    suspend fun getMapHouses(bounds: MapBounds, filter: HouseFilter): Result<List<House>>
    
    fun getFavoriteHouses(): Flow<List<House>>
    suspend fun addFavorite(houseId: String): Result<Unit>
    suspend fun removeFavorite(houseId: String): Result<Unit>
    suspend fun isFavorite(houseId: String): Flow<Boolean>
    
    suspend fun getViewHistory(): Flow<List<House>>
    suspend fun addViewHistory(houseId: String): Result<Unit>
    suspend fun clearViewHistory(): Result<Unit>
}

interface AgentHouseRepository {
    suspend fun createHouse(house: House): Result<String>
    suspend fun updateHouse(house: House): Result<Unit>
    suspend fun deleteHouse(houseId: String): Result<Unit>
    suspend fun getMyHouses(status: String?, page: Int): Result<PagedData<House>>
    
    suspend fun refreshHouse(houseId: String): Result<Unit>
    suspend fun changeHouseStatus(houseId: String, status: String): Result<Unit>
}
