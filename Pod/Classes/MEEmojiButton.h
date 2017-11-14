//
//  MEEmojiButton.h
//  Makemoji
//
//  Created by steve on 5/28/15.
//  Copyright (c) 2015 Makemoji. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CYRKeyboardButton.h"
#import <FLAnimatedImage/FLAnimatedImageView.h>

@protocol MEEmojiButtonDelegate;

@interface MEEmojiButton : CYRKeyboardButton
@property (nonatomic) UIImageView *imageView;
@property (nonatomic) FLAnimatedImageView *gifImageView;
@property (nonatomic, weak) id <MEEmojiButtonDelegate> delegate;
@end

@protocol MEEmojiButtonDelegate <NSObject>
- (void)meEmojiButton:(MEEmojiButton *)emojiButton didSelectKey:(UIView *)view;
@end
