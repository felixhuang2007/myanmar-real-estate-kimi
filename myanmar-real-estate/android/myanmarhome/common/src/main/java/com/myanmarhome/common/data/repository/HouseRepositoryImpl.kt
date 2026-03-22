package com.myanmarhome.common.data.repository

import com.myanmarhome.common.data.local.dao.FavoriteHouseDao
import com.myanmarhome.common.data.local.dao.ViewHistoryDao
import com.myanmarhome.common.data.remote.api.HomeApi
import com.myanmarhome.common.data.remote.api.HouseApi
import com.myanmarhome.common.domain.model.House
import com.myanmarhome.common.domain.model.HouseFilter
import com.myanmarhome.common.domain.model.MapBounds
import com.myanmarhome.common.domain.model.PagedData
import com.myanmarhome.common.domain.repository.HomeRepository
import com.myanmarhome.common.domain.repository.HouseRepository
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class HomeRepositoryImpl @Inject constructor(
    private val homeApi: HomeApi
) : HomeRepository {
    
    override suspend fun getHomeData(cityCode: String?) = try {
        val response = homeApi.getHomeData(cityCode)
        response.toResult()
    } catch (e: Exception) {
        Result.failure(e)
    }
    
    override suspend fun getCities() = try {
        val response = homeApi.getCities()
        response.toResult()
    } catch (e: Exception) {
        Result.failure(e)
    }
    
    override suspend fun getDistricts(cityCode: String) = try {
        val response = homeApi.getDistricts(cityCode)
        response.toResult()
    } catch (e: Exception) {
        Result.failure(e)
    }
}

@Singleton
class HouseRepositoryImpl @Inject constructor(
    private val houseApi: HouseApi,
    private val favoriteHouseDao: FavoriteHouseDao,
    private val viewHistoryDao: ViewHistoryDao
) : HouseRepository {
    
    override suspend fun searchHouses(
        filter: HouseFilter,
        page: Int,
        pageSize: Int
    ) = try {
        val response = houseApi.searchHouses(
            transactionType = filter.transactionType?.let { 
                when (it) {
                    is com.myanmarhome.common.domain.model.TransactionType.Sale -> "sale"
                    is com.myanmarhome.common.domain.model.TransactionType.Rent -> "rent"
                }
            },
            cityCode = filter.cityCode,
            districtCode = filter.districtCode,
            priceMin = filter.priceMin?.toString(),
            priceMax = filter.priceMax?.toString(),
            areaMin = filter.areaMin,
            areaMax = filter.areaMax,
            roomCount = filter.roomCount,
            keywords = filter.keywords,
            sortBy = when (filter.sortBy) {
                is com.myanmarhome.common.domain.model.SortType.Default -> "default"
                is com.myanmarhome.common.domain.model.SortType.PriceAsc -> "price_asc"
                is com.myanmarhome.common.domain.model.SortType.PriceDesc -> "price_desc"
                is com.myanmarhome.common.domain.model.SortType.Date -> "date"
                is com.myanmarhome.common.domain.model.SortType.Area -> "area"
            },
            page = page,
            pageSize = pageSize
        )
        response.toResult()
    } catch (e: Exception) {
        Result.failure(e)
    }
    
    override suspend fun getHouseDetail(houseId: String) = try {
        val response = houseApi.getHouseDetail(houseId)
        response.toResult()
    } catch (e: Exception) {
        Result.failure(e)
    }
    
    override suspend fun getRecommendHouses(cityCode: String?, limit: Int) = try {
        val response = houseApi.getRecommendHouses(cityCode, limit)
        response.toResult()
    } catch (e: Exception) {
        Result.failure(e)
    }
    
    override suspend fun getMapClusters(
        bounds: MapBounds,
        zoom: Int,
        filter: HouseFilter
    ) = try {
        // TODO: Map cluster API call
        Result.success(emptyList())
    } catch (e: Exception) {
        Result.failure(e)
    }
    
    override suspend fun getMapHouses(bounds: MapBounds, filter: HouseFilter) = try {
        // TODO: Map houses API call
        Result.success(emptyList())
    } catch (e: Exception) {
        Result.failure(e)
    }
    
    override fun getFavoriteHouses(): Flow<List<House>> {
        return favoriteHouseDao.getAll().map { entities ->
            // TODO: Map entities to domain models
            emptyList()
        }
    }
    
    override suspend fun addFavorite(houseId: String): Result<Unit> {
        // TODO: Implement add favorite
        return Result.success(Unit)
    }
    
    override suspend fun removeFavorite(houseId: String): Result<Unit> {
        // TODO: Implement remove favorite
        return Result.success(Unit)
    }
    
    override fun isFavorite(houseId: String): Flow<Boolean> {
        return favoriteHouseDao.isFavorite(houseId)
    }
    
    override suspend fun getViewHistory(): Flow<List<House>> {
        return viewHistoryDao.getAll().map { entities ->
            // TODO: Map entities to domain models
            emptyList()
        }
    }
    
    override suspend fun addViewHistory(houseId: String): Result<Unit> {
        // TODO: Implement add view history
        return Result.success(Unit)
    }
    
    override suspend fun clearViewHistory(): Result<Unit> {
        viewHistoryDao.clearAll()
        return Result.success(Unit)
    }
}
