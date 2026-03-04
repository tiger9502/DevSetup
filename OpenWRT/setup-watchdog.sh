#!/bin/bash

set -e

echo "Creating /etc/config/resettether..."
cat > /etc/config/resettether << 'EOF'
if pgrep -f "easytether-usb" > /dev/null 2>&1; then
    kill $(pgrep -f "easytether-usb" | grep -v $$)
fi
sleep 5
easytether-usb
EOF

chmod +x /etc/config/resettether

echo "Creating /etc/config/easytether..."
cat > /etc/config/easytether << 'EOF'
for i in $(seq 1 20);
do
    if (ip a s tap-easytether up); then
        :
    else
        sh /etc/config/resettether
    fi
    sleep 5
done
EOF

chmod +x /etc/config/easytether

echo "Creating /etc/config/watchdog..."
cat > /etc/config/watchdog << 'EOF'
. /lib/functions/network.sh
network_flush_cache
network_find_wan NET_IF
network_get_gateway NET_GW "${NET_IF}"

if ping -c 1 -w 3 "${NET_GW}" &> /dev/null; then
    if curl -s --head --connect-timeout 5 "https://github.com" > /dev/null 2>&1; then
        exit 0
    fi
fi

sh /etc/config/resettether
EOF

chmod +x /etc/config/watchdog

echo "Configuring cron jobs..."
crontab -l 2>/dev/null | grep -v "easytether" | grep -v "watchdog" | grep -v "reboot -f" > /tmp/crontab.tmp || true
cat >> /tmp/crontab.tmp << 'EOF'
0 6 */15 * * reboot -f
* * * * * sh /etc/config/easytether
* * * * * sh /etc/config/watchdog
EOF
crontab /tmp/crontab.tmp
rm /tmp/crontab.tmp

echo "Restarting cron service..."
/etc/init.d/cron restart

echo "Blocking Apple MDM enrollment..."
if ! grep -q "iprofiles.apple.com" /etc/hosts; then
    echo "0.0.0.0 iprofiles.apple.com" >> /etc/hosts
fi
if ! grep -q "mdmenrollment.apple.com" /etc/hosts; then
    echo "0.0.0.0 mdmenrollment.apple.com" >> /etc/hosts
fi
if ! grep -q "deviceenrollment.apple.com" /etc/hosts; then
    echo "0.0.0.0 deviceenrollment.apple.com" >> /etc/hosts
fi
if ! grep -q "gdmf.apple.com" /etc/hosts; then
    echo "0.0.0.0 gdmf.apple.com" >> /etc/hosts
fi
