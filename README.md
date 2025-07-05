# ghostbsd-gershwin-wrappers
Compiled application wrappers designed to provide proper dock status

Prerequisites

- Gershwin installation

## Build Instructions

### Build
```bash
gmake
```

### Install
```bash
sudo gmake install 
```

### Run
```bash
openapp HelloWorld
```

### Generate new wrappers

```
./generate-wrapper-code.sh Chromium /usr/local/bin/chromium /Users/jmaloney/Downloads/chrome.png
```



