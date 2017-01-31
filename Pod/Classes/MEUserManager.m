//
//  MEUserManager.m
//  Makemoji
//
//  Created by steve on 3/17/15.
//  Copyright (c) 2015 Makemoji. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "MEUserManager.h"

@interface MEUserManager () {
NSString *userName;
NSString *token;
}
@property (nonatomic) NSString *userName;
@property (nonatomic) NSString *token;
@end

@implementation MEUserManager

@synthesize token;
@synthesize userId;
@synthesize userName;
//@synthesize messageController;

#pragma mark Singleton Methods

+ (id)sharedManager {
    static MEUserManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init {
    if (self = [super init]) {
        token = @"";
        userId = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        userName = @"";
    }
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}

@end
