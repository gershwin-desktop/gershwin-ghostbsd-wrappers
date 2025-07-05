#!/usr/local/bin/bash

# Usage: generate-wrapper-code.sh <AppName> <ExecutablePath> <IconPath>
# Example: generate-wrapper-code.sh Chromium /usr/local/bin/chromium /Users/jmaloney/Downloads/chrome.png

if [ $# -ne 3 ]; then
    echo "Usage: $0 <AppName> <ExecutablePath> <IconPath>"
    echo "Example: $0 Chromium /usr/local/bin/chromium /Users/jmaloney/Downloads/chrome.png"
    exit 1
fi

APP_NAME="$1"
EXECUTABLE_PATH="$2"
ICON_PATH="$3"

# Derived values
APP_DIR="./${APP_NAME,,}-app"  # Convert to lowercase and add -app suffix
LAUNCHER_CLASS="${APP_NAME}Launcher"
ICON_FILENAME="${APP_NAME}.png"

echo "Generating wrapper for $APP_NAME..."
echo "Target directory: $APP_DIR"
echo "Executable: $EXECUTABLE_PATH"
echo "Icon: $ICON_PATH"

# Create target directory
mkdir -p "$APP_DIR"

# Copy icon file if it exists
if [ -f "$ICON_PATH" ]; then
    echo "Copying icon file..."
    cp "$ICON_PATH" "$APP_DIR/$ICON_FILENAME"
else
    echo "Warning: Icon file $ICON_PATH not found. Creating placeholder."
    touch "$APP_DIR/$ICON_FILENAME"
fi

# Generate GNUmakefile
echo "Generating GNUmakefile..."
cat > "$APP_DIR/GNUmakefile" << EOF
include \$(GNUSTEP_MAKEFILES)/common.make

APP_NAME = $APP_NAME

${APP_NAME}_OBJC_FILES = \\
	main.m \\
	${LAUNCHER_CLASS}.m

include \$(GNUSTEP_MAKEFILES)/application.make

# Create the Info.plist file
after-all::
	@echo "Creating Info-gnustep.plist..."
	@echo '{' > ${APP_NAME}.app/Resources/Info-gnustep.plist
	@echo '    ApplicationName = "$APP_NAME";' >> ${APP_NAME}.app/Resources/Info-gnustep.plist
	@echo '    ApplicationDescription = "$APP_NAME Web Browser";' >> ${APP_NAME}.app/Resources/Info-gnustep.plist
	@echo '    ApplicationRelease = "1.0";' >> ${APP_NAME}.app/Resources/Info-gnustep.plist
	@echo '    NSExecutable = "$APP_NAME";' >> ${APP_NAME}.app/Resources/Info-gnustep.plist
	@echo '    CFBundleIconFile = "$ICON_FILENAME";' >> ${APP_NAME}.app/Resources/Info-gnustep.plist
	@echo '    NSPrincipalClass = "NSApplication";' >> ${APP_NAME}.app/Resources/Info-gnustep.plist
	@echo '    LSUIElement = "NO";' >> ${APP_NAME}.app/Resources/Info-gnustep.plist
	@echo '}' >> ${APP_NAME}.app/Resources/Info-gnustep.plist
	@echo "Info-gnustep.plist created successfully"
	@if [ -f $ICON_FILENAME ]; then \\
		echo "Copying $ICON_FILENAME to app bundle..."; \\
		cp $ICON_FILENAME ${APP_NAME}.app/Resources/; \\
	else \\
		echo "Creating placeholder $ICON_FILENAME..."; \\
		echo "Place your $ICON_FILENAME icon in the Resources directory"; \\
		touch ${APP_NAME}.app/Resources/$ICON_FILENAME; \\
	fi
EOF

# Generate main.m
echo "Generating main.m..."
cat > "$APP_DIR/main.m" << EOF
#import <AppKit/AppKit.h>
#import "${LAUNCHER_CLASS}.h"

int main(int argc, const char *argv[])
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    // Create the shared application instance
    [NSApplication sharedApplication];
    
    // Create and set our custom delegate
    ${LAUNCHER_CLASS} *launcher = [[${LAUNCHER_CLASS} alloc] init];
    [NSApp setDelegate:launcher];
    
    NSLog(@"Starting $APP_NAME app wrapper");
    
    // Run the application
    int result = NSApplicationMain(argc, argv);
    
    [pool release];
    return result;
}
EOF

# Generate Launcher header file
echo "Generating ${LAUNCHER_CLASS}.h..."
cat > "$APP_DIR/${LAUNCHER_CLASS}.h" << EOF
#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@interface ${LAUNCHER_CLASS} : NSObject <NSApplicationDelegate>
{
    NSTask *${APP_NAME,,}Task;
    NSString *${APP_NAME,,}ExecutablePath;
    BOOL is${APP_NAME}Running;
    NSConnection *serviceConnection;
}

- (void)launch${APP_NAME};
- (BOOL)is${APP_NAME}CurrentlyRunning;
- (void)handle${APP_NAME}Termination:(NSNotification *)notification;

@end
EOF

# Generate Launcher implementation file
echo "Generating ${LAUNCHER_CLASS}.m..."
cat > "$APP_DIR/${LAUNCHER_CLASS}.m" << EOF
#import "${LAUNCHER_CLASS}.h"

@implementation ${LAUNCHER_CLASS}

- (id)init
{
    self = [super init];
    if (self) {
        ${APP_NAME,,}ExecutablePath = @"$EXECUTABLE_PATH";
        is${APP_NAME}Running = NO;
        ${APP_NAME,,}Task = nil;
    }
    return self;
}

- (void)applicationWillFinishLaunching:(NSNotification *)notification
{
    NSString *iconPath = [[NSBundle mainBundle] pathForResource:@"$APP_NAME" ofType:@"png"];
    if (iconPath && [[NSFileManager defaultManager] fileExistsAtPath:iconPath]) {
        NSImage *icon = [[NSImage alloc] initWithContentsOfFile:iconPath];
        if (icon) {
            [NSApp setApplicationIconImage:icon];
            [icon release];
        }
    }
    
    serviceConnection = [NSConnection defaultConnection];
    [serviceConnection setRootObject:self];
    
    if (![serviceConnection registerName:@"${LAUNCHER_CLASS}"]) {
        NSConnection *existing = [NSConnection connectionWithRegisteredName:@"${LAUNCHER_CLASS}" host:nil];
        if (existing) {
            NSLog(@"$APP_NAME launcher already running, activating existing instance");
        }
        exit(0);
    }
    
    NSLog(@"$APP_NAME launcher initialized");
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    if ([self is${APP_NAME}CurrentlyRunning]) {
        NSLog(@"$APP_NAME is already running");
    } else {
        NSLog(@"$APP_NAME not running, launching it");
        [self launch${APP_NAME}];
    }
}

- (void)launch${APP_NAME}
{
    if (is${APP_NAME}Running && ${APP_NAME,,}Task && [${APP_NAME,,}Task isRunning]) {
        NSLog(@"$APP_NAME is already running");
        return;
    }
    
    NSLog(@"Launching $APP_NAME from: %@", ${APP_NAME,,}ExecutablePath);
    
    ${APP_NAME,,}Task = [[NSTask alloc] init];
    [${APP_NAME,,}Task setLaunchPath:${APP_NAME,,}ExecutablePath];
    [${APP_NAME,,}Task setArguments:@[]];
    
    NSMutableDictionary *environment = [[[NSProcessInfo processInfo] environment] mutableCopy];
    [${APP_NAME,,}Task setEnvironment:environment];
    [environment release];
    
    [[NSNotificationCenter defaultCenter] 
        addObserver:self 
        selector:@selector(handle${APP_NAME}Termination:) 
        name:NSTaskDidTerminateNotification 
        object:${APP_NAME,,}Task];
    
    NS_DURING
        [${APP_NAME,,}Task launch];
        is${APP_NAME}Running = YES;
        NSLog(@"$APP_NAME launched successfully with PID: %d", [${APP_NAME,,}Task processIdentifier]);
    NS_HANDLER
        NSLog(@"Failed to launch $APP_NAME: %@", localException);
        is${APP_NAME}Running = NO;
        [${APP_NAME,,}Task release];
        ${APP_NAME,,}Task = nil;
        
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"$APP_NAME Launch Error"];
        [alert setInformativeText:[NSString stringWithFormat:@"Could not launch $APP_NAME from %@. Please check that $APP_NAME is installed.", ${APP_NAME,,}ExecutablePath]];
        [alert addButtonWithTitle:@"OK"];
        [alert runModal];
        [alert release];
        
        [NSApp terminate:self];
    NS_ENDHANDLER
}

- (BOOL)is${APP_NAME}CurrentlyRunning
{
    if (${APP_NAME,,}Task && [${APP_NAME,,}Task isRunning]) {
        return YES;
    }
    
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/usr/bin/pgrep"];
    [task setArguments:@[@"-f", @"${APP_NAME,,}"]];
    
    NSPipe *pipe = [NSPipe pipe];
    [task setStandardOutput:pipe];
    [task setStandardError:[NSPipe pipe]];
    
    BOOL running = NO;
    NS_DURING
        [task launch];
        [task waitUntilExit];
        
        if ([task terminationStatus] == 0) {
            running = YES;
            NSLog(@"$APP_NAME process found via pgrep");
        }
    NS_HANDLER
        NSLog(@"pgrep command failed: %@", localException);
        running = NO;
    NS_ENDHANDLER
    
    [task release];
    return running;
}

- (void)handle${APP_NAME}Termination:(NSNotification *)notification
{
    NSTask *task = [notification object];
    
    if (task == ${APP_NAME,,}Task) {
        NSLog(@"$APP_NAME process terminated (PID: %d)", [task processIdentifier]);
        is${APP_NAME}Running = NO;
        
        [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                        name:NSTaskDidTerminateNotification 
                                                      object:${APP_NAME,,}Task];
        [${APP_NAME,,}Task release];
        ${APP_NAME,,}Task = nil;
        
        NSLog(@"$APP_NAME has quit, terminating $APP_NAME launcher");
        [NSApp terminate:self];
    }
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag
{
    NSLog(@"$APP_NAME app wrapper activated from dock");
    
    if ([self is${APP_NAME}CurrentlyRunning]) {
        NSLog(@"$APP_NAME is already running");
    } else {
        [self launch${APP_NAME}];
    }
    
    return NO;
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
    NSLog(@"$APP_NAME launcher will terminate");
    
    if (serviceConnection) {
        [serviceConnection invalidate];
    }
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
    return NSTerminateNow;
}

- (void)dealloc
{
    if (${APP_NAME,,}Task) {
        [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                        name:NSTaskDidTerminateNotification 
                                                      object:${APP_NAME,,}Task];
        [${APP_NAME,,}Task release];
    }
    [super dealloc];
}

@end
EOF

echo ""
echo "✅ Successfully generated $APP_NAME wrapper in $APP_DIR"
echo ""
echo "To build and run:"
echo "  cd $APP_DIR"
echo "  make"
echo "  ./${APP_NAME}.app/${APP_NAME}"
echo ""
echo "Files generated:"
echo "  - GNUmakefile"
echo "  - main.m"
echo "  - ${LAUNCHER_CLASS}.h"
echo "  - ${LAUNCHER_CLASS}.m"
echo "  - $ICON_FILENAME (copied from $ICON_PATH)"