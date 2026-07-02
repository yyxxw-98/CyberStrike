FROM oven/bun:1-alpine
WORKDIR /app

# 复制根目录依赖文件
COPY package.json bun.lock ./
# 复制 monorepo 子包目录（install 前必须存在）
COPY packages ./packages
# 复制业务代码目录
COPY code ./code

# 安装依赖
RUN bun install --frozen-lock
# 执行项目构建 + 全局注册命令
RUN bun run build && bun link

EXPOSE 3000
CMD ["cyberstrike", "web"]