package com.myanmarhome.common.domain.repository

import com.myanmarhome.common.domain.model.Conversation
import com.myanmarhome.common.domain.model.HouseCardData
import com.myanmarhome.common.domain.model.Message
import kotlinx.coroutines.flow.Flow

interface ChatRepository {
    fun getConversations(): Flow<List<Conversation>>
    suspend fun deleteConversation(conversationId: String): Result<Unit>
    suspend fun clearUnread(conversationId: String): Result<Unit>
    
    fun getMessages(conversationId: String): Flow<List<Message>>
    suspend fun sendTextMessage(conversationId: String, content: String): Result<Message>
    suspend fun sendImageMessage(conversationId: String, imagePath: String): Result<Message>
    suspend fun sendVoiceMessage(conversationId: String, voicePath: String, duration: Int): Result<Message>
    suspend fun sendHouseCard(conversationId: String, house: HouseCardData): Result<Message>
    suspend fun recallMessage(messageId: String): Result<Unit>
    
    suspend fun initIM(userId: String, token: String): Result<Unit>
    suspend fun logoutIM(): Result<Unit>
}
