//
//  METextInputView.h
//  MakemojiSDK
//
//  Copyright © 2015 Makemoji. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MEInputAccessoryView.h"

typedef NS_ENUM(NSInteger, MECellStyle)
{
    MECellStyleDefault = 0,
    MECellStyleSimple, // full width simple table cell
    MECellStyleChat // Messages style table cell
};

extern NSString * const MESubstituteOptionEmojiSizeRatio; // default to 1.0
extern NSString * const MESubstituteOptionFont; // default to system
extern NSString * const MESubstituteOptionLinkStyle; // default to empty
extern NSString * const MESubstituteOptionTextColor; // default to black
extern NSString * const MESubstituteOptionUseParagraphBlocks; // default to NO
extern NSString * const MESubstituteOptionShouldScanForLinks; // default to NO


@protocol METextInputViewDelegate;

@interface METextInputView : UIView <UIScrollViewDelegate>

// container view for the text input view, the send button, camera button and overlay views
@property (nonatomic) UIView *textInputContainerView;

// solid background that by default uses the MEMessageEntryBackground image
@property (nonatomic) UIImageView *barBackgroundImageView;

// a rounded corner overlay image view that uses the MEMessageEntryInputField image
@property (nonatomic) UIImageView *textOverlayImageView;

//background view under text input
@property (nonatomic) UIView *textSolidBackgroundView;

// buttons for chat actions
@property (nonatomic) UIButton *sendButton;
@property (nonatomic) UIButton *cameraButton;

@property (nonatomic) UILabel *placeholderLabel;

// the navigation / trending keyboard bar
@property (nonatomic) MEInputAccessoryView *meAccessory;

// only usable in detached input mode. adds a view on top of the Makemoji navigation bar.
@property (nonatomic) UIView *inputAccessoryView;

@property UIReturnKeyType keyboardReturnKeyType;
@property UIKeyboardType keyboardType;
@property UIKeyboardAppearance keyboardAppearance;
@property UITextAutocorrectionType autocorrectionType;
@property (nonatomic) NSAttributedString *attributedString;
@property (nonatomic) NSString *HTMLText;
@property (nonatomic) UIScrollView *textInputView;
@property (nonatomic) NSString *defaultFontFamily;
@property (nonatomic) NSString *text;
@property BOOL enablesReturnKeyAutomatically;

@property BOOL displayCameraButton;
@property BOOL displaySendButton;
@property BOOL disableIntroAnimation;
@property BOOL shouldHideNavigation;

// should trigger send message when a gif is selected from the keyboard
@property BOOL shouldAutosendGif;
@property CGFloat currentKeyboardPosition;
@property CGFloat emojiRatio;
@property CGFloat fontSize;

// textView delegate
@property (nonatomic, weak) id <METextInputViewDelegate> delegate;

// current state of detached input
@property (readonly) BOOL detachedTextInput;
@property BOOL shouldClearOnSend;
@property UIEdgeInsets edgeInsets;
// array of cached cell heights when using cellHeightForHTML
@property (nonatomic) NSMutableArray * cachedHeights;

- (void)setFont:(UIFont *)font;

- (void)setDefaultFontSize:(CGFloat)fontSize;

- (void)detachTextInputView:(BOOL)option;

// deprecated, use become/resignFirstResponder
- (void)showKeyboard;
- (void)hideKeyboard;


// you can attach a custom button to this method as a action to trigger a send delegate call
- (void)sendMessage;

// returns a cached height for a cell. use this to avoid recalculating heights for collection or table view cells
- (CGFloat)cellHeightForHTML:(NSString *)html atIndexPath:(NSIndexPath *)indexPath maxCellWidth:(CGFloat)width cellStyle:(MECellStyle)cellStyle;

- (void)setTextInputTextColor:(UIColor *)textColor;

// this method converts a substitued message back to html with default settings
+ (NSString *)convertSubstituedToHTML:(NSString *)substitute;
+ (NSString *)convertSubstituedToHTMLWithParagraphBlocks:(NSString *)substitute;
+ (NSString *)convertSubstituedToHTMLWithParagraphBlocks:(NSString *)substitute withFont:(UIFont *)font textColor:(UIColor *)color;
+ (NSString *)convertSubstituedToHTML:(NSString *)substitute withFont:(UIFont *)font textColor:(UIColor *)color;
+ (NSString *)convertSubstituedToHTML:(NSString *)substitute withFontName:(NSString *)fontName pointSize:(CGFloat)pointSize textColor:(UIColor *)color;
+ (NSString *)convertSubstituedToHTML:(NSString *)substitute withFont:(UIFont *)font textColor:(UIColor *)color emojiRatio:(CGFloat)ratio;
+ (NSString *)convertSubstituedToHTML:(NSString *)substitute withFont:(UIFont *)font textColor:(UIColor *)color linkStyle:(NSString *)linkStyle;
+ (NSString *)convertSubstituteToHTML:(NSString *)substitute options:(NSDictionary *)options;

+(NSString *)transformHTML:(NSString * )html withFont:(UIFont *)font textColor:(UIColor *)color;
+ (NSUInteger)numberOfCharactersInSubstitute:(NSString *)string;

// scan a plaintext message and detect makemoji substituted strings
+ (BOOL)detectMakemojiMessage:(NSString *)message;

- (NSArray *)textAttachments;

// set the current default style using a CSS string
- (void)setDefaultParagraphStyle:(NSString *)style;
- (void)replaceRange:(UITextRange *)range withText:(id)text;
- (void)setSelectedTextRange:(UITextRange *)newTextRange animated:(BOOL)animated;

// returns current scroll view content size
- (CGSize)contentSize;
- (NSUInteger)substituteCharacterCount;
- (void)setChannel:(NSString *)channel;

@end

@protocol METextInputViewDelegate <NSObject>
- (void)meTextInputView:(METextInputView *)inputView didTapSend:(NSDictionary *)message;
@optional
- (void)meTextInputView:(METextInputView *)inputView didTapHypermoji:(NSString*)urlString;
- (void)meTextInputView:(METextInputView *)inputView didTapHyperlink:(NSString*)urlString;
- (void)meTextInputView:(METextInputView *)inputView didTapCameraButton:(UIButton*)cameraButton;
- (void)meTextInputView:(METextInputView *)inputView didChangeFrame:(CGRect)frame;
- (void)meTextInputView:(METextInputView *)inputView selectedLockedCategory:(NSString *)category;
- (void)meTextInputViewDidChange:(METextInputView *)inputView;
- (BOOL)meTextInputView:(METextInputView *)inputView shouldChangeTextInRange:(NSRange)range replacementText:(NSAttributedString *)text;
- (BOOL)shouldBeginEditing:(METextInputView *)inputView; // will be deprecated in a future release
- (void)meTextInputViewDidBeginEditing:(METextInputView *)inputView;
- (void)meTextInputViewDidEndEditing:(METextInputView *)inputView;
- (void)meTextInputView:(METextInputView *)inputView scrollViewDidScroll:(UIScrollView *)scrollView;
@end
