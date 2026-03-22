package com.myanmarhome.common.data.local.database

import androidx.room.Database
import androidx.room.RoomDatabase
import androidx.room.TypeConverters
import com.myanmarhome.common.data.local.dao.FavoriteHouseDao
import com.myanmarhome.common.data.local.dao.SearchHistoryDao
import com.myanmarhome.common.data.local.dao.ViewHistoryDao
import com.myanmarhome.common.data.local.entity.FavoriteHouseEntity
import com.myanmarhome.common.data.local.entity.SearchHistoryEntity
import com.myanmarhome.common.data.local.entity.ViewHistoryEntity

@Database(
    entities = [
        FavoriteHouseEntity::class,
        ViewHistoryEntity::class,
        SearchHistoryEntity::class
    ],
    version = 1,
    exportSchema = false
)
@TypeConverters(Converters::class)
abstract class AppDatabase : RoomDatabase() {
    abstract fun favoriteHouseDao(): FavoriteHouseDao
    abstract fun viewHistoryDao(): ViewHistoryDao
    abstract fun searchHistoryDao(): SearchHistoryDao
}
