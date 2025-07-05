#import "SoftwareLauncher.h"

@implementation SoftwareLauncher

- (id)init
{
    self = [super init];
    if (self) {
        softwareExecutablePath = @"/usr/local/bin/software-station";
        isSoftwareRunning = NO;
        softwareTask = nil;
    }
    return self;
}

- (void)applicationWillFinishLaunching:(NSNotification *)notification
{
    NSString *iconPath = [[NSBundle mainBundle] pathForResource:@"Software" ofType:@"png"];
    if (iconPath && [[NSFileManager defaultManager] fileExistsAtPath:iconPath]) {
        NSImage *icon = [[NSImage alloc] initWithContentsOfFile:iconPath];
        if (icon) {
            [NSApp setApplicationIconImage:icon];
            [icon release];
        }
    }
    
    serviceConnection = [NSConnection defaultConnection];
    [serviceConnection setRootObject:self];
    
    if (![serviceConnection registerName:@"SoftwareLauncher"]) {
        NSConnection *existing = [NSConnection connectionWithRegisteredName:@"SoftwareLauncher" host:nil];
        if (existing) {
            NSLog(@"Software launcher already running, activating existing instance");
        }
        exit(0);
    }
    
    NSLog(@"Software launcher initialized");
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    if ([self isSoftwareCurrentlyRunning]) {
        NSLog(@"Software is already running");
    } else {
        NSLog(@"Software not running, launching it");
        [self launchSoftware];
    }
}

- (void)launchSoftware
{
    if (isSoftwareRunning && softwareTask && [softwareTask isRunning]) {
        NSLog(@"Software is already running");
        return;
    }
    
    NSLog(@"Launching Software from: %@", softwareExecutablePath);
    
    softwareTask = [[NSTask alloc] init];
    [softwareTask setLaunchPath:softwareExecutablePath];
    [softwareTask setArguments:@[]];
    
    NSMutableDictionary *environment = [[[NSProcessInfo processInfo] environment] mutableCopy];
    [softwareTask setEnvironment:environment];
    [environment release];
    
    [[NSNotificationCenter defaultCenter] 
        addObserver:self 
        selector:@selector(handleSoftwareTermination:) 
        name:NSTaskDidTerminateNotification 
        object:softwareTask];
    
    NS_DURING
        [softwareTask launch];
        isSoftwareRunning = YES;
        NSLog(@"Software launched successfully with PID: %d", [softwareTask processIdentifier]);
    NS_HANDLER
        NSLog(@"Failed to launch Software: %@", localException);
        isSoftwareRunning = NO;
        [softwareTask release];
        softwareTask = nil;
        
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"Software Launch Error"];
        [alert setInformativeText:[NSString stringWithFormat:@"Could not launch Software from %@. Please check that Software is installed.", softwareExecutablePath]];
        [alert addButtonWithTitle:@"OK"];
        [alert runModal];
        [alert release];
        
        [NSApp terminate:self];
    NS_ENDHANDLER
}

- (BOOL)isSoftwareCurrentlyRunning
{
    if (softwareTask && [softwareTask isRunning]) {
        return YES;
    }
    
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/usr/bin/pgrep"];
    [task setArguments:@[@"-f", @"software"]];
    
    NSPipe *pipe = [NSPipe pipe];
    [task setStandardOutput:pipe];
    [task setStandardError:[NSPipe pipe]];
    
    BOOL running = NO;
    NS_DURING
        [task launch];
        [task waitUntilExit];
        
        if ([task terminationStatus] == 0) {
            running = YES;
            NSLog(@"Software process found via pgrep");
        }
    NS_HANDLER
        NSLog(@"pgrep command failed: %@", localException);
        running = NO;
    NS_ENDHANDLER
    
    [task release];
    return running;
}

- (void)handleSoftwareTermination:(NSNotification *)notification
{
    NSTask *task = [notification object];
    
    if (task == softwareTask) {
        NSLog(@"Software process terminated (PID: %d)", [task processIdentifier]);
        isSoftwareRunning = NO;
        
        [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                        name:NSTaskDidTerminateNotification 
                                                      object:softwareTask];
        [softwareTask release];
        softwareTask = nil;
        
        NSLog(@"Software has quit, terminating Software launcher");
        [NSApp terminate:self];
    }
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag
{
    NSLog(@"Software app wrapper activated from dock");
    
    if ([self isSoftwareCurrentlyRunning]) {
        NSLog(@"Software is already running");
    } else {
        [self launchSoftware];
    }
    
    return NO;
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
    NSLog(@"Software launcher will terminate");
    
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
    if (softwareTask) {
        [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                        name:NSTaskDidTerminateNotification 
                                                      object:softwareTask];
        [softwareTask release];
    }
    [super dealloc];
}

@end
