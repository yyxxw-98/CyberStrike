#!/bin/sh
# 强制创建目录，解决挂载时序报错
mkdir -p /workspace
mkdir -p /migration

if [ -z "$(ls -A /workspace)" ]; then
  echo "检测/workspace为空，分步复制，跳过node_modules减少内存占用"
  cd /app
  # 只复制业务源码，跳过超大node_modules文件夹，从根源降低内存峰值
  find . -maxdepth 1 ! -name "node_modules" -exec cp -r {} /workspace/ \;
  chmod -R 777 /workspace
  echo "文件复制完成，WebIDE可正常读取项目目录"
fi

# 核心修复1：切换工作目录到/workspace，程序直接在持久卷运行
cd /workspace

# 核心修复2：使用程序原生支持的监听参数 --主机名 0.0.0.0
exec cyberstrike web --hostname 0.0.0.0
