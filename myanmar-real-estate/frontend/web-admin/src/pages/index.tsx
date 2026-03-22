import React from 'react';
import { Navigate } from 'umi';
import { useAuthStore } from '@/stores';

// 首页重定向到 Dashboard 或登录页
const IndexPage: React.FC = () => {
  const { isLogin } = useAuthStore();

  if (!isLogin) {
    return <Navigate to="/login" replace />;
  }

  return <Navigate to="/dashboard" replace />;
};

export default IndexPage;
