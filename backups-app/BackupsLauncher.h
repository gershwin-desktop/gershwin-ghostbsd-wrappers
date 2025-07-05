#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@interface BackupsLauncher : NSObject <NSApplicationDelegate>
{
    NSTask *backupsTask;
    NSString *backupsExecutablePath;
    BOOL isBackupsRunning;
    NSConnection *serviceConnection;
}

- (void)launchBackups;
- (BOOL)isBackupsCurrentlyRunning;
- (void)handleBackupsTermination:(NSNotification *)notification;

@end
