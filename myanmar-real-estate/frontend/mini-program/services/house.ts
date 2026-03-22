/**
 * 房源相关API服务
 */
import { http } from './request'
import { IHouse, IHouseSearchFilters, IPageData, IMapCluster } from '../types'

/**
 * 搜索房源
 * @param filters 筛选条件
 * @param page 页码
 * @param pageSize 每页数量
 */
export function searchHouses(
  filters: IHouseSearchFilters,
  page: number = 1,
  pageSize: number = 20
): Promise<IPageData<IHouse>> {
  return http.get('/houses/search', {
    ...filters,
    page,
    pageSize
  })
}

/**
 * 获取房源详情
 * @param id 房源ID
 */
export function getHouseDetail(id: string): Promise<IHouse> {
  return http.get(`/houses/${id}`)
}

/**
 * 获取推荐房源
 * @param cityCode 城市代码
 * @param limit 数量
 */
export function getRecommendHouses(cityCode: string, limit: number = 10): Promise<IHouse[]> {
  return http.get('/houses/recommend', { cityCode, limit })
}

/**
 * 获取地图聚合数据
 * @param bounds 边界
 * @param zoom 缩放级别
 * @param filters 筛选条件
 */
export function getMapClusters(
  bounds: {
    swLat: number
    swLng: number
    neLat: number
    neLng: number
  },
  zoom: number,
  filters?: IHouseSearchFilters
): Promise<{
  level: number
  clusters: IMapCluster[]
  houses?: IHouse[]
}> {
  return http.post('/houses/map/clusters', {
    bounds,
    zoom,
    filters
  })
}

/**
 * 收藏房源
 * @param houseId 房源ID
 */
export function favoriteHouse(houseId: string): Promise<void> {
  return http.post(`/houses/${houseId}/favorite`)
}

/**
 * 取消收藏
 * @param houseId 房源ID
 */
export function unfavoriteHouse(houseId: string): Promise<void> {
  return http.delete(`/houses/${houseId}/favorite`)
}

/**
 * 获取收藏列表
 * @param page 页码
 * @param pageSize 每页数量
 */
export function getFavoriteHouses(page: number = 1, pageSize: number = 20): Promise<IPageData<IHouse>> {
  return http.get('/houses/favorites', { page, pageSize })
}

/**
 * 发布房源（房东/经纪人）
 * @param data 房源数据
 */
export function publishHouse(data: Partial<IHouse>): Promise<{ houseId: string }> {
  return http.post('/houses', data, { loadingText: '发布中...' })
}

/**
 * 更新房源
 * @param id 房源ID
 * @param data 房源数据
 */
export function updateHouse(id: string, data: Partial<IHouse>): Promise<void> {
  return http.put(`/houses/${id}`, data)
}

/**
 * 获取我的房源列表
 * @param page 页码
 * @param pageSize 每页数量
 */
export function getMyHouses(page: number = 1, pageSize: number = 20): Promise<IPageData<IHouse>> {
  return http.get('/houses/my', { page, pageSize })
}