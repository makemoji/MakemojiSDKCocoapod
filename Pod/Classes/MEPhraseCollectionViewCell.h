//
//  MEPhraseCollectionViewCell.h
//  Makemoji
//
//  Created by steve on 8/18/15.
//  Copyright (c) 2015 Makemoji. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MEPhraseCollectionViewCell : UICollectionViewCell

@property (nonatomic) UILabel *flashTagLabel;
@property (nonatomic) NSString *currentInput;
@property (nonatomic) NSString *flashTag;
@property (nonatomic) NSMutableArray *emoji;
@property (nonatomic) NSMutableArray *imageViews;

- (void)setData:(NSDictionary *)data;

@end
