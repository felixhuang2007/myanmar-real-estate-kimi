#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""远程执行缅甸房产平台测试脚本 - 使用 Windows OpenSSH"""

import subprocess
import sys
import os
from datetime import datetime

def run_remote_test():
    host = "43.163.122.42"
    username = "ubuntu"

    # SSH 可执行文件路径
    ssh_exe = "C:/Windows/System32/OpenSSH/ssh.exe"

    # 创建日志文件
    log_file = "remote_test_{}.log".format(datetime.now().strftime("%Y%m%d_%H%M%S"))
    print("Log file: {}".format(log_file))

    # 构建远程命令
    remote_commands = [
        "cd ~/myanmarestate/myanmar-real-estate-kimi",
        "git pull origin master 2>&1",
        "bash devops/scripts/run-all-tests.sh --smoke 2>&1"
    ]
    remote_command = " && ".join(remote_commands)

    # 构建 SSH 命令 - 使用密钥登录
    ssh_cmd = [
        ssh_exe,
        "-o", "StrictHostKeyChecking=no",
        "-o", "ConnectTimeout=30",
        "-o", "ServerAliveInterval=60",
        "-o", "ServerAliveCountMax=3",
        "{}@{}".format(username, host),
        remote_command
    ]

    print("Connecting to {}...".format(host))
    print("Executing remote test...")
    print("=" * 60)

    try:
        # 使用 Popen 来实时获取输出
        process = subprocess.Popen(
            ssh_cmd,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            encoding='utf-8',
            errors='replace',
            bufsize=1
        )

        # 收集输出
        all_output = []

        # 实时读取输出
        for line in process.stdout:
            all_output.append(line)
            # 打印安全字符
            safe_line = line.encode('ascii', 'ignore').decode('ascii')
            print(safe_line, end='', flush=True)

        # 等待进程完成
        exit_code = process.wait()

        print("\n" + "=" * 60)
        print("Test completed, exit code: {}".format(exit_code))

        # 保存完整输出到文件
        with open(log_file, 'w', encoding='utf-8') as f:
            f.write("".join(all_output))
        print("Full output saved to: {}".format(log_file))

        return exit_code == 0

    except Exception as e:
        print("\n[ERROR]: {}".format(str(e)))
        import traceback
        traceback.print_exc()
        return False

if __name__ == "__main__":
    success = run_remote_test()
    sys.exit(0 if success else 1)
