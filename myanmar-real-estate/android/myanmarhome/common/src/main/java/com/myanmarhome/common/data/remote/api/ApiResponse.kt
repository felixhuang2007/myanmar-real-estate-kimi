package com.myanmarhome.common.data.remote.api

import com.google.gson.annotations.SerializedName

/**
 * 统一API响应格式
 */
data class ApiResponse<T>(
    @SerializedName("code")
    val code: Int,
    @SerializedName("message")
    val message: String,
    @SerializedName("data")
    val data: T?,
    @SerializedName("timestamp")
    val timestamp: Long
) {
    fun isSuccess(): Boolean = code == 200
}

/**
 * 业务异常
 */
sealed class ApiException(message: String) : Exception(message) {
    class BadRequest(message: String) : ApiException(message)
    class Unauthorized(message: String) : ApiException(message)
    class Forbidden(message: String) : ApiException(message)
    class NotFound(message: String) : ApiException(message)
    class ServerError(message: String) : ApiException(message)
    class NetworkError(message: String) : ApiException(message)
    class UnknownError(message: String) : ApiException(message)
}

fun <T> ApiResponse<T>.toResult(): Result<T> {
    return if (isSuccess()) {
        data?.let { Result.success(it) }
            ?: Result.failure(ApiException.UnknownError("Response data is null"))
    } else {
        Result.failure(mapCodeToException(code, message))
    }
}

private fun mapCodeToException(code: Int, message: String): ApiException {
    return when (code) {
        400 -> ApiException.BadRequest(message)
        401 -> ApiException.Unauthorized(message)
        403 -> ApiException.Forbidden(message)
        404 -> ApiException.NotFound(message)
        in 500..599 -> ApiException.ServerError(message)
        else -> ApiException.UnknownError(message)
    }
}
