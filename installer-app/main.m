#import <AppKit/AppKit.h>
#import "InstallerLauncher.h"

int main(int argc, const char *argv[])
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    // Create the shared application instance
    [NSApplication sharedApplication];
    
    // Create and set our custom delegate
    InstallerLauncher *launcher = [[InstallerLauncher alloc] init];
    [NSApp setDelegate:launcher];
    
    NSLog(@"Starting Installer app wrapper");
    
    // Run the application
    int result = NSApplicationMain(argc, argv);
    
    [pool release];
    return result;
}
