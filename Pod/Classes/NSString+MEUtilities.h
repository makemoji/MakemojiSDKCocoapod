//
//  NSString+MEUtilities.h
//  Makemoji
//
//  Created by steve on 5/20/15.
//  Copyright (c) 2015 Makemoji. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (MEUtilities)

- (BOOL)endsWithCharacter: (unichar) c;
- (NSString *)sha1;
@end
