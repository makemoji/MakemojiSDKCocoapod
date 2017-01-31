//
//  NSAttributedString_MoreExtensions.h
//  Makemoji
//
//  Created by steve on 3/13/15.
//  Copyright (c) 2015 Makemoji. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSAttributedString (NSAttributedString_MoreExtensions)

/**
 * @method allAttachments
 * @abstract Fetchs all attachments from an NSAttributedString.
 * @discussion This method searchs for NSAttachmentAttributeName attributes within the string instead of searching for NSAttachmentCharacter characters.
 */
- (NSArray *)allAttachments;

@end
