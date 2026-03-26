#!/bin/bash
# 复制 SSH 公钥到服务器

SERVER_IP="43.163.122.42"
USER="ubuntu"
PASSWORD="Rh[HS#)6Z$YNs8bw"
PUB_KEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJqoJpq33PJAJJNSAw2cgrPbBWV7I8UhaMAXXfUKnWnC felix@vip.qq.com"

echo "正在复制公钥到服务器..."

# 使用 sshpass 或 expect 来自动输入密码
# 这里使用 ssh 的 ControlMaster 或者直接追加

# 方法：先 ssh 登录，然后追加公钥
ssh -o StrictHostKeyChecking=no -o ConnectTimeout=30 \
    -o PasswordAuthentication=yes \
    ${USER}@${SERVER_IP} "mkdir -p ~/.ssh && echo '${PUB_KEY}' >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys && chmod 700 ~/.ssh"

echo "公钥已复制。现在尝试免密登录..."
ssh -o ConnectTimeout=10 ${USER}@${SERVER_IP} "echo 'SSH key login successful'"
