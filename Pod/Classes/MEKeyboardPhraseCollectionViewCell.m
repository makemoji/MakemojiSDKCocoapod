//
//  MEKeyboardPhraseCollectionViewCell.m
//  Makemoji
//
//  Created by steve on 8/21/15.
//  Copyright (c) 2015 Makemoji. All rights reserved.
//

#import "MEKeyboardPhraseCollectionViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation MEKeyboardPhraseCollectionViewCell
- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
        self.contentView.clipsToBounds = YES;
        self.contentView.backgroundColor = [UIColor colorWithWhite:0.88 alpha:1];
        self.contentView.layer.borderColor = [[UIColor colorWithWhite:0.85 alpha:1] CGColor];
        self.contentView.layer.borderWidth = 1;
        self.contentView.layer.cornerRadius = 4.0;
        self.emoji = [NSMutableArray array];
        self.imageViews = [NSMutableArray array];
        
    }
    return self;
}

-(void)setData:(NSDictionary *)data {
    
    for (UIView * view in self.imageViews) {
        [view removeFromSuperview];
    }
    
    [self.imageViews removeAllObjects];
    
    NSUInteger sint =  0;
    NSArray * emoji = [data objectForKey:@"emoji"];
    if (emoji != nil) {
        self.emoji = [NSMutableArray arrayWithArray:emoji];
        for (NSDictionary * imgView in self.emoji) {
            NSNumber * native = [imgView objectForKey:@"native"];
            
            if (native != nil) {
                UILabel * emojiView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
                emojiView.translatesAutoresizingMaskIntoConstraints = NO;
                [emojiView setContentMode:UIViewContentModeScaleAspectFit];
                emojiView.font = [UIFont boldSystemFontOfSize:28];
                [emojiView setText:[imgView objectForKey:@"character"]];
                [self.imageViews addObject:emojiView];
                [self.contentView addSubview:[self.imageViews lastObject]];
            } else {
                UIImageView *v = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
                v.hidden = YES;
                [v sd_setImageWithURL:[NSURL URLWithString:[imgView objectForKey:@"image_url"]] placeholderImage:nil];
                [self.imageViews addObject:v];
                [self.contentView addSubview:[self.imageViews lastObject]];
            }
            sint++;
        }
    }
    
    [self setNeedsLayout];
    
}

-(void)layoutSubviews {
    [super layoutSubviews];
    NSUInteger sint =  0;
    CGFloat sOffset = 30;
    for (UIImageView * imgVi in self.imageViews) {
        imgVi.hidden = YES;
    }
    
    if (self.emoji != nil) {
        for (NSDictionary * imgView in self.emoji) {
            UIView * imgV = [self.imageViews objectAtIndex:sint];
            imgV.hidden = NO;
            imgV.frame = CGRectMake(sOffset*sint+2, 2, 30, 30);
            sint++;
        }
    }
    
}



@end
