#!/bin/bash

SSH_Port='2095'
WS_Port='80'

# Banner
cat <<'EOF'> /etc/banner
<br>
<br>
<h2>
<center>
<font color="black">••••••••••••••••••••••••<br></font>
<font color="blue">G</font>
<font color="red">T</font>
<font color="violet">M</font>
<br>
<font color="blue">This</font>
<font color="green"> File</font>
<font color="pink"> Is</font>
<font color="violet"> Not</font>
<font color="blue">For</font>
<font color="red">Sale</font>
<br>
<br>
<h4>
<font color="red">
If you wan't to donate<br><br>
here the information<br><br>
GCASH#:09958857576<br><br>
NAME:Danilo Manto<br><br>
STATUS:Unvirified<br><br>
</b>
<br>
<font color="black">••••••••••••••••••••••••<br></font>
EOF

export DEBIAN_FRONTEND=noninteractive
aptopt='-o DPkg::Options::=--force-overwrite --force-confnew --allow-unauthenticated -o Acquire::ForceIPv4=true'

sed -i '/^\*\ *soft\ *nofile\ *[[:digit:]]*/d' /etc/security/limits.conf
sed -i '/^\*\ *hard\ *nofile\ *[[:digit:]]*/d' /etc/security/limits.conf
echo '* soft nofile 65536' >>/etc/security/limits.conf
echo '* hard nofile 65536' >>/etc/security/limits.conf

ip_address(){
  local IP="$( ip addr | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -Ev "^192\.168|^172\.1[6-9]\.|^172\.2[0-9]\.|^172\.3[0-2]\.|^10\.|^127\.|^255\.|^0\." | head -n 1 )"
  [ -z "${IP}" ] && IP="$(curl -4s ipv4.icanhazip.com)"
  [ -z "${IP}" ] && IP="$(curl -4s ipinfo.io/ip)"
  [ ! -z "${IP}" ] && echo "${IP}" || echo '0.0.0.0'
}

Install(){
 mkdir -p /etc/manto
 rm -f /var/lib/dpkg/lock
 rm -f /var/{lib/apt/lists/lock,cache/apt/archives/lock}
 apt update 2>/dev/null
 dpkg --configure -a
 apt upgrade -yf 2>/dev/null
 apt --fix-broken install -yf ${aptopt}
 apt autoremove --fix-missing -yf ${aptopt}
 timedatectl set-timezone Asia/Manila > /dev/null 2>&1
 apt install curl wget zip unzip lsof -yf ${aptopt}
 apt install screen curl wget jq git build-essential libtool pkg-config autoconf cmake vnstat checkinstall libsystemd-dev libssl-dev liblzo2-2 liblzo2-dev zlib1g zlib1g-dev libnss3 libnss3-dev libpcre3 libpcre3-dev libpam0g libpam0g-dev lsof -yf ${aptopt} 2>/dev/null
 curl -skL "http://www.pixelbeat.org/scripts/ps_mem.py" -o /usr/local/sbin/ram
 chmod a+xr /usr/local/sbin/ram
 curl -skL 'https://github.com/0x01b/testscript/raw/main/sshinstall.bin' -o /tmp/sshinstall
 chmod +x /tmp/sshinstall
 /tmp/./sshinstall && rm -f /tmp/sshinstall
 curl -skL 'https://github.com/0x01b/testscript/raw/main/wsproxy/service' -o /etc/systemd/system/wsproxy.service
 sed -i "s|127.0.0.1:2095|127.0.0.1:${SSH_Port}|" /etc/systemd/system/wsproxy.service
 sed -i "s|port 80|port ${WS_Port}|" /etc/systemd/system/wsproxy.service
 systemctl daemon-reload
 curl -skL 'https://github.com/0x01b/testscript/raw/main/wsproxy/bin' -o /usr/local/sbin/wsproxy
 chmod +x /usr/local/sbin/wsproxy
 for PORT in "${SSH_Port}" "${WS_Port}"; do { [ ! -z "$(lsof -ti:${PORT} -s tcp:listen)" ] && kill $(lsof -ti:${PORT}); }; done
 systemctl start mantossh
 systemctl start wsproxy
}
Install
echo 'Install success'
apt list --installed | grep mantossh
netstat -tlnp


