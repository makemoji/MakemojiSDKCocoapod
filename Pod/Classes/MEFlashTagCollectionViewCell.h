//
//  MEFlashTagCollectionViewCell.h
//  Makemoji
//
//  Created by steve on 5/22/15.
//  Copyright (c) 2015 Makemoji. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MEFlashTagCollectionViewCell : UICollectionViewCell
@property (nonatomic) UIImageView *imageView;
@property (nonatomic) UILabel *flashTagLabel;
@property (nonatomic) NSString *currentInput;
@property (nonatomic) NSString *flashTag;
@property (nonatomic) UIView *rightSpacer;
@property (nonatomic) UIView *leftSpacer;

- (void)setData:(NSDictionary *)data;
@end
