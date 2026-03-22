/**
 * 房源搜索页
 */
import { IHouse, IHouseSearchFilters } from '../../types'
import { searchHouses } from '../../services/house'

interface IData extends IHouseSearchFilters {
  houses: IHouse[]
  isLoading: boolean
  hasMore: boolean
  page: number
  showFilter: boolean
  historyKeywords: string[]
}

Page({
  data: {
    transactionType: 'sale' as const,
    cityCode: 'yangon',
    districtCode: '',
    priceMin: undefined,
    priceMax: undefined,
    areaMin: undefined,
    areaMax: undefined,
    roomCount: '',
    houseType: undefined,
    keywords: '',
    sortBy: 'default',
    
    houses: [],
    isLoading: false,
    hasMore: true,
    page: 1,
    showFilter: false,
    historyKeywords: []
  } as IData,

  onLoad(options: { type?: string; keywords?: string }) {
    if (options.type) {
      this.setData({ transactionType: options.type as any })
    }
    if (options.keywords) {
      this.setData({ keywords: options.keywords })
    }
    
    // 加载搜索历史
    const history = wx.getStorageSync('searchHistory') || []
    this.setData({ historyKeywords: history })
    
    this.searchHouses()
  },

  onPullDownRefresh() {
    this.setData({ page: 1, houses: [] })
    this.searchHouses().then(() => {
      wx.stopPullDownRefresh()
    })
  },

  onReachBottom() {
    if (this.data.hasMore && !this.data.isLoading) {
      this.loadMore()
    }
  },

  // 搜索房源
  async searchHouses() {
    this.setData({ isLoading: true })
    try {
      const filters: IHouseSearchFilters = {
        transactionType: this.data.transactionType,
        cityCode: this.data.cityCode,
        districtCode: this.data.districtCode || undefined,
        priceMin: this.data.priceMin,
        priceMax: this.data.priceMax,
        areaMin: this.data.areaMin,
        areaMax: this.data.areaMax,
        roomCount: this.data.roomCount || undefined,
        houseType: this.data.houseType,
        keywords: this.data.keywords || undefined,
        sortBy: this.data.sortBy as any
      }
      
      const result = await searchHouses(filters, 1, 20)
      this.setData({
        houses: result.list,
        hasMore: result.hasMore,
        page: 1
      })
    } catch (error) {
      console.error('搜索失败', error)
    } finally {
      this.setData({ isLoading: false })
    }
  },

  // 加载更多
  async loadMore() {
    const nextPage = this.data.page + 1
    this.setData({ isLoading: true })
    
    try {
      const filters: IHouseSearchFilters = {
        transactionType: this.data.transactionType,
        cityCode: this.data.cityCode,
        keywords: this.data.keywords || undefined,
        sortBy: this.data.sortBy as any
      }
      
      const result = await searchHouses(filters, nextPage, 20)
      this.setData({
        houses: [...this.data.houses, ...result.list],
        hasMore: result.hasMore,
        page: nextPage
      })
    } catch (error) {
      console.error('加载更多失败', error)
    } finally {
      this.setData({ isLoading: false })
    }
  },

  // 输入关键词
  onKeywordInput(e: WechatMiniprogram.InputEvent) {
    this.setData({ keywords: e.detail.value })
  },

  // 确认搜索
  onSearchConfirm() {
    // 保存搜索历史
    if (this.data.keywords) {
      const history = [this.data.keywords, ...this.data.historyKeywords.filter(h => h !== this.data.keywords)].slice(0, 10)
      wx.setStorageSync('searchHistory', history)
      this.setData({ historyKeywords: history })
    }
    
    this.setData({ page: 1, houses: [] })
    this.searchHouses()
  },

  // 点击历史关键词
  onHistoryTap(e: WechatMiniprogram.TouchEvent) {
    const { keyword } = e.currentTarget.dataset
    this.setData({ keywords: keyword })
    this.onSearchConfirm()
  },

  // 清除历史
  clearHistory() {
    wx.removeStorageSync('searchHistory')
    this.setData({ historyKeywords: [] })
  },

  // 切换交易类型
  switchTransactionType(e: WechatMiniprogram.TouchEvent) {
    const { type } = e.currentTarget.dataset
    this.setData({ transactionType: type, page: 1, houses: [] })
    this.searchHouses()
  },

  // 显示/隐藏筛选
  toggleFilter() {
    this.setData({ showFilter: !this.data.showFilter })
  },

  // 选择区域
  selectDistrict(e: WechatMiniprogram.TouchEvent) {
    const { code } = e.currentTarget.dataset
    this.setData({ 
      districtCode: this.data.districtCode === code ? '' : code 
    })
  },

  // 选择价格
  selectPrice(e: WechatMiniprogram.TouchEvent) {
    const { min, max } = e.currentTarget.dataset
    this.setData({ 
      priceMin: min,
      priceMax: max 
    })
  },

  // 选择户型
  selectRoom(e: WechatMiniprogram.TouchEvent) {
    const { count } = e.currentTarget.dataset
    this.setData({ 
      roomCount: this.data.roomCount === count ? '' : count 
    })
  },

  // 重置筛选
  resetFilter() {
    this.setData({
      districtCode: '',
      priceMin: undefined,
      priceMax: undefined,
      areaMin: undefined,
      areaMax: undefined,
      roomCount: '',
      houseType: undefined
    })
  },

  // 确认筛选
  confirmFilter() {
    this.setData({ showFilter: false, page: 1, houses: [] })
    this.searchHouses()
  },

  // 切换排序
  changeSort(e: WechatMiniprogram.TouchEvent) {
    const { sort } = e.currentTarget.dataset
    this.setData({ sortBy: sort, page: 1, houses: [] })
    this.searchHouses()
  },

  // 点击房源
  onHouseTap(e: WechatMiniprogram.TouchEvent) {
    const { id } = e.currentTarget.dataset
    wx.navigateTo({
      url: `/pages/detail/detail?id=${id}`
    })
  }
})