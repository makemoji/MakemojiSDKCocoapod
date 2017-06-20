//
//  MEInputView.h
//  Makemoji
//
//  Copyright (c) 2015 Makemoji. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MEInputViewDelegate;

@interface MEInputView : UIView

@property (nonatomic) UIButton *deleteButton;
@property (nonatomic) UIButton *globeButton;
@property (nonatomic) UIPageControl *pageControl;
@property (nonatomic, weak) id <MEInputViewDelegate> delegate;
@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) NSIndexPath *selectedCategory;
@property (nonatomic) UICollectionView *collectionView;
@property (nonatomic) UICollectionView *emojiView;
@property (nonatomic) UICollectionView *gifCategoryView;
@property (nonatomic) NSString * lockedImagePath;

- (void)goBack;
- (void)selectSection:(NSString *)section;
- (void)loadData;

@end

@protocol MEInputViewDelegate <NSObject>
@optional
- (void)meInputView:(MEInputView *)inputView globeButtonTapped:(UIButton *)globeButton;
- (void)meInputView:(MEInputView *)inputView deleteButtonRelease:(UIButton *)deleteButton;
- (void)meInputView:(MEInputView *)inputView deleteButtonTapped:(UIButton *)deleteButton;
- (void)meInputView:(MEInputView *)inputView didSelectCategory:(NSString *)category;
- (void)meInputView:(MEInputView *)inputView didSelectEmoji:(NSDictionary *)emoji image:(UIImage *)image;
@end
