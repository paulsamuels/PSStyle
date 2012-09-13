//
//  MyAppStyle.h
//  PSStyle
//
//  Created by Paul Samuels on 11/09/2012.
//  Copyright (c) 2012 Paul Samuels. All rights reserved.
//

#import "PSStyleManager.h"

@interface ExampleStyle : PSStyleManager

@property (nonatomic, strong, readonly) UIColor *undefinedColor;
@property (nonatomic, strong, readonly) UIColor *redColor;
@property (nonatomic, strong, readonly) UIColor *blueColor;
@property (nonatomic, strong, readonly) UIImage *darkRoundedImage;
@property (nonatomic, strong, readonly) UIImage *undefinedRoundedImage;

@end
