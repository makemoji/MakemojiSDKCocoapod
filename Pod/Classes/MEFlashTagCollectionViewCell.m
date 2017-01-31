//
//  MEFlashTagCollectionViewCell.m
//  Makemoji
//
//  Created by steve on 5/22/15.
//  Copyright (c) 2015 Makemoji. All rights reserved.
//

#import "MEFlashTagCollectionViewCell.h"

@implementation MEFlashTagCollectionViewCell

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
       self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
        self.contentView.clipsToBounds = YES;
        
        
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(2, 2, 34, 34)];
        self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [self.contentView addSubview:self.imageView];
        
        self.flashTagLabel = [[UILabel alloc] init];
        self.flashTagLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.flashTagLabel.textColor = [UIColor grayColor];
        self.flashTagLabel.font = [UIFont boldSystemFontOfSize:14];
        self.flashTagLabel.preferredMaxLayoutWidth = frame.size.width-46;
        self.flashTagLabel.minimumScaleFactor = 0.8;
        self.flashTagLabel.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:self.flashTagLabel];

//        self.rightSpacer = [[UIView alloc]  init];
//        self.rightSpacer.translatesAutoresizingMaskIntoConstraints = NO;
//        [self.rightSpacer setBackgroundColor:[UIColor clearColor]];
//        [self.contentView addSubview:self.rightSpacer];
//        
//        self.leftSpacer = [[UIView alloc]  init];
//        self.leftSpacer.translatesAutoresizingMaskIntoConstraints = NO;
//        [self.leftSpacer setBackgroundColor:[UIColor clearColor]];
//        [self.contentView addSubview:self.leftSpacer];
        
        self.currentInput = @"";

        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
        
        NSDictionary *viewsDictionary =
        NSDictionaryOfVariableBindings(_imageView, _flashTagLabel);
        //NSLog(@"%@", viewsDictionary);
        NSArray *constraints =
        [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-4@900-[_imageView(34)]-3@900-[_flashTagLabel]|"
                                                options:0 metrics:nil views:viewsDictionary];
        
        
        [self.contentView addConstraints:constraints];
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_imageView(34)]|" options:0 metrics:nil views:viewsDictionary]];
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
    [self.imageView.layer removeAllAnimations];
    
    if ([data objectForKey:@"link_url"] != [NSNull null]) {
        CABasicAnimation *imageSwitchAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        imageSwitchAnimation.fromValue = [NSNumber numberWithFloat:1];
        imageSwitchAnimation.toValue = [NSNumber numberWithFloat:0.33];
        imageSwitchAnimation.duration = 1.0f;
        imageSwitchAnimation.repeatCount = HUGE_VALF;
        imageSwitchAnimation.autoreverses = YES;
        [self.imageView.layer addAnimation:imageSwitchAnimation forKey:@"animateContents"];
    }
    
    [self layoutIfNeeded];

}

-(void)prepareForReuse {
    self.currentInput = @"";
}


-(void)layoutSubviews {
    [super layoutSubviews];
//    self.imageView.frame = CGRectMake(2, 2, self.contentView.frame.size.height-4, self.contentView.frame.size.height-4);
//    CGSize labelSize = [self.flashTagLabel sizeThatFits:CGSizeMake((self.contentView.frame.size.width - 4 - self.imageView.frame.size.width - 4), self.flashTagLabel.frame.size.height)];
//    
//    self.flashTagLabel.center = self.contentView.center;
//    
//    CGFloat totalSize = labelSize.width + 4 + self.imageView.frame.size.width;
//    CGFloat remainSize = self.contentView.frame.size.width - totalSize;
//    CGFloat padding = remainSize / 2;
//    self.imageView.frame = CGRectMake(padding, 2, self.contentView.frame.size.height-4, self.contentView.frame.size.height-4);
//    
//    self.flashTagLabel.frame = CGRectMake(self.imageView.frame.origin.x+self.imageView.frame.size.width+4, self.flashTagLabel.frame.origin.y, labelSize.width, self.flashTagLabel.frame.size.height);
//    //self.rightBorder.frame = CGRectMake(self.contentView.frame.size.width-1, 0, 1, self.contentView.frame.size.height);
}

@end
