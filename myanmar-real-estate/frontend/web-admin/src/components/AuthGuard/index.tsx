import React from 'react';
import { Navigate, Outlet } from 'umi';
import { useAuthStore } from '@/stores';

const AuthGuard: React.FC = () => {
  const { isLogin } = useAuthStore();
  
  if (!isLogin && !localStorage.getItem('token')) {
    return <Navigate to="/login" replace />;
  }
  
  return <Outlet />;
};

export default AuthGuard;