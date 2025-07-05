#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@interface InstallerLauncher : NSObject <NSApplicationDelegate>
{
    NSTask *installerTask;
    NSString *installerExecutablePath;
    BOOL isInstallerRunning;
    NSConnection *serviceConnection;
}

- (void)launchInstaller;
- (BOOL)isInstallerCurrentlyRunning;
- (void)handleInstallerTermination:(NSNotification *)notification;

@end
