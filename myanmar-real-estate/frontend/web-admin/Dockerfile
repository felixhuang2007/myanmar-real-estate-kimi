# Stage 1: build
# 使用阿里云镜像源加速
FROM registry.cn-hangzhou.aliyuncs.com/library/node:20 AS builder
WORKDIR /app

COPY package*.json ./
# 使用阿里云 npm 镜像源
RUN npm config set registry https://registry.npmmirror.com && npm ci --legacy-peer-deps

COPY . .
RUN chmod +x ./node_modules/.bin/umi && ./node_modules/.bin/umi build

# Stage 2: serve
# 使用阿里云镜像源加速
FROM registry.cn-hangzhou.aliyuncs.com/library/nginx:alpine
COPY --from=builder /app/dist /usr/share/nginx/html
COPY nginx-spa.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
