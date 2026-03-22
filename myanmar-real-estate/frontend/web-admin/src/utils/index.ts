/**
 * 工具函数
 */

/**
 * 格式化价格
 * @param price 价格
 * @param unit 单位
 * @returns 格式化后的价格
 */
export function formatPrice(price: number, unit: string = '万缅币'): string {
  if (price >= 10000) {
    return `${(price / 10000).toFixed(1)}亿${unit}`;
  }
  return `${price}${unit}`;
}

/**
 * 格式化日期
 * @param date 日期
 * @param format 格式
 * @returns 格式化后的日期
 */
export function formatDate(
  date: string | Date | number | null | undefined,
  format: string = 'YYYY-MM-DD HH:mm:ss'
): string {
  if (!date) return '-';
  const d = new Date(date);
  if (isNaN(d.getTime())) return '-';
  const year = d.getFullYear();
  const month = String(d.getMonth() + 1).padStart(2, '0');
  const day = String(d.getDate()).padStart(2, '0');
  const hour = String(d.getHours()).padStart(2, '0');
  const minute = String(d.getMinutes()).padStart(2, '0');
  const second = String(d.getSeconds()).padStart(2, '0');
  
  return format
    .replace('YYYY', String(year))
    .replace('MM', month)
    .replace('DD', day)
    .replace('HH', hour)
    .replace('mm', minute)
    .replace('ss', second);
}

/**
 * 格式化相对时间
 * @param date 日期
 * @returns 相对时间
 */
export function formatRelativeTime(date: string | Date | number): string {
  const now = new Date().getTime();
  const target = new Date(date).getTime();
  const diff = now - target;
  
  const minute = 60 * 1000;
  const hour = 60 * minute;
  const day = 24 * hour;
  
  if (diff < minute) {
    return '刚刚';
  } else if (diff < hour) {
    return `${Math.floor(diff / minute)}分钟前`;
  } else if (diff < day) {
    return `${Math.floor(diff / hour)}小时前`;
  } else {
    return formatDate(date, 'MM-DD');
  }
}

/**
 * 手机号脱敏
 * @param phone 手机号
 * @returns 脱敏后的手机号
 */
export function maskPhone(phone: string): string {
  if (!phone || phone.length < 7) return phone;
  return phone.replace(/(\d{3})\d{4}(\d+)/, '$1****$2');
}