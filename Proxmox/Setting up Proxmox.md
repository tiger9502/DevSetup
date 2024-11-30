## Installing Proxmox
### Hardware overview
We start with the OpenWRT router we have already set up as the network gateway and router. This setup allows us to get internet access by tethering to the cellular network via 5G.

The Proxmox virtualization environment will be installed on a mini computer. In 2024, this is a CWWK 4 net-port NAS server with N100 processor and 16GB of ram. It has a four NVME SSD array intended for a RAID-10 setup, offering a reliable data storage of 2TB.

Additionally, the Proxmox VE will be installed on a system drive of 256GB capacity.

### Install procedure
It's better to prepare a boot usb using [Ventoy](https://github.com/ventoy/Ventoy). Copy the proxmox installation iso onto the ventoy usb and boot the machine into the installer.

Follow the instructions to finish setting up Proxmox VE. Note, a static ip address must be assigned to the Proxmox server in the local lan. For example, we can set the name of the server to "mox.lan" and the ip address to "192.168.1.105/24". Proceed to set a root password.

Once installation is finished, we can login as root into the debian shell. Next, add the free (licenseless) debian repo:
```nano /etc/apt/sources.list```

Insert a line as follows: ```deb http://download.proxmox.com/debian/pve bookworm pve-no-subscription```
Save, and update the packages: ```apt update && apt upgrade -y```

Verify that the web interface is accessible using the root login by visiting the proxmox server lan address with port 8006 (i.e. 192.168.1.105:8006).

Note the repo can also be updated by using the web interface under Node -> Updates -> Repositories.

## NAS related setups (SMB)
hint: In proxmox host, examine all the disk volumes: ```fdisk -l```

Using the web interface, create a zfs volume by selecting all drives. Pick a RAID setting (for secure data use RAID 10). If the drives were previously formatted they will need to be wiped so remember to back up the data.

Go to the local drive (not zfs) and download the template for alpine container template. Create a new CT using the downloaded template with the following settings:
- General:
```
Host name: samba (example)
CT ID: (choose an ID)
Password: (set a root password for the NAS server)
```
- Template:
```
Storage: local (name of the local volume for proxmox)
Template: (the alpine linux image we downloaded)
```

- Disk, CPU, Memory:
```
Storage: (choose the local volume)
Disk Size: 4GB (this is the container disk size. We will add the NAS volume later)
Cores: 1
Memory: 512
Swap: 512
```

- Network, DNS:
Use default settings (Optional: change the static IP address for the NAS server)

Once the LXC is up and running, using the console terminal to login with the root password created. Excecute the following commands:
```
apk -U upgrade && apk add openssh nano samba
mkdir /samba && chmod 0777 /samba
```

Edit the ssh config by ```nano /etc/ssh/sshd_config``` and change "PermitRootLogin" to "yes" for easier ssh access.
Edit samba config by inserting into ```nano /etc/samba/smb.conf```:
```
[nas]
  browseable = yes
  writable = yes
  path = /samba
```

Add samba user with password (set user and SMB passwords when prompted):
```
adduser <your_samba_username>
smbpasswd -a <your_samba_username>
```

Finally start samba as a service:
```
rc-update add samba && rc-service samba start
```

At this point you should be able to access the nas server via SMB. Next we mount the nas volume at /samba in the samba server. Go to proxmox, under the "Resources" tab for the samba server, create a new Mount Point with the nas dataset to ```/samba```.

Inside the samba server, you can verify that the mount point is successfully mounted by ```df -h```. Now make the samba user own the shared folder:
```
chown -R <username>:<username> /samba
```
Now verify read/write are working correctly by connecting to the NAS using the username and SMB password.

To make samba discoverable locally by windows, run:
```
apk add wsdd
rc-update add wsdd && rc-service wsdd start
```


## Docker host

## Dev environment

## External access

## GPU compute

## External hosting

## Email server

## Video conference hosting

## Media servers

## Smart home integration
