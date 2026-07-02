FROM oven/bun:1-alpine
RUN apk add --no-cache git
WORKDIR /app

# 复制根目录依赖文件
COPY package.json bun.lock ./
# 复制 monorepo 子包目录（install 前必须存在）
COPY turbo.json ./  
COPY patches ./patches
COPY packages ./packages
# 复制业务代码目录


# 安装依赖
RUN bun install 
# 执行项目构建 + 全局注册命令
RUN bun run build

EXPOSE 3000
CMD ["/app/packages/cyberstrike/dist/cyberstrike", "web"]