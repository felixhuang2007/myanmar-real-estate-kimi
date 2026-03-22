package com.myanmarhome.common.data.local.entity

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "favorite_houses")
data class FavoriteHouseEntity(
    @PrimaryKey
    val houseId: String,
    val title: String,
    val coverImage: String,
    val price: String,
    val priceUnit: String,
    val area: Double,
    val rooms: String,
    val location: String,
    val addedAt: Long = System.currentTimeMillis()
)

@Entity(tableName = "view_history")
data class ViewHistoryEntity(
    @PrimaryKey
    val houseId: String,
    val title: String,
    val coverImage: String,
    val price: String,
    val priceUnit: String,
    val area: Double,
    val rooms: String,
    val location: String,
    val viewedAt: Long = System.currentTimeMillis()
)

@Entity(tableName = "search_history")
data class SearchHistoryEntity(
    @PrimaryKey
    val keywords: String,
    val searchCount: Int = 1,
    val lastSearchAt: Long = System.currentTimeMillis()
)
