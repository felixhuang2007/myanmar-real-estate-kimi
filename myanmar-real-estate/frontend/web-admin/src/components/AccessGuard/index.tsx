/**
 * 权限守卫组件
 */
import React from 'react';
import { useUser } from '@/stores';

interface AccessGuardProps {
  permission: string;
  children: React.ReactNode;
  fallback?: React.ReactNode;
}

const AccessGuard: React.FC<AccessGuardProps> = ({ 
  permission, 
  children, 
  fallback = null 
}) => {
  const user = useUser();
  
  const hasPermission = user?.permissions?.includes(permission);
  
  if (!hasPermission) {
    return <>{fallback}</>;
  }
  
  return <>{children}</>;
};

export default AccessGuard;