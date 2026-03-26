# 远程执行测试脚本
$server = "43.163.122.42"
$user = "ubuntu"
$password = ConvertTo-SecureString "Rh[HS#)6Z$YNs8bw" -AsPlainText -Force
cred = New-Object System.Management.Automation.PSCredential($user, $password)

# 创建 SSH 会话
$session = New-SSHSession -ComputerName $server -Credential $cred -AcceptKey

# 执行命令
$result = Invoke-SSHCommand -SessionId $session.SessionId -Command "cd ~/myanmarestate/myanmar-real-estate-kimi && git pull origin master && bash devops/scripts/run-all-tests.sh --full"

# 输出结果
Write-Host $result.Output

# 关闭会话
Remove-SSHSession -SessionId $session.SessionId
