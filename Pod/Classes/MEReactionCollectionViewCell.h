//
//  MEReactionCollectionViewCell.h
//  MakemojiSDK
//
//  Created by steve on 6/11/16.
//  Copyright © 2016 Makemoji. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MEReactionCollectionViewCell : UICollectionViewCell

@property (nonatomic) UIImageView *imageView;
@property (nonatomic) UILabel *totalLabel;
@property (nonatomic) UILabel *unicodeEmoji;
@property (nonatomic) UIColor *highlightColor;
@property (nonatomic) UIColor *borderColor;
@property (nonatomic) UIColor *textColor;

- (void)setReactionData:(NSDictionary *)reaction;

@end
