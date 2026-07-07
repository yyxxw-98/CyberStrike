#!/bin/sh
# CyberStrike Railway持久卷初始化脚本
# 判断/workspace是否为空卷
if [ -z "$(ls -A /workspace)" ]; then
  echo "检测到/workspace持久卷为空，正在复制/app全部项目文件"
  cp -r /app/* /workspace/
  chmod -R 777 /workspace
  echo "文件复制完成，WebIDE可正常读取项目目录"
fi
# 传递原有启动参数 cyberstrike web
exec "$@"
