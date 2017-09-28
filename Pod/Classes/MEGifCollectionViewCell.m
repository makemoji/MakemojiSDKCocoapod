//
//  MEGifCollectionViewCell.m
//  MakemojiSDK
//
//  Created by steve on 2/5/16.
//  Copyright © 2016 Makemoji. All rights reserved.
//

#import "MEGifCollectionViewCell.h"

@implementation MEGifCollectionViewCell
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView = [[FLAnimatedImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self.imageView setContentMode:UIViewContentModeScaleAspectFit];
        self.imageView.clipsToBounds = YES;
        self.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.imageView];
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    self.imageView.frame = CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height);
}
@end
