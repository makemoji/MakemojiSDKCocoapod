//
//  MEInputAccessoryView.h
//  Makemoji
//
//  Copyright (c) 2015 Makemoji. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MEInputView.h"

@interface MEInputAccessoryView : UIView <UIGestureRecognizerDelegate, MEInputViewDelegate>

// navigation buttons
@property (nonatomic) UIButton *flashtagButton;
@property (nonatomic) UIButton *gridButton;
@property (nonatomic) UIButton *trendingButton;
@property (nonatomic) UIButton *favoriteButton;

// back button and title shown during category selection
@property (nonatomic) UIButton *backButton;
@property (nonatomic) UILabel *titleLabel;

// input view for Makemoji emoji
@property (nonatomic) MEInputView *meInputView;

// the currently selected mode for the input view
@property (nonatomic) NSString *currentToggle;

// flashtag horizontal collection view
@property (nonatomic) UICollectionView *flashtagCollectionView;
@property (nonatomic) UICollectionView *emojiView;

@property BOOL flashtagOnly;
@property BOOL disableNavigation;
@property BOOL disableSearch;
@property BOOL disableUnicodeSearch;

- (void)didSelectEmoji:(NSDictionary *)emoji image:(UIImage *)image;
- (void)didSelectGif:(NSDictionary *)gif;
- (void)didSelectCategory;
- (void)deleteButtonTapped;
- (void)setTextView:(id)textView;
- (void)textViewDidBeginEditing:(id)textView;
- (void)textViewDidEndEditing:(id)textView;
- (void)textViewDidChangeSelection:(id)textView;
- (void)textViewDidChange:(id)textView;
- (void)introBarAnimation:(BOOL)animate;
- (void)setNavigationBackgroundColor:(UIColor *)color;
- (void)setNavigationHighlightColor:(UIColor *)color;
- (void)loadData;
@end
