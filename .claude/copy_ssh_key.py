#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""复制 SSH 公钥到远程服务器"""

import paramiko
import time

def copy_ssh_key():
    host = "43.163.122.42"
    username = "ubuntu"
    password = "Rh[HS#)6Z$YNs8bw"
    pub_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJqoJpq33PJAJJNSAw2cgrPbBWV7I8UhaMAXXfUKnWnC felix@vip.qq.com"

    print("Connecting to {}...".format(host))

    try:
        client = paramiko.SSHClient()
        client.set_missing_host_key_policy(paramiko.AutoAddPolicy())

        # 连接服务器 - 尝试多次
        for attempt in range(3):
            try:
                client.connect(
                    hostname=host,
                    username=username,
                    password=password,
                    timeout=30,
                    banner_timeout=60,
                    auth_timeout=30,
                    look_for_keys=False,
                    allow_agent=False
                )
                break
            except Exception as e:
                print("Attempt {} failed: {}".format(attempt + 1, str(e)))
                if attempt < 2:
                    time.sleep(2)
                else:
                    raise

        print("[OK] SSH connected")

        # 创建 .ssh 目录并添加公钥
        commands = [
            "mkdir -p ~/.ssh",
            "chmod 700 ~/.ssh",
            "echo '{}' >> ~/.ssh/authorized_keys".format(pub_key),
            "chmod 600 ~/.ssh/authorized_keys",
            "cat ~/.ssh/authorized_keys | wc -l"
        ]

        for cmd in commands:
            stdin, stdout, stderr = client.exec_command(cmd)
            exit_code = stdout.channel.recv_exit_status()
            output = stdout.read().decode('utf-8', errors='replace').strip()
            error = stderr.read().decode('utf-8', errors='replace').strip()

            if error:
                print("Command: {}".format(cmd))
                print("Error: {}".format(error))
            else:
                print("[OK] {}".format(cmd))
                if output:
                    print("Output: {}".format(output))

        client.close()
        print("\nSSH key copied successfully!")
        print("You can now login without password:")
        print("  ssh ubuntu@{}".format(host))

        return True

    except Exception as e:
        print("\n[ERROR]: {}".format(str(e)))
        import traceback
        traceback.print_exc()
        return False

if __name__ == "__main__":
    success = copy_ssh_key()
    exit(0 if success else 1)
