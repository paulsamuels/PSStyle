//
//  PSStyle.h
//  Testing
//
//  Created by Paul Samuels on 11/09/2012.
//  Copyright (c) 2012 Paul Samuels. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PSStyleManager;

@protocol PSStyleDispatcher <NSObject>

+ (BOOL)canHandleStyleSelector:(SEL)sel;

- (id)initWithStyleManager:(PSStyleManager *)styleManager;
- (id)styleAssetWithKey:(NSString *)key metaData:(id)metaData;

@optional
- (void)purgeCaches;

@end

@interface PSStyleManager : NSObject

@property (nonatomic, strong)         NSString             *plistPath;
@property (nonatomic, strong)         NSNotificationCenter *notificationCenter;
@property (nonatomic, copy, readonly) NSString             *assetDirectory;

- (BOOL)registerStyleDispatcherClass:(Class)styleDispatcherClass;
- (void)unregisterStyleDispatcherClass:(Class)styleDispatcherClass;

@end
