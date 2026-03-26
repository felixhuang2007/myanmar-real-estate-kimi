/**
 * 房源相关API
 */
import { http } from './request';
import { IHouse, IPageData } from '@/types';

/**
 * 获取房源列表
 * @param params 查询参数
 */
export async function getHouseList(params?: {
  current?: number;
  pageSize?: number;
  keyword?: string;
  transactionType?: string;
  verificationStatus?: string;
  status?: string;
  cityCode?: string;
}): Promise<IPageData<IHouse>> {
  return http.get('/admin/houses', params);
}

/**
 * 获取房源详情
 * @param id 房源ID
 */
export async function getHouseDetail(id: string): Promise<IHouse> {
  return http.get(`/admin/houses/${id}`);
}

/**
 * 审核房源
 * @param id 房源ID
 * @param status 审核状态
 * @param reason 原因
 */
export async function auditHouse(
  id: string, 
  status: 'approved' | 'rejected', 
  reason?: string
): Promise<void> {
  return http.post(`/admin/houses/${id}/audit`, { status, reason });
}

/**
 * 上架/下架房源
 * @param id 房源ID
 * @param status 状态
 */
export async function updateHouseStatus(
  id: string, 
  status: 'active' | 'inactive'
): Promise<void> {
  return http.put(`/admin/houses/${id}/status`, { status });
}

/**
 * 删除房源
 * @param id 房源ID
 */
export async function deleteHouse(id: string): Promise<void> {
  return http.delete(`/admin/houses/${id}`);
}

/**
 * 获取房源统计数据
 */
export async function getHouseStats(): Promise<{
  total: number;
  todayNew: number;
  pendingAudit: number;
  pendingVerification: number;
}> {
  return http.get('/admin/houses/stats');
}

/**
 * 获取验真任务列表
 * @param params 查询参数
 */
export const getVerificationTasks = (params: any) =>
  http.get<{ list: any[]; total: number }>('/verification/tasks', { params });