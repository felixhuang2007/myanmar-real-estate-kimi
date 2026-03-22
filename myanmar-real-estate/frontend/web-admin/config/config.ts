import { defineConfig } from 'umi';

export default defineConfig({
  routes: [
    {
      path: '/login',
      component: './Login',
      layout: false,
    },
    {
      path: '/',
      component: '@/layouts/index',
      routes: [
        {
          path: '/',
          redirect: '/dashboard',
        },
        {
          path: '/dashboard',
          name: '数据大屏',
          component: './Dashboard',
        },
        {
          path: '/houses',
          name: '房源管理',
          routes: [
            {
              path: '/houses/list',
              name: '房源列表',
              component: './Houses/List',
            },
            {
              path: '/houses/audit',
              name: '房源审核',
              component: './Houses/Audit',
            },
            {
              path: '/houses/verification',
              name: '房源验真',
              component: './Houses/Verification',
            },
          ],
        },
        {
          path: '/users',
          name: '用户管理',
          routes: [
            {
              path: '/users/c-end',
              name: 'C端用户',
              component: './Users/CEnd',
            },
          ],
        },
        {
          path: '/agents',
          name: '经纪人管理',
          routes: [
            {
              path: '/agents/list',
              name: '经纪人列表',
              component: './Agents/List',
            },
            {
              path: '/agents/performance',
              name: '业绩统计',
              component: './Agents/Performance',
            },
            {
              path: '/agents/acn',
              name: 'ACN分佣',
              component: './Agents/ACN',
            },
          ],
        },
        {
          path: '/finance',
          name: '财务管理',
          routes: [
            {
              path: '/finance/commission',
              name: '佣金管理',
              component: './Finance/Commission',
            },
            {
              path: '/finance/withdrawal',
              name: '提现管理',
              component: './Finance/Withdrawal',
            },
            {
              path: '/finance/reports',
              name: '财务报表',
              component: './Finance/Reports',
            },
          ],
        },
        {
          path: '/operations',
          name: '运营中心',
          routes: [
            {
              path: '/operations/banners',
              name: 'Banner管理',
              component: './Operations/Banners',
            },
            {
              path: '/operations/content',
              name: '内容管理',
              component: './Operations/Content',
            },
          ],
        },
        {
          path: '/settings',
          name: '系统设置',
          routes: [
            {
              path: '/settings/general',
              name: '基础设置',
              component: './Settings/General',
            },
            {
              path: '/settings/roles',
              name: '角色权限',
              component: './Settings/Roles',
            },
            {
              path: '/settings/commission-rules',
              name: '分佣规则',
              component: './Settings/CommissionRules',
            },
          ],
        },
      ],
    },
  ],
  npmClient: 'npm',
  title: 'Myanmar Home 管理后台',
  metas: [
    {
      'http-equiv': 'Content-Security-Policy',
      content: "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval'; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:; font-src 'self' data:; connect-src 'self' http://localhost:* http://127.0.0.1:*;",
    },
    {
      'http-equiv': 'X-Content-Type-Options',
      content: 'nosniff',
    },
    {
      'http-equiv': 'X-Frame-Options',
      content: 'SAMEORIGIN',
    },
  ],
  proxy: {
    '/api': {
      target: 'http://localhost:8080',
      changeOrigin: true,
    },
  },
});
