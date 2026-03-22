/**
 * 缅甸房产平台小程序 - 应用入口
 * Myanmar Home Mini Program App Entry
 */
import { IAppOption } from './types/app'
import { userStore } from './stores/user'
import { systemStore } from './stores/system'

App<IAppOption>({
  globalData: {
    userInfo: null,
    systemInfo: null,
    locationInfo: null,
    apiBaseUrl: '',
    imConfig: null
  },

  onLaunch(options) {
    console.log('App onLaunch', options)
    this.initSystem()
    this.initUser()
  },

  onShow(options) {
    console.log('App onShow', options)
  },

  onHide() {
    console.log('App onHide')
  },

  onError(msg) {
    console.error('App onError', msg)
  },

  // 初始化系统信息
  initSystem() {
    const systemInfo = wx.getSystemInfoSync()
    this.globalData.systemInfo = systemInfo
    systemStore.setSystemInfo(systemInfo)
    
    // 设置API基础URL（根据环境切换）
    const env = systemInfo.env?.VERSION || 'develop'
    this.globalData.apiBaseUrl = env === 'release' 
      ? 'https://api.myanmarhome.com'
      : 'https://dev-api.myanmarhome.com'
  },

  // 初始化用户信息
  initUser() {
    const token = wx.getStorageSync('token')
    if (token) {
      userStore.setToken(token)
      this.fetchUserInfo()
    }
  },

  // 获取用户信息
  async fetchUserInfo() {
    try {
      const userInfo = await userStore.fetchUserInfo()
      this.globalData.userInfo = userInfo
    } catch (error) {
      console.error('获取用户信息失败', error)
    }
  },

  // 全局分享配置
  onShareAppMessage() {
    return {
      title: '缅甸房产平台 - 真实房源，透明价格',
      path: '/pages/index/index',
      imageUrl: '/assets/images/share-default.png'
    }
  }
})