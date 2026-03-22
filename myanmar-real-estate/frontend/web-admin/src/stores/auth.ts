/**
 * 全局状态管理
 */
import { create } from 'zustand';
import { persist } from 'zustand/middleware';
import { IUser } from '@/types';

interface AuthState {
  // 状态
  token: string | null;
  user: IUser | null;
  isLogin: boolean;
  
  // 方法
  setToken: (token: string) => void;
  setUser: (user: IUser) => void;
  logout: () => void;
}

export const useAuthStore = create<AuthState>()(
  persist(
    (set) => ({
      token: null,
      user: null,
      isLogin: false,
      
      setToken: (token) => set({ token, isLogin: !!token }),
      
      setUser: (user) => set({ user }),
      
      logout: () => {
        localStorage.removeItem('token');
        set({ token: null, user: null, isLogin: false });
      },
    }),
    {
      name: 'auth-storage',
      partialize: (state) => ({ token: state.token, user: state.user }),
    }
  )
);

// 便捷hooks
export const useToken = () => useAuthStore((state) => state.token);
export const useUser = () => useAuthStore((state) => state.user);
export const useIsLogin = () => useAuthStore((state) => state.isLogin);