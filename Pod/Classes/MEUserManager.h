//
//  MEUserManager.h
//  Makemoji
//
//  Copyright (c) 2015 Makemoji. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MEUserManager : NSObject {
    NSString *userId;
}
@property (nonatomic) NSString *userId;

+ (id)sharedManager;

@end
