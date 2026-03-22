/**
 * 经纪人相关API
 */
import { http } from './request';

export interface IAgent {
  id: number;
  name: string;
  phone: string;
  avatar?: string;
  license_number?: string;
  agency_name?: string;
  status: string; // active/inactive/pending/rejected
  verified: boolean;
  house_count: number;
  deal_count: number;
  created_at: string;
}

export const getAgentList = (params: {
  status?: string;
  search?: string;
  page?: number;
  pageSize?: number;
}) => http.get<{ list: IAgent[]; total: number }>('/admin/agents', { params });

export const auditAgent = (id: number, data: { status: string; reason?: string }) =>
  http.post(`/admin/agents/${id}/audit`, data);

export const getAgentDetail = (id: number) =>
  http.get<IAgent>(`/admin/agents/${id}`);
