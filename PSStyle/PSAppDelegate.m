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
//    self.window.backgroundColor = [[MyAppStyle sharedInstance] blueColor];
  [self.window makeKeyAndVisible];
  
  UIImage *image = [[MyAppStyle sharedInstance] darkRoundedImage];
  UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
  imageView.frame = CGRectMake(100, 100, 100, 100);
  [self.window addSubview:imageView];
  
  NSLog(@"%@", [[MyAppStyle sharedInstance] darkRoundedImage]);
  
  return YES;
}

@end
