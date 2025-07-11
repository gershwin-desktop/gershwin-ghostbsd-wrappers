# Top-level GNUmakefile for ghostbsd-gershwin-wrappers
# Builds and installs CLI tools and app wrappers

# Define app subdirectories
APP_DIRS = backups-app software-app updater-app

# Define CLI scripts to install
CLI_SCRIPTS = Library/Tools/Backups-CLI Library/Tools/Software-CLI Library/Tools/Updater-CLI

# Installation directories
CLI_INSTALL_DIR = /Library/Tools
APP_INSTALL_DIR = /Applications

# Default target - build everything (no installation)
all: build-apps

# Install CLI scripts to /Library/Tools
install-cli-scripts:
	@echo "Installing CLI scripts to $(CLI_INSTALL_DIR)..."
	@mkdir -p $(CLI_INSTALL_DIR)
	@for script in $(CLI_SCRIPTS); do \
		echo "Installing $$script to $(CLI_INSTALL_DIR)/"; \
		install -m 755 "$$script" "$(CLI_INSTALL_DIR)/"; \
	done
	@echo "CLI scripts installed successfully"

# Build all apps
build-apps:
	@echo "Building all applications..."
	@for dir in $(APP_DIRS); do \
		echo "Building $$dir..."; \
		$(MAKE) -C $$dir || exit 1; \
	done
	@echo "All applications built successfully"

# Install all apps to /Applications
install-apps:
	@echo "Installing all applications to $(APP_INSTALL_DIR)..."
	@for dir in $(APP_DIRS); do \
		echo "Installing from $$dir..."; \
		$(MAKE) -C $$dir install INSTALL_ROOT=$(APP_INSTALL_DIR) || exit 1; \
	done
	@echo "All applications installed successfully"

# Full install - CLI scripts and apps
install: install-cli-scripts build-apps install-apps

# Clean all build artifacts
clean:
	@echo "Cleaning all build artifacts..."
	@for dir in $(APP_DIRS); do \
		echo "Cleaning $$dir..."; \
		$(MAKE) -C $$dir clean || true; \
	done
	@echo "Clean completed"

# Individual app targets
build-backups:
	@echo "Building Backups app..."
	@$(MAKE) -C backups-app

build-installer:
	@echo "Building Installer app..."
	@$(MAKE) -C installer-app

build-software:
	@echo "Building Software app..."
	@$(MAKE) -C software-app

build-updater:
	@echo "Building Updater app..."
	@$(MAKE) -C updater-app

# Individual install targets
install-backups: build-backups
	@echo "Installing Backups app..."
	@$(MAKE) -C backups-app install INSTALL_ROOT=$(APP_INSTALL_DIR)

install-installer: build-installer
	@echo "Installing Installer app..."
	@$(MAKE) -C installer-app install INSTALL_ROOT=$(APP_INSTALL_DIR)

install-software: build-software
	@echo "Installing Software app..."
	@$(MAKE) -C software-app install INSTALL_ROOT=$(APP_INSTALL_DIR)

install-updater: build-updater
	@echo "Installing Updater app..."
	@$(MAKE) -C updater-app install INSTALL_ROOT=$(APP_INSTALL_DIR)

# Uninstall CLI scripts
uninstall-cli-scripts:
	@echo "Removing CLI scripts from $(CLI_INSTALL_DIR)..."
	@for script in $(CLI_SCRIPTS); do \
		script_name=$$(basename "$$script"); \
		if [ -f "$(CLI_INSTALL_DIR)/$$script_name" ]; then \
			echo "Removing $(CLI_INSTALL_DIR)/$$script_name"; \
			rm -f "$(CLI_INSTALL_DIR)/$$script_name"; \
		fi; \
	done

# Uninstall apps
uninstall-apps:
	@echo "Removing applications from $(APP_INSTALL_DIR)..."
	@if [ -d "$(APP_INSTALL_DIR)/Backups.app" ]; then \
		echo "Removing $(APP_INSTALL_DIR)/Backups.app"; \
		rm -rf "$(APP_INSTALL_DIR)/Backups.app"; \
	fi
	@if [ -d "$(APP_INSTALL_DIR)/Installer.app" ]; then \
		echo "Removing $(APP_INSTALL_DIR)/Installer.app"; \
		rm -rf "$(APP_INSTALL_DIR)/Installer.app"; \
	fi
	@if [ -d "$(APP_INSTALL_DIR)/Software.app" ]; then \
		echo "Removing $(APP_INSTALL_DIR)/Software.app"; \
		rm -rf "$(APP_INSTALL_DIR)/Software.app"; \
	fi
	@if [ -d "$(APP_INSTALL_DIR)/Updater.app" ]; then \
		echo "Removing $(APP_INSTALL_DIR)/Updater.app"; \
		rm -rf "$(APP_INSTALL_DIR)/Updater.app"; \
	fi

# Full uninstall
uninstall: uninstall-cli-scripts uninstall-apps

# Help target
help:
	@echo "GhostBSD Gershwin Wrappers Build System"
	@echo ""
	@echo "Available targets:"
	@echo "  all                 - Build all apps (default, no installation)"
	@echo "  install             - Install CLI scripts and build/install all apps"
	@echo "  install-cli-scripts - Install CLI scripts to $(CLI_INSTALL_DIR)"
	@echo "  build-apps          - Build all applications"
	@echo "  install-apps        - Install all applications to $(APP_INSTALL_DIR)"
	@echo ""
	@echo "Individual app targets:"
	@echo "  build-backups       - Build Backups app only"
	@echo "  build-installer     - Build Installer app only"
	@echo "  build-software      - Build Software app only"
	@echo "  build-updater       - Build Updater app only"
	@echo ""
	@echo "Individual install targets:"
	@echo "  install-backups     - Build and install Backups app"
	@echo "  install-installer   - Build and install Installer app"
	@echo "  install-software    - Build and install Software app"
	@echo "  install-updater     - Build and install Updater app"
	@echo ""
	@echo "Cleanup targets:"
	@echo "  clean               - Clean all build artifacts"
	@echo "  uninstall           - Remove all installed files"
	@echo "  uninstall-cli-scripts - Remove CLI scripts only"
	@echo "  uninstall-apps      - Remove installed apps only"
	@echo ""
	@echo "Usage examples:"
	@echo "  gmake               - Build everything"
	@echo "  sudo gmake install  - Install everything"
	@echo "  gmake clean         - Clean build artifacts"
	@echo "  sudo gmake uninstall - Remove all installed files"

# Declare phony targets
.PHONY: all install install-cli-scripts build-apps install-apps clean \
        build-backups build-installer build-software build-updater \
        install-backups install-installer install-software install-updater \
        uninstall uninstall-cli-scripts uninstall-apps help
