# Developer Setups

The following is a step by step guide on how to setup a fresh computer for common development work.

## MacOS
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
brew install python@3.11 && pip install --user pipenv
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
