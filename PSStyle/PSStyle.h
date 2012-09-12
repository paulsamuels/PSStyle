//
//  PSStyle2.h
//  Testing
//
//  Created by Paul Samuels on 11/09/2012.
//  Copyright (c) 2012 Paul Samuels. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PSStyle : NSObject

@property (nonatomic, strong) NSString             *plistPath;
@property (nonatomic, strong) NSNotificationCenter *notificationCenter;

+ (id)sharedInstance;

@end
