FROM oven/bun:1-slim
RUN apt update && apt install -y git
WORKDIR /app

COPY package.json bun.lock ./
COPY turbo.json ./
COPY patches ./patches
COPY packages ./packages

RUN bun install
RUN bun run build

# 容器内编译Linux二进制
RUN cd packages/cyberstrike && bun run compile
# 打印目录排查 + 赋予执行权限
RUN ls -la /app/packages/cyberstrike/dist/
RUN chmod +x /app/packages/cyberstrike/dist/cyberstrike
# 同时校验文件存在+可执行
RUN test -x /app/packages/cyberstrike/dist/cyberstrike || exit 1

EXPOSE 3000
CMD ["/app/packages/cyberstrike/dist/cyberstrike-linux-x64-musl/bin/cyberstrike", "web"]