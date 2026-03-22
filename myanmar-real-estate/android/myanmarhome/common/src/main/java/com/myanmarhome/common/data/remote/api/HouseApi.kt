package com.myanmarhome.common.data.remote.api

import com.myanmarhome.common.domain.model.HomeData
import com.myanmarhome.common.domain.model.City
import com.myanmarhome.common.domain.model.District
import com.myanmarhome.common.domain.model.House
import com.myanmarhome.common.domain.model.PagedData
import retrofit2.http.GET
import retrofit2.http.Path
import retrofit2.http.Query

interface HomeApi {
    @GET("api/v1/home")
    suspend fun getHomeData(
        @Query("cityCode") cityCode: String?
    ): ApiResponse<HomeData>
    
    @GET("api/v1/cities")
    suspend fun getCities(): ApiResponse<List<City>>
    
    @GET("api/v1/cities/{cityCode}/districts")
    suspend fun getDistricts(
        @Path("cityCode") cityCode: String
    ): ApiResponse<List<District>>
}

interface HouseApi {
    @GET("api/v1/houses/search")
    suspend fun searchHouses(
        @Query("transactionType") transactionType: String?,
        @Query("cityCode") cityCode: String?,
        @Query("districtCode") districtCode: String?,
        @Query("priceMin") priceMin: String?,
        @Query("priceMax") priceMax: String?,
        @Query("areaMin") areaMin: Double?,
        @Query("areaMax") areaMax: Double?,
        @Query("roomCount") roomCount: String?,
        @Query("keywords") keywords: String?,
        @Query("sortBy") sortBy: String,
        @Query("page") page: Int,
        @Query("pageSize") pageSize: Int
    ): ApiResponse<PagedData<House>>
    
    @GET("api/v1/houses/{houseId}")
    suspend fun getHouseDetail(
        @Path("houseId") houseId: String
    ): ApiResponse<House>
    
    @GET("api/v1/houses/recommend")
    suspend fun getRecommendHouses(
        @Query("cityCode") cityCode: String?,
        @Query("limit") limit: Int
    ): ApiResponse<List<House>>
    
    @GET("api/v1/houses/map/clusters")
    suspend fun getMapClusters(
        @Query("swLat") swLat: Double,
        @Query("swLng") swLng: Double,
        @Query("neLat") neLat: Double,
        @Query("neLng") neLng: Double,
        @Query("zoom") zoom: Int,
        @Query("transactionType") transactionType: String?,
        @Query("priceMin") priceMin: String?,
        @Query("priceMax") priceMax: String?
    ): ApiResponse<List<MapClusterDto>>
    
    @GET("api/v1/houses/map/houses")
    suspend fun getMapHouses(
        @Query("swLat") swLat: Double,
        @Query("swLng") swLng: Double,
        @Query("neLat") neLat: Double,
        @Query("neLng") neLng: Double,
        @Query("transactionType") transactionType: String?,
        @Query("priceMin") priceMin: String?,
        @Query("priceMax") priceMax: String?
    ): ApiResponse<List<House>>
}

data class MapClusterDto(
    val id: String,
    val name: String,
    val lat: Double,
    val lng: Double,
    val avgPrice: String,
    val totalCount: Int
)
