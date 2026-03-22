import React from 'react';
import { Link, useLocation, Navigate, Outlet, useNavigate } from 'umi';
import { ProLayout } from '@ant-design/pro-components';
import {
  DashboardOutlined,
  HomeOutlined,
  UserOutlined,
  TeamOutlined,
  MoneyCollectOutlined,
  SettingOutlined,
  ShopOutlined,
  LogoutOutlined,
} from '@ant-design/icons';
import { useAuthStore } from '@/stores';
import { Dropdown, MenuProps } from 'antd';

const menuData = [
  {
    path: '/dashboard',
    name: '数据大屏',
    icon: <DashboardOutlined />,
  },
  {
    path: '/houses',
    name: '房源管理',
    icon: <HomeOutlined />,
    children: [
      {
        path: '/houses/list',
        name: '房源列表',
      },
      {
        path: '/houses/audit',
        name: '房源审核',
      },
      {
        path: '/houses/verification',
        name: '房源验真',
      },
    ],
  },
  {
    path: '/users',
    name: '用户管理',
    icon: <UserOutlined />,
    children: [
      {
        path: '/users/cend',
        name: 'C端用户',
      },
    ],
  },
  {
    path: '/agents',
    name: '经纪人管理',
    icon: <TeamOutlined />,
    children: [
      {
        path: '/agents/list',
        name: '经纪人列表',
      },
      {
        path: '/agents/performance',
        name: '业绩统计',
      },
      {
        path: '/agents/acn',
        name: 'ACN分佣',
      },
    ],
  },
  {
    path: '/finance',
    name: '财务管理',
    icon: <MoneyCollectOutlined />,
    children: [
      {
        path: '/finance/commission',
        name: '佣金管理',
      },
      {
        path: '/finance/withdrawal',
        name: '提现管理',
      },
      {
        path: '/finance/reports',
        name: '财务报表',
      },
    ],
  },
  {
    path: '/operations',
    name: '运营中心',
    icon: <ShopOutlined />,
    children: [
      {
        path: '/operations/banners',
        name: 'Banner管理',
      },
      {
        path: '/operations/content',
        name: '内容管理',
      },
    ],
  },
  {
    path: '/settings',
    name: '系统设置',
    icon: <SettingOutlined />,
    children: [
      {
        path: '/settings/general',
        name: '基础设置',
      },
      {
        path: '/settings/roles',
        name: '角色权限',
      },
      {
        path: '/settings/commissionrules',
        name: '分佣规则',
      },
    ],
  },
];

const Layout: React.FC = () => {
  const location = useLocation();
  const navigate = useNavigate();
  const { token, user, logout } = useAuthStore();
  const isLogin = !!token;

  const menuItems: MenuProps['items'] = [
    {
      key: 'logout',
      icon: <LogoutOutlined />,
      label: '退出登录',
      onClick: () => {
        logout();
        navigate('/login');
      },
    },
  ];

  // 未登录，跳转到登录页
  if (!isLogin && location.pathname !== '/login') {
    return <Navigate to="/login" replace />;
  }

  // 登录页不需要布局
  if (location.pathname === '/login') {
    return <Outlet />;
  }

  return (
    <ProLayout
      title="缅甸房产管理后台"
      logo="https://gw.alipayobjects.com/zos/rmsportal/KDpgvguMpGfqaHPjicRK.svg"
      layout="mix"
      location={location}
      route={{ routes: menuData }}
      menuItemRender={(item, dom) => (
        <Link to={item.path || '/'}>{dom}</Link>
      )}
      actionsRender={() => [
        <Dropdown key="avatar" menu={{ items: menuItems }} placement="bottomRight">
          <div style={{ cursor: 'pointer', display: 'flex', alignItems: 'center', gap: 8 }}>
            <img
              src={user?.avatar || 'https://gw.alipayobjects.com/zos/antfincdn/efFD%24IOql2/weixintupian_20170331104822.jpg'}
              alt="avatar"
              style={{ width: 24, height: 24, borderRadius: '50%' }}
            />
            <span>{user?.nickname || user?.username || '管理员'}</span>
          </div>
        </Dropdown>,
      ]}
      onMenuHeaderClick={() => {
        navigate('/dashboard');
      }}
    >
      <Outlet />
    </ProLayout>
  );
};

export default Layout;
