#!/bin/sh
# CyberStrike Railway云端持久卷初始化脚本 适配本仓库容器路径
# 判断/workspace挂载卷是否为空
if [ -z "$(ls -A /workspace)" ]; then
  echo "【初始化】检测到持久卷为空，正在复制容器内置项目源码到/workspace"
  # /app 是你Dockerfile打包所有代码的根目录，和现有构建逻辑完全匹配
  cp -r /app/* /workspace/
  # 给挂载卷全部读写权限，解决Railway权限拦截
  chmod -R 777 /workspace
  echo "【初始化完成】项目文件已全部复制到工作目录"
fi
# 执行你原本写好的启动命令，完全保留你修改后的启动逻辑
exec "$@"
