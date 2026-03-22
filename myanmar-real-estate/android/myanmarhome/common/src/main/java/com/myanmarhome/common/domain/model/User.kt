package com.myanmarhome.common.domain.model

import android.os.Parcelable
import kotlinx.parcelize.Parcelize

@Parcelize
data class User(
    val id: String,
    val phone: String,
    val nickname: String?,
    val avatar: String?,
    val realName: String?,
    val idCardNumber: String?,
    val identityStatus: IdentityStatus,
    val createdAt: String
) : Parcelable

sealed class IdentityStatus : Parcelable {
    @Parcelize
    object Unverified : IdentityStatus()
    
    @Parcelize
    object Pending : IdentityStatus()
    
    @Parcelize
    object Verified : IdentityStatus()
    
    @Parcelize
    object Failed : IdentityStatus()
}

@Parcelize
data class Agent(
    val id: String,
    val userId: String,
    val name: String,
    val phone: String,
    val avatar: String?,
    val company: String?,
    val companyAddress: String?,
    val licenseNumber: String?,
    val status: AgentStatus,
    val rating: Float,
    val dealCount: Int,
    val houseCount: Int,
    val regionCode: String,
    val joinDate: String
) : Parcelable

sealed class AgentStatus : Parcelable {
    @Parcelize
    object Pending : AgentStatus()
    
    @Parcelize
    object Active : AgentStatus()
    
    @Parcelize
    object Suspended : AgentStatus()
    
    @Parcelize
    object Inactive : AgentStatus()
}

@Parcelize
data class LoginResult(
    val userId: String,
    val token: String,
    val expiresAt: Long,
    val isNewUser: Boolean,
    val user: User
) : Parcelable

@Parcelize
data class RegisterRequest(
    val phone: String,
    val verifyCode: String,
    val password: String? = null
) : Parcelable

@Parcelize
data class VerifyIdentityRequest(
    val realName: String,
    val idCardNumber: String,
    val idCardFront: String,
    val idCardBack: String? = null
) : Parcelable
