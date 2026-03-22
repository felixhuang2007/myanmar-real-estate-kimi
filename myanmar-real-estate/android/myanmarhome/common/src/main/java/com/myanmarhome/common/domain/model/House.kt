package com.myanmarhome.common.domain.model

import android.os.Parcelable
import kotlinx.parcelize.Parcelize
import java.math.BigDecimal

sealed class HouseType {
    object Apartment : HouseType()
    object House : HouseType()
    object Townhouse : HouseType()
    object Land : HouseType()
    object Commercial : HouseType()
}

sealed class TransactionType {
    object Sale : TransactionType()
    object Rent : TransactionType()
}

sealed class PropertyType {
    object Grant : PropertyType()      // 地契(ဂရန်)
    object License : PropertyType()    // 许可证(လိုင်စင်)
    object Contract : PropertyType()   // 合同转让
}

sealed class VerificationStatus {
    object Unverified : VerificationStatus()
    object Pending : VerificationStatus()
    object Verified : VerificationStatus()
    object Failed : VerificationStatus()
}

@Parcelize
data class House(
    val id: String,
    val title: String,
    val coverImage: String,
    val images: List<String>,
    val video: String?,
    val transactionType: TransactionType,
    val houseType: HouseType,
    val price: BigDecimal,
    val priceUnit: String,
    val priceNote: String?,
    val area: Double,
    val rooms: String,
    val floor: String?,
    val totalFloors: Int?,
    val decoration: String?,
    val orientation: String?,
    val buildYear: Int?,
    val description: String?,
    val highlights: List<String>,
    val facilities: List<String>,
    val address: String,
    val district: District,
    val community: Community?,
    val latitude: Double,
    val longitude: Double,
    val nearby: List<NearbyFacility>,
    val propertyType: PropertyType?,
    val ownership: String?,
    val hasLoan: Boolean?,
    val propertyCertificate: String?,
    val verificationStatus: VerificationStatus,
    val verifiedAt: String?,
    val verifiedBy: String?,
    val tags: List<String>,
    val agent: AgentInfo,
    val publishTime: String,
    val status: HouseStatus
) : Parcelable

@Parcelize
data class HouseStatus(
    val isAvailable: Boolean,
    val isFavorite: Boolean,
    val viewCount: Int,
    val favoriteCount: Int
) : Parcelable

@Parcelize
data class District(
    val code: String,
    val name: String,
    val nameEn: String?,
    val cityCode: String
) : Parcelable

@Parcelize
data class Community(
    val id: String,
    val name: String,
    val nameEn: String?,
    val districtCode: String,
    val avgPrice: BigDecimal?,
    val houseCount: Int
) : Parcelable

@Parcelize
data class NearbyFacility(
    val type: FacilityType,
    val name: String,
    val distance: String
) : Parcelable

sealed class FacilityType {
    object School : FacilityType()
    object Hospital : FacilityType()
    object Mall : FacilityType()
    object Transport : FacilityType()
    object Park : FacilityType()
    object Restaurant : FacilityType()
}

@Parcelize
data class AgentInfo(
    val id: String,
    val name: String,
    val avatar: String?,
    val company: String?,
    val rating: Float,
    val dealCount: Int,
    val phone: String
) : Parcelable

@Parcelize
data class HouseFilter(
    val transactionType: TransactionType? = null,
    val cityCode: String? = null,
    val districtCode: String? = null,
    val communityId: String? = null,
    val houseType: HouseType? = null,
    val priceMin: BigDecimal? = null,
    val priceMax: BigDecimal? = null,
    val areaMin: Double? = null,
    val areaMax: Double? = null,
    val roomCount: String? = null,
    val keywords: String? = null,
    val sortBy: SortType = SortType.Default,
    val verificationOnly: Boolean = false
) : Parcelable

sealed class SortType {
    object Default : SortType()
    object PriceAsc : SortType()
    object PriceDesc : SortType()
    object Date : SortType()
    object Area : SortType()
}

@Parcelize
data class MapBounds(
    val swLat: Double,
    val swLng: Double,
    val neLat: Double,
    val neLng: Double
) : Parcelable

@Parcelize
data class MapCluster(
    val id: String,
    val name: String,
    val latitude: Double,
    val longitude: Double,
    val avgPrice: BigDecimal,
    val totalCount: Int,
    val bounds: MapBounds
) : Parcelable

@Parcelize
data class PagedData<T : Parcelable>(
    val total: Int,
    val page: Int,
    val pageSize: Int,
    val list: List<T>
) : Parcelable
