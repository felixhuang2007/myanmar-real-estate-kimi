/**
 * HTTP请求服务封装
 */
import { IApiResponse } from '../types'

// 请求配置
interface RequestConfig {
  url: string
  method?: 'GET' | 'POST' | 'PUT' | 'DELETE' | 'PATCH'
  data?: any
  header?: Record<string, string>
  loading?: boolean
  loadingText?: string
}

// 获取基础URL
function getBaseUrl(): string {
  const app = getApp()
  return app?.globalData?.apiBaseUrl || 'https://api.myanmarhome.com'
}

// 获取Token
function getToken(): string | undefined {
  return wx.getStorageSync('token')
}

/**
 * 统一请求方法
 * @param config 请求配置
 * @returns Promise<T>
 */
export function request<T = any>(config: RequestConfig): Promise<T> {
  return new Promise((resolve, reject) => {
    // 显示加载中
    if (config.loading !== false) {
      wx.showLoading({
        title: config.loadingText || '加载中...',
        mask: true
      })
    }

    const token = getToken()
    const header: Record<string, string> = {
      'Content-Type': 'application/json',
      ...config.header
    }
    
    if (token) {
      header['Authorization'] = `Bearer ${token}`
    }

    wx.request({
      url: `${getBaseUrl()}${config.url}`,
      method: config.method || 'GET',
      data: config.data,
      header,
      timeout: 30000,
      success: (res) => {
        const data = res.data as IApiResponse<T>
        
        if (res.statusCode >= 200 && res.statusCode < 300) {
          if (data.code === 0 || data.code === 200) {
            resolve(data.data)
          } else {
            // 业务错误
            wx.showToast({
              title: data.message || '请求失败',
              icon: 'none'
            })
            reject(new Error(data.message))
          }
        } else if (res.statusCode === 401) {
          // Token过期，清除登录状态
          wx.removeStorageSync('token')
          wx.removeStorageSync('user_info')
          
          wx.showToast({
            title: '登录已过期，请重新登录',
            icon: 'none'
          })
          
          // 跳转到登录页
          setTimeout(() => {
            wx.navigateTo({
              url: '/pages/login/login'
            })
          }, 1500)
          
          reject(new Error('Unauthorized'))
        } else {
          // HTTP错误
          wx.showToast({
            title: `请求失败 (${res.statusCode})`,
            icon: 'none'
          })
          reject(new Error(`HTTP ${res.statusCode}`))
        }
      },
      fail: (err) => {
        wx.showToast({
          title: '网络请求失败',
          icon: 'none'
        })
        reject(err)
      },
      complete: () => {
        if (config.loading !== false) {
          wx.hideLoading()
        }
      }
    })
  })
}

// 便捷方法
export const http = {
  get: <T = any>(url: string, params?: any, config?: Partial<RequestConfig>) => 
    request<T>({ url, method: 'GET', data: params, ...config }),
  
  post: <T = any>(url: string, data?: any, config?: Partial<RequestConfig>) => 
    request<T>({ url, method: 'POST', data, ...config }),
  
  put: <T = any>(url: string, data?: any, config?: Partial<RequestConfig>) => 
    request<T>({ url, method: 'PUT', data, ...config }),
  
  delete: <T = any>(url: string, config?: Partial<RequestConfig>) => 
    request<T>({ url, method: 'DELETE', ...config }),
  
  patch: <T = any>(url: string, data?: any, config?: Partial<RequestConfig>) => 
    request<T>({ url, method: 'PATCH', data, ...config })
}