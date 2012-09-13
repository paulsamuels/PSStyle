//
//  PSFakeNotificationCenter.h
//  PSStyle
//
//  Created by Paul Samuels on 13/09/2012.
//  Copyright (c) 2012 Paul Samuels. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PSFakeNotificationCenter : NSObject

@property (nonatomic, assign) BOOL didRegister;

- (void)addObserver:(id)observer selector:(SEL)aSelector name:(NSString *)aName object:(id)anObject;
- (void)removeObserver:(id)notificationObserver;

@end
