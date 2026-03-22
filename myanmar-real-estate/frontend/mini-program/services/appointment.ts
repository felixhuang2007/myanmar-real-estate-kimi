/**
 * 预约相关API服务
 */
import { http } from './request'
import { IAppointment, ICreateAppointmentParams, IPageData } from '../types'

/**
 * 创建预约
 * @param params 预约参数
 */
export function createAppointment(params: ICreateAppointmentParams): Promise<IAppointment> {
  return http.post('/appointments', params, { loadingText: '提交中...' })
}

/**
 * 获取预约详情
 * @param id 预约ID
 */
export function getAppointmentDetail(id: string): Promise<IAppointment> {
  return http.get(`/appointments/${id}`)
}

/**
 * 获取我的预约列表（用户端）
 * @param status 状态筛选
 * @param page 页码
 * @param pageSize 每页数量
 */
export function getMyAppointments(
  status?: string,
  page: number = 1,
  pageSize: number = 20
): Promise<IPageData<IAppointment>> {
  return http.get('/appointments/my', { status, page, pageSize })
}

/**
 * 获取经纪人预约列表（经纪人端）
 * @param status 状态筛选
 * @param page 页码
 * @param pageSize 每页数量
 */
export function getAgentAppointments(
  status?: string,
  page: number = 1,
  pageSize: number = 20
): Promise<IPageData<IAppointment>> {
  return http.get('/appointments/agent', { status, page, pageSize })
}

/**
 * 确认预约
 * @param id 预约ID
 * @param note 备注
 */
export function confirmAppointment(id: string, note?: string): Promise<void> {
  return http.post(`/appointments/${id}/confirm`, { note })
}

/**
 * 拒绝预约
 * @param id 预约ID
 * @param reason 原因
 */
export function rejectAppointment(id: string, reason: string): Promise<void> {
  return http.post(`/appointments/${id}/reject`, { reason })
}

/**
 * 取消预约
 * @param id 预约ID
 * @param reason 原因
 */
export function cancelAppointment(id: string, reason: string): Promise<void> {
  return http.post(`/appointments/${id}/cancel`, { reason })
}

/**
 * 完成预约
 * @param id 预约ID
 */
export function completeAppointment(id: string): Promise<void> {
  return http.post(`/appointments/${id}/complete`)
}

/**
 * 评价预约
 * @param id 预约ID
 * @param rating 评分
 * @param feedback 反馈
 */
export function rateAppointment(id: string, rating: number, feedback?: string): Promise<void> {
  return http.post(`/appointments/${id}/rate`, { rating, feedback })
}