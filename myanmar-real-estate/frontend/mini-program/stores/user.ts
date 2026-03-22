/**
 * 用户状态管理
 */
import { IUserInfo } from '../types'

interface UserState {
  token: string | null
  userInfo: IUserInfo | null
  isLogin: boolean
  isLoading: boolean
}

interface UserStore {
  state: UserState
  setToken(token: string): void
  setUserInfo(userInfo: IUserInfo): void
  clearUser(): void
  fetchUserInfo(): Promise<IUserInfo>
}

// 简单的状态管理实现
const userStore: UserStore = {
  state: {
    token: null,
    userInfo: null,
    isLogin: false,
    isLoading: false
  },

  setToken(token: string) {
    this.state.token = token
    this.state.isLogin = !!token
    wx.setStorageSync('token', token)
  },

  setUserInfo(userInfo: IUserInfo) {
    this.state.userInfo = userInfo
    wx.setStorageSync('user_info', userInfo)
  },

  clearUser() {
    this.state.token = null
    this.state.userInfo = null
    this.state.isLogin = false
    wx.removeStorageSync('token')
    wx.removeStorageSync('user_info')
  },

  async fetchUserInfo(): Promise<IUserInfo> {
    const { http } = require('../services')
    const userInfo = await http.get('/user/info')
    this.setUserInfo(userInfo)
    return userInfo
  }
}

export { userStore }