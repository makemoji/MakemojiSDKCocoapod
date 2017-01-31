//
//  LinkedImageView.h
//  Makemoji
//
//  Created by steve on 6/23/15.
//  Copyright (c) 2015 Makemoji. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MELinkedImageViewDelegate;

@interface MELinkedImageView : UIView

@property (nonatomic) UIImageView *imageView;
@property (nonatomic) NSURL *imageContentUrl;
@property (nonatomic) NSURL *linkedUrl;
@property (nonatomic, weak) id <MELinkedImageViewDelegate> delegate;

- (void)setImageUrl:(NSString *)imageUrl link:(NSString *)link;
- (void)didTap;

@end

@protocol MELinkedImageViewDelegate <NSObject>
@optional
-(void)meLinkedImageView:(MELinkedImageView *)messageView didTapHypermoji:(NSString*)urlString;
@end
