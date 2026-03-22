// UmiJS 运行时配置文件
// 文档: https://umijs.org/docs/api/runtime-config

// 在应用渲染之前执行
export const render = (oldRender: () => void) => {
  oldRender();
};

// 根组件包装
export const rootContainer = (container: React.ReactNode) => {
  return container;
};

// 路由切换时触发
export const onRouteChange = ({
  location,
  routes,
  action,
}: {
  location: { pathname: string };
  routes: any[];
  action?: string;
}) => {
  console.log('Route changed:', location.pathname);
};
