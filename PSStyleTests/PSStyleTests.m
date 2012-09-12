//
//  PSStyleTests.m
//  PSStyleTests
//
//  Created by Paul Samuels on 11/09/2012.
//  Copyright (c) 2012 Paul Samuels. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "MyAppStyle.h"
#import "PSFakeNotificationCenter.h"
#import <objc/runtime.h>
#import <objc/message.h>

@interface PSStyle (Testing)

+ (void)reset;

@end

@interface PSStyleTests : SenTestCase

@property (nonatomic, strong) MyAppStyle *style;

@end

@implementation PSStyleTests

- (void)setUp
{
  [super setUp];
  
  _style = [MyAppStyle sharedInstance];
}

- (void)tearDown
{
  [[_style class] reset];
  [super tearDown];
}

- (void)testItProvidesNastySingletonAccess;
{
  STAssertEqualObjects([MyAppStyle sharedInstance], [MyAppStyle sharedInstance], @"");
}

- (void)testItScreamsIfColorIsNotInTheStyleSheet;
{
  STAssertThrows((void)self.style.undefinedColor, @"");
}

- (void)testItGetsColorsInTheStyleSheet;
{
  UIColor *expected = [UIColor colorWithRed:255.f/255.f green:0.f/155.f blue:0.f/255.f alpha:255.f/255.f];

  STAssertEqualObjects(self.style.redColor, expected, @"");
}

- (void)testItCanDealWithChaningThePlist;
{
  NSString *customPlist = [[NSBundle bundleForClass:[self class]] pathForResource:@"customStyle" ofType:@"plist"];
  STAssertNoThrow(self.style.plistPath = customPlist, @"");
}

- (void)testItGetsNewColorsIfPlistChanges;
{
  NSString *customPlist = [[NSBundle bundleForClass:[self class]] pathForResource:@"customStyle" ofType:@"plist"];
  self.style.plistPath = customPlist;
  
  UIColor *expected = [UIColor colorWithRed:0.f/255.f green:255.f/155.f blue:0.f/255.f alpha:255.f/255.f];
  
  STAssertEqualObjects(self.style.redColor, expected, @"");
}

- (void)testItGetsRoundedImagesInTheStyleSheet;
{
  STAssertNotNil(self.style.darkRoundedImage, @"");
}

- (void)testItScreamsIfRoundedImageIsNotInTheStyleSheet;
{
  STAssertThrows((void)self.style.undefinedRoundedImage, @"");
}

- (void)testItRegistersToReceiveLowMemoryNotifications;
{
  PSFakeNotificationCenter *notificationCenter = [[PSFakeNotificationCenter alloc] init];
  
  self.style.notificationCenter = (id)notificationCenter;
  (void)[self.style init];
  
  STAssertTrue(notificationCenter.didRegister, @"");
}

//- (void)testItPurgesDataInLowMemoryConditions;
//{
//  id object = nil;
//  object_getInstanceVariable(self.style, "as", &object);
//}

@end
