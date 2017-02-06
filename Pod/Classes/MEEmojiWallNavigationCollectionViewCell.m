//
//  MEEmojiWallNavigationCollectionViewCell.m
//  MakemojiSDK
//
//  Created by steve on 1/22/16.
//  Copyright © 2016 Makemoji. All rights reserved.
//

#import "MEEmojiWallNavigationCollectionViewCell.h"

@implementation MEEmojiWallNavigationCollectionViewCell

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.clipsToBounds = YES;
        self.contentView.layer.cornerRadius = self.contentView.frame.size.width/2;
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width-10, self.contentView.frame.size.width-10)];
        self.imageView.center = self.contentView.center;
        [self.imageView setImage:[UIImage imageNamed:@"Makemoji.bundle/defaultnavicon" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil]];
        [self.imageView setContentMode:UIViewContentModeScaleAspectFit];
        self.imageView.alpha = 0.70;
        [self.contentView addSubview:self.imageView];
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    self.imageView.center = self.contentView.center;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    if (selected) {
        self.imageView.alpha = 1.0;
        self.contentView.backgroundColor = [UIColor colorWithRed:0.82 green:0.847 blue:0.874 alpha:1];
    } else {
        self.contentView.backgroundColor = [UIColor clearColor];
        self.imageView.alpha = 0.75;
    }
}

@end
