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
static UIImage *RoundedImageDispatcher(PSStyle *self, SEL _cmd);

@interface PSStyle ()

@property (nonatomic, strong) NSDictionary        *styleMappings;
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

- (void)dealloc;
{
  [self.notificationCenter removeObserver:self];
}

- (id)init;
{
  self = [super init];
  if (self) {
    [self createDirectoryStructure];
    [self.notificationCenter addObserver:self
                                selector:@selector(didReceiveMemoryWarning)
                                    name:UIApplicationDidReceiveMemoryWarningNotification
                                  object:nil];
  }
  return self;
}

- (void)didReceiveMemoryWarning;
{
  [[self class] reset];
}

+ (void)reset;
{
  PSStyle *instance = [self sharedInstance];
  
//  [[NSFileManager defaultManager] removeItemAtPath:[instance generatedImagesDirectory] error:nil];
  instance->_plistPath     = nil;
  instance->_styleMappings = nil;
  instance->_colors        = nil;
}

+ (BOOL)resolveInstanceMethod:(SEL)sel;
{
  NSString *key = NSStringFromSelector(sel);
  
  BOOL didAdd = NO;
  
  if ([key hasSuffix:@"RoundedImage"]) {
    didAdd = class_addMethod([self class], sel, (IMP)RoundedImageDispatcher, "@@:");
  } else if ([key hasSuffix:@"Color"]) {
    didAdd = class_addMethod([self class], sel, (IMP)ColorDispatcher, "@@:");
  }
  
  return didAdd || [super resolveInstanceMethod:sel];
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

- (void)createDirectoryStructure;
{
  [[NSFileManager defaultManager] createDirectoryAtPath:[self generatedImagesDirectory]
                            withIntermediateDirectories:YES
                                             attributes:nil
                                                  error:nil];
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
    _colors        = nil;
    [self createDirectoryStructure];
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

- (NSMutableDictionary *)colors;
{
  return _colors = _colors ?: [[NSMutableDictionary alloc] init];
}

- (NSNotificationCenter *)notificationCenter;
{
  return _notificationCenter = _notificationCenter ?: [NSNotificationCenter defaultCenter];
}

@end

static UIColor *ColorDispatcher(PSStyle *self, SEL _cmd)
{
  NSString *key = NSStringFromSelector(_cmd);
  UIColor *color = [self.colors objectForKey:key];
  
  if (!color) {
    color = [self colorWithRGBA:[self.styleMappings objectForKey:key]];
    [self.colors setValue:color forKey:key];
  }
  
  if (!color) {
    [NSException raise:NSInternalInconsistencyException format:@"No color found for %@", key];
  }
  
  return color;
}

static UIImage *RoundedImageDispatcher(PSStyle *self, SEL _cmd)
{
  NSString     *key     = NSStringFromSelector(_cmd);
  NSDictionary *options = [self.styleMappings objectForKey:key];
  
  id        colorComponentsOrName  = [options objectForKey:@"color"];
  CGFloat   radius                 = [[options objectForKey:@"radius"] floatValue];
  
  UIColor *color = nil;
  
  if ([colorComponentsOrName respondsToSelector:@selector(count)]) {
    color = [self colorWithRGBA:colorComponentsOrName];
  } else {
    color = [self.colors objectForKey:colorComponentsOrName];
    if (!color) {
      color = [UIColor performSelector:NSSelectorFromString(colorComponentsOrName)];
    }
  }
  
  CGFloat   scale     = [UIScreen mainScreen].scale;
  NSString *imagePath = [[self generatedImagesDirectory] stringByAppendingFormat:@"/%@%@.png", key, 2 == scale ? @"@2x" : @""];
  
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
