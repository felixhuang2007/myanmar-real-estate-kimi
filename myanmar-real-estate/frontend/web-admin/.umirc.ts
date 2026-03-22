import { defineConfig } from 'umi';

export default defineConfig({
  title: '缅甸房产管理后台',
  // 禁用 MFSU 以避免 __webpack_require__.nmd 错误
  mfsu: false,
  npmClient: 'npm',
  // 代理配置 - 将 API 请求转发到后端服务
  proxy: {
    '/api': {
      target: 'http://localhost:8080',
      changeOrigin: true,
    },
  },
});
