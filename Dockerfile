FROM oven/bun:1-slim
RUN apt update && apt install -y git
WORKDIR /app

COPY package.json bun.lock ./
COPY turbo.json ./
COPY patches ./patches
COPY packages ./packages

RUN bun install
RUN bun run build

RUN cd packages/cyberstrike && bun run build
RUN chmod +x /app/packages/cyberstrike/dist/cyberstrike
RUN test -x /app/packages/cyberstrike/dist/cyberstrike || exit 1

RUN find /app/packages/cyberstrike -name cyberstrike -type f -exec cp {} /usr/local/bin/cyberstrike \;

COPY . .
# 核心修复：永久创建程序读取目录/workspace，映射/app全部源码
RUN mkdir -p /workspace && ln -s /app/* /workspace/

EXPOSE 3000
# 标准无错误启动命令，监听全网
CMD ["cyberstrike", "web", "--hostname", "0.0.0.0"]