if ! [ $(id -u) = 0 ]; then
   echo "The script need to be run as root." >&2
   exit 1
fi

mkdir build
cd build
git clone https://github.com/SoftEtherVPN/SoftEtherVPN.git
cd SoftEtherVPN
apt -y install cmake gcc g++ libncurses5-dev libreadline-dev libssl-dev make zlib1g-dev
git submodule init && git submodule update
./configure
make -C tmp
make -C tmp install
cd ..
vpnserver start

(cat <<EOF
OpenVpnEnable yes /PORTS:"1194"
SecureNatDisable
BridgeCreate DEFAULT /DEVICE:soft /TAP:yes
OpenVpnMakeConfig openvpnconfig.zip
EOF
)|vpncmd localhost:5555 /server /adminhub:DEFAULT /password:"" /CMD
pwd
cp dhcpd.conf /etc/dhcpd.conf

systemctl start network@tap_soft
systemctl start dhcpd4@tap_soft

cp softether-override-require-dhcpd.conf /etc/systemd/system/softethervpn-server.service.d/dhcpd.conf

cp ipv4_forwarding.conf /etc/sysctl.d/ipv4_forwarding.conf
sysctl --system. /etc/sysctl.d/ipv4_forwarding.conf

iptables -A INPUT -s 10.10.1.1/24 -m state --state NEW -j ACCEPT
iptables -A OUTPUT -s 10.10.1.1/24 -m state --state NEW -j ACCEPT
iptables -A FORWARD -s 10.10.1.1/24 -m state --state NEW -j ACCEPT

iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT

sudo iptables -t nat -A POSTROUTING -s 10.10.1.1/24 -o eth0 -j MASQUERADE

mkdir -p openvpnconfig
unzip -o openvpnconfig.zip -d openvpnconfig/
install -C -m 775 -o www-data openvpnconfig/*l3.ovpn /var/www/yehudae.ga/openvpnconfig.ovpn
cd ..
