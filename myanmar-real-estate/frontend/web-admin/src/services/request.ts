/**
 * HTTP请求服务封装
 */
import axios, { AxiosInstance, AxiosRequestConfig, AxiosResponse } from 'axios';
import { IApiResponse } from '@/types';
import { message } from 'antd';

// 创建axios实例
const request: AxiosInstance = axios.create({
  baseURL: '/api',
  timeout: 30000,
  headers: {
    'Content-Type': 'application/json',
  },
});

// 请求拦截器
request.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// 响应拦截器
request.interceptors.response.use(
  (response: AxiosResponse<IApiResponse>) => {
    const { data } = response;
    
    if (data.code === 0 || data.code === 200) {
      return data.data;
    }
    
    // 业务错误
    message.error(data.message || '请求失败');
    return Promise.reject(new Error(data.message));
  },
  (error) => {
    if (error.response) {
      const { status, data } = error.response;
      
      switch (status) {
        case 401:
          message.error('登录已过期，请重新登录');
          localStorage.removeItem('token');
          localStorage.removeItem('user');
          window.location.href = '/login';
          break;
        case 403:
          message.error('没有权限执行此操作');
          break;
        case 404:
          message.error('请求的资源不存在');
          break;
        case 500:
          message.error('服务器错误，请稍后重试');
          break;
        default:
          message.error(data?.message || `请求失败 (${status})`);
      }
    } else {
      message.error('网络请求失败，请检查网络连接');
    }
    
    return Promise.reject(error);
  }
);

export default request;

// 便捷方法
export const http = {
  get: <T = any>(url: string, params?: any, config?: AxiosRequestConfig) => 
    request.get(url, { params, ...config }) as Promise<T>,
  
  post: <T = any>(url: string, data?: any, config?: AxiosRequestConfig) => 
    request.post(url, data, config) as Promise<T>,
  
  put: <T = any>(url: string, data?: any, config?: AxiosRequestConfig) => 
    request.put(url, data, config) as Promise<T>,
  
  delete: <T = any>(url: string, config?: AxiosRequestConfig) => 
    request.delete(url, config) as Promise<T>,
  
  patch: <T = any>(url: string, data?: any, config?: AxiosRequestConfig) => 
    request.patch(url, data, config) as Promise<T>,
};