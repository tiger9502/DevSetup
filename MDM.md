# This is a guide for bypassing the MDM enrollment for various devices.

## Apple Silicon Mac

Useful Downloads:
- IPSW: ipsw.me/product/mac
- Configurator 2: find in Apple Appstore

### Step 1:
Follow the official guide and boot the mac into Recovery.

Use the "Disk Utility" and delete the entire drive of Macintosh HD.

### Step 2:
Follow the official guide to boot the mac into DFU.

Using another macbook with Configurator 2, download and restore the operating system into the MDM managed Mac. This guide was tested with OS Ventura.

### Step 3:
Boot into Recovery mode again. Open terminal and perform the following:
- Disable SIP with ```csrutil disable```
- Activate the root user:
    ```dscl -f /Volumes/Data/private/var/db/dslocal/nodes/Default localhost -passwd /Local/Default/Users/root```
- When prompted, create a root user password.
- Note the Data volume could have different paths depending on the OS.

### Step 4:
- Restart the Mac, go through setup but stop before connecting to WiFi.
- Open terminal by pressing ```Command + Option + Control + T```
- The Apple menu should be now accessible by clicking the apple logo on the top left of the screen. Go to System Settings -> Users and Groups -> Add Account.
- When asked for permissions, use the root account and password entered before. Create a new user and set as administrator.
- Turn off the Mac by long pressing the power button.



