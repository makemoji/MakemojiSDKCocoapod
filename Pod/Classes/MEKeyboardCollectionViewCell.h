//
//  MEKeyboardCollectionViewCell.h
//  Makemoji
//
//  Created by steve on 5/28/15.
//  Copyright (c) 2015 Makemoji. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MEEmojiButton.h"

@interface MEKeyboardCollectionViewCell : UICollectionViewCell <MEEmojiButtonDelegate>

@property MEEmojiButton *inputButton;

- (void)startLinkAnimation;
@end
