//
//  PSStyleMeViewController.m
//  PSStyle
//
//  Created by Paul Samuels on 14/09/2012.
//  Copyright (c) 2012 Paul Samuels. All rights reserved.
//

#import "PSStyleMeViewController.h"
#import "ExampleStyle.h"

@interface PSStyleMeViewController ()

@property (nonatomic, weak) IBOutlet UIButton *backgroundColorButton;
@property (nonatomic, weak) IBOutlet UIButton *buttonButton;
@property (nonatomic, weak) IBOutlet UISlider *red;
@property (nonatomic, weak) IBOutlet UISlider *green;
@property (nonatomic, weak) IBOutlet UISlider *blue;
@property (nonatomic, weak) IBOutlet UISlider *alpha;
@property (nonatomic, weak) IBOutlet UISlider *radius;
@property (nonatomic, strong) IBOutletCollection(UIButton) NSArray *buttons;

- (IBAction)buttonTapped:(UIButton *)button;

@end

@implementation PSStyleMeViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  for (UIButton *button in self.buttons) {
    [button setBackgroundImage:self.style.darkRoundedImage forState:UIControlStateNormal];
  }
}

- (IBAction)buttonTapped:(UIButton *)button;
{
  NSArray *color = @[
  @(floorf(self.red.value)),
  @(floorf(self.green.value)),
  @(floorf(self.blue.value)),
  @(floorf(self.alpha.value))
  ];
  
  NSDictionary *buttonRoundedImage = @{
  @"color" : @"roundedImageColor",
  @"radius" : @(floorf(self.radius.value)),
  };
  
  NSArray *roundedImageColor = @[
  @(floorf(self.red.value)),
  @(floorf(self.green.value)),
  @(floorf(self.blue.value)),
  @(floorf(self.alpha.value))
  ];
  
  NSDictionary *style = @{
  @"backgroundColor" : color,
  @"roundedImageColor" : roundedImageColor,
  @"buttonRoundedImage" : buttonRoundedImage,
  };
  
  [style writeToFile:[self customPlistPath] atomically:YES];
  self.style.plistPath = [self customPlistPath];
  
  if (button == self.backgroundColorButton) {
    self.view.backgroundColor = self.style.backgroundColor;
  } else if (button == self.buttonButton) {
    for (UIButton *button in self.buttons) {
      [button setBackgroundImage:self.style.buttonRoundedImage forState:UIControlStateNormal];
    }
  }
}

- (NSString *)customPlistPath;
{
  NSString *cachesDir = [[[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject] path];
  return [cachesDir stringByAppendingPathComponent:@"customStyle.plist"];
}

@end
