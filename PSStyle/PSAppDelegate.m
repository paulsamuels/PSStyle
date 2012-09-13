//
//  PSAppDelegate.m
//  PSStyle
//
//  Created by Paul Samuels on 11/09/2012.
//  Copyright (c) 2012 Paul Samuels. All rights reserved.
//

#import "PSAppDelegate.h"
#import "ExampleStyle.h"
#import "PSStyleColorDispatcher.h"
#import "PSStyleRoundedImageDispatcher.h"

@implementation PSAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  
  ExampleStyle *style = [[ExampleStyle alloc] init];
  [style registerStyleDispatcherClass:[PSStyleColorDispatcher class]];
  [style registerStyleDispatcherClass:[PSStyleRoundedImageDispatcher class]];
  
  UIImage *image = style.darkRoundedImage;
  UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
  imageView.frame = CGRectMake(100, 100, 100, 100);
  [self.window addSubview:imageView];

  style.plistPath = [[NSBundle mainBundle] pathForResource:@"customStyle" ofType:@"plist"];
  
  self.window.backgroundColor = style.redColor;
  [self.window makeKeyAndVisible];
  
  return YES;
}

@end
