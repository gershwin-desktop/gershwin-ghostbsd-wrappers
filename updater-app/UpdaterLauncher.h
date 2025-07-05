#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@interface UpdaterLauncher : NSObject <NSApplicationDelegate>
{
    NSTask *updaterTask;
    NSString *updaterExecutablePath;
    BOOL isUpdaterRunning;
    NSConnection *serviceConnection;
}

- (void)launchUpdater;
- (BOOL)isUpdaterCurrentlyRunning;
- (void)handleUpdaterTermination:(NSNotification *)notification;

@end
