# MacOS Developer Setups

The following is a step by step guide on how to setup a fresh computer for common development work.


## MacOS
For a better terminal experience, install iTerm:
```
https://iterm2.com/downloads.html
```

Before start, make sure XCode is installed together with CLT:
```
xcode-select --install
```

### Homebrew
```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### VSCode
```
https://code.visualstudio.com/download
```

Launch VSCode, press SHIFT+COMMAND+P and select "install 'code' command in PATH"

### Golang
Find the instruction here: ```https://go.dev/doc/install```

### Javascript
```
brew install nvm && brew install npm
```

### Python
If pytorch is required, check the python3 version supported by the latest pytorch version.
As of this writing, the latest supported version is 3.11.
```
brew install python@3.11 && pip3 install --user pipenv
python3 -m pip install --upgrade pip
```

Then optionally install the relevant pytorch packages:
```
pip3 install --user torch torchvision torchaudio
```

In order to start developing with pytorch, it's recommended to use an isolated environment. In a python project directory:
```
python3.11 -m venv .
```
Modify the pyvenv.cfg file to point to the correct python version. Late you can activate and deactivate the python environment with:
```
source ./bin/activate
deactivate
```

### Docker
Install docker desktop:
```
https://docs.docker.com/desktop/install/mac-install/
```

Then pull the essential docker images. For web development, typically:
```
docker pull mysql
docker pull redis
```

### Git
```
brew install git
```
To make sure git works correctly, first we generate a ssh keys (replace the email to a desired address):
```
ssh-keygen -t ed25519 -C "******@gmail.com"
```

Go to ```https://github.com/settings/keys``` and add a new ssh key. Paste the content of the following file that was just generated:
```
more ~/.ssh/id_ed25519.pub
```

And finally, add the ssh key to the ssh config:
```
touch ~/.ssh/config
```

Add the entry:
```
Host github.com
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_ed25519
```
Note:  Omit the "UseKeychain" line if ssh key was not generated with a passphrase.

Now you should be able to autenticate into your github repos.

Finally make sure to set a desired git author:
```
git config --global user.name "***** **"
git config --global user.email "*********@users.noreply.github.com"
```
