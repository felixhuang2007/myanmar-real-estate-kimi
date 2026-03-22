/**
 * 登录页
 */
import { sendVerifyCode, loginByPhone } from '../../services/user'

interface IData {
  phone: string
  verifyCode: string
  countdown: number
  isSending: boolean
  isLoading: boolean
}

Page({
  data: {
    phone: '',
    verifyCode: '',
    countdown: 0,
    isSending: false,
    isLoading: false
  } as IData,

  // 输入手机号
  onPhoneInput(e: WechatMiniprogram.InputEvent) {
    this.setData({ phone: e.detail.value })
  },

  // 输入验证码
  onCodeInput(e: WechatMiniprogram.InputEvent) {
    this.setData({ verifyCode: e.detail.value })
  },

  // 发送验证码
  async sendCode() {
    if (this.data.countdown > 0 || this.data.isSending) return
    
    const phone = this.data.phone.trim()
    if (!phone) {
      wx.showToast({ title: '请输入手机号', icon: 'none' })
      return
    }
    
    // 验证缅甸手机号格式
    const pattern = /^(\+95|0)9\d{8,9}$/
    if (!pattern.test(phone.replace(/\s/g, ''))) {
      wx.showToast({ title: '请输入有效的缅甸手机号', icon: 'none' })
      return
    }
    
    this.setData({ isSending: true })
    
    try {
      await sendVerifyCode(phone)
      wx.showToast({ title: '验证码已发送', icon: 'success' })
      
      // 开始倒计时
      this.setData({ countdown: 60 })
      const timer = setInterval(() => {
        if (this.data.countdown <= 1) {
          clearInterval(timer)
          this.setData({ countdown: 0, isSending: false })
        } else {
          this.setData({ countdown: this.data.countdown - 1 })
        }
      }, 1000)
    } catch (error) {
      wx.showToast({ title: '发送失败，请重试', icon: 'none' })
      this.setData({ isSending: false })
    }
  },

  // 登录
  async login() {
    const phone = this.data.phone.trim()
    const code = this.data.verifyCode.trim()
    
    if (!phone) {
      wx.showToast({ title: '请输入手机号', icon: 'none' })
      return
    }
    if (!code) {
      wx.showToast({ title: '请输入验证码', icon: 'none' })
      return
    }
    
    this.setData({ isLoading: true })
    
    try {
      const result = await loginByPhone(phone, code)
      
      // 保存登录态
      wx.setStorageSync('token', result.token)
      wx.setStorageSync('user_info', result.userInfo)
      
      wx.showToast({ title: '登录成功', icon: 'success' })
      
      // 返回上一页或跳转到首页
      setTimeout(() => {
        const pages = getCurrentPages()
        if (pages.length > 1) {
          wx.navigateBack()
        } else {
          wx.switchTab({ url: '/pages/index/index' })
        }
      }, 1500)
    } catch (error) {
      wx.showToast({ title: '登录失败，请重试', icon: 'none' })
    } finally {
      this.setData({ isLoading: false })
    }
  }
})