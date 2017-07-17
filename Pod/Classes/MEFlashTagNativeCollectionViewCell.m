//
//  MEFlashTagNativeCollectionViewCell.m
//  Makemoji
//
//  Created by steve on 5/27/15.
//  Copyright (c) 2015 Makemoji. All rights reserved.
//

#import "MEFlashTagNativeCollectionViewCell.h"

@implementation MEFlashTagNativeCollectionViewCell
- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.clipsToBounds = YES;
        self.emojiView.translatesAutoresizingMaskIntoConstraints = NO;
        self.emojiView = [[UILabel alloc] initWithFrame: CGRectMake(0,0,frame.size.width, frame.size.height)];
        [self.emojiView setContentMode:UIViewContentModeScaleAspectFit];
        self.emojiView.font = [UIFont boldSystemFontOfSize:30];
        self.emojiView.adjustsFontSizeToFitWidth = YES;
        self.emojiView.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.emojiView];
    }
    return self;
}



-(void)setData:(NSDictionary *)data {
    [self.emojiView setText:[data objectForKey:@"character"]];
    [self layoutIfNeeded];
}

-(void)layoutSubviews {
    [super layoutSubviews];
    self.emojiView.frame = CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height);
}

-(void)prepareForReuse {
    self.currentInput = @"";
}

@end
