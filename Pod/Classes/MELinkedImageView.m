//
//  LinkedImageView.m
//  Makemoji
//
//  Created by steve on 6/23/15.
//  Copyright (c) 2015 Makemoji. All rights reserved.
//

#import "MELinkedImageView.h"
#import "MakemojiSDK.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UIImage+GIF.h"


@implementation MELinkedImageView

- (id)init {
    return [self initWithFrame:CGRectZero];
}

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        self.imageView.backgroundColor = [UIColor clearColor];
        self.gifImageView = [[FLAnimatedImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        self.gifImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.imageView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
        self.gifImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.imageView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
        [self addSubview:self.gifImageView];
        [self addSubview:self.imageView];
    }
    return self;
}


-(void)setImageUrl:(NSString *)imageUrl link:(NSString *)link {
    self.imageContentUrl = [NSURL URLWithString:imageUrl];

    NSString * path = @"MEPlaceholder";
//    if ([[SDImageCache sharedImageCache]diskImageExistsWithKey:self.imageContentUrl.absoluteString]) {
//        path = [[SDImageCache sharedImageCache] defaultCachePathForKey:self.imageContentUrl.absoluteString];
//    }

    if ([imageUrl containsString:@"gif"]) {
        [self.gifImageView sd_setImageWithURL:self.imageContentUrl
                          placeholderImage:[UIImage imageNamed:path]
                                   options:SDWebImageLowPriority
                                 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                     
                                 }];
    } else {
        [self.imageView sd_setImageWithURL:self.imageContentUrl
                          placeholderImage:[UIImage imageNamed:path]
                                   options:SDWebImageLowPriority
                                 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                     
                                 }];
    }

    if (link.length > 0 && self.linkedUrl == nil) {

        self.linkedUrl = [NSURL URLWithString:link];
        
        CABasicAnimation *imageSwitchAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        imageSwitchAnimation.fromValue = [NSNumber numberWithFloat:1];
        imageSwitchAnimation.toValue = [NSNumber numberWithFloat:0.33];
        imageSwitchAnimation.duration = 1.0f;
        imageSwitchAnimation.repeatCount = HUGE_VALF;
        imageSwitchAnimation.autoreverses = YES;
        [self.imageView.layer addAnimation:imageSwitchAnimation forKey:@"animateContents"];
        
        UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap)];
        [self addGestureRecognizer:tapGesture];
    } else {
        self.linkedUrl = nil;
        for (UIGestureRecognizer *recognizer in self.gestureRecognizers) {
            [self removeGestureRecognizer:recognizer];
        }
    }
    
}

-(void)didTap {
    __weak MELinkedImageView * weakSelf = self;
    if (self.delegate && [self.delegate respondsToSelector:@selector(meLinkedImageView:didTapHypermoji:)]) {
        [self.delegate meLinkedImageView:weakSelf didTapHypermoji:weakSelf.linkedUrl.absoluteString];
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *userInfo = @{@"url": weakSelf.linkedUrl.absoluteString};
        [[NSNotificationCenter defaultCenter] postNotificationName:MEHypermojiLinkClicked object:weakSelf userInfo:userInfo];
    });
}

-(void)layoutSubviews {
    [super layoutSubviews];
    if ([self.imageView.layer animationKeys] > 0) {
        //NSLog(@" has animations");
    } else {
        //NSLog(@" no animations");
    }
    
}


-(void)dealloc {
    self.imageView.image = nil;
    self.gifImageView.image = nil;
    self.delegate = nil;
    if ([self.imageView.layer animationKeys] > 0) {
        [self.imageView.layer removeAllAnimations];
    }
}

@end
