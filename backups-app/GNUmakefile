include $(GNUSTEP_MAKEFILES)/common.make

APP_NAME = Backups

Backups_OBJC_FILES = \
	main.m \
	BackupsLauncher.m

include $(GNUSTEP_MAKEFILES)/application.make

# Create the Info.plist file
after-all::
	@echo "Creating Info-gnustep.plist..."
	@echo '{' > Backups.app/Resources/Info-gnustep.plist
	@echo '    ApplicationName = "Backups";' >> Backups.app/Resources/Info-gnustep.plist
	@echo '    ApplicationDescription = "Backups Web Browser";' >> Backups.app/Resources/Info-gnustep.plist
	@echo '    ApplicationRelease = "1.0";' >> Backups.app/Resources/Info-gnustep.plist
	@echo '    NSExecutable = "Backups";' >> Backups.app/Resources/Info-gnustep.plist
	@echo '    CFBundleIconFile = "Backups.png";' >> Backups.app/Resources/Info-gnustep.plist
	@echo '    NSPrincipalClass = "NSApplication";' >> Backups.app/Resources/Info-gnustep.plist
	@echo '    LSUIElement = "NO";' >> Backups.app/Resources/Info-gnustep.plist
	@echo '}' >> Backups.app/Resources/Info-gnustep.plist
	@echo "Info-gnustep.plist created successfully"
	@if [ -f Backups.png ]; then \
		echo "Copying Backups.png to app bundle..."; \
		cp Backups.png Backups.app/Resources/; \
	else \
		echo "Creating placeholder Backups.png..."; \
		echo "Place your Backups.png icon in the Resources directory"; \
		touch Backups.app/Resources/Backups.png; \
	fi
