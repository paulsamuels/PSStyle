//
//  PSStyle.m
//  Testing
//
//  Created by Paul Samuels on 11/09/2012.
//  Copyright (c) 2012 Paul Samuels. All rights reserved.
//

#import "PSStyleManager.h"
#import "PSStyleDispatcher.h"
#import <objc/runtime.h>

static id StyleDispatch(PSStyleManager *self, SEL _cmd);

@interface PSStyleManager ()

@property (nonatomic, strong) NSDictionary        *styleMappings;
@property (nonatomic, strong) NSMutableArray      *styleClasses;
@property (nonatomic, strong) NSMutableDictionary *dispatchers;

@end

@implementation PSStyleManager {
  NSString *_plistPath;
}

- (void)dealloc;
{
  [self.notificationCenter removeObserver:self];
}

- (id)init;
{
  self = [super init];
  if (self) {
    [self.notificationCenter addObserver:self
                                selector:@selector(didReceiveMemoryWarning)
                                    name:UIApplicationDidReceiveMemoryWarningNotification
                                  object:nil];
  }
  return self;
}

- (BOOL)registerStyleClass:(Class)styleClass;
{
  if ([styleClass conformsToProtocol:@protocol(PSStyleDispatcher)]) {
    NSString *className = NSStringFromClass(styleClass);
    
    [self.styleClasses removeObject:className];
    [self.styleClasses insertObject:className atIndex:0];
    
    return YES;
  }
  return NO;
}

- (void)unregisterStyleClass:(Class)styleClass;
{
  NSString *className = NSStringFromClass(styleClass);
  [self.styleClasses removeObject:className];
}

- (void)didReceiveMemoryWarning;
{
  [self purgeAll];
}

- (void)purgeAll;
{
  [self.dispatchers.allValues makeObjectsPerformSelector:@selector(purgeCaches)];
}

+ (BOOL)resolveInstanceMethod:(SEL)sel;
{    
  BOOL methodAdded = class_addMethod([self class], sel, (IMP)StyleDispatch, "@@:");;
  return methodAdded || [super resolveInstanceMethod:sel];
}

- (id<PSStyleDispatcher>)dispatcherForClass:(Class)dispatcherClass;
{
  NSString *className = NSStringFromClass(dispatcherClass);
  
  id<PSStyleDispatcher> dispatcher = [self.dispatchers objectForKey:className];
  
  if (!dispatcher) {
    dispatcher = [[dispatcherClass alloc] initWithStyleManager:self];
    [self.dispatchers setValue:dispatcher forKey:className];
  }
  
  return dispatcher;
}

#pragma mark - Properties

- (void)setPlistPath:(NSString *)plistPath;
{
  if (_plistPath != plistPath) {
    _plistPath     = plistPath;
    _styleMappings = nil;
    [self purgeAll];
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

- (NSMutableArray *)styleClasses;
{
  return _styleClasses = _styleClasses ?: [[NSMutableArray alloc] init];
}

- (NSNotificationCenter *)notificationCenter;
{
  return _notificationCenter = _notificationCenter ?: [NSNotificationCenter defaultCenter];
}

- (NSMutableDictionary *)dispatchers;
{
  return _dispatchers = _dispatchers ?: [[NSMutableDictionary alloc] init];
}

@end

static id StyleDispatch(PSStyleManager *self, SEL _cmd)
{
  NSString *className  = nil;
  id        styleAsset = nil;
  
  NSEnumerator *enumerator = [self.styleClasses reverseObjectEnumerator];
  
  while (!styleAsset && (className = [enumerator nextObject])) {
    
    Class styleClass = NSClassFromString(className);
    if (styleClass && [styleClass canHandleStyleSelector:_cmd]) {
      
      id<PSStyleDispatcher> dispatcher = [self dispatcherForClass:styleClass];
      NSDictionary *metaData = [self.styleMappings objectForKey:NSStringFromSelector(_cmd)];
      styleAsset = [dispatcher styleAssetWithKey:NSStringFromSelector(_cmd) metaData:metaData];
      
      break;
    }
    
  }
  
  return styleAsset;
}
