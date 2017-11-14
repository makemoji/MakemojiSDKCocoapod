//
//  MEEmojiButton.m
//  Makemoji
//
//  Created by steve on 5/28/15.
//  Copyright (c) 2015 Makemoji. All rights reserved.
//

#import "MEEmojiButton.h"
#import "MEKeyboardPopupView.h"

@implementation MEEmojiButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    [super commonInit];
    self.input = @" ";
    self.accessibilityLabel = @"emoji button";
    // Input label
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    self.gifImageView = [[FLAnimatedImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    
    self.gifImageView.accessibilityLabel = @"gif";
    self.imageView.accessibilityLabel = @"emoji";

    self.gifImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;

    self.gifImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.imageView];
    [self addSubview:self.gifImageView];
    self.buttonView = [[MEKeyboardPopupView alloc] initWithFrame:CGRectMake(0, 0, 58+14, 104+3)];
    self.buttonView.alpha = 0;

}


- (void)showInputView {
    if (self.buttonView.superview == nil) {
        [self.window addSubview:self.buttonView];
    }

    self.buttonView.alpha = 1;
    self.buttonView.characterView.image = self.imageView.image;
    CGRect trans = [self.window convertRect:self.superview.superview.frame fromView:self.superview.superview.superview];
    self.buttonView.frame = CGRectMake(trans.origin.x-12, trans.origin.y-72, 58+14, 104+3);
    [self.window bringSubviewToFront:self.buttonView];
}

- (void)hideInputView
{
    [UIView animateWithDuration:0.1
                          delay:0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         if (self.buttonView != nil) {
                             self.buttonView.alpha = 0;
                         }
                     }
                     completion:^(BOOL finished) {
                         if (finished == YES) {

                         }
                     }];
    
    [self setNeedsDisplay];
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    if ([self.delegate respondsToSelector:@selector(meEmojiButton:didSelectKey:)]) {
        [self.delegate meEmojiButton:self didSelectKey:self.buttonView];
    }
    
}

-(void)dealloc {
    [self.buttonView removeFromSuperview];
    self.buttonView = nil;
}

@end
