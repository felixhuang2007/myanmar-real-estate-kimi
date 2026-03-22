/**
 * 全局类型定义
 */

// 用户类型
export type UserType = 'admin' | 'operator' | 'viewer';

// 用户状态
export interface IUser {
  id: string;
  username: string;
  nickname: string;
  avatar?: string;
  phone: string;
  email?: string;
  role: UserType;
  permissions: string[];
  status: 'active' | 'inactive';
  lastLoginAt?: string;
  createdAt: string;
}

// 登录响应
export interface ILoginResponse {
  token: string;
  user: IUser;
}

// API 响应格式
export interface IApiResponse<T = any> {
  code: number;
  message: string;
  data: T;
  timestamp: number;
}

// 分页请求参数
export interface IPageParams {
  current?: number;
  pageSize?: number;
}

// 分页响应数据
export interface IPageData<T> {
  list: T[];
  total: number;
  current: number;
  pageSize: number;
}

// 房源类型
export interface IHouse {
  id: string;
  title: string;
  transactionType: 'sale' | 'rent';
  houseType: string;
  price: number;
  priceUnit: string;
  area: number;
  rooms: string;
  city: string;
  district: string;
  address: string;
  images: string[];
  verificationStatus: 'unverified' | 'pending' | 'verified' | 'failed';
  status: 'active' | 'inactive' | 'sold' | 'rented';
  viewCount: number;
  favoriteCount: number;
  publishTime: string;
  agent?: IAgentBrief;
  owner?: IOwnerBrief;
}

export interface IAgentBrief {
  id: string;
  name: string;
  avatar?: string;
  company?: string;
  phone?: string;
}

export interface IOwnerBrief {
  id: string;
  name: string;
  phone?: string;
}

// 经纪人类型
export interface IAgent {
  id: string;
  userId: string;
  name: string;
  avatar?: string;
  phone: string;
  company?: string;
  licenseNumber?: string;
  verifyStatus: 'pending' | 'verified' | 'rejected';
  rating: number;
  dealCount: number;
  monthlyGMV: number;
  monthlyDealCount: number;
  status: 'active' | 'inactive';
  joinTime: string;
}

// C端用户类型
export interface IEndUser {
  id: string;
  phone: string;
  nickname?: string;
  avatar?: string;
  realName?: string;
  identityStatus: 'unverified' | 'pending' | 'verified' | 'rejected';
  favoriteCount: number;
  appointmentCount: number;
  createdAt: string;
}

// 统计数据类型
export interface IDashboardStats {
  // 用户数据
  totalUsers: number;
  todayNewUsers: number;
  activeUsers: number;
  
  // 房源数据
  totalHouses: number;
  todayNewHouses: number;
  verifiedHouses: number;
  
  // 交易数据
  todayAppointments: number;
  monthAppointments: number;
  monthDeals: number;
  monthGMV: number;
  
  // 经纪人数据
  totalAgents: number;
  activeAgents: number;
  todayNewAgents: number;
}

// 趋势数据
export interface ITrendData {
  date: string;
  value: number;
}