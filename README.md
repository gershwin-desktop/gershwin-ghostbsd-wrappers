# ghostbsd-gershwin-wrappers
Compiled application wrappers

### Prerequisites

- Gershwin installation

## Build Instructions

### Build the wrappers
```bash
gmake
```

### Install wrappers in /Applications
```bash
sudo gmake install 
```

### Generate new wrappers

```bash
./generate-wrapper-code.sh Chromium /usr/local/bin/chromium /Users/jmaloney/Downloads/chrome.png
```

### Find icon using XDG

```bash
./iconfinder.sh /usr/local/share/applications/chromium-browser.desktop
```
