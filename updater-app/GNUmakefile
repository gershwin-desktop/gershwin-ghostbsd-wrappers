include $(GNUSTEP_MAKEFILES)/common.make

APP_NAME = Updater

Updater_OBJC_FILES = \
	main.m \
	UpdaterLauncher.m

include $(GNUSTEP_MAKEFILES)/application.make

# Create the Info.plist file
after-all::
	@echo "Creating Info-gnustep.plist..."
	@echo '{' > Updater.app/Resources/Info-gnustep.plist
	@echo '    ApplicationName = "Updater";' >> Updater.app/Resources/Info-gnustep.plist
	@echo '    ApplicationDescription = "Updater Web Browser";' >> Updater.app/Resources/Info-gnustep.plist
	@echo '    ApplicationRelease = "1.0";' >> Updater.app/Resources/Info-gnustep.plist
	@echo '    NSExecutable = "Updater";' >> Updater.app/Resources/Info-gnustep.plist
	@echo '    CFBundleIconFile = "Updater.png";' >> Updater.app/Resources/Info-gnustep.plist
	@echo '    NSPrincipalClass = "NSApplication";' >> Updater.app/Resources/Info-gnustep.plist
	@echo '    LSUIElement = "NO";' >> Updater.app/Resources/Info-gnustep.plist
	@echo '}' >> Updater.app/Resources/Info-gnustep.plist
	@echo "Info-gnustep.plist created successfully"
	@if [ -f Updater.png ]; then \
		echo "Copying Updater.png to app bundle..."; \
		cp Updater.png Updater.app/Resources/; \
	else \
		echo "Creating placeholder Updater.png..."; \
		echo "Place your Updater.png icon in the Resources directory"; \
		touch Updater.app/Resources/Updater.png; \
	fi
