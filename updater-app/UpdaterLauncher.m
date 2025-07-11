#import "UpdaterLauncher.h"

@implementation UpdaterLauncher

- (id)init
{
    self = [super init];
    if (self) {
        updaterExecutablePath = @"/Library/Tools/Updater-CLI";
        isUpdaterRunning = NO;
        updaterTask = nil;
    }
    return self;
}

- (void)applicationWillFinishLaunching:(NSNotification *)notification
{
    NSString *iconPath = [[NSBundle mainBundle] pathForResource:@"Updater" ofType:@"png"];
    if (iconPath && [[NSFileManager defaultManager] fileExistsAtPath:iconPath]) {
        NSImage *icon = [[NSImage alloc] initWithContentsOfFile:iconPath];
        if (icon) {
            [NSApp setApplicationIconImage:icon];
            [icon release];
        }
    }
    
    serviceConnection = [NSConnection defaultConnection];
    [serviceConnection setRootObject:self];
    
    if (![serviceConnection registerName:@"UpdaterLauncher"]) {
        NSConnection *existing = [NSConnection connectionWithRegisteredName:@"UpdaterLauncher" host:nil];
        if (existing) {
            NSLog(@"Updater launcher already running, activating existing instance");
        }
        exit(0);
    }
    
    NSLog(@"Updater launcher initialized");
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    if ([self isUpdaterCurrentlyRunning]) {
        NSLog(@"Updater is already running");
    } else {
        NSLog(@"Updater not running, launching it");
        [self launchUpdater];
    }
}

- (void)launchUpdater
{
    if (isUpdaterRunning && updaterTask && [updaterTask isRunning]) {
        NSLog(@"Updater is already running");
        return;
    }
    
    NSLog(@"Launching Updater from: %@", updaterExecutablePath);
    
    updaterTask = [[NSTask alloc] init];
    [updaterTask setLaunchPath:updaterExecutablePath];
    [updaterTask setArguments:@[]];
    
    NSMutableDictionary *environment = [[[NSProcessInfo processInfo] environment] mutableCopy];
    [updaterTask setEnvironment:environment];
    [environment release];
    
    [[NSNotificationCenter defaultCenter] 
        addObserver:self 
        selector:@selector(handleUpdaterTermination:) 
        name:NSTaskDidTerminateNotification 
        object:updaterTask];
    
    NS_DURING
        [updaterTask launch];
        isUpdaterRunning = YES;
        NSLog(@"Updater launched successfully with PID: %d", [updaterTask processIdentifier]);
    NS_HANDLER
        NSLog(@"Failed to launch Updater: %@", localException);
        isUpdaterRunning = NO;
        [updaterTask release];
        updaterTask = nil;
        
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"Updater Launch Error"];
        [alert setInformativeText:[NSString stringWithFormat:@"Could not launch Updater from %@. Please check that Updater is installed.", updaterExecutablePath]];
        [alert addButtonWithTitle:@"OK"];
        [alert runModal];
        [alert release];
        
        [NSApp terminate:self];
    NS_ENDHANDLER
}

- (BOOL)isUpdaterCurrentlyRunning
{
    if (updaterTask && [updaterTask isRunning]) {
        return YES;
    }
    
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/usr/bin/pgrep"];
    [task setArguments:@[@"-f", @"updater"]];
    
    NSPipe *pipe = [NSPipe pipe];
    [task setStandardOutput:pipe];
    [task setStandardError:[NSPipe pipe]];
    
    BOOL running = NO;
    NS_DURING
        [task launch];
        [task waitUntilExit];
        
        if ([task terminationStatus] == 0) {
            running = YES;
            NSLog(@"Updater process found via pgrep");
        }
    NS_HANDLER
        NSLog(@"pgrep command failed: %@", localException);
        running = NO;
    NS_ENDHANDLER
    
    [task release];
    return running;
}

- (void)handleUpdaterTermination:(NSNotification *)notification
{
    NSTask *task = [notification object];
    
    if (task == updaterTask) {
        NSLog(@"Updater process terminated (PID: %d)", [task processIdentifier]);
        isUpdaterRunning = NO;
        
        [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                        name:NSTaskDidTerminateNotification 
                                                      object:updaterTask];
        [updaterTask release];
        updaterTask = nil;
        
        NSLog(@"Updater has quit, terminating Updater launcher");
        [NSApp terminate:self];
    }
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag
{
    NSLog(@"Updater app wrapper activated from dock");
    
    if ([self isUpdaterCurrentlyRunning]) {
        NSLog(@"Updater is already running");
    } else {
        [self launchUpdater];
    }
    
    return NO;
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
    NSLog(@"Updater launcher will terminate");
    
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
    if (updaterTask) {
        [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                        name:NSTaskDidTerminateNotification 
                                                      object:updaterTask];
        [updaterTask release];
    }
    [super dealloc];
}

@end
