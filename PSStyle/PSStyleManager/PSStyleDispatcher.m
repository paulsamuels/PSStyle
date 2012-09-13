//
//  PSStyleDispatcher.m
//  PSStyle
//
//  Created by Paul Samuels on 13/09/2012.
//  Copyright (c) 2012 Paul Samuels. All rights reserved.
//

#import "PSStyleDispatcher.h"

@implementation PSStyleDispatcher

- (id)initWithStyleManager:(PSStyleManager *)styleManager;
{
  self = [super init];
  if (self) {
    _styleManager = styleManager;
  }
  return self;
}

+ (BOOL)canHandleStyleSelector:(SEL)sel;
{
  return NO;
}

- (id)styleAssetWithKey:(NSString *)key metaData:(id)metaData;
{
  [self doesNotRecognizeSelector:_cmd];
  return nil;
}

@end
