/**
 * Banner相关API
 */
import { http } from './request';

export interface IBanner {
  id: number;
  title: string;
  image_url: string;
  link_url?: string;
  link_type: string; // house/url/none
  link_id?: number;
  position: string; // home/search/detail
  sort_order: number;
  status: string; // active/inactive
  start_at?: string;
  end_at?: string;
  click_count: number;
  created_at: string;
}

export const getBannerList = (params?: { position?: string; status?: string }) =>
  http.get<{ list: IBanner[]; total: number }>('/admin/banners', { params });

export const createBanner = (data: Partial<IBanner>) =>
  http.post<IBanner>('/admin/banners', data);

export const updateBanner = (id: number, data: Partial<IBanner>) =>
  http.put<IBanner>(`/admin/banners/${id}`, data);

export const deleteBanner = (id: number) =>
  http.delete(`/admin/banners/${id}`);

export const updateBannerStatus = (id: number, status: string) =>
  http.put(`/admin/banners/${id}/status`, { status });
