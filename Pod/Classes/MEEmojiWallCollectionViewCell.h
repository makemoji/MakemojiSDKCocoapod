//
//  MEEmojiWallCollectionViewCell.h
//  MakemojiSDK
//
//  Created by steve on 4/9/16.
//  Copyright © 2016 Makemoji. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MEEmojiWallCollectionViewCell : UICollectionViewCell <UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic) UICollectionView *emojiCollectionView;
@property (nonatomic) NSArray *emoji;
@property (nonatomic) NSString *selectedCategory;
@property (nonatomic) CGSize itemSize;
@property BOOL isVideoCollection;
@property (nonatomic) UIColor *videoTextColor;
@property (nonatomic) UIColor *playOverlayTint;

- (void)setEmojiData:(NSArray *)emoji;

@end
