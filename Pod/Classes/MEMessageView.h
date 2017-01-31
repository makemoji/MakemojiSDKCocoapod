//
//  MEMessageView.h
//  MakemojiSDK
//
//  Created by steve on 3/7/16.
//  Copyright © 2016 Makemoji. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MEMessageViewDelegate;

@interface MEMessageView : UIView

@property (readonly) UIView *textContentView;
@property (readonly) NSAttributedString *attributedString;
@property UIEdgeInsets edgeInsets;
@property NSInteger numberOfLines;
@property (nonatomic, weak) id <MEMessageViewDelegate> delegate;

- (void)setHTMLString:(NSString *)html;

// deprecated, use suggestedSizeForTextForSize. yes this is misspelled but follows DT naming
- (CGSize)suggestedFrameSizeToFitEntireStringConstraintedToWidth:(CGFloat)width;

- (CGSize)suggestedSizeForTextForSize:(CGSize)size;

@end

@protocol MEMessageViewDelegate <NSObject>
@optional
- (void)meMessageView:(MEMessageView *)messageView didTapHypermoji:(NSString*)urlString;
- (void)meMessageView:(MEMessageView *)messageView didTapHyperlink:(NSString*)urlString;
@end
