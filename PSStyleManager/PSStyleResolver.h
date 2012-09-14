//
//  PSStyleDispatcher.h
//  PSStyle
//
//  Created by Paul Samuels on 13/09/2012.
//  Copyright (c) 2012 Paul Samuels. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PSStyleManager.h"

@interface PSStyleResolver : NSObject <PSStyleResolver>

@property (nonatomic, weak) PSStyleManager *styleManager;

@end
