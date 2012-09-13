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
    [self createDirectoryStructure];
    [self.notificationCenter addObserver:self
                                selector:@selector(didReceiveMemoryWarning)
                                    name:UIApplicationDidReceiveMemoryWarningNotification
                                  object:nil];
  }
  return self;
}

- (BOOL)registerStyleDispatcherClass:(Class)styleDispatcherClass;
{
  if ([styleDispatcherClass conformsToProtocol:@protocol(PSStyleDispatcher)]) {
    NSString *className = NSStringFromClass(styleDispatcherClass);
    
    [self.styleClasses removeObject:className];
    [self.styleClasses insertObject:className atIndex:0];
    
    return YES;
  }
  return NO;
}

- (void)unregisterStyleDispatcherClass:(Class)styleDispatcherClass;
{
  NSString *className = NSStringFromClass(styleDispatcherClass);
  [self.styleClasses removeObject:className];
}

- (void)didReceiveMemoryWarning;
{
  [self purgeAll];
}

- (void)purgeAll;
{
  for (id dispatcher in self.dispatchers.allValues) {
    if ([dispatcher respondsToSelector:@selector(purgeCaches)]) {
      [dispatcher purgeCaches];
    }
  }
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

- (void)createDirectoryStructure;
{
  [[NSFileManager defaultManager] createDirectoryAtPath:self.assetDirectory
                            withIntermediateDirectories:YES
                                             attributes:nil
                                                  error:nil];
}

#pragma mark - Properties


- (NSString *)assetDirectory;
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
    [self purgeAll];
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
  NSString *key        = NSStringFromSelector(_cmd);
  
  NSEnumerator *enumerator = [self.styleClasses reverseObjectEnumerator];
  
  while ((className = [enumerator nextObject])) {
    
    Class styleClass = NSClassFromString(className);
    if (styleClass && [styleClass canHandleStyleSelector:_cmd]) {
      
      id<PSStyleDispatcher> dispatcher = [self dispatcherForClass:styleClass];
      NSDictionary *metaData = [self.styleMappings objectForKey:key];
      styleAsset = [dispatcher styleAssetWithKey:key metaData:metaData];
      
      break;
    }
    
  }
  
  if (!styleAsset) {
    [NSException raise:NSInternalInconsistencyException format:@"No style asset found for %@", key];
  }
  
  return styleAsset;
}
