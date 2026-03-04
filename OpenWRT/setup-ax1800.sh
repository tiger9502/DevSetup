#!/bin/bash

set -e

echo "Updating package list..."
opkg update

echo "Installing useful packages..."
opkg install unzip openssh-sftp-server openssl-util kmod-usb-net-rndis kmod-usb-storage usbutils

echo "Downloading and installing easytether driver..."
wget http://www.mobile-stream.com/beta/openwrt/easytether-usb-tiny_0.8.9-5_openwrt-19.07.3.zip
unzip easytether-usb-tiny_0.8.9-5_openwrt-19.07.3.zip
tar -zxf 19.07.3/bcm53xx/generic/easytether-usb-tiny_0.8.9-5_arm_cortex-a9.ipk
tar -zxf data.tar.gz -C /

echo "Creating adbkey..."
mkdir -p /etc/easytether
openssl genpkey -algorithm rsa -pkeyopt rsa_keygen_bits:2048 -out /etc/easytether/adbkey
chown root:root /etc/easytether/adbkey
chmod 600 /etc/easytether/adbkey

echo "Configuring network interface..."
if [ ! -f /etc/config/network ]; then
    echo "Error: /etc/config/network not found"
    exit 1
fi

cp /etc/config/network /etc/config/network.bak

if grep -q "^config interface 'wan'" /etc/config/network; then
    sed -i '/^config interface.*'"'"'wan'"'"'$/,/^$/{ /option proto/d; /option ifname/d; }' /etc/config/network
    sed -i '/^config interface.*'"'"'wan'"'"'$/a\    option proto '"'"'dhcp'"'"'\n    option ifname '"'"'tap-easytether'"'"'' /etc/config/network
fi

if grep -q "^config interface 'wan6'" /etc/config/network; then
    sed -i '/^config interface.*'"'"'wan6'"'"'$/,/^$/{ /option proto/d; /option ifname/d; }' /etc/config/network
    sed -i '/^config interface.*'"'"'wan6'"'"'$/a\    option proto '"'"'dhcp'"'"'\n    option ifname '"'"'tap-easytether'"'"'' /etc/config/network
fi

if ! grep -q "^config interface 'easytether'" /etc/config/network; then
    cat >> /etc/config/network << EOF

config interface 'easytether'
    option proto 'dhcp'
    option metric '30'
    option ifname 'tap-easytether'
EOF
fi

echo "Creating firewall.user..."
cat > /etc/firewall.user << EOF
iptables -t mangle -I POSTROUTING -o usb0 -j TTL --ttl-set 65
EOF

echo "Modifying firewall configuration..."
if [ ! -f /etc/config/firewall ]; then
    echo "Error: /etc/config/firewall not found"
    exit 1
fi

cp /etc/config/firewall /etc/config/firewall.bak

if grep -q "^config include" /etc/config/firewall; then
    if ! grep -A2 "^config include" /etc/config/firewall | grep -q "option fw4_compatible '1'"; then
        sed -i "/option path '\/etc\/firewall.user'/a\\    option fw4_compatible '1'" /etc/config/firewall
    fi
else
    cat >> /etc/config/firewall << EOF

config include
    option path '/etc/firewall.user'
    option fw4_compatible '1'
EOF
fi

if ! grep -q "list network 'easytether'" /etc/config/firewall; then
    sed -i "/list network 'wwan'/a\\    list network 'easytether'" /etc/config/firewall
fi

echo "Restarting firewall..."
/etc/init.d/firewall restart
