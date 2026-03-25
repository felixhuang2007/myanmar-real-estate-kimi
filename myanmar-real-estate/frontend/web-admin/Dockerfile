# Stage 1: build
FROM node:20 AS builder
WORKDIR /app

COPY package*.json ./
# 使用 npm 淘宝镜像加速
RUN npm config set registry https://registry.npmmirror.com && npm ci --legacy-peer-deps

COPY . .
RUN chmod +x ./node_modules/.bin/umi && ./node_modules/.bin/umi build

# Stage 2: serve
FROM nginx:alpine
COPY --from=builder /app/dist /usr/share/nginx/html
COPY nginx-spa.conf /etc/nginx/conf.d/default.conf
EXPOSE 80