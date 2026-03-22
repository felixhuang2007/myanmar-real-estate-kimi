/**
 * 系统状态管理
 */
import { ILocationInfo } from '../types'

interface SystemState {
  systemInfo: WechatMiniprogram.SystemInfo | null
  locationInfo: ILocationInfo | null
  networkType: string
  isConnected: boolean
}

interface SystemStore {
  state: SystemState
  setSystemInfo(info: WechatMiniprogram.SystemInfo): void
  setLocationInfo(info: ILocationInfo): void
  setNetworkStatus(type: string, isConnected: boolean): void
}

const systemStore: SystemStore = {
  state: {
    systemInfo: null,
    locationInfo: null,
    networkType: 'unknown',
    isConnected: true
  },

  setSystemInfo(info: WechatMiniprogram.SystemInfo) {
    this.state.systemInfo = info
  },

  setLocationInfo(info: ILocationInfo) {
    this.state.locationInfo = info
    wx.setStorageSync('location', info)
  },

  setNetworkStatus(type: string, isConnected: boolean) {
    this.state.networkType = type
    this.state.isConnected = isConnected
  }
}

export { systemStore }