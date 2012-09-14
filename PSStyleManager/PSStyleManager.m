//
//  PSStyle.m
//  Testing
//
//  Created by Paul Samuels on 11/09/2012.
//  Copyright (c) 2012 Paul Samuels. All rights reserved.
//

#import "PSStyleManager.h"
#import "PSStyleResolver.h"
#import <objc/runtime.h>

static NSMutableSet *ResolverClasses;

static id StyleDispatch(PSStyleManager *self, SEL _cmd);

@interface PSStyleManager ()

@property (nonatomic, strong) NSDictionary        *styleMappings;
@property (nonatomic, strong) NSMutableArray      *styleResolverClasses;
@property (nonatomic, strong) NSMutableDictionary *resolvers;

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

+ (void)initialize;
{
  if (self == [PSStyleManager class]) {
    ResolverClasses = [[NSMutableSet alloc] init];
  }
}

- (BOOL)registerStyleResolverClass:(Class)styleResolverClass;
{
  if ([styleResolverClass conformsToProtocol:@protocol(PSStyleResolver)]) {
    NSString *className = NSStringFromClass(styleResolverClass);
    
    [self.styleResolverClasses removeObject:className];
    [self.styleResolverClasses insertObject:className atIndex:0];
    
    [ResolverClasses addObject:className];
    
    return YES;
  }
  return NO;
}

- (void)unregisterStyleResolverClass:(Class)styleResolverClass;
{
  NSString *className = NSStringFromClass(styleResolverClass);
  [self.styleResolverClasses removeObject:className];
  
  [ResolverClasses removeObject:className];
}

- (void)didReceiveMemoryWarning;
{
  [self purgeAll];
}

- (void)purgeAll;
{
  for (id resolver in self.resolvers.allValues) {
    if ([resolver respondsToSelector:@selector(purgeCaches)]) {
      [resolver purgeCaches];
    }
  }
}

+ (BOOL)resolveInstanceMethod:(SEL)sel;
{
  BOOL methodAdded = NO;
  
  for (NSString *className in ResolverClasses) {
    Class resolverClass = NSClassFromString(className);
    
    if (resolverClass && [resolverClass canHandleStyleSelector:sel] && ![className hasPrefix:@"_"]) {
      methodAdded = class_addMethod([self class], sel, (IMP)StyleDispatch, "@@:");
    }
  }
  
  return methodAdded || [super resolveInstanceMethod:sel];
}

- (id<PSStyleResolver>)resolverForClass:(Class)resolverClass;
{
  NSString *className = NSStringFromClass(resolverClass);
  
  id<PSStyleResolver> resolver = [self.resolvers objectForKey:className];
  
  if (!resolver) {
    resolver = [[resolverClass alloc] initWithStyleManager:self];
    [self.resolvers setValue:resolver forKey:className];
  }
  
  return resolver;
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
  NSString *cachesDirectory = [[[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject] path];
  
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

- (NSMutableArray *)styleResolverClasses;
{
  return _styleResolverClasses = _styleResolverClasses ?: [[NSMutableArray alloc] init];
}

- (NSNotificationCenter *)notificationCenter;
{
  return _notificationCenter = _notificationCenter ?: [NSNotificationCenter defaultCenter];
}

- (NSMutableDictionary *)resolvers;
{
  return _resolvers = _resolvers ?: [[NSMutableDictionary alloc] init];
}

@end

static id StyleDispatch(PSStyleManager *self, SEL _cmd)
{
  NSString *className  = nil;
  id        styleAsset = nil;
  NSString *key        = NSStringFromSelector(_cmd);
  
  NSEnumerator *enumerator = [self.styleResolverClasses reverseObjectEnumerator];
  
  while ((className = [enumerator nextObject])) {
    
    Class styleClass = NSClassFromString(className);
    if (styleClass && [styleClass canHandleStyleSelector:_cmd]) {
      
      id<PSStyleResolver> resolver = [self resolverForClass:styleClass];
      NSDictionary *metaData = [self.styleMappings objectForKey:key];
      styleAsset = [resolver styleAssetWithKey:key metaData:metaData];
      
      break;
    }
    
  }
  
  if (!styleAsset) {
    [NSException raise:NSInternalInconsistencyException format:@"No style asset found for %@", key];
  }
  
  return styleAsset;
}
