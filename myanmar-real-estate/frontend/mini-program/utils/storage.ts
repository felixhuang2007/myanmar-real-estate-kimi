/**
 * 存储工具封装
 */

const StorageKeys = {
  TOKEN: 'token',
  USER_INFO: 'user_info',
  SEARCH_HISTORY: 'search_history',
  LOCATION: 'location',
  SETTINGS: 'settings'
} as const

/**
 * 存储数据
 * @param key 键名
 * @param data 数据
 */
export function setStorage<T>(key: string, data: T): void {
  try {
    wx.setStorageSync(key, data)
  } catch (e) {
    console.error('Storage set error:', e)
  }
}

/**
 * 获取数据
 * @param key 键名
 * @param defaultValue 默认值
 * @returns 存储的数据
 */
export function getStorage<T>(key: string, defaultValue?: T): T | undefined {
  try {
    return wx.getStorageSync(key) ?? defaultValue
  } catch (e) {
    console.error('Storage get error:', e)
    return defaultValue
  }
}

/**
 * 移除数据
 * @param key 键名
 */
export function removeStorage(key: string): void {
  try {
    wx.removeStorageSync(key)
  } catch (e) {
    console.error('Storage remove error:', e)
  }
}

/**
 * 清空存储
 */
export function clearStorage(): void {
  try {
    wx.clearStorageSync()
  } catch (e) {
    console.error('Storage clear error:', e)
  }
}

// Token 相关
export const tokenStorage = {
  set: (token: string) => setStorage(StorageKeys.TOKEN, token),
  get: () => getStorage<string>(StorageKeys.TOKEN),
  remove: () => removeStorage(StorageKeys.TOKEN)
}

// 用户信息相关
export const userStorage = {
  set: (userInfo: any) => setStorage(StorageKeys.USER_INFO, userInfo),
  get: () => getStorage<any>(StorageKeys.USER_INFO),
  remove: () => removeStorage(StorageKeys.USER_INFO)
}

// 搜索历史相关
export const searchHistoryStorage = {
  set: (history: string[]) => setStorage(StorageKeys.SEARCH_HISTORY, history),
  get: () => getStorage<string[]>(StorageKeys.SEARCH_HISTORY, []),
  add: (keyword: string) => {
    const history = searchHistoryStorage.get()
    const newHistory = [keyword, ...history.filter(h => h !== keyword)].slice(0, 10)
    searchHistoryStorage.set(newHistory)
  },
  clear: () => removeStorage(StorageKeys.SEARCH_HISTORY)
}