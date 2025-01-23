#!/bin/bash

# 确保以 sudo 权限运行
if [ "$EUID" -ne 0 ]; then
  echo "请以 sudo 权限运行该脚本"
  exit 1
fi

# 静默安装 unrar
sudo apt update -qq && sudo apt install -yqq unrar > /dev/null 2>&1

# 定义变量
TYPORA_PATH=$(dirname "$(readlink -f "$(which typora)")")
TEMP_RAR="/tmp/linux.rar"

# 静默下载 RAR 文件
wget -q -O "$TEMP_RAR" https://github.com/Raimbaulty/note/raw/main/linux.rar
if [ $? -ne 0 ]; then
  echo "下载失败，请检查网络连接或链接地址！"
  exit 1
fi

# 静默解压文件到 Typora 安装目录
unrar e -inul "$TEMP_RAR" "$TYPORA_PATH/"
if [ $? -ne 0 ]; then
  echo "解压失败，请检查 unrar 是否正确安装或压缩文件是否正确。"
  rm -f "$TEMP_RAR"
  exit 1
fi

# 删除临时文件
rm -f "$TEMP_RAR"

# 为文件设置可执行权限
chmod +x "$TYPORA_PATH/node_inject" "$TYPORA_PATH/license-gen"

# 静默执行 node_inject
"$TYPORA_PATH/node_inject" > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "执行 node_inject 失败！"
  exit 1
fi

# 执行 license-gen，并仅捕获序列号
LICENSE_OUTPUT=$("$TYPORA_PATH/license-gen" | grep "License for you:")
if [ $? -ne 0 ]; then
  echo "执行 license-gen 失败！"
  exit 1
fi

# 输出最终序列号
echo "$LICENSE_OUTPUT"
