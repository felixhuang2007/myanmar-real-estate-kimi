import React from 'react';
import { Navigate, useLocation } from 'umi';
import { useAuthStore } from '@/stores';

interface AuthGuardProps {
  children: React.ReactNode;
}

const AuthGuard: React.FC<AuthGuardProps> = ({ children }) => {
  const { isLogin } = useAuthStore();
  const location = useLocation();

  // 未登录且不在登录页，跳转到登录页
  if (!isLogin && location.pathname !== '/login') {
    return <Navigate to="/login" replace state={{ from: location }} />;
  }

  // 已登录且在登录页，跳转到首页
  if (isLogin && location.pathname === '/login') {
    return <Navigate to="/" replace />;
  }

  return <>{children}</>;
};

export default AuthGuard;
