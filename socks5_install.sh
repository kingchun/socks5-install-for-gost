#!/bin/bash 
#默认安装在/usr/local/bin/gost
#配置文件在/etc/systemd/system/gost.service
#如果需要更换配置就卸载了重新安装就好了
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'




install_gost(){
apt update || yum update
apt install wget curl gzip jq -y ||yum install  epel-release wget curl jq gunzip -y

version_tmp=$(curl https://api.github.com/repos/ginuerzh/gost/releases/latest  | jq .tag_name -r)
version=${version_tmp:1}
wget -O gost_${version}_linux_amd64.tar.gz https://github.com/ginuerzh/gost/releases/download/v${version}/gost_${version}_linux_amd64.tar.gz --no-check-certificate
file=gost_${version}_linux_amd64.tar.gz
tar -zxvf ${file}
mv gost /usr/local/bin/gost
chmod +x /usr/local/bin/gost

read -p "请输入socks5用户名:" user
read -p "请输入socks5密码:" passwd
read -p "请输入socks5端口:" port

cat > /etc/systemd/system/gost.service << EOF
[Unit]
Description=Gost Proxy
After=network.target
Wants=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/gost -L ${user}:${passwd}@:${port} socks5://:${port}
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload

systemctl start gost.service

systemctl enable gost.service

echo "The installation is complete"
ip=$(curl ip.sb -4)
echo "
The installation is complete!
Link information
IP:${ip}
Port:${port}
User:${user}
Passwd:${passwd}
"

}
uninstall(){
systemctl stop gost.service
rm -rf /usr/local/bin/gost
rm -rf /etc/systemd/system/gost.service
systemctl daemon-reload
echo "Uninstall complete"
}

function info(){
ls /etc/systemd/system/ | grep gost.service > /dev/null
install_status=$?
if [ $install_status == 0 ]
then
   install_info="${green}installed${plain}"
else
   install_info="${red}not installed${plain}"
fi
}
info


write_conf(){
cat > gost.conf << EOF
{
  "services": [
    {
      "name": "service-0",
      "addr": "${port}",
      "handler": {
        "type": "socks5",
        "auth": {
          "username": "${user}",
          "password": "${passwd}"
        }
      },
      "listener": {
        "type": "tcp"
      }
    }
  ]
}
EOF
}

echo -e "${green} ******************** ${plain}"
echo -e "${green} 垃圾socks5一键安装脚本 ${plain}"
echo -e "${green} ******************** ${plain}"
echo -e "${green} 1安装gost ${plain}"
echo -e "${green} 2卸载gost ${plain}"
echo -e "${green}install status: ${install_info}${plain}"
read  -p "请输入选项1或2:" xuanxiang
###根据选择执行那个函数###
case $xuanxiang in
 "1")
  install_gost
  ;;
 "2")
  uninstall
  ;;
 *)
  echo -e "${red} 输入有毛病呀老铁 ${plain}"
  ;;
esac
