//
//  MEPhraseCollectionViewCell.m
//  Makemoji
//
//  Created by steve on 8/18/15.
//  Copyright (c) 2015 Makemoji. All rights reserved.
//

#import "MEPhraseCollectionViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation MEPhraseCollectionViewCell
- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
        self.contentView.clipsToBounds = YES;
        self.contentView.backgroundColor = [UIColor colorWithWhite:0.88 alpha:1];
        self.contentView.layer.borderColor = [[UIColor colorWithWhite:0.85 alpha:1] CGColor];
        self.contentView.layer.borderWidth = 1;
        self.contentView.layer.cornerRadius = 4.0;
        self.flashTagLabel = [[UILabel alloc] init];
        self.flashTagLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.flashTagLabel.textColor = [UIColor grayColor];
        self.flashTagLabel.font = [UIFont boldSystemFontOfSize:14];
        self.flashTagLabel.preferredMaxLayoutWidth = frame.size.width-46;
        //self.flashTagLabel.minimumScaleFactor = 0.8;
        //self.flashTagLabel.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:self.flashTagLabel];
        
        self.currentInput = @"";
        self.emoji = [NSMutableArray array];
        self.imageViews = [NSMutableArray array];

        
    }
    return self;
}

-(void)setData:(NSDictionary *)data {
    const CGFloat fontSize = 14;
    UIFont *boldFont = [UIFont boldSystemFontOfSize:fontSize];
    UIColor *foregroundColor = [UIColor grayColor];
    UIColor *foundColor = [UIColor darkGrayColor];
    
    NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
                           boldFont, NSFontAttributeName,
                           foregroundColor, NSForegroundColorAttributeName, nil];
    
    NSDictionary *subAttrs = [NSDictionary dictionaryWithObjectsAndKeys:
                              foundColor, NSForegroundColorAttributeName, nil];
    
    NSString * flashtag = @"";
    if ([[data objectForKey:@"flashtag"] isKindOfClass:[NSString class]]) {
        flashtag = [data objectForKey:@"flashtag"];
    } else if ([[data objectForKey:@"flashtag"] isKindOfClass:[NSNumber class]]) {
        flashtag = [[data objectForKey:@"flashtag"] stringValue];
    } else {
        return;
    }
    
    if (flashtag.length <= 0) {
        return;
    }
    
    NSMutableAttributedString *attributedText =
    [[NSMutableAttributedString alloc] initWithString:flashtag
                                           attributes:attrs];
    
    NSString * searched = [data objectForKey:@"searched"];
    
    if (searched != nil && searched > 0) {
        NSRange range = NSMakeRange(0,searched.length);
        [attributedText setAttributes:subAttrs range:range];
    }
    
    [self.flashTagLabel setAttributedText:attributedText];

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
    
    [self.flashTagLabel sizeToFit];
    CGFloat width = self.flashTagLabel.frame.size.width;
    if (self.flashTagLabel.frame.size.width > 100) {
        width = 100;
    }
    self.flashTagLabel.frame = CGRectMake((sOffset*sint)+4, 0, width, 34);

}


@end
