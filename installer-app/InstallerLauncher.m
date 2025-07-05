#import "InstallerLauncher.h"

@implementation InstallerLauncher

- (id)init
{
    self = [super init];
    if (self) {
        installerExecutablePath = @"/usr/local/bin/gbi";
        isInstallerRunning = NO;
        installerTask = nil;
    }
    return self;
}

- (void)applicationWillFinishLaunching:(NSNotification *)notification
{
    NSString *iconPath = [[NSBundle mainBundle] pathForResource:@"Installer" ofType:@"png"];
    if (iconPath && [[NSFileManager defaultManager] fileExistsAtPath:iconPath]) {
        NSImage *icon = [[NSImage alloc] initWithContentsOfFile:iconPath];
        if (icon) {
            [NSApp setApplicationIconImage:icon];
            [icon release];
        }
    }
    
    serviceConnection = [NSConnection defaultConnection];
    [serviceConnection setRootObject:self];
    
    if (![serviceConnection registerName:@"InstallerLauncher"]) {
        NSConnection *existing = [NSConnection connectionWithRegisteredName:@"InstallerLauncher" host:nil];
        if (existing) {
            NSLog(@"Installer launcher already running, activating existing instance");
        }
        exit(0);
    }
    
    NSLog(@"Installer launcher initialized");
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    if ([self isInstallerCurrentlyRunning]) {
        NSLog(@"Installer is already running");
    } else {
        NSLog(@"Installer not running, launching it");
        [self launchInstaller];
    }
}

- (void)launchInstaller
{
    if (isInstallerRunning && installerTask && [installerTask isRunning]) {
        NSLog(@"Installer is already running");
        return;
    }
    
    NSLog(@"Launching Installer from: %@", installerExecutablePath);
    
    installerTask = [[NSTask alloc] init];
    [installerTask setLaunchPath:installerExecutablePath];
    [installerTask setArguments:@[]];
    
    NSMutableDictionary *environment = [[[NSProcessInfo processInfo] environment] mutableCopy];
    [installerTask setEnvironment:environment];
    [environment release];
    
    [[NSNotificationCenter defaultCenter] 
        addObserver:self 
        selector:@selector(handleInstallerTermination:) 
        name:NSTaskDidTerminateNotification 
        object:installerTask];
    
    NS_DURING
        [installerTask launch];
        isInstallerRunning = YES;
        NSLog(@"Installer launched successfully with PID: %d", [installerTask processIdentifier]);
    NS_HANDLER
        NSLog(@"Failed to launch Installer: %@", localException);
        isInstallerRunning = NO;
        [installerTask release];
        installerTask = nil;
        
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"Installer Launch Error"];
        [alert setInformativeText:[NSString stringWithFormat:@"Could not launch Installer from %@. Please check that Installer is installed.", installerExecutablePath]];
        [alert addButtonWithTitle:@"OK"];
        [alert runModal];
        [alert release];
        
        [NSApp terminate:self];
    NS_ENDHANDLER
}

- (BOOL)isInstallerCurrentlyRunning
{
    if (installerTask && [installerTask isRunning]) {
        return YES;
    }
    
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/usr/bin/pgrep"];
    [task setArguments:@[@"-f", @"installer"]];
    
    NSPipe *pipe = [NSPipe pipe];
    [task setStandardOutput:pipe];
    [task setStandardError:[NSPipe pipe]];
    
    BOOL running = NO;
    NS_DURING
        [task launch];
        [task waitUntilExit];
        
        if ([task terminationStatus] == 0) {
            running = YES;
            NSLog(@"Installer process found via pgrep");
        }
    NS_HANDLER
        NSLog(@"pgrep command failed: %@", localException);
        running = NO;
    NS_ENDHANDLER
    
    [task release];
    return running;
}

- (void)handleInstallerTermination:(NSNotification *)notification
{
    NSTask *task = [notification object];
    
    if (task == installerTask) {
        NSLog(@"Installer process terminated (PID: %d)", [task processIdentifier]);
        isInstallerRunning = NO;
        
        [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                        name:NSTaskDidTerminateNotification 
                                                      object:installerTask];
        [installerTask release];
        installerTask = nil;
        
        NSLog(@"Installer has quit, terminating Installer launcher");
        [NSApp terminate:self];
    }
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag
{
    NSLog(@"Installer app wrapper activated from dock");
    
    if ([self isInstallerCurrentlyRunning]) {
        NSLog(@"Installer is already running");
    } else {
        [self launchInstaller];
    }
    
    return NO;
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
    NSLog(@"Installer launcher will terminate");
    
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
    if (installerTask) {
        [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                        name:NSTaskDidTerminateNotification 
                                                      object:installerTask];
        [installerTask release];
    }
    [super dealloc];
}

@end
