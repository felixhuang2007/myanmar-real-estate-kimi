/**
 * HTTP请求服务封装 - 修复版本
 * 修复内容: 添加XSS防护和敏感信息过滤
 */
import axios, { AxiosInstance, AxiosRequestConfig, AxiosResponse } from 'axios';
import DOMPurify from 'dompurify';
import { IApiResponse } from '@/types';
import { message } from 'antd';

// 创建axios实例
const request: AxiosInstance = axios.create({
  baseURL: '/api',
  timeout: 30000,
  headers: {
    'Content-Type': 'application/json',
    'X-Requested-With': 'XMLHttpRequest',
  },
});

// 请求拦截器
request.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    
    // 添加请求ID用于追踪
    config.headers['X-Request-ID'] = generateRequestId();
    
    return config;
  },
  (error) => {
    // 记录错误但不暴露敏感信息
    logError('Request Error', error);
    return Promise.reject(error);
  }
);

// 响应拦截器
request.interceptors.response.use(
  (response: AxiosResponse<IApiResponse>) => {
    const { data } = response;
    
    if (data.code === 0 || data.code === 200) {
      // 对返回数据进行XSS过滤
      const sanitizedData = sanitizeResponse(data.data);
      return sanitizedData;
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
    
    // 记录错误到监控服务（不包含敏感信息）
    logError('Response Error', {
      status: error.response?.status,
      message: error.message,
      url: error.config?.url,
    });
    
    return Promise.reject(error);
  }
);

/**
 * XSS消毒处理
 * 递归处理响应数据中的所有字符串
 */
function sanitizeResponse(data: any): any {
  if (data === null || data === undefined) {
    return data;
  }
  
  if (typeof data === 'string') {
    return DOMPurify.sanitize(data, {
      ALLOWED_TAGS: [], // 不允许任何HTML标签
      ALLOWED_ATTR: [], // 不允许任何属性
    });
  }
  
  if (Array.isArray(data)) {
    return data.map(sanitizeResponse);
  }
  
  if (typeof data === 'object') {
    const sanitized: any = {};
    for (const [key, value] of Object.entries(data)) {
      sanitized[key] = sanitizeResponse(value);
    }
    return sanitized;
  }
  
  return data;
}

/**
 * 生成请求ID
 */
function generateRequestId(): string {
  return `${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
}

/**
 * 错误日志记录（安全版本）
 * 过滤掉敏感信息如token、password等
 */
function logError(type: string, error: any): void {
  const sensitiveKeys = ['token', 'password', 'secret', 'key', 'auth', 'credential'];
  
  function filterSensitive(obj: any): any {
    if (typeof obj !== 'object' || obj === null) {
      return obj;
    }
    
    const filtered: any = {};
    for (const [key, value] of Object.entries(obj)) {
      const lowerKey = key.toLowerCase();
      if (sensitiveKeys.some(sk => lowerKey.includes(sk))) {
        filtered[key] = '***REDACTED***';
      } else if (typeof value === 'object') {
        filtered[key] = filterSensitive(value);
      } else {
        filtered[key] = value;
      }
    }
    return filtered;
  }
  
  // 发送到错误追踪服务
  if (window.errorTracker) {
    window.errorTracker.captureException(error, {
      tags: { type },
      extra: filterSensitive(error),
    });
  }
  
  // 控制台只输出类型，不输出详情
  console.error(`[${type}] 发生错误，详情已发送到监控系统`);
}

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

// 扩展Window接口
declare global {
  interface Window {
    errorTracker?: {
      captureException: (error: any, context?: any) => void;
    };
  }
}
