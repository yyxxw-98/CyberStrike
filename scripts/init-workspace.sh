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

# 启动web服务
exec "$@"
