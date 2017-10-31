//
//  NSString+MEUtilities.m
//  Makemoji
//
//  Created by steve on 5/20/15.
//  Copyright (c) 2015 Makemoji. All rights reserved.
//

#import "NSString+MEUtilities.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation NSString (MEUtilities)
- (BOOL) endsWithCharacter: (unichar) c
{
    NSUInteger length = [self length];
    return (length > 0) && ([self characterAtIndex: length - 1] == c);
}


- (NSString *)sha1
{
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, (int)data.length, digest);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
    {
        [output appendFormat:@"%02x", digest[i]];
    }
    
    return output;
}


@end
