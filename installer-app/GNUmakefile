include $(GNUSTEP_MAKEFILES)/common.make

APP_NAME = Installer

Installer_OBJC_FILES = \
	main.m \
	InstallerLauncher.m

include $(GNUSTEP_MAKEFILES)/application.make

# Create the Info.plist file
after-all::
	@echo "Creating Info-gnustep.plist..."
	@echo '{' > Installer.app/Resources/Info-gnustep.plist
	@echo '    ApplicationName = "Installer";' >> Installer.app/Resources/Info-gnustep.plist
	@echo '    ApplicationDescription = "Installer Web Browser";' >> Installer.app/Resources/Info-gnustep.plist
	@echo '    ApplicationRelease = "1.0";' >> Installer.app/Resources/Info-gnustep.plist
	@echo '    NSExecutable = "Installer";' >> Installer.app/Resources/Info-gnustep.plist
	@echo '    CFBundleIconFile = "Installer.png";' >> Installer.app/Resources/Info-gnustep.plist
	@echo '    NSPrincipalClass = "NSApplication";' >> Installer.app/Resources/Info-gnustep.plist
	@echo '    LSUIElement = "NO";' >> Installer.app/Resources/Info-gnustep.plist
	@echo '}' >> Installer.app/Resources/Info-gnustep.plist
	@echo "Info-gnustep.plist created successfully"
	@if [ -f Installer.png ]; then \
		echo "Copying Installer.png to app bundle..."; \
		cp Installer.png Installer.app/Resources/; \
	else \
		echo "Creating placeholder Installer.png..."; \
		echo "Place your Installer.png icon in the Resources directory"; \
		touch Installer.app/Resources/Installer.png; \
	fi
