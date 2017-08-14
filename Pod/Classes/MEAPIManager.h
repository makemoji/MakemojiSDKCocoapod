//
//  MEApiManager.h
//  Makemoji
//
//  Created by steve on 3/2/15.
//  Copyright (c) 2015 Makemoji. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import "MEAPIConstants.h"
#import "MEUserManager.h"

@interface MEAPIManager : AFHTTPSessionManager

@property (nonatomic) NSDate *imageViewSessionStart;
@property (nonatomic) NSString *sdkKey;
@property (nonatomic) NSString *channel;
@property (nonatomic) NSArray * categories;
@property (nonatomic) NSArray * lockedCategories;
@property (nonatomic) NSString *externalUserId;
@property (nonatomic) NSMutableDictionary *imageViews;
@property (nonatomic) NSMutableArray *emojiClicks;
@property (nonatomic) NSDate *clickSessionStart;

+ (instancetype)client;
- (void)imageViewWithId:(NSString *)emojiId;
- (void)beginImageViewSessionWithTag:(NSString *)tag;
- (void)endImageViewSession;
- (void)clickWithEmoji:(NSDictionary *)emoji;
- (NSString *)cacheNameWithChannel:(NSString *)cacheName;

@end
