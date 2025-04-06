# Quest Remote Workstation Setup

## Prerequisites
We need to enable Developer Mode for the Quest device, typically via the Meta Desktop or Mobile App.

## Get Linux
As an Android 14 device, we can get linux running via [Termux](https://f-droid.org/en/packages/com.termux/). Install the downloaded apk using a computer with Android Platform Tools:
```adb install termux.apk```

Open the Termux app and update its packages:
```pkg update && pkg upgrade```

Install the proot package for Termux:
```pkg install proot-distro```

Get the alpine linux flavor for proot:
```
proot-distro list
proot-distro install alpine
```

Login into the alpine flavor linux environment:
```proot-distro login alpine```

Install required libraries:
```apk update && apk upgrade && apk add libstdc++```

Download VSCode:
```wget -O ```