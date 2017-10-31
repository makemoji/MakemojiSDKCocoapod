//
//  NSAttributedString_MoreExtensions.m
//  Makemoji
//
//  Created by steve on 3/13/15.
//  Copyright (c) 2015 Makemoji. All rights reserved.
//

#import "NSAttributedString_MoreExtensions.h"

@implementation NSAttributedString (NSAttributedString_MoreExtensions)
- (NSArray *)allAttachments
{
    NSMutableArray *theAttachments = [NSMutableArray array];
    NSRange theStringRange = NSMakeRange(0, [self length]);
    if (theStringRange.length > 0)
    {
        unsigned N = 0;
        do
        {
            NSRange theEffectiveRange;
            NSDictionary *theAttributes = [self attributesAtIndex:N longestEffectiveRange:&theEffectiveRange inRange:theStringRange];
            NSTextAttachment *theAttachment = [theAttributes objectForKey:NSAttachmentAttributeName];
            if (theAttachment != NULL)
                [theAttachments addObject:theAttachment];
            N = (int)theEffectiveRange.location + (int)theEffectiveRange.length;
        }
        while (N < theStringRange.length);
    }
    return(theAttachments);
}

@end
