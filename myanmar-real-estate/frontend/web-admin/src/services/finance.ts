/**
 * 财务相关API
 */
import { http } from './request';

export interface IWithdrawal {
  id: number;
  agent_id: number;
  agent_name: string;
  agent_phone: string;
  amount: number;
  status: 'pending' | 'approved' | 'rejected' | 'paid';
  bank_name?: string;
  bank_account?: string;
  bank_holder?: string;
  reject_reason?: string;
  created_at: string;
  updated_at: string;
}

export interface IACNTransaction {
  id: number;
  house_id: number;
  house_title: string;
  transaction_price: number;
  commission_amount: number;
  platform_fee: number;
  status: string; // pending/confirmed/settled/rejected/disputed
  entry_agent?: string;
  maintainer_agent?: string;
  viewer_agent?: string;
  closer_agent?: string;
  referrer_agent?: string;
  settlement_date?: string;
  created_at: string;
}

export interface ICommissionDetail {
  id: number;
  transaction_id: number;
  agent_id: number;
  agent_name: string;
  role: string;
  role_display: string;
  amount: number;
  percentage: number;
  status: string;
  paid_at?: string;
  created_at: string;
}

// 提现审核列表
export const getWithdrawals = (params?: {
  page?: number;
  pageSize?: number;
  status?: string;
}) => http.get<{ list: IWithdrawal[]; total: number }>('/admin/withdrawals', params);

// 审核提现（通过/拒绝）
export const auditWithdrawal = (id: number, data: { status: 'approved' | 'rejected'; reason?: string }) =>
  http.post(`/admin/withdrawals/${id}/audit`, data);

// ACN交易列表（管理员视角）
export const getACNTransactions = (params?: {
  page?: number;
  pageSize?: number;
  status?: string;
}) => http.get<{ list: IACNTransaction[]; total: number }>('/acn/transactions', params);

// 确认ACN交易
export const confirmACNTransaction = (id: number) =>
  http.post(`/acn/transactions/${id}/confirm`, {});

// 拒绝ACN交易
export const rejectACNTransaction = (id: number, data: { reason: string }) =>
  http.post(`/acn/transactions/${id}/reject`, data);

// 佣金结算明细列表
export const getCommissionDetails = (params?: {
  page?: number;
  pageSize?: number;
  status?: string;
  agent_id?: number;
}) => http.get<{ list: ICommissionDetail[]; total: number }>('/acn/commission-details', params);
