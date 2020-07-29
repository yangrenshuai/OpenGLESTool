//
//  AppDelegate.m
//  OpenGLESTool
//
//  Created by apple on 2020/7/22.
//  Copyright © 2020 apple. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    NSApplication* app = [NSApplication sharedApplication];
    NSMenu* mainMenu = app.mainMenu;
    
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
    NSLog(@"applicationWillTerminate");
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}

@end
