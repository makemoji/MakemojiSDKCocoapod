//
//  MEKeyboardCollectionViewCell.m
//  Makemoji
//
//  Created by steve on 5/28/15.
//  Copyright (c) 2015 Makemoji. All rights reserved.
//

#import "MEKeyboardCollectionViewCell.h"

@implementation MEKeyboardCollectionViewCell

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        self.inputButton = [MEEmojiButton new];
        self.inputButton.accessibilityLabel = @"Emoji";
        self.inputButton.frame = CGRectMake(0,0,frame.size.width, frame.size.height);
        self.inputButton.translatesAutoresizingMaskIntoConstraints = NO;
        self.inputButton.delegate = self;
        [self.contentView addSubview:self.inputButton];
        
    }
    return self;
}

-(void)meEmojiButton:(MEEmojiButton *)emojiButton didSelectKey:(UIView *)view {
    UICollectionView * collectionView = (UICollectionView *)[self superview];
    NSIndexPath * indexPath = [collectionView indexPathForCell:self];
    [collectionView.delegate collectionView:collectionView didSelectItemAtIndexPath:indexPath];
}

-(void)startLinkAnimation {
    [self.inputButton.layer removeAllAnimations];
    CABasicAnimation *imageSwitchAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    imageSwitchAnimation.fromValue = [NSNumber numberWithFloat:1];
    imageSwitchAnimation.toValue = [NSNumber numberWithFloat:0.33];
    imageSwitchAnimation.duration = 1.0f;
    imageSwitchAnimation.repeatCount = HUGE_VALF;
    imageSwitchAnimation.autoreverses = YES;
    [self.inputButton.layer addAnimation:imageSwitchAnimation forKey:@"animateContents"];
}

-(void)layoutSubviews {
    [super layoutSubviews];
    self.inputButton.frame = CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height);
}

-(void)prepareForReuse {
    [super prepareForReuse];
    self.inputButton.imageView.image = nil;
    self.inputButton.gifImageView.animatedImage = nil;
    self.inputButton.gifImageView.image = nil;
}

-(void)dealloc {
    self.inputButton.delegate = nil;
}

@end
