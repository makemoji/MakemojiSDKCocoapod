//
//  MakemojiSDK.h
//  MakemojiSDK
//
//  Copyright (c) 2015 Makemoji. All rights reserved.
//

#import <Foundation/Foundation.h>

// NSNotification names

// unlocking notification names
extern NSString *const MECategoryUnlockedSuccessNotification;
extern NSString *const MECategoryUnlockedFailedNotification;
extern NSString *const MECategorySelectedLockedCategory;

// notification thrown when a hypermoji is tapped
extern NSString *const MEHypermojiLinkClicked;

// notifcation thrown when a link is tapped
extern NSString *const MEHyperlinkClicked;

@interface MakemojiSDK : NSObject

+ (void)setSDKKey:(NSString *)sdkKey;
+ (void)setChannel:(NSString *)channel;
+ (void)unlockCategory:(NSString *)category;
+ (NSArray *)unlockedGroups;

@end
