package com.myanmarhome.common.domain.model

import android.os.Parcelable
import kotlinx.parcelize.Parcelize
import java.math.BigDecimal

@Parcelize
data class ACNTransaction(
    val id: String,
    val houseId: String,
    val houseTitle: String,
    val dealPrice: BigDecimal,
    val commission: BigDecimal,
    val dealDate: String,
    val contractImage: String?,
    val participants: List<ACNParticipant>,
    val platformFee: BigDecimal,
    val status: ACNTransactionStatus,
    val createdAt: String,
    val updatedAt: String
) : Parcelable

@Parcelize
data class ACNParticipant(
    val role: ACNRole,
    val agentId: String,
    val agentName: String,
    val agentAvatar: String?,
    val commission: BigDecimal,
    val status: ACNParticipantStatus
) : Parcelable

sealed class ACNRole : Parcelable {
    @Parcelize
    object Entrant : ACNRole()      // 房源录入人
    
    @Parcelize
    object Maintainer : ACNRole()   // 房源维护人
    
    @Parcelize
    object Introducer : ACNRole()   // 客源转介绍
    
    @Parcelize
    object Accompanier : ACNRole()  // 带看人
    
    @Parcelize
    object Closer : ACNRole()       // 成交人
}

sealed class ACNParticipantStatus : Parcelable {
    @Parcelize
    object Pending : ACNParticipantStatus()
    
    @Parcelize
    object Confirmed : ACNParticipantStatus()
    
    @Parcelize
    object Rejected : ACNParticipantStatus()
}

sealed class ACNTransactionStatus : Parcelable {
    @Parcelize
    object PendingConfirm : ACNTransactionStatus()
    
    @Parcelize
    object Confirmed : ACNTransactionStatus()
    
    @Parcelize
    object Settled : ACNTransactionStatus()
    
    @Parcelize
    object Disputed : ACNTransactionStatus()
}

@Parcelize
data class CommissionSummary(
    val totalCommission: BigDecimal,
    val pendingCommission: BigDecimal,
    val settledCommission: BigDecimal,
    thisMonthCommission: BigDecimal,
    val dealCount: Int,
    val ranking: Int
) : Parcelable
