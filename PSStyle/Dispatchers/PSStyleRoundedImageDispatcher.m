//
//  PSStyleRoundedImageDispatcher.m
//  PSStyle
//
//  Created by Paul Samuels on 13/09/2012.
//  Copyright (c) 2012 Paul Samuels. All rights reserved.
//

#import "PSStyleRoundedImageDispatcher.h"

@implementation PSStyleRoundedImageDispatcher

+ (BOOL)canHandleStyleSelector:(SEL)sel;
{
  return [NSStringFromSelector(sel) hasSuffix:@"RoundedImage"];
}

- (id)styleAssetWithKey:(NSString *)key metaData:(id)metaData;
{
  id        colorComponentsOrName  = [metaData objectForKey:@"color"];
  CGFloat   radius                 = [[metaData objectForKey:@"radius"] floatValue];

  UIColor *color = nil;

  if ([colorComponentsOrName respondsToSelector:@selector(count)]) {
//    color = [self colorWithRGBA:colorComponentsOrName];
  } else {    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    color = [self.styleManager performSelector:NSSelectorFromString(colorComponentsOrName)];
#pragma clang diagnostic pop
  }

  CGFloat   scale     = [UIScreen mainScreen].scale;
  NSString *imagePath = [self.styleManager.assetDirectory stringByAppendingFormat:@"/%@%@.png", key, 2 == scale ? @"@2x" : @""];

  UIImage *image = [UIImage imageNamed:key];

  if (!image) {
    image = [[UIImage alloc] initWithContentsOfFile:imagePath];
  }

  if (!image) {
    CGFloat width = (radius * 2) + 1;
    CGSize  size  = CGSizeMake(width, width);
    CGRect  rect  = (CGRect){ CGPointZero, size };

    UIGraphicsBeginImageContextWithOptions(size, NO, scale);

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, rect);

    [color setFill];
    UIBezierPath *roundedRect = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:radius];
    [roundedRect fill];

    image = UIGraphicsGetImageFromCurrentImageContext();

    NSData *imageData = UIImagePNGRepresentation(image);
    [imageData writeToFile:imagePath atomically:YES];

    UIGraphicsEndImageContext();
  }

  return [image resizableImageWithCapInsets:UIEdgeInsetsMake(radius, radius, radius, radius)];
}

- (void)purgeCaches;
{
  
}

@end
