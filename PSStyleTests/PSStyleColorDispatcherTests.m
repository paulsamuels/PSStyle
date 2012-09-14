//
//  PSStyleColorDispatcherTests.m
//  PSStyle
//
//  Created by Paul Samuels on 13/09/2012.
//  Copyright (c) 2012 Paul Samuels. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "PSStyleColorResolver.h"

@interface PSStyleColorResolver (Testing)

@property (nonatomic, strong) NSMutableDictionary *cache;

@end

@interface PSStyleColorDispatcherTests : SenTestCase

@property (nonatomic, strong) PSStyleColorResolver *colorDispatcher;

@end

@implementation PSStyleColorDispatcherTests

- (void)setUp;
{
  [super setUp];
  self.colorDispatcher = [[PSStyleColorResolver alloc] init];
}

- (void)tearDown;
{
  self.colorDispatcher = nil;
  [super tearDown];
}

- (void)testItHandlesMethodsSuffixedWithColor;
{
  STAssertTrue([[self.colorDispatcher class] canHandleStyleSelector:NSSelectorFromString(@"someColor")], @"");
  STAssertTrue([[self.colorDispatcher class] canHandleStyleSelector:NSSelectorFromString(@"anotherColor")], @"");
}

- (void)testItWillNotHandleOtherSelectors;
{
  STAssertFalse([[self.colorDispatcher class] canHandleStyleSelector:NSSelectorFromString(@"someColorA")], @"");
  STAssertFalse([[self.colorDispatcher class] canHandleStyleSelector:NSSelectorFromString(@"someSelector")], @"");
}

- (void)testItCachesNewlyAddedItems;
{
  NSUInteger startCount = self.colorDispatcher.cache.count;
  
  [self.colorDispatcher styleAssetWithKey:@"someColor" metaData:[self redColor]];
  
  STAssertEquals(self.colorDispatcher.cache.count, startCount + 1, @"");
  
  [self.colorDispatcher styleAssetWithKey:@"someOtherColor" metaData:[self blueColor]];
  
  STAssertEquals(self.colorDispatcher.cache.count, startCount + 2, @"");
}

- (void)testItUsesCachedColorsWhenAvailable;
{
  NSUInteger startCount = self.colorDispatcher.cache.count;
  
  [self.colorDispatcher styleAssetWithKey:@"someColor" metaData:[self redColor]];
  [self.colorDispatcher styleAssetWithKey:@"someColor" metaData:[self redColor]];
  
  STAssertEquals(self.colorDispatcher.cache.count, startCount + 1, @"");
}

- (void)testItCanPurgeTheCache;
{
  [self.colorDispatcher styleAssetWithKey:@"someColor" metaData:[self redColor]];
  
  [self.colorDispatcher purgeCaches];
  
  STAssertEquals(self.colorDispatcher.cache.count, (NSUInteger)0, @"");
}

- (NSArray *)redColor;
{
  return @[ @(255), @(0), @(0), @(255) ];
}

- (NSArray *)blueColor;
{
  return @[ @(0), @(0), @(255), @(255) ];
}

@end
