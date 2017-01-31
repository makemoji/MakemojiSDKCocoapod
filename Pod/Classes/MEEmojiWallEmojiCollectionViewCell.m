//
//  MEEmojiWallEmojiCollectionViewCell.m
//  MakemojiSDK
//
//  Created by steve on 4/9/16.
//  Copyright © 2016 Makemoji. All rights reserved.
//

#import "MEEmojiWallEmojiCollectionViewCell.h"

@implementation MEEmojiWallEmojiCollectionViewCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
        [self.imageView setContentMode:UIViewContentModeScaleAspectFit];
        self.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.imageView];
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    self.imageView.frame = CGRectMake(0, 0, self.contentView.frame.size.width-25, self.contentView.frame.size.height-25);
    self.imageView.center = self.contentView.center;
    
}

@end
