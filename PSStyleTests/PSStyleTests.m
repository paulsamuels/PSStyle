//
//  PSStyleTests.m
//  PSStyleTests
//
//  Created by Paul Samuels on 11/09/2012.
//  Copyright (c) 2012 Paul Samuels. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "ExampleStyle.h"
#import "PSFakeNotificationCenter.h"
#import "PSStyleColorResolver.h"
#import <objc/runtime.h>
#import <objc/message.h>

@interface PSStyleTests : SenTestCase

@property (nonatomic, strong) ExampleStyle *style;

@end

@implementation PSStyleTests

- (void)setUp
{
  [super setUp];
  
  _style = [[ExampleStyle alloc] init];
}

- (void)tearDown
{
  _style = nil;
  [super tearDown];
}

- (void)testItCanDealWithChangingThePlist;
{
  NSString *customPlist = [[NSBundle bundleForClass:[self class]] pathForResource:@"customStyle" ofType:@"plist"];
  STAssertNoThrow(self.style.plistPath = customPlist, @"");
}

- (void)testItRegistersToReceiveLowMemoryNotifications;
{
  PSFakeNotificationCenter *notificationCenter = [[PSFakeNotificationCenter alloc] init];
  
  self.style.notificationCenter = (id)notificationCenter;
  (void)[self.style init];
  
  STAssertTrue(notificationCenter.didRegister, @"");
}

- (void)testItReturnsNOIfAddingInvalidDispatcher;
{
  STAssertFalse([self.style registerStyleResolverClass:[NSObject class]], @"");
}

- (void)testItCanAddDispatchers;
{
  STAssertTrue([self.style registerStyleResolverClass:[PSStyleColorResolver class]], @"");
}

- (void)testItCanRemoveDispatchers;
{
  STAssertNoThrow([self.style unregisterStyleResolverClass:[PSStyleColorResolver class]], @"");
}

@end
