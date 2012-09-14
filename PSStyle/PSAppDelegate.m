//
//  PSAppDelegate.m
//  PSStyle
//
//  Created by Paul Samuels on 11/09/2012.
//  Copyright (c) 2012 Paul Samuels. All rights reserved.
//

#import "PSAppDelegate.h"
#import "ExampleStyle.h"
#import "PSStyleColorResolver.h"
#import "PSStyleRoundedImageResolver.h"

#import "PSStyleMeViewController.h"

@implementation PSAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  
  ExampleStyle *style = [[ExampleStyle alloc] init];
  [style registerStyleResolverClass:[PSStyleColorResolver class]];
  [style registerStyleResolverClass:[PSStyleRoundedImageResolver class]];
  
  PSStyleMeViewController *viewController = [[PSStyleMeViewController alloc] init];
  viewController.style = style;
  
  self.window.rootViewController = viewController;

  [self.window makeKeyAndVisible];
  
  return YES;
}

@end
