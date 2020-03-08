#!/bin/bash

echo 'Setting users hard and soft limits in /etc/security/limits.conf... '
file="/etc/security/limits.conf"
echo '* soft nproc 102400'
echo '* soft nproc 102400' >> $file
echo '* hard nproc 1000000'
echo '* hard nproc 1000000' >> $file
echo '* soft nofile 1048576'
echo '* soft nofile 1048576' >> $file
echo '* hard nofile 1048576'
echo '* hard nofile 1048576' >> $file
echo '* - memlock unlimited'
echo '* - memlock unlimited' >> $file
echo '* soft sigpending 102400'
echo '* soft sigpending 102400' >> $file
echo '* hard sigpending 102400'
echo '* hard sigpending 102400' >> $file
echo 'root - memlock unlimited'
echo 'root - memlock unlimited' >> $file
echo 'root soft nofile 1048576'
echo 'root soft nofile 1048576' >> $file
echo 'root hard nofile 1048576'
echo 'root hard nofile 1048576' >> $file
echo 'root soft nproc 102400'
echo 'root soft nproc 102400' >> $file
echo 'root hard nproc 1000000'
echo 'root hard nproc 1000000' >> $file
echo 'root soft sigpending 102400'
echo 'root soft sigpending 102400' >> $file
echo 'root hard sigpending 102400'
echo 'root hard sigpending 102400' >> $file
echo "... done!"
echo

echo 'Setting system descriptors in /etc/sysctl.conf... '
file="/etc/sysctl.conf"
echo 'fs.file-max=500000'
echo 'fs.file-max=500000' >> $file
echo "... done!"
echo

echo 'Editing limits in  /etc/systemd/system.conf... '
file="/etc/systemd/system.conf"
echo 'DefaultLimitDATA=infinity'
echo 'DefaultLimitDATA=infinity' >> $file
echo 'DefaultLimitSTACK=infinity'
echo 'DefaultLimitSTACK=infinity' >> $file
echo 'DefaultLimitCORE=infinity'
echo 'DefaultLimitCORE=infinity' >> $file
echo 'DefaultLimitRSS=infinity'
echo 'DefaultLimitRSS=infinity' >> $file
echo 'DefaultLimitNOFILE=500000'
echo 'DefaultLimitNOFILE=500000' >> $file
echo 'DefaultLimitAS=infinity'
echo 'DefaultLimitAS=infinity' >> $file
echo 'DefaultLimitNPROC=500000'
echo 'DefaultLimitNPROC=500000' >> $file
echo 'DefaultLimitMEMLOCK=infinity'
echo 'DefaultLimitMEMLOCK=infinity' >> $file
echo "... done! "

echo 'Editing limits in /etc/systemd/user.conf... '
file="/etc/systemd/user.conf"
echo 'DefaultLimitDATA=infinity'
echo 'DefaultLimitDATA=infinity' >> $file
echo 'DefaultLimitSTACK=infinity'
echo 'DefaultLimitSTACK=infinity' >> $file
echo 'DefaultLimitCORE=infinity'
echo 'DefaultLimitCORE=infinity' >> $file
echo 'DefaultLimitRSS=infinity'
echo 'DefaultLimitRSS=infinity' >> $file
echo 'DefaultLimitNOFILE=500000'
echo 'DefaultLimitNOFILE=500000' >> $file
echo 'DefaultLimitAS=infinity'
echo 'DefaultLimitAS=infinity' >> $file
echo 'DefaultLimitNPROC=500000'
echo 'DefaultLimitNPROC=500000' >> $file
echo 'DefaultLimitMEMLOCK=infinity'
echo 'DefaultLimitMEMLOCK=infinity' >> $file
echo "... done!"
echo
