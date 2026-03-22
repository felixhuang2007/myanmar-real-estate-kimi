/**
 * 用户相关API服务
 */
import { http } from './request'
import { IUserInfo, IApiResponse } from '../types'

/**
 * 发送验证码
 * @param phone 手机号
 */
export function sendVerifyCode(phone: string): Promise<void> {
  return http.post('/auth/send-code', { phone })
}

/**
 * 手机号登录
 * @param phone 手机号
 * @param code 验证码
 */
export function loginByPhone(phone: string, code: string): Promise<{ token: string; userInfo: IUserInfo }> {
  return http.post('/auth/login/phone', { phone, code })
}

/**
 * 获取用户信息
 */
export function getUserInfo(): Promise<IUserInfo> {
  return http.get('/user/info')
}

/**
 * 更新用户信息
 * @param data 用户信息
 */
export function updateUserInfo(data: Partial<IUserInfo>): Promise<IUserInfo> {
  return http.put('/user/info', data)
}

/**
 * 实名认证
 * @param data 认证信息
 */
export function verifyIdentity(data: {
  realName: string
  idCardNumber: string
  idCardFront: string
  idCardBack?: string
}): Promise<{ verifyId: string; status: string }> {
  return http.post('/user/verify', data)
}

/**
 * 上传头像
 * @param filePath 文件路径
 */
export function uploadAvatar(filePath: string): Promise<{ url: string }> {
  return new Promise((resolve, reject) => {
    const token = wx.getStorageSync('token')
    wx.uploadFile({
      url: `${getApp().globalData.apiBaseUrl}/user/avatar`,
      filePath,
      name: 'file',
      header: {
        'Authorization': `Bearer ${token}`
      },
      success: (res) => {
        const data = JSON.parse(res.data)
        if (data.code === 0) {
          resolve(data.data)
        } else {
          reject(new Error(data.message))
        }
      },
      fail: reject
    })
  })
}