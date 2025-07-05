#import "BackupsLauncher.h"

@implementation BackupsLauncher

- (id)init
{
    self = [super init];
    if (self) {
        backupsExecutablePath = @"/usr/local/bin/backup-station";
        isBackupsRunning = NO;
        backupsTask = nil;
    }
    return self;
}

- (void)applicationWillFinishLaunching:(NSNotification *)notification
{
    NSString *iconPath = [[NSBundle mainBundle] pathForResource:@"Backups" ofType:@"png"];
    if (iconPath && [[NSFileManager defaultManager] fileExistsAtPath:iconPath]) {
        NSImage *icon = [[NSImage alloc] initWithContentsOfFile:iconPath];
        if (icon) {
            [NSApp setApplicationIconImage:icon];
            [icon release];
        }
    }
    
    serviceConnection = [NSConnection defaultConnection];
    [serviceConnection setRootObject:self];
    
    if (![serviceConnection registerName:@"BackupsLauncher"]) {
        NSConnection *existing = [NSConnection connectionWithRegisteredName:@"BackupsLauncher" host:nil];
        if (existing) {
            NSLog(@"Backups launcher already running, activating existing instance");
        }
        exit(0);
    }
    
    NSLog(@"Backups launcher initialized");
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    if ([self isBackupsCurrentlyRunning]) {
        NSLog(@"Backups is already running");
    } else {
        NSLog(@"Backups not running, launching it");
        [self launchBackups];
    }
}

- (void)launchBackups
{
    if (isBackupsRunning && backupsTask && [backupsTask isRunning]) {
        NSLog(@"Backups is already running");
        return;
    }
    
    NSLog(@"Launching Backups from: %@", backupsExecutablePath);
    
    backupsTask = [[NSTask alloc] init];
    [backupsTask setLaunchPath:backupsExecutablePath];
    [backupsTask setArguments:@[]];
    
    NSMutableDictionary *environment = [[[NSProcessInfo processInfo] environment] mutableCopy];
    [backupsTask setEnvironment:environment];
    [environment release];
    
    [[NSNotificationCenter defaultCenter] 
        addObserver:self 
        selector:@selector(handleBackupsTermination:) 
        name:NSTaskDidTerminateNotification 
        object:backupsTask];
    
    NS_DURING
        [backupsTask launch];
        isBackupsRunning = YES;
        NSLog(@"Backups launched successfully with PID: %d", [backupsTask processIdentifier]);
    NS_HANDLER
        NSLog(@"Failed to launch Backups: %@", localException);
        isBackupsRunning = NO;
        [backupsTask release];
        backupsTask = nil;
        
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"Backups Launch Error"];
        [alert setInformativeText:[NSString stringWithFormat:@"Could not launch Backups from %@. Please check that Backups is installed.", backupsExecutablePath]];
        [alert addButtonWithTitle:@"OK"];
        [alert runModal];
        [alert release];
        
        [NSApp terminate:self];
    NS_ENDHANDLER
}

- (BOOL)isBackupsCurrentlyRunning
{
    if (backupsTask && [backupsTask isRunning]) {
        return YES;
    }
    
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/usr/bin/pgrep"];
    [task setArguments:@[@"-f", @"backups"]];
    
    NSPipe *pipe = [NSPipe pipe];
    [task setStandardOutput:pipe];
    [task setStandardError:[NSPipe pipe]];
    
    BOOL running = NO;
    NS_DURING
        [task launch];
        [task waitUntilExit];
        
        if ([task terminationStatus] == 0) {
            running = YES;
            NSLog(@"Backups process found via pgrep");
        }
    NS_HANDLER
        NSLog(@"pgrep command failed: %@", localException);
        running = NO;
    NS_ENDHANDLER
    
    [task release];
    return running;
}

- (void)handleBackupsTermination:(NSNotification *)notification
{
    NSTask *task = [notification object];
    
    if (task == backupsTask) {
        NSLog(@"Backups process terminated (PID: %d)", [task processIdentifier]);
        isBackupsRunning = NO;
        
        [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                        name:NSTaskDidTerminateNotification 
                                                      object:backupsTask];
        [backupsTask release];
        backupsTask = nil;
        
        NSLog(@"Backups has quit, terminating Backups launcher");
        [NSApp terminate:self];
    }
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag
{
    NSLog(@"Backups app wrapper activated from dock");
    
    if ([self isBackupsCurrentlyRunning]) {
        NSLog(@"Backups is already running");
    } else {
        [self launchBackups];
    }
    
    return NO;
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
    NSLog(@"Backups launcher will terminate");
    
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
    if (backupsTask) {
        [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                        name:NSTaskDidTerminateNotification 
                                                      object:backupsTask];
        [backupsTask release];
    }
    [super dealloc];
}

@end
