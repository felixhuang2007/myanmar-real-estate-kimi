package com.myanmarhome.common.domain.model

import android.os.Parcelable
import kotlinx.parcelize.Parcelize
import java.math.BigDecimal

@Parcelize
data class Appointment(
    val id: String,
    val houseId: String,
    val houseTitle: String,
    val houseCover: String,
    val agentId: String,
    val agentName: String,
    val agentAvatar: String?,
    val userId: String,
    val appointmentTime: String,
    val status: AppointmentStatus,
    val note: String?,
    val createdAt: String,
    val updatedAt: String
) : Parcelable

sealed class AppointmentStatus : Parcelable {
    @Parcelize
    object Pending : AppointmentStatus()
    
    @Parcelize
    object Confirmed : AppointmentStatus()
    
    @Parcelize
    object Rejected : AppointmentStatus()
    
    @Parcelize
    object Cancelled : AppointmentStatus()
    
    @Parcelize
    object Completed : AppointmentStatus()
    
    @Parcelize
    object NoShow : AppointmentStatus()
}

@Parcelize
data class CreateAppointmentRequest(
    val houseId: String,
    val agentId: String,
    val appointmentTime: String,
    val note: String? = null
) : Parcelable

@Parcelize
data class Conversation(
    val id: String,
    val targetId: String,
    val targetName: String,
    val targetAvatar: String?,
    val lastMessage: Message?,
    val unreadCount: Int,
    val updatedAt: String
) : Parcelable

@Parcelize
data class Message(
    val id: String,
    val conversationId: String,
    val senderId: String,
    val senderName: String,
    val senderAvatar: String?,
    val type: MessageType,
    val content: String,
    val status: MessageStatus,
    val createdAt: String
) : Parcelable

sealed class MessageType : Parcelable {
    @Parcelize
    object Text : MessageType()
    
    @Parcelize
    object Image : MessageType()
    
    @Parcelize
    object Voice : MessageType()
    
    @Parcelize
    object HouseCard : MessageType()
    
    @Parcelize
    object System : MessageType()
}

sealed class MessageStatus : Parcelable {
    @Parcelize
    object Sending : MessageStatus()
    
    @Parcelize
    object Sent : MessageStatus()
    
    @Parcelize
    object Delivered : MessageStatus()
    
    @Parcelize
    object Read : MessageStatus()
    
    @Parcelize
    object Failed : MessageStatus()
}

@Parcelize
data class HouseCardData(
    val houseId: String,
    val title: String,
    val coverImage: String,
    val price: BigDecimal,
    val priceUnit: String,
    val area: Double,
    val rooms: String,
    val location: String
) : Parcelable
