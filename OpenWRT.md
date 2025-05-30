# OpenWRT Setup Instructions

Note most of the setup steps are based on ~~GL-iNet B1300 Model~~. Updated: GL-iNet AX1800.
Note that the setup guide assumes that we will end up with the subnet starting at 192.168.1.1.

## Step 1: Firmware
- In luci, there is an option to upgrade the firmware with OpenWRT versions. You may find the images on OpenWRT's official site, for example [here](https://openwrt.org/toh/gl.inet/gl-b1300#upgrading_openwrt).
> [!NOTE]
> For AX1800, OpenWRT version 21.02 works (Firmware version 4.6.8). Newer firmware does not work as of May 2025.
- Once flashed, you will need to connect to 192.168.1.1 via an ethernet connection. Set an admin password in System -> Administration. (Note: for different models the default gateway may be different; it is 192.168.8.1 for AX1800)
- Go to Network -> Wireless. Enable all wireless interfaces, set SSID and wifi password (recommended security: WPA2-PSK). Note that you should set different SSIDs for 2.4G and 5G networks.

## ~~Step 1 Deprecated: Basic Setups~~
- ~~Login to router's admin interface. Make sure there is an internet connection, typically via an ethernet cable.~~
- ~~Set a new admin password. If there are subnet conflict, also set a different subnet by editing the second to last integer in the gateway ip address.~~
- ~~Update the router's firmware by downloading the latest stable release from the manufacture's website. [Example](https://dl.gl-inet.com/router/b1300/)~~
- ~~Depending on the firmware, you may need to set the admin password etc. again.~~
- ~~Go to advanced, and install luci if it's not already installed.~~

## Step 2: OpenWRT
- SSH into the router with ```ssh -o HostKeyAlgorithms=+ssh-rsa -o PubkeyAcceptedKeyTypes=+ssh-rsa root@192.168.1.1``` and the admin password.
> [!NOTE]
> For AX1800, the following steps should be skipped. Proceed to Step 3.
- Create file ```/etc/config/firewall.user```:
  ```
  nft add rule inet fw4 mangle_forward oifname usb0 ip ttl set 65
  ```
- Modify ```/etc/config/firewall```, and add the following:
  ```
  config include
    option path '/etc/config/firewall.user'
    option fw4_compatible '1'
  ```
- Restart the firewall: ```/etc/init.d/firewall restart```

## ~~Step 2 Deprecated: Add Luci iptables TTL Rule~~
- ~~Skip this step if you flashed OpenWRT 22.03 in Step 1A.~~
- ~~Login to luci using the samd admin password as root.~~
- ~~Go to Network > Firewall > Custom Rules.~~
- ~~Add the following line at the end:~~
~~```iptables -t mangle -I POSTROUTING -o usb0 -j TTL --ttl-set 65```~~

## Step 3: Prepare Linux Environment
- You may need to connect the router to a wifi network to get access to the internet. Refer to [this instruction](https://openwrt.org/docs/guide-user/network/wifi/connect_client_wifi).
- If the router gateway is 192.168.1.1, first go to Network > Interfaces > LAN and set IPv4 Address temporarily to 192.168.2.1. Save, and re-login to OpenWRT using 192.168.2.1.
- In Network > Wireless, Click Scan on any radio and select the Wifi network; enter the password/key and save and apply. Make sure the mode of the interface is set to Client; you may need to disable the other radio. Note, modern phones usually only allow tethering via the 5G radio (802.11ac/n).
- SSH into the router with ```ssh -o HostKeyAlgorithms=+ssh-rsa root@192.168.2.1``` and the same admin password. Note that the router's IP address may be different.
- Install the following useful packages:
    ```
    opkg update
    opkg install openssh-sftp-server openssl-util kmod-usb-net-rndis kmod-usb-storage
    ```

## Step 4: Install easytether Driver
Refer to [this guide](https://docs.gl-inet.com/en/3/tutorials/tether/)
- Find the chipset information on the router's website. [Example](https://www.gl-inet.com/products/gl-b1300/). For B1300, the chipset is arm_cortex-a7_neon-vfpv4.
- Go to easytether's [driver download page](http://www.mobile-stream.com/easytether/drivers.html) and locate the right driver. Typically, use the tiny driver. [Example](http://www.mobile-stream.com/beta/openwrt/easytether-usb-tiny_0.8.9-5_openwrt-19.07.3.zip)
- For GLiNet AX1800, we will need to use the bcm53xx driver (opkg install won't work). Find the latest driver similar to below, extract and copy the content to system paths:
    ```
    wget http://www.mobile-stream.com/beta/openwrt/easytether-usb-tiny_0.8.9-5_openwrt-19.07.3.zip
    opkg install bsdtar
    bsdtar -zxf easytether-usb-tiny_0.8.9-5_openwrt-19.07.3.zip
    cd 19.07.3/bcm53xx/generic/
    bsdtar -zxf easytether-usb-tiny_0.8.9-5_arm_cortex-a9.ipk
    bsdtar -zxf data.tar.gz -C /
    ```
  If the bsdtar package is no longer available, manually download and unzip the package and transfer data.tar.gz to the router via SCP. Run the last command with tar instead of bsdtar.
- ~~Unzip the driver and find the correct chipset folder. Using SCP and transfer the correct driver into the router, such as:~~
    ~~```scp ~/Downloads/19.07.3/ipq40xx/generic/easytether-usb-tiny_0.8.9-5_arm_cortex-a7_neon-vfpv4.ipk root@192.168.2.1:/tmp/```~~
- ~~SSH into the router and install the driver like so:~~
    ~~```opkg install /tmp/easytether-usb-tiny_0.8.9-5_arm_cortex-a7_neon-vfpv4.ipk```~~
- Add an adbkey as follows:
    ```
    mkdir -p /etc/easytether &&
    openssl genpkey -algorithm rsa -pkeyopt rsa_keygen_bits:2048 -out /etc/easytether/adbkey &&
    chown root:root /etc/easytether/adbkey &&
    chmod 600 /etc/easytether/adbkey
    ```
- Edit /etc/config/network, and make sure the relevant sections contain the correct options:
  - config interface 'wan' and 'wan6' should contain (proto may be'dhcpv6' for wan6):
    ```
    option proto 'dhcp'
    option ifname 'tap-easytether'
    ```
  - create an interface 'easytether':
    ```
    config interface easytether
        option proto 'dhcp'
        option metric '30'
        option ifname 'tap-easytether'
    ```
- ~~(deprecated) Edit /etc/config/firewall, and find the zone config containing ```option name 'wan'```, modify the ```option network``` line by adding ```easytether``` to the end like:~~
    ~~```option network 'wan wan6 wwan easytether'```~~
  If it's OpenWRT 23.05, find ```list network 'wan'``` and so on in /etc/config/firewall. Add an additional line:
    ```
    list network 'easytether'
    ```
- To make your life easier later, remove the Client Wifi Network. Restore the LAN IPv4 Address to 192.168.1.1 if not set already.

## Step 5: Phone Connection
- Make sure to use an Android phone that has been rooted. Install the easytether pro app and go through with the tutorial.
- In Android Settings > Developer Options, make sure that USB debugging is enabled. Default USB mode should be file transfer (MTP). Also, turn off the USB debugging timeout.
- Connect the phone to the router using a USB cable. If prompted, select always allow USB debugging from the device.
- SSH in to the router again. Verify that easytether-usb works: ```easytehter-usb```. You should see a log saying it's CONNECTED.
- Verify that the easytether app shows "Connection Established".

## Step 6: Optimizations
We need to create a few scripts to help us monitor and automate the tethering process.
- (Deprecated) First, a quick script to reset the USB interface.

  >[!NOTE]
  >The package usbutils may no longer be available. Alternatives are WIP.

  Make sure we have the required package installed: ```opkg install usbutils```
  Create ```/etc/config/resettether```:
  ```
  for i in $(seq 1 60);
  do
      if (usbreset "Pixel 6a" || usbreset SAMSUNG_android || usbreset 001/002)
      then exit 0
      fi
      sleep 5
  done

  reboot -f
  ```
  ~~Note that it should contain all cellphone models that you are expected to tether with. To find the proper product name, use:~~
  ```
  lsusb -v | grep iProduct
  ```
- Next, add a script to automatically reconnect to tether at ```/etc/config/easytether```:
  ```
  for i in $(seq 1 20);
  do
      if (ip a s tap-easytether up); then
          :
      else
          sh /etc/config/resettether && easytether-usb
      fi
      sleep 3
  done
  ```
- Add a script to detect downage at ```/etc/config/watchdog```:
  ```
  . /lib/functions/network.sh
  network_flush_cache
  network_find_wan NET_IF
  network_get_gateway NET_GW "${NET_IF}"

  for i in $(seq 1 5);
  do
      if ping -c 1 -w 3 "${NET_GW}" &> /dev/null
      then exit 0
      fi
  done

  sh /etc/config/resettether
  ```
- Finally, use ```crontab -e``` to edit the cron jobs:
  ```
  * * * * * sh /etc/config/easytether
  * * * * * sh /etc/config/watchdog
  0 6 * * * reboot -f
  ```
  The reboot line does a reboot everyday at 6am. You may want to change or exclude this.


## Additional Note
- If at any time the radio networks in wireless section need to be recreated, make sure to use mode "Access Point" and network "lan".

## Congratulations, you have completed the setup for easytether.
