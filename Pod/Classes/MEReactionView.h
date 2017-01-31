//
//  MEReactionView.h
//  MakemojiSDK
//
//  Created by steve on 5/11/16.
//  Copyright © 2016 Makemoji. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MEEmojiWall.h"

// notification name when a reaction is chosen
extern NSString * const MEReactionNotification;

@interface MEReactionView : UIView <UICollectionViewDelegate, UICollectionViewDataSource, MEEmojiWallDelegate>

// your unique content id for this reaction set. reaction data is retreieved when this value is set or changes.
@property (nonatomic) NSString *contentId;

// the emoji wall trigger button
@property (nonatomic) UIButton *wallTriggerView;

// current set of reactions, including defaults
@property (nonatomic) NSMutableArray *reactions;

// the current user reaction
@property (nonatomic) NSDictionary *currentUserReaction;

// the collection view for showing reactions
@property (nonatomic) UICollectionView *reactionCollectionView;

// border and text color when a user has selected a reaction, defaults to light blue
@property (nonatomic) UIColor *cellHighlightColor;

// cell border color for reactions, defaults to light gray
@property (nonatomic) UIColor *cellBorderColor;

// default cell text color, defaults to gray
@property (nonatomic) UIColor *cellTextColor;

// your view controller for displaying the emoji wall
@property (weak) UIViewController *viewController;

// convenience init method
- (instancetype)initWithFrame:(CGRect)frame contentId:(NSString *)contentId;

@end
