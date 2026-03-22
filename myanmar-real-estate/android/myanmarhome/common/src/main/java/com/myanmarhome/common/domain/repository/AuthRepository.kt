package com.myanmarhome.common.domain.repository

import com.myanmarhome.common.domain.model.Agent
import com.myanmarhome.common.domain.model.AgentStatus
import com.myanmarhome.common.domain.model.LoginResult
import com.myanmarhome.common.domain.model.RegisterRequest
import com.myanmarhome.common.domain.model.User
import com.myanmarhome.common.domain.model.VerifyIdentityRequest
import kotlinx.coroutines.flow.Flow

interface AuthRepository {
    suspend fun login(phone: String, verifyCode: String): Result<LoginResult>
    suspend fun register(request: RegisterRequest): Result<LoginResult>
    suspend fun logout(): Result<Unit>
    suspend fun refreshToken(): Result<String>
    
    suspend fun sendVerifyCode(phone: String): Result<Unit>
    suspend fun verifyIdentity(request: VerifyIdentityRequest): Result<Unit>
    
    fun isLoggedIn(): Flow<Boolean>
    fun getCurrentUser(): Flow<User?>
    fun getCurrentAgent(): Flow<Agent?>
    
    suspend fun getUserProfile(): Result<User>
    suspend fun updateUserProfile(nickname: String?, avatar: String?): Result<User>
    
    suspend fun getAgentProfile(): Result<Agent>
    suspend fun updateAgentProfile(company: String?, licenseNumber: String?): Result<Agent>
}

interface UserPreferencesRepository {
    suspend fun saveToken(token: String)
    suspend fun getToken(): String?
    suspend fun clearToken()
    
    suspend fun saveUserId(userId: String)
    suspend fun getUserId(): String?
    suspend fun clearUserId()
    
    suspend fun saveThemeMode(isDark: Boolean)
    fun getThemeMode(): Flow<Boolean>
    
    suspend fun saveLanguage(language: String)
    fun getLanguage(): Flow<String>
    
    suspend fun saveLastCity(cityCode: String)
    fun getLastCity(): Flow<String?>
}
