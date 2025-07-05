include $(GNUSTEP_MAKEFILES)/common.make

APP_NAME = Software

Software_OBJC_FILES = \
	main.m \
	SoftwareLauncher.m

include $(GNUSTEP_MAKEFILES)/application.make

# Create the Info.plist file
after-all::
	@echo "Creating Info-gnustep.plist..."
	@echo '{' > Software.app/Resources/Info-gnustep.plist
	@echo '    ApplicationName = "Software";' >> Software.app/Resources/Info-gnustep.plist
	@echo '    ApplicationDescription = "Software Web Browser";' >> Software.app/Resources/Info-gnustep.plist
	@echo '    ApplicationRelease = "1.0";' >> Software.app/Resources/Info-gnustep.plist
	@echo '    NSExecutable = "Software";' >> Software.app/Resources/Info-gnustep.plist
	@echo '    CFBundleIconFile = "Software.png";' >> Software.app/Resources/Info-gnustep.plist
	@echo '    NSPrincipalClass = "NSApplication";' >> Software.app/Resources/Info-gnustep.plist
	@echo '    LSUIElement = "NO";' >> Software.app/Resources/Info-gnustep.plist
	@echo '}' >> Software.app/Resources/Info-gnustep.plist
	@echo "Info-gnustep.plist created successfully"
	@if [ -f Software.png ]; then \
		echo "Copying Software.png to app bundle..."; \
		cp Software.png Software.app/Resources/; \
	else \
		echo "Creating placeholder Software.png..."; \
		echo "Place your Software.png icon in the Resources directory"; \
		touch Software.app/Resources/Software.png; \
	fi
