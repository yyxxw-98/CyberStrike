FROM oven/bun:1-slim
RUN apt update && apt install -y git
WORKDIR /app

# 分层复制依赖文件，缓存加速构建
COPY package.json bun.lock ./
COPY turbo.json ./
COPY patches ./patches
COPY packages ./packages

# 安装全部依赖 + 整体项目前端构建
RUN bun install
RUN bun run build

# 【关键修复】编译Linux二进制，必须用compile，不是build
RUN cd packages/cyberstrike && bun run compile
# 给编译出来的二进制赋执行权限
RUN chmod +x /app/packages/cyberstrike/dist/cyberstrike
# 校验二进制文件存在，不存在直接终止构建
RUN test -x /app/packages/cyberstrike/dist/cyberstrike || exit 1

# 把二进制复制到系统全局PATH，任意目录可直接调用cyberstrike
RUN find /app/packages/cyberstrike -name cyberstrike -type f -exec cp {} /usr/local/bin/cyberstrike \;

# 复制仓库剩余全部根目录源码文件
COPY . .
# 复制workspace初始化脚本到系统全局
COPY scripts/init-workspace.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/init-workspace.sh
# 先注释软链接，等构建成功再放开，减少报错叠加
# RUN mkdir -p /workspace && ln -s /app/* /workspace/

EXPOSE 3000
# 最简无冲突启动命令，无不存在的--workdir参数
EXPOSE 3000
# 挂载卷初始化前置脚本，再启动web服务
ENTRYPOINT ["/usr/local/bin/init-workspace.sh"]
CMD ["cyberstrike", "web", "--hostname", "0.0.0.0"]
