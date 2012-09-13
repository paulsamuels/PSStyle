//
//  PSStyleColorDispatcher.m
//  PSStyle
//
//  Created by Paul Samuels on 13/09/2012.
//  Copyright (c) 2012 Paul Samuels. All rights reserved.
//

#import "PSStyleColorDispatcher.h"

@interface PSStyleColorDispatcher ()

@property (nonatomic, strong) NSMutableDictionary *cache;

@end

@implementation PSStyleColorDispatcher

+ (BOOL)canHandleStyleSelector:(SEL)sel;
{
  return [NSStringFromSelector(sel) hasSuffix:@"Color"];
}

- (id)styleAssetWithKey:(NSString *)key metaData:(id)metaData;
{
  UIColor *color = [self.cache objectForKey:key];
  
  if (!color) {
    color = [self colorWithRGBA:metaData];
    [self.cache setValue:color forKey:key];
  }
  
  if (!color) {
    [NSException raise:NSInternalInconsistencyException format:@"No color found for %@", key];
  }
  
  return color;
}

- (UIColor *)colorWithRGBA:(NSArray *)RGBA;
{
  if (RGBA.count < 4) {
    return nil;
  }
  
  CGFloat red   = [[RGBA objectAtIndex:0] floatValue] / 255.f;
  CGFloat green = [[RGBA objectAtIndex:1] floatValue] / 255.f;
  CGFloat blue  = [[RGBA objectAtIndex:2] floatValue] / 255.f;
  CGFloat alpha = [[RGBA objectAtIndex:3] floatValue] / 255.f;
  
  return [[UIColor alloc] initWithRed:red green:green blue:blue alpha:alpha];
}

- (void)purgeCaches;
{
  self.cache = nil;
}

#pragma mark - Properties

- (NSMutableDictionary *)cache;
{
  return _cache = _cache ?: [[NSMutableDictionary alloc] init];
}

@end
