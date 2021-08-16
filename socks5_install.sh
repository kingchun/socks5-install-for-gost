# !/bin/bash 
#默认安装在/usr/local/bin/gost
#配置文件在/etc/systemd/system/gost.service
#如果需要更换配置就卸载了重新安装就好了
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'

install_gost(){
apt update &&yum update
apt install wget curl gunzip -y ||yum install wget curl gunzip -y

wget https://github.com/ginuerzh/gost/releases/download/v2.11.1/gost-linux-amd64-2.11.1.gz
gunzip gost-linux-amd64-2.11.1.gz
mv gost-linux-amd64-2.11.1 /usr/local/bin/gost
chmod +x /usr/local/bin/gost

echo -n "请输入socks5用户名:"                   # 参数-n的作用是不换行，echo默认换行
read  user

echo -n "请输入socks5密码:"                   # 参数-n的作用是不换行，echo默认换行
read  passwd

echo -n "请输入socks5端口:"                   # 参数-n的作用是不换行，echo默认换行
read  port

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

echo "The installation is complete"
}
uninstall(){
systemctl stop gost.service
rm -rf /usr/local/bin/gost
rm -rf /etc/systemd/system/gost.service
systemctl daemon-reload
echo "Uninstall complete"
}


echo -e "\033[0;32m ******************** \033[0m"
echo -e "\033[0;32m 垃圾socks5一键安装脚本 \033[0m"
echo -e "\033[0;32m ******************** \033[0m"
echo -e "\033[0;32m 1安装gost \033[0m"
echo -e "\033[0;32m 2卸载gost \033[0m"
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
  echo -e "\033[0;31m 输入有毛病呀老铁 \033[0m"
  ;;
esac
