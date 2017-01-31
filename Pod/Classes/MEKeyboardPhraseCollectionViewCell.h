//
//  MEKeyboardPhraseCollectionViewCell.h
//  Makemoji
//
//  Created by steve on 8/21/15.
//  Copyright (c) 2015 Makemoji. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MEKeyboardPhraseCollectionViewCell : UICollectionViewCell

@property (nonatomic) NSMutableArray *emoji;
@property (nonatomic) NSMutableArray *imageViews;

- (void)setData:(NSDictionary *)data;
@end
