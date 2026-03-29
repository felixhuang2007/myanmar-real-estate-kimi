@echo off
echo y | plink -ssh -P 22 -l ubuntu -pw Rh[HS#)6Z$YNs8bw -batch ubuntu@43.163.122.42 "cd ~/myanmarestate/myanmar-real-estate-kimi/devops/scripts && bash api-test-suite.sh 2>&1"
