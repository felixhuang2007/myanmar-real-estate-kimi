# Stage 1: build
FROM node:20-alpine AS builder
WORKDIR /app

# 安装构建工具
RUN apk add --no-cache python3 make g++

COPY package*.json ./
RUN npm ci --legacy-peer-deps

# 修复 node_modules/.bin 权限
RUN chmod -R +x node_modules/.bin/ 2>/dev/null || true

COPY . .
RUN npx umi build

# Stage 2: serve
FROM nginx:alpine
COPY --from=builder /app/dist /usr/share/nginx/html
COPY nginx-spa.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
