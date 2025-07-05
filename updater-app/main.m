#import <AppKit/AppKit.h>
#import "UpdaterLauncher.h"

int main(int argc, const char *argv[])
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    // Create the shared application instance
    [NSApplication sharedApplication];
    
    // Create and set our custom delegate
    UpdaterLauncher *launcher = [[UpdaterLauncher alloc] init];
    [NSApp setDelegate:launcher];
    
    NSLog(@"Starting Updater app wrapper");
    
    // Run the application
    int result = NSApplicationMain(argc, argv);
    
    [pool release];
    return result;
}
