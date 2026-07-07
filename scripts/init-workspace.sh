#!/bin/sh
# 先强制创建/workspace目录，规避挂载时序延迟报错
mkdir -p /workspace
mkdir -p /migration
# 目录存在后再复制文件
if [ -z "$(ls -A /workspace)" ]; then
  echo "检测到/workspace持久卷为空，正在复制/app全部项目文件"
  cp -r /app/* /workspace/
  chmod -R 777 /workspace
  echo "文件复制完成，WebIDE可正常读取项目目录"
fi
# 执行web启动程序
exec "$@"
