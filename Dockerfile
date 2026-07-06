FROM oven/bun:1-slim
RUN apt update && apt install -y git
WORKDIR /app

# 分层缓存依赖
COPY package.json bun.lock ./
COPY turbo.json ./
COPY patches ./patches
COPY packages ./packages

RUN bun install
RUN bun run build

# 编译二进制
RUN cd packages/cyberstrike && bun run compile
RUN chmod +x /app/packages/cyberstrike/dist/cyberstrike
RUN test -x /app/packages/cyberstrike/dist/cyberstrike || exit 1

# 复制二进制到系统全局
RUN find /app/packages/cyberstrike -name cyberstrike -type f -exec cp {} /usr/local/bin/cyberstrike \;

# 复制仓库全部剩余源码（补齐所有根目录文件）
COPY . .

# 核心修复：创建程序前端必须的/workspace，软链接映射/app全部源码
RUN mkdir -p /workspace && ln -s /app/* /workspace/

EXPOSE 3000
# 标准启动命令：监听全网，无无效参数
CMD ["cyberstrike", "web", "--hostname", "0.0.0.0"]