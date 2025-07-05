#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@interface SoftwareLauncher : NSObject <NSApplicationDelegate>
{
    NSTask *softwareTask;
    NSString *softwareExecutablePath;
    BOOL isSoftwareRunning;
    NSConnection *serviceConnection;
}

- (void)launchSoftware;
- (BOOL)isSoftwareCurrentlyRunning;
- (void)handleSoftwareTermination:(NSNotification *)notification;

@end
