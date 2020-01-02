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
vpnserver start

openvpnconfig=mktemp /tmp/openvpnconfig_XXXXXXXXX.zip
echo "Enter new password:"
read -s password
(cat <<EOF
ServerPasswordSet $password
OpenVpnEnable yes /PORTS:"1194"
SecureNatEnable
OpenVpnMakeConfig $openvpnconfig
EOF
)|vpncmd localhost:5555 /server /adminhub:DEFAULT /password: /IN

cd ..
rm -R build
