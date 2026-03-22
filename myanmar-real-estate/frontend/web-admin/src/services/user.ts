/**
 * 用户相关API
 */
import { http } from './request';
import { IUser, ILoginResponse, IPageData, IEndUser } from '@/types';

interface SendCodeResponse {
  expired_at: number;
  interval: number;
  code?: string;  // 开发环境返回
}

/**
 * 发送登录验证码
 * @param phone 手机号
 */
export async function sendVerificationCode(phone: string): Promise<SendCodeResponse> {
  return http.post('/auth/send-verification-code', { phone, type: 'login' });
}

/**
 * 管理员登录（手机号+验证码）
 * @param phone 手机号
 * @param code 验证码
 */
export async function adminLogin(phone: string, code: string): Promise<ILoginResponse> {
  return http.post('/auth/login', { phone, code, device_id: 'web_admin' });
}

/**
 * 获取当前用户信息
 */
export async function getCurrentUser(): Promise<IUser> {
  return http.get('/admin/user/current');
}

/**
 * 获取用户列表
 * @param params 查询参数
 */
export async function getUserList(params?: { 
  current?: number; 
  pageSize?: number;
  keyword?: string;
  role?: string;
  status?: string;
}): Promise<IPageData<IUser>> {
  return http.get('/admin/users', params);
}

/**
 * 创建用户
 * @param data 用户数据
 */
export async function createUser(data: Partial<IUser>): Promise<IUser> {
  return http.post('/admin/users', data);
}

/**
 * 更新用户
 * @param id 用户ID
 * @param data 用户数据
 */
export async function updateUser(id: string, data: Partial<IUser>): Promise<IUser> {
  return http.put(`/admin/users/${id}`, data);
}

/**
 * 删除用户
 * @param id 用户ID
 */
export async function deleteUser(id: string): Promise<void> {
  return http.delete(`/admin/users/${id}`);
}

/**
 * 获取C端用户列表
 * @param params 查询参数
 */
export async function getEndUserList(params?: {
  current?: number;
  pageSize?: number;
  keyword?: string;
  identityStatus?: string;
}): Promise<IPageData<IEndUser>> {
  return http.get('/admin/users/c-end', params);
}