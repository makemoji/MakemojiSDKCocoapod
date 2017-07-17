//
//  MEFlashTagCollectionViewCell.h
//  Makemoji
//
//  Created by steve on 5/22/15.
//  Copyright (c) 2015 Makemoji. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MEEmojiButton.h"

@interface MEFlashTagCollectionViewCell : UICollectionViewCell <MEEmojiButtonDelegate>

@property MEEmojiButton *inputButton;

- (void)startLinkAnimation;
@end
