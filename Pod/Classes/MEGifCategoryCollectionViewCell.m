//
//  MEGifCategoryCollectionViewCell.m
//  MakemojiSDK
//
//  Created by steve on 2/5/16.
//  Copyright © 2016 Makemoji. All rights reserved.
//

#import "MEGifCategoryCollectionViewCell.h"

@implementation MEGifCategoryCollectionViewCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.clipsToBounds = YES;
        self.categoryImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 34, 34)];
        [self.categoryImage setContentMode:UIViewContentModeScaleAspectFill];
        [self.contentView addSubview:self.categoryImage];
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    self.categoryImage.frame = CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height);
}

-(void)randomizeGradient {
    
}

@end
