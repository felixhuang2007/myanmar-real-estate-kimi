/**
 * 统计相关API
 */
import { http } from './request';
import { IDashboardStats, ITrendData } from '@/types';

/**
 * 获取仪表盘统计数据
 */
export async function getDashboardStats(): Promise<IDashboardStats> {
  return http.get('/admin/dashboard/stats');
}

/**
 * 获取用户趋势数据
 * @param days 天数
 */
export async function getUserTrend(days: number = 7): Promise<ITrendData[]> {
  return http.get('/admin/dashboard/trend/users', { days });
}

/**
 * 获取房源趋势数据
 * @param days 天数
 */
export async function getHouseTrend(days: number = 7): Promise<ITrendData[]> {
  return http.get('/admin/dashboard/trend/houses', { days });
}

/**
 * 获取交易趋势数据
 * @param days 天数
 */
export async function getDealTrend(days: number = 7): Promise<ITrendData[]> {
  return http.get('/admin/dashboard/trend/deals', { days });
}