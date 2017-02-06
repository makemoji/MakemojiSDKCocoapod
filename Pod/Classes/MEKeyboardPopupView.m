//
//  MEKeyboardPopupView.m
//  Makemoji
//
//  Created by steve on 5/5/15.
//  Copyright (c) 2015 Makemoji. All rights reserved.
//

#import "MEKeyboardPopupView.h"

@implementation MEKeyboardPopupView

- (id)init {
    return [self initWithFrame:CGRectZero];
}

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self.backgroundImageView setImage:[UIImage imageNamed:@"Makemoji.bundle/MEKeyPop" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil]];
        self.backgroundImageView.contentMode = UIViewContentModeScaleToFill;
        self.backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self addSubview:self.backgroundImageView];
        self.characterView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        self.characterView.contentMode = UIViewContentModeScaleAspectFit;
        self.characterView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:self.characterView];
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    self.backgroundImageView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    CGPoint newcenter = self.backgroundImageView.center;
    newcenter.y = 30;
    self.characterView.center = newcenter;
}

@end
