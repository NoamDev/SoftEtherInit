if ! [ $(id -u) = 0 ]; then
   echo "The script need to be run as root." >&2
   exit 1
fi

mkdir build
cd build
git clone https://github.com/SoftEtherVPN/SoftEtherVPN_Stable.git
cd SoftEtherVPN_Stable
apt -y install cmake gcc g++ libncurses5-dev libreadline-dev libssl-dev make zlib1g-dev
./configure
make install
cd ..
vpnserver start

echo "Enter new password:"
read -s password
(cat <<EOF
OpenVpnEnable yes /PORTS:"1194"
SecureNatEnable
OpenVpnMakeConfig openvpnconfig/openvpnconfig.zip
EOF
)|vpncmd localhost:5555 /server /adminhub:DEFAULT /password:"" /CMD

unzip openvpnconfig/openvpnconfig.zip
install -C -m 775 -o www-data openvpnconfig/*l3.ovpn /var/www/yehudae.ga/openvpnconfig.ovpn
cd ..
