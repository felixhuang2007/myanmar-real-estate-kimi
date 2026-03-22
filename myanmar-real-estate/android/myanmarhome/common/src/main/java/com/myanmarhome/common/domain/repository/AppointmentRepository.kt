package com.myanmarhome.common.domain.repository

import com.myanmarhome.common.domain.model.Appointment
import com.myanmarhome.common.domain.model.AppointmentStatus
import com.myanmarhome.common.domain.model.CreateAppointmentRequest
import kotlinx.coroutines.flow.Flow

interface AppointmentRepository {
    suspend fun createAppointment(request: CreateAppointmentRequest): Result<Appointment>
    suspend fun cancelAppointment(appointmentId: String, reason: String?): Result<Unit>
    suspend fun getAppointmentDetail(appointmentId: String): Result<Appointment>
    
    fun getMyAppointments(status: AppointmentStatus?): Flow<List<Appointment>>
    
    // Agent only
    suspend fun confirmAppointment(appointmentId: String): Result<Unit>
    suspend fun rejectAppointment(appointmentId: String, reason: String): Result<Unit>
    suspend fun completeAppointment(appointmentId: String): Result<Unit>
    fun getAgentAppointments(status: AppointmentStatus?): Flow<List<Appointment>>
}
