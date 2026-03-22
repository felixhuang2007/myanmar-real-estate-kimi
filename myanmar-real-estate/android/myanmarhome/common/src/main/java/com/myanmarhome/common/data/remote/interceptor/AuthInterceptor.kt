package com.myanmarhome.common.data.remote.interceptor

import com.myanmarhome.common.domain.repository.UserPreferencesRepository
import kotlinx.coroutines.runBlocking
import okhttp3.Interceptor
import okhttp3.Response
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class AuthInterceptor @Inject constructor(
    private val userPreferencesRepository: UserPreferencesRepository
) : Interceptor {
    override fun intercept(chain: Interceptor.Chain): Response {
        val request = chain.request()
        val token = runBlocking { userPreferencesRepository.getToken() }
        
        return if (token != null) {
            val newRequest = request.newBuilder()
                .header("Authorization", "Bearer $token")
                .build()
            chain.proceed(newRequest)
        } else {
            chain.proceed(request)
        }
    }
}

@Singleton
class LoggingInterceptor @Inject constructor() : Interceptor {
    override fun intercept(chain: Interceptor.Chain): Response {
        val request = chain.request()
        val startTime = System.currentTimeMillis()
        
        val response = chain.proceed(request)
        val duration = System.currentTimeMillis() - startTime
        
        // 日志输出
        val logMessage = buildString {
            appendLine("╔═══════════════════════════════════════════════════════")
            appendLine("║ Request: ${request.method} ${request.url}")
            appendLine("║ Headers: ${request.headers}")
            appendLine("║ Response: ${response.code} (${duration}ms)")
            appendLine("╚═══════════════════════════════════════════════════════")
        }
        
        android.util.Log.d("OkHttp", logMessage)
        
        return response
    }
}
