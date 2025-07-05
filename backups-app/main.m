#import <AppKit/AppKit.h>
#import "BackupsLauncher.h"

int main(int argc, const char *argv[])
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    // Create the shared application instance
    [NSApplication sharedApplication];
    
    // Create and set our custom delegate
    BackupsLauncher *launcher = [[BackupsLauncher alloc] init];
    [NSApp setDelegate:launcher];
    
    NSLog(@"Starting Backups app wrapper");
    
    // Run the application
    int result = NSApplicationMain(argc, argv);
    
    [pool release];
    return result;
}
