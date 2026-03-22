/**
 * 房源相关类型定义
 */

// 交易类型
export type TransactionType = 'sale' | 'rent'

// 房源类型
export type HouseType = 'apartment' | 'house' | 'townhouse' | 'land' | 'commercial'

// 装修类型
export type DecorationType = 'rough' | 'simple' | 'fine' | 'luxury'

// 朝向
export type Orientation = 'east' | 'south' | 'west' | 'north' | 'southeast' | 'southwest' | 'northeast' | 'northwest'

// 产权类型（缅甸特殊）
export type PropertyType = 'grant' | 'license' | 'contract' | 'other'

// 验真状态
export type VerificationStatus = 'unverified' | 'pending' | 'verified' | 'failed'

// 房源基础信息
export interface IHouse {
  id: string
  title: string
  transactionType: TransactionType
  houseType: HouseType
  price: number
  priceUnit: string
  area: number
  rooms: string
  floor?: string
  totalFloors?: number
  decoration?: DecorationType
  orientation?: Orientation
  buildYear?: number
  
  // 位置
  city: string
  cityCode: string
  district: string
  districtCode: string
  community?: string
  address: string
  latitude?: number
  longitude?: number
  
  // 描述
  description?: string
  highlights?: string[]
  facilities?: string[]
  images: string[]
  video?: string
  
  // 产权
  propertyType?: PropertyType
  ownership?: string
  hasLoan?: boolean
  
  // 验真
  verificationStatus: VerificationStatus
  verifiedAt?: string
  
  // 标签
  tags: string[]
  
  // 统计
  viewCount: number
  favoriteCount: number
  
  // 时间
  publishTime: string
  status: 'active' | 'inactive' | 'sold' | 'rented'
  
  // 经纪人/房东信息
  agent?: IAgentBrief
  owner?: IOwnerBrief
}

// 经纪人简要信息
export interface IAgentBrief {
  id: string
  name: string
  avatar?: string
  company?: string
  rating: number
  dealCount: number
  phone?: string
}

// 房东简要信息
export interface IOwnerBrief {
  id: string
  name: string
  phone?: string
}

// 房源搜索筛选条件
export interface IHouseSearchFilters {
  transactionType?: TransactionType
  cityCode?: string
  districtCode?: string
  community?: string
  priceMin?: number
  priceMax?: number
  areaMin?: number
  areaMax?: number
  roomCount?: string
  houseType?: HouseType
  decoration?: DecorationType
  floor?: string
  orientation?: Orientation
  verificationStatus?: VerificationStatus
  keywords?: string
  sortBy?: 'default' | 'price_asc' | 'price_desc' | 'date' | 'area_desc'
}

// 地图聚合数据
export interface IMapCluster {
  id: string
  name: string
  latitude: number
  longitude: number
  avgPrice: number
  totalCount: number
  bounds: {
    swLat: number
    swLng: number
    neLat: number
    neLng: number
  }
}