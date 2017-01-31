//
//  MEFlashTagNativeCollectionViewCell.m
//  Makemoji
//
//  Created by steve on 5/27/15.
//  Copyright (c) 2015 Makemoji. All rights reserved.
//

#import "MEFlashTagNativeCollectionViewCell.h"

@implementation MEFlashTagNativeCollectionViewCell
- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
        self.contentView.clipsToBounds = YES;
        
        
        self.emojiView = [[UILabel alloc] initWithFrame:CGRectMake(2, 2, 34, 34)];
        self.emojiView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.emojiView setContentMode:UIViewContentModeScaleAspectFit];
        self.emojiView.font = [UIFont boldSystemFontOfSize:30];
        [self.contentView addSubview:self.emojiView];
        
        self.flashTagLabel = [[UILabel alloc] init];
        self.flashTagLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.flashTagLabel.textColor = [UIColor grayColor];
        self.flashTagLabel.font = [UIFont boldSystemFontOfSize:14];
        self.flashTagLabel.preferredMaxLayoutWidth = frame.size.width-46;
        self.flashTagLabel.minimumScaleFactor = 0.8;
        self.flashTagLabel.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:self.flashTagLabel];
        
        self.currentInput = @"";
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
        
        NSDictionary *viewsDictionary =
        NSDictionaryOfVariableBindings(_emojiView, _flashTagLabel);
        //NSLog(@"%@", viewsDictionary);
        NSArray *constraints =
        [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-4@900-[_emojiView(34)]-3@900-[_flashTagLabel]|"
                                                options:0 metrics:nil views:viewsDictionary];
        
        
        [self.contentView addConstraints:constraints];
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_emojiView(34)]|" options:0 metrics:nil views:viewsDictionary]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_flashTagLabel]-|" options:0 metrics:nil views:viewsDictionary]];
        
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
    
    if (self.currentInput != nil && self.currentInput.length > 0 && flashtag.length > self.currentInput.length) {
        NSRange range = NSMakeRange(0,self.currentInput.length);
        [attributedText setAttributes:subAttrs range:range];
    }
    
    [self.flashTagLabel setAttributedText:attributedText];

    
    [self.flashTagLabel setAttributedText:attributedText];
    [self.emojiView setText:[data objectForKey:@"character"]];
    [self layoutIfNeeded];
    
}

-(void)layoutSubviews {
    [super layoutSubviews];
}

-(void)prepareForReuse {
    self.currentInput = @"";
}

@end
