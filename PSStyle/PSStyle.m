//
//  PSStyle2.m
//  Testing
//
//  Created by Paul Samuels on 11/09/2012.
//  Copyright (c) 2012 Paul Samuels. All rights reserved.
//

#import "PSStyle.h"
#import <objc/runtime.h>

static UIColor *ColorDispatcher(id self, SEL _cmd);
static id BlockDispatcher(id self, SEL _cmd);

@interface PSStyle ()

@property (nonatomic, strong) NSDictionary        *styleMappings;
@property (nonatomic, strong) NSMutableDictionary *blocks;
@property (nonatomic, strong) NSMutableDictionary *colors;

@end

@implementation PSStyle {
  NSString *_plistPath;
}

+ (id)sharedInstance;
{
  static id instance = nil;
  
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    instance = [[self alloc] init];
  });
  
  return instance;
}

- (id)init;
{
  self = [super init];
  if (self) {
    [self loadStyleComponents];
  }
  return self;
}

+ (void)reset;
{
  PSStyle *instance = [self sharedInstance];
  
  instance->_plistPath     = nil;
  instance->_styleMappings = nil;
  [instance loadStyleComponents];
}

+ (BOOL)resolveInstanceMethod:(SEL)sel;
{
  NSString *key = NSStringFromSelector(sel);
  
  if ([key hasSuffix:@"RoundedImage"]) {
    class_addMethod([self class], sel, (IMP)BlockDispatcher, "@@:");
    return YES;
  } else if ([key hasSuffix:@"Color"]) {
    class_addMethod([self class], sel, (IMP)ColorDispatcher, "@@:");
    return YES;
  }
  
  return [super resolveInstanceMethod:sel];
}

- (void)loadStyleComponents;
{
  [[NSFileManager defaultManager] createDirectoryAtPath:[self generatedImagesDirectory]
                            withIntermediateDirectories:YES
                                             attributes:nil
                                                  error:nil];
  
  NSMutableArray *colorKeys        = [[NSMutableArray alloc] init];
  NSMutableArray *roundedImageKeys = [[NSMutableArray alloc] init];
  
  for (NSString *key in self.styleMappings.allKeys) {
    if ([key hasSuffix:@"Color"]) {
      [colorKeys addObject:key];
    } else if ([key hasSuffix:@"RoundedImage"]) {
      [roundedImageKeys addObject:key];
    }
  }
  
  for (NSString *key in colorKeys) {
    UIColor *color = [self colorWithRGBA:[self.styleMappings objectForKey:key]];
    [self.colors setObject:color forKey:key];
  }
  
  for (NSString *key in roundedImageKeys) {
    NSDictionary *options = [self.styleMappings objectForKey:key];
    
    id        colorName  = [options objectForKey:@"color"];
    CGFloat   radius     = [[options objectForKey:@"radius"] floatValue];
    
    UIColor *color = nil;
    
    if ([colorName respondsToSelector:@selector(count)]) {
      color = [self colorWithRGBA:colorName];
    } else {
      color = [self.colors objectForKey:colorName];
      if (!color) {
        color = [UIColor performSelector:NSSelectorFromString(colorName)];
      }
    }
    
    CGFloat scale = [UIScreen mainScreen].scale;
    NSString *imagePath = [[self generatedImagesDirectory] stringByAppendingFormat:@"/%@%@.png", key, 2 == scale ? @"@2x" : @""];
    
    [self.blocks setObject:^{
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
      
    } forKey:key];
  }
}

- (UIColor *)colorWithRGBA:(NSArray *)RGBA;
{
  CGFloat red   = [[RGBA objectAtIndex:0] floatValue] / 255.f;
  CGFloat green = [[RGBA objectAtIndex:1] floatValue] / 255.f;
  CGFloat blue  = [[RGBA objectAtIndex:2] floatValue] / 255.f;
  CGFloat alpha = [[RGBA objectAtIndex:3] floatValue] / 255.f;
  
  return [[UIColor alloc] initWithRed:red green:green blue:blue alpha:alpha];
}

#pragma mark - Properties

- (NSString *)generatedImagesDirectory
{
  NSString *cachesDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
  
  NSString *directory = [[self.plistPath stringByDeletingPathExtension] lastPathComponent];
  
  return [cachesDirectory stringByAppendingPathComponent:directory];
}

- (void)setPlistPath:(NSString *)plistPath;
{
  if (_plistPath != plistPath) {
    _plistPath     = plistPath;
    _styleMappings = nil;
    [self loadStyleComponents];
  }
}

- (NSString *)plistPath;
{
  return _plistPath = _plistPath ?: [[NSBundle bundleForClass:[self class]] pathForResource:@"style" ofType:@"plist"];
}

- (NSDictionary *)styleMappings;
{
  return _styleMappings = _styleMappings ?: [[NSDictionary alloc] initWithContentsOfFile:self.plistPath];
}

- (NSMutableDictionary *)blocks;
{
  return _blocks = _blocks ?: [[NSMutableDictionary alloc] init];
}

- (NSMutableDictionary *)colors;
{
  return _colors = _colors ?: [[NSMutableDictionary alloc] init];
}

@end

static UIColor *ColorDispatcher(PSStyle *self, SEL _cmd)
{
  NSString *key = NSStringFromSelector(_cmd);
  UIColor *color = [self.colors objectForKey:key];
  
  if (!color) {
    [NSException raise:NSInternalInconsistencyException format:@"No color found for %@", key];
  }
  
  return color;
}

static id BlockDispatcher(id self, SEL _cmd)
{
  NSString *key = NSStringFromSelector(_cmd);
  UIColor * (^block)(void) = [[self blocks] objectForKey:key];
  
  if (!block) {
    [NSException raise:NSInternalInconsistencyException format:@"No block found for %@", key];
  }
  
  return block();
}
