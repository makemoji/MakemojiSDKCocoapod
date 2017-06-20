//
//  MakemojiSDK.m
//  MakemojiSDK
//
//  Created by steve on 7/1/15.
//  Copyright (c) 2015 Makemoji. All rights reserved.
//

#import "MakemojiSDK.h"
#import "MEAPIManager.h"
#import <SDWebImage/UIImageView+WebCache.h>

NSString *const MECategoryUnlockedSuccessNotification = @"MECategoryUnlockedSuccessNotification";
NSString *const MECategoryUnlockedFailedNotification = @"MECategoryUnlockedFailedNotification";
NSString *const MECategorySelectedLockedCategory = @"MECategorySelectedLockedCategory";
NSString *const MEHypermojiLinkClicked = @"MEHypermojiLinkClicked";
NSString *const MEHyperlinkClicked = @"MEHyperlinkClicked";

@implementation MakemojiSDK

+(void)setSDKKey:(NSString *)sdkKey {
    [[MEAPIManager client] setSdkKey:sdkKey];
    NSString * url = @"emoji/emojiWall";
    MEAPIManager * manager = [MEAPIManager client];
    [manager.requestSerializer setValue:sdkKey forHTTPHeaderField:@"makemoji-sdkkey"];

    [manager GET:url parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSError * error;
        NSData * jsonData = [NSJSONSerialization dataWithJSONObject:responseObject options:kNilOptions error:&error];
        NSString *path = [[MakemojiSDK applicationDocumentsDirectory].path
                          stringByAppendingPathComponent:[[MEAPIManager client] cacheNameWithChannel:@"wall"]];
        [[NSFileManager defaultManager] createFileAtPath:path
                                                contents:jsonData
                                              attributes:nil];

    } failure:^(NSURLSessionDataTask *task, NSError *error) {

    }];

    //[[SDImageCache sharedImageCache] setMaxCacheAge:INT_MAX];
    
}

+(void)setChannel:(NSString *)channel {
    MEAPIManager * manager = [MEAPIManager client];
    [manager setChannel:channel];
    [manager.requestSerializer setValue:channel forHTTPHeaderField:@"makemoji-channel"];
}

+(NSArray *)unlockedGroups {
    NSUserDefaults * usrInfo = [[NSUserDefaults alloc] initWithSuiteName:@"MakemojiSDK"];
    if (usrInfo == nil) {
        return [NSArray array];
    }
    NSArray * unlockedGroups = [usrInfo objectForKey:@"MEUnlockedGroups"];
    if (unlockedGroups != nil && unlockedGroups.count > 0) {
        return unlockedGroups;
    }
    return [NSArray array];
}

+(void)unlockCategory:(NSString *)category {
    NSMutableArray * unlocked = [NSMutableArray array];
   
    NSUserDefaults * usrInfo = [[NSUserDefaults alloc] initWithSuiteName:@"MakemojiSDK"];
        __weak NSString * catName = category;
    
    if (usrInfo != nil) {
        NSArray * unlockedGroups = [usrInfo objectForKey:@"MEUnlockedGroups"];
        if (unlockedGroups != nil) {
            unlocked = [NSMutableArray arrayWithArray:unlockedGroups];
            for (NSString * arCatName in unlocked) {
                if ([arCatName isEqualToString:category]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSDictionary *userInfo = @{@"category_name": catName};
                        [[NSNotificationCenter defaultCenter] postNotificationName:MECategoryUnlockedSuccessNotification object:nil userInfo:userInfo];
                    });
                    return;
                }
            }
        }
    }
    
    NSString * url = @"emoji/unlockGroup";
    MEAPIManager * manager = [MEAPIManager client];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:url parameters:@{@"category_name" : category} success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        NSUserDefaults * userInfo = [[NSUserDefaults alloc] initWithSuiteName:@"MakemojiSDK"];
        [unlocked addObject:category];
        [userInfo setObject:[NSArray arrayWithArray:unlocked] forKey:@"MEUnlockedGroups"];
        [userInfo synchronize];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *userInfo = @{@"category_name": catName};
            [[NSNotificationCenter defaultCenter] postNotificationName:MECategoryUnlockedSuccessNotification object:nil userInfo:userInfo];
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *userInfo = @{@"category_name": catName};
            [[NSNotificationCenter defaultCenter] postNotificationName:MECategoryUnlockedFailedNotification object:error userInfo:userInfo];
        });
    }];
    
}

+ (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                   inDomains:NSUserDomainMask] lastObject];
}

@end
