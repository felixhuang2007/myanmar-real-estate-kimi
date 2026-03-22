/**
 * 经纪人和ACN相关类型定义
 */

// 经纪人信息
export interface IAgent {
  id: string
  userId: string
  name: string
  avatar?: string
  phone: string
  company?: string
  companyCode?: string
  
  // 认证信息
  licenseNumber?: string
  licenseImage?: string
  verifyStatus: 'pending' | 'verified' | 'rejected'
  
  // 评分
  rating: number
  dealCount: number
  reviewCount: number
  
  // 业绩
  monthlyGMV: number
  monthlyDealCount: number
  
  // 角色
  roles: IACNRole[]
  
  // 时间
  joinTime: string
}

// ACN角色
export type ACNRoleType = 
  | 'ENTRANT'      // 房源录入人
  | 'MAINTAINER'   // 房源维护人
  | 'INTRODUCER'   // 客源转介绍
  | 'ACCOMPANIER'  // 带看人
  | 'CLOSER'       // 成交人

// ACN角色定义
export interface IACNRole {
  code: ACNRoleType
  name: string
  commissionRatio: number
}

// ACN成交记录
export interface IACNTransaction {
  id: string
  houseId: string
  houseTitle: string
  
  // 成交信息
  dealPrice: number
  commission: number
  dealDate: string
  
  // 参与方
  participants: {
    role: ACNRoleType
    agentId: string
    agentName: string
    commission: number
    status: 'pending' | 'confirmed' | 'rejected'
  }[]
  
  // 平台服务费
  platformFee: number
  
  // 状态
  status: 'pending_confirm' | 'confirmed' | 'settled' | 'disputed'
  
  // 时间
  createdAt: string
  settledAt?: string
}

// 客户信息
export interface IClient {
  id: string
  name: string
  phone: string
  avatar?: string
  
  // 需求
  budgetMin?: number
  budgetMax?: number
  preferredAreas?: string[]
  houseType?: string
  
  // 来源
  source: 'platform' | 'referral' | 'walk_in'
  introducerId?: string
  
  // 状态
  status: 'new' | 'following' | 'viewing' | 'negotiating' | 'deal' | 'lost'
  
  // 跟进
  lastFollowAt?: string
  followCount: number
  
  // 标签
  tags?: string[]
  
  // 时间
  createdAt: string
  updatedAt: string
}

// 跟进记录
export interface IFollowUp {
  id: string
  clientId: string
  agentId: string
  type: 'phone' | 'wechat' | 'visit' | 'other'
  content: string
  nextFollowDate?: string
  createdAt: string
}