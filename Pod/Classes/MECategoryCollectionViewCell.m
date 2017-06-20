//
//  MECategoryCollectionViewCell.m
//  Makemoji
//
//  Created by steve on 1/20/15.
//  Copyright (c) 2015 Makemoji. All rights reserved.
//

#import "MECategoryCollectionViewCell.h"

@implementation MECategoryCollectionViewCell


- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(4, 4, 60, 60)];
        [self.imageView setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin];
        
        [self.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [self.imageView setCenter:self.contentView.center];
        [self.imageView setFrame:CGRectMake(self.imageView.frame.origin.x, 6, 60, 60)];
        
        [self.contentView addSubview:self.imageView];
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 70, 20)];
        self.titleLabel.center = self.contentView.center;
        self.titleLabel.frame = CGRectMake(self.titleLabel.frame.origin.x, self.imageView.frame.size.height+self.imageView.frame.origin.y, 70, 18);
        self.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.titleLabel];
 
        self.lockedImageView = [[UIImageView alloc] initWithFrame:CGRectMake(4, 4, 60, 60)];
        [self.lockedImageView setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin];
        [self.lockedImageView setContentMode:UIViewContentModeScaleAspectFit];
        [self.lockedImageView setCenter:self.contentView.center];
        [self.lockedImageView setFrame:CGRectMake(self.lockedImageView.frame.origin.x, 6, 60, 60)];

        [self.contentView addSubview:self.lockedImageView];
        
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    self.imageView.center = self.contentView.center;
    self.lockedImageView.center = self.contentView.center;
    self.titleLabel.frame = CGRectMake(self.titleLabel.frame.origin.x, self.imageView.frame.size.height+self.imageView.frame.origin.y, 70, 18);
}

@end
