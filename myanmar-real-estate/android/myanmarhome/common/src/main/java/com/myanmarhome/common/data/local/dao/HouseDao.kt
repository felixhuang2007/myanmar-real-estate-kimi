package com.myanmarhome.common.data.local.dao

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import com.myanmarhome.common.data.local.entity.FavoriteHouseEntity
import kotlinx.coroutines.flow.Flow

@Dao
interface FavoriteHouseDao {
    @Query("SELECT * FROM favorite_houses ORDER BY addedAt DESC")
    fun getAll(): Flow<List<FavoriteHouseEntity>>
    
    @Query("SELECT * FROM favorite_houses WHERE houseId = :houseId")
    suspend fun getById(houseId: String): FavoriteHouseEntity?
    
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insert(entity: FavoriteHouseEntity)
    
    @Query("DELETE FROM favorite_houses WHERE houseId = :houseId")
    suspend fun delete(houseId: String)
    
    @Query("SELECT EXISTS(SELECT 1 FROM favorite_houses WHERE houseId = :houseId)")
    fun isFavorite(houseId: String): Flow<Boolean>
}

@Dao
interface ViewHistoryDao {
    @Query("SELECT * FROM view_history ORDER BY viewedAt DESC LIMIT :limit")
    fun getAll(limit: Int = 100): Flow<List<ViewHistoryEntity>>
    
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insert(entity: ViewHistoryEntity)
    
    @Query("DELETE FROM view_history")
    suspend fun clearAll()
    
    @Query("DELETE FROM view_history WHERE houseId NOT IN (SELECT houseId FROM view_history ORDER BY viewedAt DESC LIMIT :keepCount)")
    suspend fun trimOldRecords(keepCount: Int = 100)
}

@Dao
interface SearchHistoryDao {
    @Query("SELECT * FROM search_history ORDER BY lastSearchAt DESC LIMIT :limit")
    fun getRecent(limit: Int = 20): Flow<List<SearchHistoryEntity>>
    
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insert(entity: SearchHistoryEntity)
    
    @Query("DELETE FROM search_history WHERE keywords = :keywords")
    suspend fun delete(keywords: String)
    
    @Query("DELETE FROM search_history")
    suspend fun clearAll()
}
