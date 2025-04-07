# Android/Quest Remote Workstation Setup

## Prerequisites
We need to enable Developer Mode for the Quest device, typically via the Meta Desktop or Mobile App.

## Android 15: Linux with Termux
For Android 15 or earlier devices, we can get linux running via [Termux](https://f-droid.org/en/packages/com.termux/). Install the downloaded apk using a computer with Android Platform Tools:
```adb install termux.apk```

Open the Termux app and update its packages:
```pkg update && pkg upgrade```

Install the proot package for Termux:
```pkg install proot-distro```

### Use Android Device as VSCode Server Locally
Get the ubuntu flavor for proot:
```
proot-distro list
proot-distro install ubuntu
```

Login into the ubuntu flavor linux environment:
```proot-distro login ubuntu```

Install required libraries:
```
apt-get update && apt-get upgrade
apt-get install wget git
```

Download VSCode. Find the latest releases on [github](https://github.com/coder/code-server/releases/). (For most Android devices we need the arm64 version):
```
wget -O - https://github.com/coder/code-server/releases/download/v4.98.2/code-server-4.98.2-macos-arm64.tar.gz | tar -C code-server -xvf
```

Now we can start a local code server from the ```bin``` folder of the extracted files. We need to set a password to login to the VSCode web interface:
```
cd code-server/bin
PASSWORD="any_password" ./code-server
```
The actual interface will be accessible via a browser (by default at 127.0.0.1:8080)

### Use Code Tunnel
If we are using the device with an internet connection, we can use the tunneling function of VSCode. For this we can use the lightweight alpine flavor of linux:
```
proot-distro install alpine
proot-distro login alpine
```

Install required packages:
```
apk update && apk upgrade
apk add libstdc++ git
```

Download VSCode for tunneling:
```
wget -O - https://update.code.visualstudio.com/latest/cli-alpine-arm64/stable | tar -C /usr/local/bin -xzf
```

Now start VSCode tunnel and follow the prompt:
```
code tunnel
```

## Android 16: Native Linux
