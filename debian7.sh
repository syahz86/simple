#!/bin/bash

# go to root
cd

# Change to Time GMT+8
ln -fs /usr/share/zoneinfo/Asia/Kuala_Lumpur /etc/localtime

# set locale
sed -i 's/AcceptEnv/#AcceptEnv/g' /etc/ssh/sshd_config
service ssh restart

# remove unused
apt-get -y --purge remove samba*;
apt-get -y --purge remove apache2*;
apt-get -y --purge remove sendmail*;
apt-get -y --purge remove bind9*;

# update
apt-get update 
apt-get -y upgrade
apt-get -y install wget curl

# disable exim
service exim4 stop
sysv-rc-conf exim4 off

# update apt-file
apt-file update

# Setting Vnstat
apt-get install vnstat
vnstat -u -i eth0
chown -R vnstat:vnstat /var/lib/vnstat
service vnstat restart

# install screenfetch
cd
wget https://github.com/KittyKatt/screenFetch/raw/master/screenfetch-dev
mv screenfetch-dev /usr/bin/screenfetch
chmod +x /usr/bin/screenfetch
echo "clear" >> .profile
echo "screenfetch" >> .profile

# setting port ssh
sed -i '/Port 22/a Port 143' /etc/ssh/sshd_config
sed -i 's/Port 22/Port  22/g' /etc/ssh/sshd_config
echo "Banner /bannerssh" >> /etc/ssh/sshd_config
service ssh restart

# install dropbear
apt-get -y install dropbear
sed -i 's/NO_START=1/NO_START=0/g' /etc/default/dropbear
sed -i 's/DROPBEAR_PORT=22/DROPBEAR_PORT=443/g' /etc/default/dropbear
sed -i 's/DROPBEAR_EXTRA_ARGS=/DROPBEAR_EXTRA_ARGS="-p 109 -p 110"/g' /etc/default/dropbear
echo "/bin/false" >> /etc/shells
sed -i 's/DROPBEAR_BANNER=""/DROPBEAR_BANNER="bannerssh"/g' /etc/default/dropbear
service ssh restart
service dropbear restart

# bannerssh
wget https://raw.githubusercontent.com/syahz86/simple/master/conf/bannerssh
mv ./bannerssh /bannerssh
chmod 0644 /bannerssh
service dropbear restart
service ssh restart

# install fail2ban
apt-get -y install fail2ban;
service fail2ban restart

# install squid3
apt-get -y install squid3
wget -O /etc/squid3/squid.conf "https://raw.githubusercontent.com/syahz86/simple/master/conf/squid.conf"
MYIP=`ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0' | grep -v '192.168'`;
sed -i s/xxxxxxxxx/$MYIP/g /etc/squid3/squid.conf;
service squid3 restart

# install webmin
cd
wget "http://prdownloads.sourceforge.net/webadmin/webmin_1.820_all.deb"
dpkg --install webmin_1.820_all.deb;
apt-get -y -f install;
rm /root/webmin_1.820_all.deb
sed -i 's/ssl=1/ssl=0/g' /etc/webmin/miniserv.conf
service webmin restart
service vnstat restart

# Install Dos Deflate
apt-get -y install dnsutils dsniff
wget https://github.com/jgmdev/ddos-deflate/archive/master.zip
unzip master.zip
cd ddos-deflate-master
./install.sh
cd

# User Status
cd
wget https://raw.githubusercontent.com/syahz86/simple/master/conf/status
chmod +x status

# Install SSH autokick
cd
wget https://raw.githubusercontent.com/syahz86/VPS/master/Autokick-debian.sh
bash Autokick-debian.sh

# Install Monitor Multilogin Dropbear & OpenSSH
cd
wget -O /usr/bin/dropmon https://raw.githubusercontent.com/syahz86/VPS/master/conf/dropmon.sh
chmod +x /usr/bin/dropmon

# Install Menu for OpenVPN
cd
wget https://raw.githubusercontent.com/syahz86/simple/master/conf/menu
mv ./menu /usr/local/bin/menu
chmod +x /usr/local/bin/menu

# Reboot Server at 12AM Everday
echo "0 0 * * * root /usr/bin/reboot" > /etc/cron.d/reboot
echo "* * * * * service dropbear restart" > /etc/cron.d/dropbear

#bonus block playstation
iptables -A OUTPUT -d account.sonyentertainmentnetwork.com -j DROP
iptables -A OUTPUT -d auth.np.ac.playstation.net -j DROP
iptables -A OUTPUT -d auth.api.sonyentertainmentnetwork.com -j DROP
iptables -A OUTPUT -d auth.api.np.ac.playstation.net -j DROP
iptables-save

#bonus block torrent
iptables -A INPUT -m string --algo bm --string "BitTorrent" -j REJECT
iptables -A INPUT -m string --algo bm --string "BitTorrent protocol" -j REJECT
iptables -A INPUT -m string --algo bm --string "peer_id=" -j REJECT
iptables -A INPUT -m string --algo bm --string ".torrent" -j REJECT
iptables -A INPUT -m string --algo bm --string "announce.php?passkey=" -j REJECT
iptables -A INPUT -m string --algo bm --string "torrent" -j REJECT
iptables -A INPUT -m string --algo bm --string "info_hash" -j REJECT
iptables -A INPUT -m string --algo bm --string "/default.ida?" -j REJECT
iptables -A INPUT -m string --algo bm --string ".exe?/c+dir" -j REJECT
iptables -A INPUT -m string --algo bm --string ".exe?/c_tftp" -j REJECT
iptables -A INPUT -m string --string "peer_id" --algo kmp -j REJECT
iptables -A INPUT -m string --string "BitTorrent" --algo kmp -j REJECT
iptables -A INPUT -m string --string "BitTorrent protocol" --algo kmp -j REJECT
iptables -A INPUT -m string --string "bittorrent-announce" --algo kmp -j REJECT
iptables -A INPUT -m string --string "announce.php?passkey=" --algo kmp -j REJECT
iptables -A INPUT -m string --string "find_node" --algo kmp -j REJECT
iptables -A INPUT -m string --string "info_hash" --algo kmp -j REJECT
iptables -A INPUT -m string --string "get_peers" --algo kmp -j REJECT
iptables -A INPUT -p tcp --dport 25 -j REJECT   
iptables -A FORWARD -p tcp --dport 25 -j REJECT 
iptables -A OUTPUT -p tcp --dport 25 -j REJECT 
iptables-save

# Restart Service
service vnstat restart
service ssh restart
service dropbear restart
service fail2ban restart
service squid3 restart
service webmin restart

# info
clear
echo "Setup by Syahz86"
echo "OpenSSH  : 22, 143"
echo "Dropbear : 109, 110, 443"
echo "Squid3   : 8080, 60000"
echo ""
echo "----------"
echo "Webmin   : http://$MYIP:10000/"
echo "Timezone : Asia/Malaysia"
echo -e "Fail2Ban : [\e[32mon\e[0m]"
echo -e "IPv6     : [\e[31moff\e[0m]"
echo -e "Torrent Block : [\e[32mon\e[0m]" 
echo -e "Playstation Block : [\e[32mon\e[0m]"
echo -e "Please type \e[1;33;44mmenu\e[0m for options"

echo "================================================"
