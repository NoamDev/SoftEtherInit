git clone https://github.com/SoftEtherVPN/SoftEtherVPN_Stable.git
cd SoftEtherVPN_Stable
sudo apt -y install cmake gcc g++ libncurses5-dev libreadline-dev libssl-dev make zlib1g-dev
./configure
sudo make install
sudo vpnserver start

openvpnconfig=mktemp /tmp/openvpnconfig_XXXXXXXXX.zip
echo "Enter new password:"
read -s password
(cat <<EOF
ServerPasswordSet $password
OpenVpnEnable yes /PORTS:"1194"
SecureNatEnable
OpenVpnMakeConfig $openvpnconfig
EOF
)|sudo vpncmd localhost:5555 /server /adminhub:DEFAULT /password: /IN