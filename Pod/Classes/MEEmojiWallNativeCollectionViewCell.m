//
//  MEEmojiWallNativeCollectionViewCell.m
//  MakemojiSDK
//
//  Created by steve on 1/26/16.
//  Copyright © 2016 Makemoji. All rights reserved.
//

#import "MEEmojiWallNativeCollectionViewCell.h"

@implementation MEEmojiWallNativeCollectionViewCell
- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.clipsToBounds = YES;
        self.emojiView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 34, 34)];
        [self.emojiView setContentMode:UIViewContentModeScaleAspectFit];
        self.emojiView.font = [UIFont boldSystemFontOfSize:28];
        [self.emojiView setAdjustsFontSizeToFitWidth:YES];
        [self.emojiView setMinimumScaleFactor:0.8];
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
    self.emojiView.font = [UIFont boldSystemFontOfSize:self.contentView.frame.size.width-30];
    self.emojiView.frame = CGRectMake(0, 0, self.contentView.frame.size.width-30, self.contentView.frame.size.height-30);
    self.emojiView.center = self.contentView.center;
}

@end
