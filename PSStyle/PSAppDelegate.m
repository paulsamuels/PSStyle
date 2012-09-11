//
//  PSAppDelegate.m
//  PSStyle
//
//  Created by Paul Samuels on 11/09/2012.
//  Copyright (c) 2012 Paul Samuels. All rights reserved.
//

#import "PSAppDelegate.h"
#import "MyAppStyle.h"

@implementation PSAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  
  self.window.backgroundColor = [[MyAppStyle sharedInstance] redColor];
  [self.window makeKeyAndVisible];
  
  return YES;
}

@end
