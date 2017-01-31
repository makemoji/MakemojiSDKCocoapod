//
//  MEEmojiWall.h
//  MakemojiSDK
//
//  Created by steve on 1/22/16.
//  Copyright © 2016 Makemoji. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol MEEmojiWallDelegate;

@interface MEEmojiWall : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic) UICollectionView *emojiCollectionView;
@property (nonatomic) UICollectionView *navigationCollectionView;
@property (nonatomic) NSIndexPath *selectedCategoryIndex;
@property (nonatomic) NSMutableArray *categories;
@property (nonatomic) NSMutableDictionary *categoryDictionary;
@property (nonatomic) NSMutableArray *trendingEmoji;
@property (nonatomic) NSMutableArray *searchResults;
@property (nonatomic) NSString *selectedCategory;
@property (nonatomic) NSString *currentKeyword;
@property (nonatomic) NSMutableArray *flashTags;
@property (nonatomic) NSString *navigationCellClass;
@property (nonatomic) UIColor *videoTextColor;
@property (nonatomic) UIColor *playOverlayTint;
@property BOOL shouldDisplayUnicodeEmoji;
@property BOOL shouldDisplayUsedEmoji;
@property BOOL shouldDisplayTrendingEmoji;
@property BOOL didDisplayOnce;
@property BOOL enableUpdates;

// defaults to 38
@property CGFloat navigationHeight;

// defaults to grid of 5x7
@property CGSize emojiSize;

// emoji wall delegate
@property (nonatomic, weak) id <MEEmojiWallDelegate> delegate;

- (void)setupLayoutWithSize:(CGSize)size;
- (void)loadEmoji;
- (void)loadedCategoryData;

@end

@protocol MEEmojiWallDelegate <NSObject>
- (void)meEmojiWall:(MEEmojiWall *)emojiWall didSelectEmoji:(NSDictionary*)emoji;
@optional
- (void)meEmojiWall:(MEEmojiWall *)emojiWall didSelectCategory:(NSDictionary *)category;
- (void)meEmojiWall:(MEEmojiWall *)emojiWall startedLoadingEmoji:(NSArray *)categories;
- (void)meEmojiWall:(MEEmojiWall *)emojiWall finishedLoadingEmoji:(NSDictionary *)emoji;
- (void)meEmojiWall:(MEEmojiWall *)emojiWall failedLoadingEmoji:(NSError *)error;
@end
