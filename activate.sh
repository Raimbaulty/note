#!/bin/bash

# 确保以 sudo 权限运行
if [ "$EUID" -ne 0 ]; then
  echo "请以 sudo 权限运行该脚本"
  exit 1
fi

# 安装 unrar
echo "正在安装 unrar..."
sudo apt update && sudo apt install -y unrar

# 定义变量
TYPORA_PATH=$(dirname "$(readlink -f "$(which typora)")")
TEMP_RAR="/tmp/linux.rar"

# 下载 RAR 文件
echo "正在下载 Linux RAR 文件..."
wget -O "$TEMP_RAR" https://github.com/Raimbaulty/note/raw/main/linux.rar
if [ $? -ne 0 ]; then
  echo "下载失败，请检查网络连接或链接地址！"
  exit 1
fi

# 解压文件到 Typora 安装目录
echo "正在解压文件到 $TYPORA_PATH..."
unrar x "$TEMP_RAR" "$TYPORA_PATH/"
if [ $? -ne 0 ]; then
  echo "解压失败，请检查 unrar 是否正确安装或压缩文件是否正确。"
  rm -f "$TEMP_RAR"
  exit 1
fi

# 删除临时文件
rm -f "$TEMP_RAR"

# 为文件设置可执行权限
echo "正在设置文件权限..."
chmod +x "$TYPORA_PATH/node_inject" "$TYPORA_PATH/license-gen"

# 执行 node_inject
echo "正在执行 node_inject..."
"$TYPORA_PATH/node_inject"
if [ $? -ne 0 ]; then
  echo "执行 node_inject 失败！"
  exit 1
fi

# 执行 license-gen
echo "正在生成许可证..."
LICENSE_OUTPUT=$("$TYPORA_PATH/license-gen")
if [ $? -ne 0 ]; then
  echo "执行 license-gen 失败！"
  exit 1
fi

# 输出结果
echo "补丁应用完成！"
echo -e "\n执行结果："
echo "$LICENSE_OUTPUT"
