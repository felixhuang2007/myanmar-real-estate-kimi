/**
 * 通用工具函数
 */

/**
 * 格式化价格显示
 * @param price 价格（万缅币）
 * @param unit 单位
 * @returns 格式化后的价格字符串
 */
export function formatPrice(price: number, unit: string = '万缅币'): string {
  if (price >= 10000) {
    return `${(price / 10000).toFixed(1)}亿${unit}`
  }
  return `${price}${unit}`
}

/**
 * 格式化面积显示
 * @param area 面积（平米）
 * @returns 格式化后的面积字符串
 */
export function formatArea(area: number): string {
  return `${area}m²`
}

/**
 * 格式化日期
 * @param date 日期字符串或时间戳
 * @param format 格式模板
 * @returns 格式化后的日期字符串
 */
export function formatDate(date: string | number | Date, format: string = 'YYYY-MM-DD'): string {
  const d = new Date(date)
  const year = d.getFullYear()
  const month = String(d.getMonth() + 1).padStart(2, '0')
  const day = String(d.getDate()).padStart(2, '0')
  const hour = String(d.getHours()).padStart(2, '0')
  const minute = String(d.getMinutes()).padStart(2, '0')
  
  return format
    .replace('YYYY', String(year))
    .replace('MM', month)
    .replace('DD', day)
    .replace('HH', hour)
    .replace('mm', minute)
}

/**
 * 格式化相对时间
 * @param date 日期字符串或时间戳
 * @returns 相对时间字符串
 */
export function formatRelativeTime(date: string | number | Date): string {
  const now = new Date().getTime()
  const target = new Date(date).getTime()
  const diff = now - target
  
  const minute = 60 * 1000
  const hour = 60 * minute
  const day = 24 * hour
  const week = 7 * day
  const month = 30 * day
  
  if (diff < minute) {
    return '刚刚'
  } else if (diff < hour) {
    return `${Math.floor(diff / minute)}分钟前`
  } else if (diff < day) {
    return `${Math.floor(diff / hour)}小时前`
  } else if (diff < week) {
    return `${Math.floor(diff / day)}天前`
  } else if (diff < month) {
    return `${Math.floor(diff / week)}周前`
  } else {
    return formatDate(date)
  }
}

/**
 * 防抖函数
 * @param fn 要执行的函数
 * @param delay 延迟时间（毫秒）
 * @returns 防抖后的函数
 */
export function debounce<T extends (...args: any[]) => any>(
  fn: T,
  delay: number = 300
): (...args: Parameters<T>) => void {
  let timer: ReturnType<typeof setTimeout> | null = null
  
  return function (...args: Parameters<T>) {
    if (timer) clearTimeout(timer)
    timer = setTimeout(() => {
      fn.apply(null, args)
    }, delay)
  }
}

/**
 * 节流函数
 * @param fn 要执行的函数
 * @param interval 间隔时间（毫秒）
 * @returns 节流后的函数
 */
export function throttle<T extends (...args: any[]) => any>(
  fn: T,
  interval: number = 300
): (...args: Parameters<T>) => void {
  let lastTime = 0
  
  return function (...args: Parameters<T>) {
    const now = Date.now()
    if (now - lastTime >= interval) {
      lastTime = now
      fn.apply(null, args)
    }
  }
}

/**
 * 深拷贝
 * @param obj 要拷贝的对象
 * @returns 拷贝后的对象
 */
export function deepClone<T>(obj: T): T {
  if (obj === null || typeof obj !== 'object') {
    return obj
  }
  
  if (obj instanceof Date) {
    return new Date(obj.getTime()) as unknown as T
  }
  
  if (Array.isArray(obj)) {
    return obj.map(item => deepClone(item)) as unknown as T
  }
  
  const cloned = {} as T
  for (const key in obj) {
    if (Object.prototype.hasOwnProperty.call(obj, key)) {
      cloned[key] = deepClone(obj[key])
    }
  }
  
  return cloned
}

/**
 * 生成唯一ID
 * @returns 唯一ID字符串
 */
export function generateId(): string {
  return `${Date.now()}-${Math.random().toString(36).substr(2, 9)}`
}

/**
 * 手机号脱敏
 * @param phone 手机号
 * @returns 脱敏后的手机号
 */
export function maskPhone(phone: string): string {
  if (phone.length !== 11 && !phone.startsWith('+95')) {
    return phone
  }
  return phone.replace(/(\d{3})\d{4}(\d{4})/, '$1****$2')
}

/**
 * 检查手机号格式（缅甸）
 * @param phone 手机号
 * @returns 是否有效
 */
export function isValidMyanmarPhone(phone: string): boolean {
  // 支持格式：+959xxx xxx xxx 或 09xxx xxx xxx
  const pattern = /^(\+95|0)9\d{8,9}$/
  return pattern.test(phone.replace(/\s/g, ''))
}

/**
 * 获取当前位置
 * @returns 位置信息
 */
export function getCurrentLocation(): Promise<WechatMiniprogram.GetLocationSuccessCallbackResult> {
  return new Promise((resolve, reject) => {
    wx.getLocation({
      type: 'gcj02',
      success: resolve,
      fail: reject
    })
  })
}

/**
 * 选择图片
 * @param count 数量
 * @param sourceType 来源
 * @returns 图片路径数组
 */
export function chooseImage(
  count: number = 1,
  sourceType: ('album' | 'camera')[] = ['album', 'camera']
): Promise<string[]> {
  return new Promise((resolve, reject) => {
    wx.chooseMedia({
      count,
      mediaType: ['image'],
      sourceType,
      success: (res) => {
        resolve(res.tempFiles.map(file => file.tempFilePath))
      },
      fail: reject
    })
  })
}