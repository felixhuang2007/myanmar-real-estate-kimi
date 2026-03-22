/**
 * 首页
 */
import { IHouse, IPageData } from '../../types'
import { searchHouses, getRecommendHouses } from '../../services/house'

interface IData {
  banners: IBanner[]
  quickEntries: IQuickEntry[]
  houses: IHouse[]
  isLoading: boolean
  hasMore: boolean
  page: number
  cityCode: string
  cityName: string
}

interface IBanner {
  id: string
  image: string
  linkType: string
  linkValue: string
}

interface IQuickEntry {
  type: string
  icon: string
  name: string
}

Page({
  data: {
    banners: [],
    quickEntries: [
      { type: 'buy', icon: '/assets/icons/buy.png', name: '买房' },
      { type: 'rent', icon: '/assets/icons/rent.png', name: '租房' },
      { type: 'publish', icon: '/assets/icons/publish.png', name: '发布' },
      { type: 'map', icon: '/assets/icons/map-entry.png', name: '地图找房' }
    ],
    houses: [],
    isLoading: false,
    hasMore: true,
    page: 1,
    cityCode: 'yangon',
    cityName: '仰光'
  } as IData,

  onLoad() {
    this.loadBanners()
    this.loadRecommendHouses()
  },

  onShow() {
    // 检查城市变化
    const location = wx.getStorageSync('location')
    if (location && location.cityCode !== this.data.cityCode) {
      this.setData({
        cityCode: location.cityCode,
        cityName: location.city
      })
      this.loadRecommendHouses()
    }
  },

  onPullDownRefresh() {
    this.setData({ page: 1, houses: [] })
    Promise.all([
      this.loadBanners(),
      this.loadRecommendHouses()
    ]).then(() => {
      wx.stopPullDownRefresh()
    })
  },

  onReachBottom() {
    if (this.data.hasMore && !this.data.isLoading) {
      this.loadMoreHouses()
    }
  },

  // 加载Banner
  async loadBanners() {
    // 模拟数据，实际从API获取
    const banners: IBanner[] = [
      { id: '1', image: 'https://example.com/banner1.jpg', linkType: 'search', linkValue: '' },
      { id: '2', image: 'https://example.com/banner2.jpg', linkType: 'house', linkValue: '123' }
    ]
    this.setData({ banners })
  },

  // 加载推荐房源
  async loadRecommendHouses() {
    this.setData({ isLoading: true })
    try {
      const result = await searchHouses({
        transactionType: 'sale',
        cityCode: this.data.cityCode,
        sortBy: 'default'
      }, 1, 20)
      
      this.setData({
        houses: result.list,
        hasMore: result.hasMore,
        page: 1
      })
    } catch (error) {
      console.error('加载房源失败', error)
    } finally {
      this.setData({ isLoading: false })
    }
  },

  // 加载更多
  async loadMoreHouses() {
    if (!this.data.hasMore) return
    
    this.setData({ isLoading: true })
    try {
      const nextPage = this.data.page + 1
      const result = await searchHouses({
        transactionType: 'sale',
        cityCode: this.data.cityCode,
        sortBy: 'default'
      }, nextPage, 20)
      
      this.setData({
        houses: [...this.data.houses, ...result.list],
        hasMore: result.hasMore,
        page: nextPage
      })
    } catch (error) {
      console.error('加载更多房源失败', error)
    } finally {
      this.setData({ isLoading: false })
    }
  },

  // 点击搜索框
  onSearchTap() {
    wx.navigateTo({
      url: '/pages/search/search'
    })
  },

  // 点击城市
  onCityTap() {
    // 显示城市选择器或跳转到城市选择页
    wx.showActionSheet({
      itemList: ['仰光', '曼德勒', '内比都'],
      success: (res) => {
        const cities = [
          { code: 'yangon', name: '仰光' },
          { code: 'mandalay', name: '曼德勒' },
          { code: 'naypyidaw', name: '内比都' }
        ]
        this.setData({
          cityCode: cities[res.tapIndex].code,
          cityName: cities[res.tapIndex].name
        })
        this.loadRecommendHouses()
      }
    })
  },

  // 点击快捷入口
  onQuickEntryTap(e: WechatMiniprogram.TouchEvent) {
    const { type } = e.currentTarget.dataset
    switch (type) {
      case 'buy':
        wx.navigateTo({
          url: '/pages/search/search?type=sale'
        })
        break
      case 'rent':
        wx.navigateTo({
          url: '/pages/search/search?type=rent'
        })
        break
      case 'publish':
        wx.navigateTo({
          url: '/pages/house-publish/house-publish'
        })
        break
      case 'map':
        wx.switchTab({
          url: '/pages/map/map'
        })
        break
    }
  },

  // 点击Banner
  onBannerTap(e: WechatMiniprogram.TouchEvent) {
    const { banner } = e.currentTarget.dataset as { banner: IBanner }
    switch (banner.linkType) {
      case 'house':
        wx.navigateTo({
          url: `/pages/detail/detail?id=${banner.linkValue}`
        })
        break
      case 'search':
        wx.navigateTo({
          url: '/pages/search/search'
        })
        break
    }
  },

  // 点击房源
  onHouseTap(e: WechatMiniprogram.TouchEvent) {
    const { id } = e.currentTarget.dataset
    wx.navigateTo({
      url: `/pages/detail/detail?id=${id}`
    })
  }
})