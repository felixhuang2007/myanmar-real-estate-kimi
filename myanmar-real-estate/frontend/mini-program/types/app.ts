/**
 * 全局应用类型定义
 */

// 应用选项接口
export interface IAppOption {
  globalData: {
    userInfo: IUserInfo | null
    systemInfo: WechatMiniprogram.SystemInfo | null
    locationInfo: ILocationInfo | null
    apiBaseUrl: string
    imConfig: IIMConfig | null
  }
  
  // 方法
  initSystem(): void
  initUser(): void
  fetchUserInfo(): Promise<void>
}

// 用户信息
export interface IUserInfo {
  id: string
  phone: string
  nickname?: string
  avatar?: string
  realName?: string
  idCardNumber?: string
  identityStatus: 'unverified' | 'pending' | 'verified' | 'rejected'
  userType: 'buyer' | 'seller' | 'agent' | 'admin'
  createdAt: string
}

// 位置信息
export interface ILocationInfo {
  latitude: number
  longitude: number
  city: string
  cityCode: string
  district?: string
  districtCode?: string
  address?: string
}

// IM配置
export interface IIMConfig {
  appKey: string
  apiUrl: string
}

// 通用响应格式
export interface IApiResponse<T = any> {
  code: number
  message: string
  data: T
  timestamp: number
}

// 分页请求参数
export interface IPageParams {
  page?: number
  pageSize?: number
}

// 分页响应数据
export interface IPageData<T> {
  list: T[]
  total: number
  page: number
  pageSize: number
  hasMore: boolean
}