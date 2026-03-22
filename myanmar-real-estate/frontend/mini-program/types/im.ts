/**
 * IM消息相关类型定义
 */

// 消息类型
export type MessageType = 'text' | 'image' | 'voice' | 'house_card' | 'system'

// 消息状态
export type MessageStatus = 'sending' | 'sent' | 'delivered' | 'read' | 'failed'

// 消息
export interface IMessage {
  id: string
  conversationId: string
  type: MessageType
  content: string
  
  // 发送者
  fromId: string
  fromName: string
  fromAvatar?: string
  
  // 接收者
  toId: string
  
  // 状态
  status: MessageStatus
  
  // 扩展数据（图片URL、语音时长等）
  extra?: {
    imageUrl?: string
    voiceDuration?: number
    houseId?: string
    houseTitle?: string
    houseImage?: string
    housePrice?: number
  }
  
  // 时间
  createdAt: string
  isSelf: boolean
}

// 会话
export interface IConversation {
  id: string
  targetId: string
  targetName: string
  targetAvatar?: string
  targetType: 'agent' | 'user'
  
  // 最后一条消息
  lastMessage?: IMessage
  unreadCount: number
  
  // 关联房源
  houseId?: string
  houseTitle?: string
  
  // 时间
  createdAt: string
  updatedAt: string
  isTop?: boolean
}