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

# 2. 👇 新增这行：自动找到构建生成的 cyberstrike 文件，强制放进系统路径并赋予执行权限！
RUN find /app/packages/cyberstrike -name cyberstrike -type f -exec cp {} /usr/local/bin/cyberstrike \; && chmod +x /usr/local/bin/cyberstrike

COPY . .

# 新增：兼容web前端默认/workspace路径
RUN mkdir -p /workspace && ln -s /app/* /workspace/
# 3. 恢复成最干净的标准启动命令
EXPOSE 3000
CMD ["cyberstrike", "web", "--hostname", "0.0.0.0"]