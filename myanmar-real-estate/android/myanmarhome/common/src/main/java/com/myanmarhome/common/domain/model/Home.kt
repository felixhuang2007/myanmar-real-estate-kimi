package com.myanmarhome.common.domain.model

import android.os.Parcelable
import kotlinx.parcelize.Parcelize
import java.math.BigDecimal

@Parcelize
data class Banner(
    val id: String,
    val image: String,
    val linkType: BannerLinkType,
    val linkValue: String,
    val sortOrder: Int
) : Parcelable

sealed class BannerLinkType : Parcelable {
    @Parcelize
    object HouseDetail : BannerLinkType()
    
    @Parcelize
    object SearchResult : BannerLinkType()
    
    @Parcelize
    object Web : BannerLinkType()
    
    @Parcelize
    object None : BannerLinkType()
}

@Parcelize
data class QuickEntry(
    val type: QuickEntryType,
    val icon: String,
    val name: String,
    val nameEn: String?
) : Parcelable

sealed class QuickEntryType : Parcelable {
    @Parcelize
    object Buy : QuickEntryType()
    
    @Parcelize
    object Rent : QuickEntryType()
    
    @Parcelize
    object Publish : QuickEntryType()
    
    @Parcelize
    object Map : QuickEntryType()
}

@Parcelize
data class HomeData(
    val banners: List<Banner>,
    val quickEntries: List<QuickEntry>,
    val recommendHouses: List<House>
) : Parcelable

@Parcelize
data class City(
    val code: String,
    val name: String,
    val nameEn: String?,
    val hot: Boolean
) : Parcelable
