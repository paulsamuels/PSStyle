//
//  PSStyle2.m
//  Testing
//
//  Created by Paul Samuels on 11/09/2012.
//  Copyright (c) 2012 Paul Samuels. All rights reserved.
//

#import "PSStyle.h"
#import <objc/objc-runtime.h>

static UIColor *ColorDispatcher(id self, SEL _cmd);

@interface PSStyle ()

@property (nonatomic, strong) NSDictionary        *styleMappings;
@property (nonatomic, strong) NSMutableDictionary *colorBlocks;

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
    [self loadBlocks];
  }
  return self;
}

+ (void)reset;
{
  PSStyle *instance = [self sharedInstance];
  
  instance->_plistPath     = nil;
  instance->_styleMappings = nil;
  [instance loadBlocks];
}

+ (BOOL)resolveInstanceMethod:(SEL)sel;
{
  NSString *key = NSStringFromSelector(sel);
  
  if ([key hasSuffix:@"Color"] && [[[self sharedInstance] colorBlocks] objectForKey:key]) {
    class_addMethod([self class], sel, (IMP)ColorDispatcher, "@@:");
    return YES;
  }
  
  return [super resolveInstanceMethod:sel];
}

- (void)loadBlocks;
{
  [self.styleMappings enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSArray *components, BOOL *stop) {
    if ([key hasSuffix:@"Color"] && 4 == components.count) {
      CGFloat red   = [[components objectAtIndex:0] floatValue] / 255.f;
      CGFloat green = [[components objectAtIndex:1] floatValue] / 255.f;
      CGFloat blue  = [[components objectAtIndex:2] floatValue] / 255.f;
      CGFloat alpha = [[components objectAtIndex:3] floatValue] / 255.f;
      
      [self.colorBlocks setObject:^{
        return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
      } forKey:key];
    }
  }];
}

#pragma mark - Properties

- (void)setPlistPath:(NSString *)plistPath;
{
  if (_plistPath != plistPath) {
    _plistPath     = plistPath;
    _styleMappings = nil;
    [self loadBlocks];
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

- (NSMutableDictionary *)colorBlocks;
{
  return _colorBlocks = _colorBlocks ?: [[NSMutableDictionary alloc] init];
}

@end

static UIColor *ColorDispatcher(id self, SEL _cmd)
{
  NSString *key = NSStringFromSelector(_cmd);
  UIColor * (^block)(void) = [[self colorBlocks] objectForKey:key];

  if (!block) {
    [NSException raise:NSInternalInconsistencyException format:@"No block found for %@", key];
  }
  
  return block();
}
