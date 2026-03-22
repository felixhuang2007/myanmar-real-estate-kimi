/**
 * 预约和带看相关类型定义
 */

// 预约状态
export type AppointmentStatus = 
  | 'pending'      // 待确认
  | 'confirmed'    // 已确认
  | 'rejected'     // 已拒绝
  | 'completed'    // 已完成
  | 'cancelled'    // 已取消
  | 'no_show'      // 爽约

// 预约信息
export interface IAppointment {
  id: string
  houseId: string
  houseTitle: string
  houseImage?: string
  
  // 客户信息
  userId: string
  userName: string
  userPhone: string
  
  // 经纪人信息
  agentId: string
  agentName: string
  agentPhone?: string
  
  // 预约时间
  appointmentDate: string
  appointmentTime: string
  
  // 状态
  status: AppointmentStatus
  
  // 备注
  userNote?: string
  agentNote?: string
  
  // 反馈
  userFeedback?: string
  userRating?: number
  agentFeedback?: string
  
  // 时间
  createdAt: string
  updatedAt: string
  confirmedAt?: string
  completedAt?: string
}

// 创建预约参数
export interface ICreateAppointmentParams {
  houseId: string
  agentId: string
  appointmentDate: string
  appointmentTime: string
  note?: string
}