//
//  PSFakeNotificationCenter.m
//  PSStyle
//
//  Created by Paul Samuels on 13/09/2012.
//  Copyright (c) 2012 Paul Samuels. All rights reserved.
//

#import "PSFakeNotificationCenter.h"

@implementation PSFakeNotificationCenter

- (void)addObserver:(id)observer selector:(SEL)aSelector name:(NSString *)aName object:(id)anObject;
{
  self.didRegister = YES;
}

@end
