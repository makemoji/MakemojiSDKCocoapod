//
//  METextInputView.m
//  MakemojiSDK
//
//  Created by steve on 10/12/15.
//  Copyright © 2015 Makemoji. All rights reserved.
//

#import "METextInputView.h"
#import "MakemojiSDK.h"
#import "NSAttributedString+HTML.h"
#import "NSAttributedString+DTRichText.h"
#import "NSMutableAttributedString+DTRichText.h"
#import "DTRichTextEditor.h"
#import "NSAttributedString_MoreExtensions.h"
#import "MEAPIManager.h"
#import "MELinkedImageView.h"
#import "MEChatTableViewCell.h"
#import "MESimpleTableViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "DTLoupeView.h"

static void * MEContainerFrameContext = &MEContainerFrameContext;
static void * MEPlaceholderTextContext = &MEPlaceholderTextContext;
NSString *const MESubstituteOptionEmojiSizeRatio = @"MESubstituteOptionEmojiSizeRatio";
NSString *const MESubstituteOptionFont = @"MESubstituteOptionFont";
NSString *const MESubstituteOptionLinkStyle = @"MESubstituteOptionLinkStyle";
NSString *const MESubstituteOptionTextColor = @"MESubstituteOptionTextColor";
NSString *const MESubstituteOptionUseParagraphBlocks = @"MESubstituteOptionUseParagraphBlocks";
NSString *const MESubstituteOptionShouldScanForLinks = @"MESubstituteOptionShouldScanForLinks";


@interface METextInputView () <DTRichTextEditorViewDelegate, DTAttributedTextContentViewDelegate>
    @property (nonatomic, retain) DTRichTextEditorView *textView;
    @property NSMutableDictionary * offscreenCells;
    @property BOOL detachedTextInput;
@end

@implementation METextInputView

@synthesize keyboardType = _keyboardType;
@synthesize keyboardReturnKeyType = _keyboardReturnKeyType;
@synthesize keyboardAppearance = _keyboardAppearance;
@synthesize displayCameraButton = _displayCameraButton;
@synthesize displaySendButton = _displaySendButton;
@synthesize shouldAutosendGif = _shouldAutosendGif;
@synthesize inputAccessoryView = _inputAccessoryView;
@synthesize defaultFontFamily = _defaultFontFamily;
@synthesize autocorrectionType = _autocorrectionType;
@synthesize emojiRatio = _emojiRatio;

- (id)init {
    return [self initWithFrame:CGRectZero];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        ___useiOS6Attributes = YES;
        self.detachedTextInput = NO;
        self.shouldClearOnSend = YES;
        self.shouldHideNavigation = NO;
        self.translatesAutoresizingMaskIntoConstraints = YES;
        self.fontSize = 16.0f;
        self.emojiRatio = 1.0f;
        self.keyboardReturnKeyType = UIReturnKeyDefault;
        self.keyboardType = UIKeyboardTypeDefault;
        self.disableIntroAnimation = NO;
        CGRect screenBounds = [[UIScreen mainScreen] bounds];
        frame = CGRectMake(0, screenBounds.size.height-90, screenBounds.size.width, 90);
        //[[SDImageCache sharedImageCache] setMaxCacheAge:INT_MAX];
        
        self.offscreenCells = [NSMutableDictionary dictionary];
        self.cachedHeights = [NSMutableArray array];

        [self setFrame:CGRectMake(0, screenBounds.size.height-90, screenBounds.size.width, 90)];
        self.clipsToBounds = NO;
        self.backgroundColor = [UIColor clearColor];
        
        self.sendButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.sendButton setTitle:@"Send" forState:UIControlStateNormal];
        self.sendButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        self.sendButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        [self.sendButton setFrame:CGRectMake(self.frame.size.width-50, 10, 40, 20)];
        [self.sendButton addTarget:self action:@selector(sendMessage) forControlEvents:UIControlEventTouchUpInside];
        [self.sendButton setEnabled:NO];
        
        self.cameraButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.cameraButton setImage:[UIImage imageNamed:@"Makemoji.bundle/MECameraIcon" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
        self.cameraButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        [self.cameraButton setFrame:CGRectMake(11, 0, 30, 44)];
        [self.cameraButton addTarget:self action:@selector(didTapCamera) forControlEvents:UIControlEventTouchUpInside];
        [self.cameraButton setTintColor:[UIColor lightGrayColor]];
        
        self.textInputContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 44)];
        [self.textInputContainerView setClipsToBounds:NO];
        self.textInputContainerView.backgroundColor = [UIColor colorWithWhite:1 alpha:1];
        
        self.textView = [[DTRichTextEditorView alloc] initWithFrame:CGRectMake(self.cameraButton.frame.origin.x+self.cameraButton.frame.size.width+12, 0, self.frame.size.width-self.sendButton.frame.size.width-self.cameraButton.frame.size.width-36, 44)];
        self.textView.attributedTextContentView.edgeInsets = UIEdgeInsetsMake(12, 10, 12, 10);
        self.textView.returnKeyType = self.keyboardReturnKeyType;
        self.textView.keyboardType = self.keyboardType;
        self.textView.font = [UIFont systemFontOfSize:self.fontSize];
        
        self.textView.defaultFontSize = self.fontSize;
        self.textView.editable = YES;
        self.textView.autocorrectionType = UITextAutocorrectionTypeDefault;
        self.textView.shouldDrawImages = NO;
        self.textView.attributedTextContentView.delegate = self;
        self.textView.backgroundColor = [UIColor clearColor];
        self.textView.editorViewDelegate = self;
        self.textView.replaceParagraphsWithLineFeeds = YES;
        self.textView.maxImageDisplaySize = CGSizeMake(20, 20);
        self.textView.clipsToBounds = NO;
        self.textView.translatesAutoresizingMaskIntoConstraints = YES;
        self.textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.textView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        self.textView.delegate = self;
        
        UIImage *entryBackground = [[UIImage imageNamed:@"Makemoji.bundle/MEMessageEntryInputField.png" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil] stretchableImageWithLeftCapWidth:13 topCapHeight:22];
        UIImage * tintableImage = [entryBackground imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        self.textOverlayImageView = [[UIImageView alloc] initWithImage:tintableImage];
        self.textOverlayImageView.frame = CGRectMake(self.cameraButton.frame.origin.x+self.cameraButton.frame.size.width+12, 0, self.frame.size.width-self.sendButton.frame.size.width-36-self.cameraButton.frame.size.width, 40);
        self.textOverlayImageView.translatesAutoresizingMaskIntoConstraints = YES;
        self.textOverlayImageView.tintColor = [UIColor colorWithWhite:1 alpha:1];
        self.textOverlayImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.textOverlayImageView.opaque = YES;
        self.textOverlayImageView.tintAdjustmentMode = UIViewTintAdjustmentModeNormal;
        
        self.textSolidBackgroundView = [[UIView alloc] initWithFrame:self.textOverlayImageView.frame];
        self.textSolidBackgroundView.backgroundColor = [UIColor whiteColor];
        self.textSolidBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        self.barBackgroundImageView = [[UIImageView alloc] initWithImage:nil];

        [self.textInputContainerView addSubview:self.textSolidBackgroundView];
        [self.textInputContainerView addSubview:self.textOverlayImageView];
        [self.textInputContainerView addSubview:self.textView];
        [self.textInputContainerView addSubview:self.sendButton];
        [self.textInputContainerView addSubview:self.cameraButton];

        self.placeholderLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.placeholderLabel.text = @"Message";
        self.placeholderLabel.textColor = [UIColor lightGrayColor];
        self.placeholderLabel.font = [UIFont systemFontOfSize:self.fontSize];
        [self.placeholderLabel sizeToFit];
        self.placeholderLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.textInputContainerView addSubview:self.placeholderLabel];
        
         self.placeholderLabel.frame = CGRectMake(self.textView.attributedTextContentView.edgeInsets.left+4+self.textView.frame.origin.x, self.textView.attributedTextContentView.edgeInsets.top+self.textView.frame.origin.y, self.placeholderLabel.frame.size.width, self.placeholderLabel.frame.size.height);
        
        
        [self addSubview:self.textInputContainerView];
        
        self.meAccessory = [[MEInputAccessoryView alloc] initWithFrame:CGRectMake(0, 44, self.frame.size.width, 46)];
        [self.meAccessory setTextView:self.textView];
        [self addSubview:self.meAccessory];
        [self bringSubviewToFront:self.textInputContainerView];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHide:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillChangeSize:)
                                                     name:UIKeyboardWillChangeFrameNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_didTapHypermoji:)
                                                 name:MEHypermojiLinkClicked
                                               object:nil];
 
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(_didTapHyperlink:)
                                                     name:MEHyperlinkClicked
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(_textInputGIFInserted:)
                                                     name:@"METextInputGIFInserted"
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(_selectedLockedCategory:)
                                                     name:@"MECategorySelectedLockedCategory"
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(loupeDidHide:)
                                                     name:DTLoupeDidHide
                                                   object:nil];
        
        
        
        [self.textInputContainerView addObserver:self forKeyPath:@"frame" options:0 context:MEContainerFrameContext];

        [self.placeholderLabel addObserver:self forKeyPath:@"text" options:0 context:MEPlaceholderTextContext];
        
    }
    return self;
}

- (void)replaceRange:(UITextRange *)range withText:(id)text {
    [self.textView replaceRange:range withText:text];
}

- (void)setSelectedTextRange:(UITextRange *)newTextRange animated:(BOOL)animated {
    DTTextRange * newRange = [DTTextRange textRangeFromStart:newTextRange.start toEnd:newTextRange.end];
    [self.textView setSelectedTextRange:newRange animated:animated];
}

-(void)setTextInputView:(UIView *)textInputView {
    return;
}

-(UIScrollView *)textInputView {
    return (UIScrollView *)self.textView;
}

-(void)setEmojiRatio:(CGFloat)emojiRatio {
    _emojiRatio = emojiRatio;
    CGFloat baseSize = 20+(self.textView.defaultFontSize-16);
    self.textView.maxImageDisplaySize = CGSizeMake(baseSize * emojiRatio, baseSize * emojiRatio);
}

-(CGFloat)emojiRatio {
    return _emojiRatio;
}

-(void)loupeDidHide:(NSNotification *)note {
    [[[DTLoupeView sharedLoupe] lWindow] setRootViewController:nil];
}

-(NSString *)defaultFontFamily {
    return _defaultFontFamily;
}

-(void)setDefaultFontFamily:(NSString *)defaultFontFamily {
    _defaultFontFamily = defaultFontFamily;
    self.textView.defaultFontFamily = defaultFontFamily;
}

-(void)setInputAccessoryView:(UIView *)inputAccessoryView {
    self.textView.inputAccessoryView = inputAccessoryView;
}

-(UIView *)inputAccessoryView {
    return self.textView.inputAccessoryView;
}

-(void)setHTMLText:(NSString *)html {
    [self.textView setHTMLString:html];
    [self showPlaceholderText];
}

-(NSString *)HTMLText {
    return [self.textView HTMLStringWithOptions:DTHTMLWriterOptionFragment];
}

-(UIKeyboardAppearance)keyboardAppearance {
    return _keyboardAppearance;
}

-(void)setAttributedString:(NSAttributedString *)attributedString {
    self.textView.attributedText = attributedString;
    [self showPlaceholderText];
}

-(NSAttributedString *)attributedString {
    return self.textView.attributedText;
}

-(void)setKeyboardAppearance:(UIKeyboardAppearance)keyboardAppearance {
    _keyboardAppearance = keyboardAppearance;
    self.textView.keyboardAppearance = keyboardAppearance;
}

-(UIReturnKeyType)keyboardReturnKeyType {
    return _keyboardReturnKeyType;
}

-(void)setKeyboardReturnKeyType:(UIReturnKeyType)keyboardReturnKeyType {
    _keyboardReturnKeyType = keyboardReturnKeyType;
    self.textView.returnKeyType = keyboardReturnKeyType;
}

-(void)setAutocorrectionType:(UITextAutocorrectionType)autocorrectionType {
    _autocorrectionType = autocorrectionType;
    self.textView.autocorrectionType = _autocorrectionType;
}

-(UITextAutocorrectionType)autocorrectionType {
    return _autocorrectionType;
}

-(BOOL)enablesReturnKeyAutomatically {
    return self.textView.enablesReturnKeyAutomatically;
}

-(void)setEnablesReturnKeyAutomatically:(BOOL)enable {
    [self.textView setEnablesReturnKeyAutomatically:enable];
}

-(NSString *)text {
    NSString * outputText = [[self.textView attributedText] plainTextString];
    if ([outputText isEqualToString:@"\n"]) { outputText = @""; }
    return outputText;
}

-(void)setText:(NSString *)text {
    [self.textView setHTMLString:text];
    [self showPlaceholderText];
}

- (BOOL)becomeFirstResponder {
    BOOL returnValue = [super becomeFirstResponder];
    returnValue = [self.textView becomeFirstResponder];
    return returnValue;
}

- (BOOL)isFirstResponder {
    BOOL returnValue = [super isFirstResponder];
    returnValue = [self.textView isFirstResponder];
    return returnValue;
}

- (BOOL)resignFirstResponder {
    BOOL returnValue = [super resignFirstResponder];
    returnValue = [self.textView resignFirstResponder];
    [self showPlaceholderText];
    return returnValue;
}


-(UIKeyboardType)keyboardType {
    return _keyboardType;
}

-(BOOL)shouldAutosendGif {
    return _shouldAutosendGif;
}

-(void)setShouldAutosendGif:(BOOL)shouldAutosendGif {
    _shouldAutosendGif = shouldAutosendGif;
}

-(void)setKeyboardType:(UIKeyboardType)keyboardType {
    _keyboardType = keyboardType;
    self.textView.keyboardType = keyboardType;
}

-(void)setDefaultFontSize:(CGFloat)fontSize {
    if (fontSize < 16) { fontSize = 16; }
    self.fontSize = fontSize;
    self.textView.defaultFontSize = fontSize;
    self.textView.font = [UIFont systemFontOfSize:self.fontSize];
    self.textView.maxImageDisplaySize = CGSizeMake((20+(fontSize-16) * self.emojiRatio), (20+(fontSize-16) * self.emojiRatio));
    self.placeholderLabel.font = [UIFont systemFontOfSize:self.fontSize];
    [self.placeholderLabel sizeToFit];
     self.placeholderLabel.frame = CGRectMake(self.textView.attributedTextContentView.edgeInsets.left+4+self.textView.frame.origin.x, self.textView.attributedTextContentView.edgeInsets.top+self.textView.frame.origin.y, self.placeholderLabel.frame.size.width, self.placeholderLabel.frame.size.height);
}

-(void)setTextInputTextColor:(UIColor *)textColor {
    NSDictionary * dictionary = [NSDictionary dictionaryWithObjectsAndKeys:textColor, DTDefaultTextColor, nil];
    [self.textView setTextDefaults:dictionary];
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];

    CGFloat totalAmount = 90;
    CGFloat totalHeight = 90;
    if (self.shouldHideNavigation == YES) {
        totalAmount = totalAmount - 46;
    }
    
    if (self.detachedTextInput == YES && self.shouldHideNavigation == YES) {
        totalAmount = 0;
        totalHeight = totalHeight - 44;
    }
    
    if (self.detachedTextInput == YES && self.shouldHideNavigation == NO) {
        totalAmount = 46;
        totalHeight = 46;
    }
    
    
    self.frame = CGRectMake(0, self.superview.frame.size.height-totalAmount, self.superview.frame.size.width, totalHeight);
    if (self.disableIntroAnimation == NO) {
        [self.meAccessory introBarAnimation:YES];
    } else {
       [self.meAccessory introBarAnimation:NO];
    }
    
}

-(void)setChannel:(NSString *)channel {

    if (![[MEAPIManager client].channel isEqualToString:channel]) {
        //NSLog(@"setting channel to %@", channel);
        [MakemojiSDK setChannel:channel];
        [self.meAccessory loadData];
            //NSLog(@"%@", channel);
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.superview.frame.size.width > self.superview.frame.size.height) {
        if (self.detachedTextInput == NO) {
            self.textInputContainerView.frame = CGRectMake(0, 0, self.frame.size.width, 44);
        
            self.textOverlayImageView.frame = CGRectMake(self.cameraButton.frame.origin.x+self.cameraButton.frame.size.width+12, 0, self.frame.size.width-self.sendButton.frame.size.width-36-self.cameraButton.frame.size.width, 40);
            self.sendButton.frame = CGRectMake(self.frame.size.width-50, 10, 40, 20);
            self.textView.frame = CGRectMake(self.cameraButton.frame.origin.x+self.cameraButton.frame.size.width+12, 0, self.frame.size.width-self.sendButton.frame.size.width-self.cameraButton.frame.size.width-36, 44);
        }
    }
    
    if ([self.textView isFirstResponder]) {

    } else {
        CGFloat totalAmount = 90;
        CGFloat totalHeight = 90;
        if (self.shouldHideNavigation == YES) {
            totalAmount = totalAmount - 46;
        }
        
        if (self.detachedTextInput == YES && self.shouldHideNavigation == NO) {
            totalAmount = 46;
            totalHeight = 46;
        }
        
        if (self.detachedTextInput == YES && self.shouldHideNavigation == YES) {
            totalAmount = 0;
            totalHeight = totalHeight - 44;
        }
        
        self.frame = CGRectMake(0, self.superview.frame.size.height-totalAmount, self.superview.frame.size.width, totalHeight);
    }
}

-(void)setDisplayCameraButton:(BOOL)displayCameraButton {
    _displayCameraButton = displayCameraButton;
    if (displayCameraButton == NO) {
        self.cameraButton.frame = CGRectZero;
        self.cameraButton.hidden = YES;
    } else {
        [self.cameraButton setFrame:CGRectMake(11, 0, 30, 44)];
        self.cameraButton.hidden = NO;
    }
    self.textView.frame = CGRectMake(self.cameraButton.frame.origin.x+self.cameraButton.frame.size.width+12, 0, self.frame.size.width-self.sendButton.frame.size.width-self.cameraButton.frame.size.width-36, 44);
    self.textOverlayImageView.frame = CGRectMake(self.cameraButton.frame.origin.x+self.cameraButton.frame.size.width+12, 0, self.frame.size.width-self.sendButton.frame.size.width-36-self.cameraButton.frame.size.width, 40);
    self.textSolidBackgroundView.frame = self.textOverlayImageView.frame;
}

-(BOOL)displayCameraButton {
    return _displayCameraButton;
}

-(void)setDisplaySendButton:(BOOL)displaySendButton {
    _displaySendButton = displaySendButton;
    if (displaySendButton == NO) {
        self.sendButton.frame = CGRectZero;
        self.sendButton.hidden = YES;
    } else {
        [self.sendButton setFrame:CGRectMake(self.frame.size.width-50, 10, 40, 20)];
        self.sendButton.hidden = NO;
    }
    self.textView.frame = CGRectMake(self.cameraButton.frame.origin.x+self.cameraButton.frame.size.width+12, 0, self.frame.size.width-self.sendButton.frame.size.width-self.cameraButton.frame.size.width-36, 44);
    self.textOverlayImageView.frame = CGRectMake(self.cameraButton.frame.origin.x+self.cameraButton.frame.size.width+12, 0, self.frame.size.width-self.sendButton.frame.size.width-36-self.cameraButton.frame.size.width, 40);
    self.textSolidBackgroundView.frame = self.textOverlayImageView.frame;    
}

-(BOOL)displaySendButton {
    return _displaySendButton;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{

    if ([keyPath isEqualToString:@"frame"] && context == MEContainerFrameContext) {
        if (self.detachedTextInput == YES) {
            self.textView.frame = CGRectMake(0, 0, self.textInputContainerView.frame.size.width, self.textInputContainerView.frame.size.height);
            self.textSolidBackgroundView.frame = CGRectMake(0, 0, self.textInputContainerView.frame.size.width, self.textInputContainerView.frame.size.height);
            __weak METextInputView * weakSelf = self;
            [UIView performWithoutAnimation:^{
                CGSize newSize = [self.placeholderLabel sizeThatFits:CGSizeMake(self.textInputContainerView.frame.size.width, CGFLOAT_MAX)];
                weakSelf.placeholderLabel.frame = CGRectMake(self.textView.attributedTextContentView.edgeInsets.left+4+self.textView.frame.origin.x, self.textView.attributedTextContentView.edgeInsets.top+1+self.textView.frame.origin.y, newSize.width, newSize.height);
            }];
            
        }

    } else if ([keyPath isEqualToString:@"text"] && context == MEPlaceholderTextContext && object == self.placeholderLabel) {
        __weak METextInputView * weakSelf = self;
        [UIView performWithoutAnimation:^{
            CGSize newSize = [self.placeholderLabel sizeThatFits:CGSizeMake(self.textInputContainerView.frame.size.width, CGFLOAT_MAX)];
            weakSelf.placeholderLabel.frame = CGRectMake(weakSelf.textView.attributedTextContentView.edgeInsets.left+4+weakSelf.textView.frame.origin.x, weakSelf.textView.attributedTextContentView.edgeInsets.top+1+weakSelf.textView.frame.origin.y, newSize.width, newSize.height);
        }];
    }
}

-(UIEdgeInsets)edgeInsets {
    return self.textView.attributedTextContentView.edgeInsets;
}

-(void)setEdgeInsets:(UIEdgeInsets)edgeInsets {
    self.textView.attributedTextContentView.edgeInsets = edgeInsets;
}




-(void)detachTextInputView:(BOOL)option {
    self.detachedTextInput = option;
    if (self.detachedTextInput == YES) {
        [self.textView removeFromSuperview];
        [self.textInputContainerView removeFromSuperview];
        self.textView.editorViewDelegate = nil;
        self.textView = nil;
        
        self.textView = [[DTRichTextEditorView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.textInputContainerView.frame.size.height)];
        self.textView.attributedTextContentView.edgeInsets = UIEdgeInsetsMake(12, 10, 12, 10);
        self.textView.returnKeyType = self.keyboardReturnKeyType;
        self.textView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        self.textView.keyboardType = self.keyboardType;
        self.textView.font = [UIFont systemFontOfSize:self.fontSize];
        self.textView.defaultFontSize = self.fontSize;
        self.textView.editable = YES;
        self.textView.autocorrectionType = UITextAutocorrectionTypeDefault;
        self.textView.shouldDrawImages = NO;
        self.textView.attributedTextContentView.delegate = self;
        self.textView.backgroundColor = [UIColor clearColor];
        self.textView.editorViewDelegate = self;
        self.textView.replaceParagraphsWithLineFeeds = YES;
        self.textView.maxImageDisplaySize = CGSizeMake((20+(self.fontSize-16)*self.emojiRatio), (20+(self.fontSize-16)*self.emojiRatio));
        self.textView.clipsToBounds = YES;
        self.textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.textView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        [self.meAccessory setTextView:self.textView];
        [self.textInputContainerView addSubview:self.textView];
        
        CGFloat inputHeight = 0;
        
//        if (self.inputAccessoryView != nil) {
//            inputHeight = self.inputAccessoryView.frame.size.height;
//        }
        
        CGFloat defaultHeight = 46;
        
        CGFloat totalHeight = inputHeight + defaultHeight;
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, totalHeight);
        self.meAccessory.frame = CGRectMake(0, inputHeight, self.frame.size.width, defaultHeight);
        self.textSolidBackgroundView.backgroundColor = [UIColor clearColor];
        self.textInputContainerView.backgroundColor = [UIColor clearColor];
        
        [self.cameraButton setHidden:YES];
        [self.sendButton setHidden:YES];
        [self.textOverlayImageView setHidden:YES];
        [self.barBackgroundImageView setHidden:YES];
        self.placeholderLabel.font = [UIFont systemFontOfSize:self.fontSize];
        __weak METextInputView * weakSelf = self;
        [UIView performWithoutAnimation:^{
            CGSize newSize = [weakSelf.placeholderLabel sizeThatFits:CGSizeMake(weakSelf.textInputContainerView.frame.size.width, CGFLOAT_MAX)];
            weakSelf.placeholderLabel.frame = CGRectMake(weakSelf.textView.attributedTextContentView.edgeInsets.left+4+weakSelf.textView.frame.origin.x, weakSelf.textView.attributedTextContentView.edgeInsets.top+1+weakSelf.textView.frame.origin.y, newSize.width, newSize.height);
        }];
        [self.textInputContainerView bringSubviewToFront:self.placeholderLabel];
    }
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.textView.delegate = nil;
    [self.textInputContainerView removeObserver:self forKeyPath:@"frame"];
    [self.placeholderLabel removeObserver:self forKeyPath:@"text"];
    self.meAccessory.meInputView = nil;
    self.meAccessory = nil;
    self.delegate = nil;
    [MakemojiSDK setChannel:@""];
}

-(void)sendMessage {
    if (self.textView.attributedText.length > 0) {
        
        DTHTMLWriter * newWriter = [[DTHTMLWriter alloc] initWithAttributedString:self.textView.attributedText];
        newWriter.useAppleConvertedSpace = NO;
        NSString * url = @"messages/create";
        
        MEAPIManager *manager = [MEAPIManager client];
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        
        NSString * htmlFragment = newWriter.HTMLFragment;
        
        NSError *error = NULL;
        NSString *pattern = @"(<img[^>]*>)";
        NSRange range = NSMakeRange(0, htmlFragment.length);
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
        NSArray *matches = [regex matchesInString:htmlFragment options:NSMatchingReportProgress range:range];
        NSMutableArray * imgMatches = [NSMutableArray array];
        for (NSTextCheckingResult * match in matches) {
            [imgMatches addObject:[htmlFragment substringWithRange:match.range]];
        }

        regex = [NSRegularExpression regularExpressionWithPattern:@"(&#[^>].+?;)" options:NSRegularExpressionCaseInsensitive error:&error];
        matches = [regex matchesInString:htmlFragment options:NSMatchingReportProgress range:range];
        
        for (NSTextCheckingResult * match in matches) {
            [imgMatches addObject:[htmlFragment substringWithRange:match.range]];
        }
        
        NSString * outputString = @"";
        if (imgMatches.count > 0) {
            for (NSString * frag in imgMatches) {
                outputString = [outputString stringByAppendingString:frag];
            }
        }
        
         if (self.textAttachments.count > 0 || ![self.text isEqualToString:@""]) {
        
            //Post Message
            [manager POST:url parameters:@{@"message" : outputString} success:^(NSURLSessionDataTask *task, id responseObject) {
                //NSLog(@"%@", responseObject);
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                //NSLog(@"%@", error);
            }];
        
        }
        
        NSString * htmlReplace = [self convertHTMLToSubstitue:htmlFragment];

        if ([htmlReplace isEqualToString:@"\n\n"]) {
            htmlReplace = @"";
        }
        
        if (self.textAttachments.count == 0 && [self.text isEqualToString:@""]) {
            htmlFragment = @"";
        }
        
        NSString * plainText = self.text;
        plainText = [METextInputView removeSubstituteStrings:plainText];
        if ([plainText length] > 0) {
            plainText = [plainText substringToIndex:[plainText length] - 1];
        }
        
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(meTextInputView:didTapSend:)]) {
            [self.delegate meTextInputView:self didTapSend:@{@"html" : htmlFragment, @"plaintext" : plainText, @"substitute" : htmlReplace}];
        }
        
        if (self.shouldClearOnSend == YES) {
            [self.textView setHTMLString:@""];
        }
        
        [self updateContainerSize:NO];
        [self showPlaceholderText];
    }
    
}

-(void)_didTapHypermoji:(NSNotification *)note {
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(meTextInputView:didTapHypermoji:)]) {
        [self.delegate meTextInputView:self didTapHypermoji:[note.userInfo objectForKey:@"url"]];
    }
}

-(void)_didTapHyperlink:(NSNotification *)note {
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(meTextInputView:didTapHypermoji:)]) {
        [self.delegate meTextInputView:self didTapHyperlink:[note.userInfo objectForKey:@"url"]];
    }
}

-(void)_selectedLockedCategory:(NSNotification *)note {
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(meTextInputView:selectedLockedCategory:)]) {
        [self.delegate meTextInputView:self selectedLockedCategory:[note.userInfo objectForKey:@"category"]];
    }
}

-(void)_textInputGIFInserted:(NSNotification *)note {
    if (self.shouldAutosendGif == YES) {
        [self sendMessage];
    }
}


- (UIView *)attributedTextContentView:(DTAttributedTextContentView *)attributedTextContentView viewForAttachment:(DTTextAttachment *)attachment frame:(CGRect)frame {
    MELinkedImageView * imageView = [[MELinkedImageView alloc] initWithFrame:frame];
    NSDictionary * dict = [attachment attributes];
    NSString * link = @"";
    if ([dict objectForKey:@"link"]) {
        link = [dict objectForKey:@"link"];
    }
    [imageView setImageUrl:[attachment.contentURL absoluteString] link:link];
    return imageView;
}

-(void)keyboardWillHide:(NSNotification *)note{
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    [self updateContainerSize:NO];
}

-(void)keyboardWillChangeSize:(NSNotification *)note {
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    BOOL shouldScroll = NO;
    shouldScroll = YES;
    self.frame = CGRectMake(0, keyboardBounds.origin.y-self.frame.size.height-self.superview.frame.origin.y, self.frame.size.width, self.frame.size.height);
    self.currentKeyboardPosition = keyboardBounds.origin.y;
    [self updateContainerSize:shouldScroll];
}

-(void)updateContainerSize:(BOOL)scroll {
    
        CGSize newSize = self.textView.contentSize;
        CGFloat currentY = self.frame.origin.y;
        if (newSize.height < 44) {
         newSize.height = 44;
        }
    
        CGFloat maxHeight = self.superview.frame.size.height - (self.superview.frame.size.height - self.currentKeyboardPosition) - 46 - self.superview.frame.origin.y;
        if (newSize.height > maxHeight) {
            newSize.height = maxHeight;
        }
    
        NSString * primaryMode = [[UITextInputMode currentInputMode] primaryLanguage];
    
        CGFloat accessoryheight = 46;
    
        if (self.meAccessory.flashtagOnly == YES) {
            if ([self.meAccessory.currentToggle isEqualToString:@"flashtag"]) {
                accessoryheight = 46;
            } else {
                accessoryheight = 0;
            }
            
        } else {
            
            if ([primaryMode isEqualToString:@"emoji"]) {
                accessoryheight = 0;
                self.meAccessory.titleLabel.hidden = YES;
                self.meAccessory.flashtagCollectionView.hidden = YES;
            } else {
                if ([self.meAccessory.currentToggle isEqualToString:@""] || [self.meAccessory.currentToggle isEqualToString:@"flashtag"]) {
                    if ([self.meAccessory.currentToggle isEqualToString:@"flashtag"]) {
                        self.meAccessory.titleLabel.hidden = YES;
                    } else {
                        self.meAccessory.titleLabel.hidden = NO;
                    }
                    accessoryheight = 46;
                } else {
                    accessoryheight = 46;
                }
        
            }
        }
    
        CGFloat yPos = self.superview.frame.size.height-newSize.height-accessoryheight;
    
        if (yPos < 0) { newSize.height += yPos; }
    
        currentY = self.currentKeyboardPosition - (newSize.height+accessoryheight) - self.superview.frame.origin.y;
    
    
        if (self.detachedTextInput == YES) {
            
            CGFloat inputHeight = 0;
            
//            if (self.inputAccessoryView != nil) {
//                inputHeight = self.inputAccessoryView.frame.size.height;
//            }

            CGFloat totalHeight = inputHeight + accessoryheight;
            
            CGFloat offsetPosition =  ([UIScreen mainScreen].bounds.size.height - self.currentKeyboardPosition);
            if (self.shouldHideNavigation == YES && offsetPosition <= 0) {
                offsetPosition = -(accessoryheight);
            } else {
                offsetPosition = 0;
            }
            
            
            self.frame = CGRectMake(self.frame.origin.x, (self.currentKeyboardPosition-accessoryheight-self.superview.frame.origin.y-inputHeight-offsetPosition), self.frame.size.width, totalHeight);

            self.meAccessory.frame = CGRectMake(0, inputHeight, self.frame.size.width, accessoryheight);
           __weak METextInputView * weakSelf = self;
            [UIView performWithoutAnimation:^{
                CGSize newSize = [weakSelf.placeholderLabel sizeThatFits:CGSizeMake(weakSelf.textInputContainerView.frame.size.width, CGFLOAT_MAX)];
                weakSelf.placeholderLabel.frame = CGRectMake(weakSelf.textView.attributedTextContentView.edgeInsets.left+4+weakSelf.textView.frame.origin.x, weakSelf.textView.attributedTextContentView.edgeInsets.top+1+weakSelf.textView.frame.origin.y, newSize.width, newSize.height);
            }];
            
            if (self.delegate != nil && [self.delegate respondsToSelector:@selector(meTextInputView:didChangeFrame:)]) {
                [self.delegate meTextInputView:self didChangeFrame:self.frame];
            }
            return;
        }

        CGFloat offsetPosition =  ([UIScreen mainScreen].bounds.size.height - self.currentKeyboardPosition);
    
        if (self.shouldHideNavigation == YES && offsetPosition <= 0) {
            offsetPosition = -(accessoryheight);
        } else {
            offsetPosition = 0;
        }
    
        self.frame = CGRectMake(self.frame.origin.x, currentY-offsetPosition, self.frame.size.width, newSize.height+accessoryheight);
        self.textInputContainerView.frame = CGRectMake(0, 0, self.frame.size.width, newSize.height);
        self.meAccessory.frame = CGRectMake(self.meAccessory.frame.origin.x, newSize.height, self.frame.size.width, accessoryheight);
        self.textView.frame = CGRectMake(self.textView.frame.origin.x, self.textView.frame.origin.y, self.textView.frame.size.width, newSize.height);
        self.placeholderLabel.frame = CGRectMake(self.textView.attributedTextContentView.edgeInsets.left+4+self.textView.frame.origin.x, self.textView.attributedTextContentView.edgeInsets.top+self.textView.frame.origin.y, self.placeholderLabel.frame.size.width, self.placeholderLabel.frame.size.height);
    
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(meTextInputView:didChangeFrame:)]) {
            [self.delegate meTextInputView:self didChangeFrame:self.frame];
        }

}

- (void)editorViewDidChange:(DTRichTextEditorView *)editorView {
    [self updateContainerSize:YES];
    [self.meAccessory textViewDidChange:editorView];
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(meTextInputViewDidChange:)]) {
        [self.delegate meTextInputViewDidChange:self];
    }
}

- (BOOL)editorView:(DTRichTextEditorView *)editorView canPerformAction:(SEL)action withSender:(id)sender {
   BOOL shouldEdit = [self editorViewShouldBeginEditing:self.textView];
   return  shouldEdit;
}

- (UIView *)attributedTextContentView:(DTAttributedTextContentView *)attributedTextContentView viewForLink:(NSURL *)url identifier:(NSString *)identifier frame:(CGRect)frame {
    DTLinkButton *button = [[DTLinkButton alloc] initWithFrame:frame];
    button.URL = url;
    button.minimumHitSize = CGSizeMake(25, 25); // adjusts it's bounds so that button is always large enough
    button.GUID = identifier;
    [button addTarget:self action:@selector(linkPushed:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)linkPushed:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^{
        DTLinkButton * linkButton = (DTLinkButton *)sender;
        NSDictionary *userInfo = @{@"url": linkButton.URL.absoluteString};
        [[NSNotificationCenter defaultCenter] postNotificationName:MEHyperlinkClicked object:self userInfo:userInfo];
    });
}

-(BOOL)editorViewShouldBeginEditing:(DTRichTextEditorView *)editorView {
    BOOL shouldBegin = YES;
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(shouldBeginEditing:)]) {
        shouldBegin = [self.delegate shouldBeginEditing:self];
    }
    
    return shouldBegin;
}

- (void)editorViewDidBeginEditing:(DTRichTextEditorView *)editorView {
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(meTextInputViewDidBeginEditing:)]) {
        [self.delegate meTextInputViewDidBeginEditing:self];
    }
}

- (void)editorViewDidEndEditing:(DTRichTextEditorView *)editorView {
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(meTextInputViewDidEndEditing:)]) {
        [self.delegate meTextInputViewDidEndEditing:self];
    }
}

- (BOOL)editorView:(DTRichTextEditorView *)editorView shouldChangeTextInRange:(NSRange)range replacementText:(NSAttributedString *)text {
    BOOL shouldChange = YES;

    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(meTextInputView:shouldChangeTextInRange:replacementText:)]) {
        shouldChange = [self.delegate meTextInputView:self shouldChangeTextInRange:range replacementText:text];
    }

    if (shouldChange == NO) { return shouldChange; }
    
    if (text.length > 0) {
        unichar lineSeparator = 0x2028;
        if ([[text string] characterAtIndex:0] == lineSeparator && self.textView.returnKeyType != UIReturnKeyDefault) {
            [self sendMessage];
            return NO;
        }
        
        if ([[text string] characterAtIndex:0] == '\n' && self.textView.returnKeyType != UIReturnKeyDefault) {
            [self sendMessage];
            return NO;
        }
    }
    return YES;
}

-(NSArray *)textAttachments {
  return [self.textView.attributedTextContentView.attributedString allAttachments];
}

-(void)showPlaceholderText {
    NSArray * attachments = [self.textView.attributedTextContentView.attributedString allAttachments];
    if ([attachments count] > 0 || self.textView.attributedTextContentView.attributedString.length > 1) {
        self.placeholderLabel.hidden = YES;
        self.sendButton.enabled = YES;
        [self updateContainerSize:YES];
        [self setEnablesReturnKeyAutomatically:YES];
    } else {
        self.sendButton.enabled = NO;
        self.placeholderLabel.hidden = NO;
        [self setEnablesReturnKeyAutomatically:NO];
    }
}

- (void)editorViewDidChangeSelection:(DTRichTextEditorView *)editorView {
    [self.meAccessory textViewDidChangeSelection:self.textView];
    [self showPlaceholderText];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    //NSLog(@"editorViewDidEndEditing");
    return YES;
}

-(void)didTapCamera {
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(meTextInputView:didTapCameraButton:)]) {
        [self.delegate meTextInputView:self didTapCameraButton:self.cameraButton];
    }
}

-(void)showKeyboard {
    if (self.textView.isFirstResponder == NO) {
        [self.textView becomeFirstResponder];
    }
}

-(void)hideKeyboard {
    [self.textView resignFirstResponder];
}

-(CGFloat)cellHeightForHTML:(NSString *)html atIndexPath:(NSIndexPath *)indexPath maxCellWidth:(CGFloat)width cellStyle:(MECellStyle)cellStyle {

    if (cellStyle == MECellStyleChat) {
    
        NSString * cellIdentifier = @"MECellStyleChat";
        MEChatTableViewCell *cell = [self.offscreenCells objectForKey:cellIdentifier];
        
        if (!cell) {
            cell = [[MEChatTableViewCell alloc] init];
            [self.offscreenCells setObject:cell forKey:cellIdentifier];
        }
        
        CGFloat height = 44;
        
        if (indexPath.row >= [self.cachedHeights count]) {
            
            [cell setHTMLString:html];
            CGSize newSize = [cell suggestedFrameSizeToFitEntireStringConstraintedToWidth:[cell cellMaxWidth:width]];
            height = [cell heightWithInitialSize:newSize];
            
            [self.cachedHeights insertObject:[NSNumber numberWithDouble:height] atIndex:indexPath.row];
        } else {
            height = [[self.cachedHeights objectAtIndex:indexPath.row] floatValue];
        }
        
        return height;
    }

    NSString * cellIdentifier = @"MESimpleTableViewCell";
    MESimpleTableViewCell *cell = [self.offscreenCells objectForKey:cellIdentifier];
    
    if (!cell) {
        cell = [[MESimpleTableViewCell alloc] init];
        [self.offscreenCells setObject:cell forKey:cellIdentifier];
    }
    
    CGFloat height = 44;
    
    if (indexPath.row >= [self.cachedHeights count]) {
        
        [cell setHTMLString:html];
        CGSize newSize = [cell suggestedFrameSizeToFitEntireStringConstraintedToWidth:width];
        height = [cell heightWithInitialSize:newSize];
        
        [self.cachedHeights insertObject:[NSNumber numberWithDouble:height] atIndex:indexPath.row];
    } else {
        height = [[self.cachedHeights objectAtIndex:indexPath.row] floatValue];
    }
    
    return height;


}

+(int)decodeNumber:(NSString*)string
{
    int num = 0;
    NSString * alphabet = @"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
    
    for (int i = 0, len = (int)[string length]; i < len; i++)
    {
        NSRange range = [alphabet rangeOfString:[string substringWithRange:NSMakeRange(i,1)]];
        num = num * 62 + (int)range.location;
    }
    
    return num;
}

+(NSString*)encodeNumber:(int)num
{
    NSString * alphabet = @"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
    NSMutableString * precursor = [NSMutableString stringWithCapacity:3];
    
    while (num > 0)
    {
        [precursor appendString:[alphabet substringWithRange:NSMakeRange( num % 62, 1 )]];
        num /= 62;
    }
    
    // http://stackoverflow.com/questions/6720191/reverse-nsstring-text
    NSMutableString *reversedString = [NSMutableString stringWithCapacity:[precursor length]];
    
    [precursor enumerateSubstringsInRange:NSMakeRange(0,[precursor length])
                                  options:(NSStringEnumerationReverse |NSStringEnumerationByComposedCharacterSequences)
                               usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                   [reversedString appendString:substring];
                               }];
    return reversedString;
}

+(NSUInteger)numberOfCharactersInSubstitute:(NSString *)string {
    NSError *error = NULL;
    NSString *pattern = @"[(.+?)";
    pattern = [NSString stringWithFormat: @"\\%@", pattern];
    pattern = [NSString stringWithFormat: @"%@\\", pattern];
    pattern = [NSString stringWithFormat: @"%@]", pattern];
    NSRange range = NSMakeRange(0, string.length);
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray *totalMatches = [regex matchesInString:string options:NSMatchingReportProgress range:range];
    NSString * replacedString = string;
    for (NSTextCheckingResult * match1 in totalMatches) {
        NSString * baseString = [string substringWithRange:match1.range];
        replacedString = [replacedString stringByReplacingOccurrencesOfString:baseString withString:@"0"];
    }
    return replacedString.length;
}

+(NSString *)removeSubstituteStrings:(NSString *)string {
    NSError *error = NULL;
    NSString *pattern = @"[(.+?)";
    pattern = [NSString stringWithFormat: @"\\%@", pattern];
    pattern = [NSString stringWithFormat: @"%@\\", pattern];
    pattern = [NSString stringWithFormat: @"%@]", pattern];
    NSRange range = NSMakeRange(0, string.length);
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray *totalMatches = [regex matchesInString:string options:NSMatchingReportProgress range:range];
    NSString * replacedString = string;
    for (NSTextCheckingResult * match1 in totalMatches) {
        NSString * baseString = [string substringWithRange:match1.range];
        replacedString = [replacedString stringByReplacingOccurrencesOfString:baseString withString:@""];
    }
    return replacedString;
}


+(NSString *)convertSubstituedToHTMLWithParagraphBlocks:(NSString *)substitute {
    substitute = [substitute stringByReplacingOccurrencesOfString:@"\n" withString:@"</span></p><p dir=\"auto\" style=\"font-family:'.SF UI Text';font-size:16px; color:#000000; margin:0px;\"><span>"];
    substitute = [substitute stringByReplacingOccurrencesOfString:@"\u2028" withString:@"</span></p><p dir=\"auto\" style=\"font-family:'.SF UI Text';font-size:16px; color:#000000; margin:0px;\"><span>"];
    substitute = [substitute stringByReplacingOccurrencesOfString:@" " withString:@" "];
    NSError *error = NULL;
    NSString *pattern = @"[(.+?)";
    pattern = [NSString stringWithFormat: @"\\%@", pattern];
    pattern = [NSString stringWithFormat: @"%@\\", pattern];
    pattern = [NSString stringWithFormat: @"%@]", pattern];
    
    NSRange range = NSMakeRange(0, substitute.length);
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray *totalMatches = [regex matchesInString:substitute options:NSMatchingReportProgress range:range];
    
    for (NSTextCheckingResult * match1 in totalMatches) {
        
        regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
        NSArray * matches = [regex matchesInString:substitute options:NSMatchingReportProgress range:NSMakeRange(0, substitute.length)];
        
        NSTextCheckingResult * firstResult2 = (NSTextCheckingResult *)[matches objectAtIndex:0];
        NSString * baseString = [[substitute substringWithRange:firstResult2.range] stringByReplacingOccurrencesOfString:@"[" withString:@""];
        baseString = [baseString stringByReplacingOccurrencesOfString:@"]" withString:@""];
        
        NSArray * split = [baseString componentsSeparatedByString:@"."];
        
        if (split.count > 1) {
            NSString * emojiName = [split objectAtIndex:0];
            
            NSString * emojiLink = @"";
            int emojiId;
            
            NSString * remaining = [[baseString stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@.", emojiName] withString:@""] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSArray * endSplit = [remaining componentsSeparatedByString:@" "];
            if (endSplit.count < 2) {
                endSplit = [remaining componentsSeparatedByString:@" "];
            }
            
            emojiId = [METextInputView decodeNumber:[endSplit objectAtIndex:0]];
            
            if (endSplit.count > 1) {
                emojiLink = [endSplit objectAtIndex:1];
            }
            
            NSString * newImag = [NSString stringWithFormat:@"<img style=\"vertical-align:middle;width:20px;height:20px;\" src=\"https://d1tvcfe0bfyi6u.cloudfront.net/emoji/%i-large@2x.png\" id=\"%i\" link=\"%@\" name=\"%@\" />", emojiId, emojiId, emojiLink, emojiName];
            
            
            if ([emojiName isEqualToString:@"gif"]) {
                newImag = [NSString stringWithFormat:@"<img style=\"vertical-align:middle;width:20px;height:20px;\" src=\"https://d1tvcfe0bfyi6u.cloudfront.net/emoji/%i-40x40@2x.gif\" id=\"%i\" link=\"%@\" name=\"%@\" />", emojiId, emojiId, emojiLink, emojiName];
            }
            
            substitute = [substitute stringByReplacingCharactersInRange:firstResult2.range withString:newImag];
            
        }
        
    }
    
    NSString * output = [NSString stringWithFormat:@"<p dir=\"auto\" style=\"font-family:'.SF UI Text';font-size:16px; color:#000000; margin:0px; \"><span>%@</span></p>", substitute];
    return output;
}

-(NSUInteger)substituteCharacterCount {
    NSUInteger charCount = 0;
    if (self.textAttachments.count > 0) {
        for(DTImageTextAttachment * attachment in self.textAttachments) {
            NSDictionary * attrDict = attachment.attributes;
            if ([attrDict objectForKey:@"id"]) {
                charCount += 4;
                NSNumber * attId = [attrDict objectForKey:@"id"];
                NSString * converId = [METextInputView encodeNumber:(int)[attId integerValue]];
                charCount += converId.length;
                charCount -= 1;
            }
            if ([attrDict objectForKey:@"link"]) {
                NSString * linkUrl = [attrDict objectForKey:@"link"];
                if (linkUrl.length > 0) {
                    charCount += linkUrl.length + 1;
                }
            }
        }
    }
    charCount += self.textView.attributedText.length;
    charCount -= 1; // ending line break
    return charCount;
}

+(NSString *)transformHTML:(NSString * )html withFont:(UIFont *)font textColor:(UIColor *)color {
    
    NSString * fontSize = [NSString stringWithFormat:@"font-size:%dpx;",(int)floorf([font pointSize])];
    NSString * fontName = [font familyName];
    NSString * fontColor = [NSString stringWithFormat:@"color:%@;", [self hexStringFromColor:color]];

    NSError *error = NULL;
    NSRange range = NSMakeRange(0, html.length);
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"color:(.+?);" options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray *totalMatches = [regex matchesInString:html options:NSMatchingReportProgress range:range];
    NSString * replaceColor = @"color:#000000;";
    if (totalMatches.count > 0) {
        NSTextCheckingResult * firstMatch = [totalMatches objectAtIndex:0];
        replaceColor = [html substringWithRange:firstMatch.range];
    }
    html = [html stringByReplacingOccurrencesOfString:replaceColor withString:fontColor];
    
    NSString * replaceFontSize = @"font-size:16px;";
    range = NSMakeRange(0, html.length);
    regex = [NSRegularExpression regularExpressionWithPattern:@"font-size:(.+?);" options:NSRegularExpressionCaseInsensitive error:&error];
    totalMatches = [regex matchesInString:html options:NSMatchingReportProgress range:range];
    
    if (totalMatches.count > 0) {
        NSTextCheckingResult * firstMatch = [totalMatches objectAtIndex:0];
        replaceFontSize = [html substringWithRange:firstMatch.range];
    }
    
    html = [html stringByReplacingOccurrencesOfString:replaceFontSize withString:fontSize];

    CGSize imageSize = CGSizeMake(20+([font pointSize]-16), 20+([font pointSize]-16));
    NSString * imageString = [NSString stringWithFormat:@"width:%dpx;height:%dpx;", (int)imageSize.width, (int)imageSize.height];
    html = [html stringByReplacingOccurrencesOfString:@"width:20px;height:20px;" withString:imageString];

    
    NSString * replaceFontFace = @"font-family:'.SF UI Text';";
    range = NSMakeRange(0, html.length);
    regex = [NSRegularExpression regularExpressionWithPattern:@"font-family:'(.+?)';" options:NSRegularExpressionCaseInsensitive error:&error];
    totalMatches = [regex matchesInString:html options:NSMatchingReportProgress range:range];
    
    if (totalMatches.count > 0) {
        NSTextCheckingResult * firstMatch = [totalMatches objectAtIndex:0];
        replaceFontFace = [html substringWithRange:firstMatch.range];
    }
    
    NSString * fontFamilyString = [NSString stringWithFormat:@"font-family:'%@';", fontName];
    html = [html stringByReplacingOccurrencesOfString:replaceFontFace withString:fontFamilyString];
    
    return html;
}

+(NSString *)convertSubstituedToHTML:(NSString *)substitute {
    substitute = [substitute stringByReplacingOccurrencesOfString:@"\n" withString:@"<br />"];
    substitute = [substitute stringByReplacingOccurrencesOfString:@" " withString:@" "];
    NSError *error = NULL;
    NSString *pattern = @"[(.+?)";
    pattern = [NSString stringWithFormat: @"\\%@", pattern];
    pattern = [NSString stringWithFormat: @"%@\\", pattern];
    pattern = [NSString stringWithFormat: @"%@]", pattern];

    NSRange range = NSMakeRange(0, substitute.length);
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray *totalMatches = [regex matchesInString:substitute options:NSMatchingReportProgress range:range];

    for (NSTextCheckingResult * match1 in totalMatches) {
        
        regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
        NSArray * matches = [regex matchesInString:substitute options:NSMatchingReportProgress range:NSMakeRange(0, substitute.length)];
        
        NSTextCheckingResult * firstResult2 = (NSTextCheckingResult *)[matches objectAtIndex:0];
        NSString * baseString = [substitute substringWithRange:firstResult2.range];
        baseString = [baseString stringByReplacingOccurrencesOfString:@"]" withString:@""];
        
        NSArray * split = [baseString componentsSeparatedByString:@"."];
        
        if (split.count > 1) {
            NSString * emojiName = [[split objectAtIndex:0] stringByReplacingOccurrencesOfString:@"[" withString:@""];

            NSString * emojiLink = @"";
            int emojiId;
            
            NSString * remaining = [[baseString stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"[%@.", emojiName] withString:@""] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            NSArray * endSplit = [remaining componentsSeparatedByString:@" "];
            if (endSplit.count < 2) {
                endSplit = [remaining componentsSeparatedByString:@" "];
            }
            
            emojiId = [METextInputView decodeNumber:[endSplit objectAtIndex:0]];
            
            if (endSplit.count > 1) {
                emojiLink = [endSplit objectAtIndex:1];
            }
            
            NSString * newImag = [NSString stringWithFormat:@"<img style=\"vertical-align:middle;width:20px;height:20px;\" src=\"https://d1tvcfe0bfyi6u.cloudfront.net/emoji/%i-large@2x.png\" id=\"%i\" link=\"%@\" name=\"%@\" />", emojiId, emojiId, emojiLink, emojiName];
            
            if ([emojiName isEqualToString:@"gif"]) {
                newImag = [NSString stringWithFormat:@"<img style=\"vertical-align:middle;width:20px;height:20px;\" src=\"https://d1tvcfe0bfyi6u.cloudfront.net/emoji/%i-40x40@2x.gif\" id=\"%i\" link=\"%@\" name=\"%@\" />", emojiId, emojiId, emojiLink, emojiName];
            }
            
            substitute = [substitute stringByReplacingCharactersInRange:firstResult2.range withString:newImag];
        
        }
            
    }

    NSString * output = [NSString stringWithFormat:@"<p dir=\"auto\" style=\"font-family:'.SF UI Text';font-size:16px;\"><span style=\"color:#000000;\">%@</span></p>", substitute];
    return output;
}

+(NSString *)convertSubstituedToHTMLWithParagraphBlocks:(NSString *)substitute withFont:(UIFont *)font textColor:(UIColor *)color {
    NSString * tempString = [METextInputView convertSubstituedToHTMLWithParagraphBlocks:substitute];
    NSString * fontSize = [NSString stringWithFormat:@"font-size:%dpx;",(int)floorf([font pointSize])];
    NSString * fontName = [font familyName];
    
    NSString * fontColor = [NSString stringWithFormat:@"color:%@;", [self hexStringFromColor:color]];
    tempString = [tempString stringByReplacingOccurrencesOfString:@"color:#000000;" withString:fontColor];
    
    tempString = [tempString stringByReplacingOccurrencesOfString:@"font-size:16px;" withString:fontSize];
    CGSize imageSize = CGSizeMake(20+([font pointSize]-16), 20+([font pointSize]-16));
    NSString * imageString = [NSString stringWithFormat:@"width:%dpx;height:%dpx;", (int)imageSize.width, (int)imageSize.height];
    tempString = [tempString stringByReplacingOccurrencesOfString:@"width:20px;height:20px;" withString:imageString];
    
    NSString * fontFamilyString = [NSString stringWithFormat:@"font-family:'%@';", fontName];
    tempString = [tempString stringByReplacingOccurrencesOfString:@"font-family:'.SF UI Text';" withString:fontFamilyString];
    
    return tempString;
}

+(NSString *)convertSubstituedToHTML:(NSString *)substitute withFont:(UIFont *)font textColor:(UIColor *)color {
    NSString * tempString = [METextInputView convertSubstituedToHTML:substitute];
    NSString * fontSize = [NSString stringWithFormat:@"font-size:%dpx;",(int)floorf([font pointSize])];
    NSString * fontName = [font familyName];

    NSString * fontColor = [NSString stringWithFormat:@"color:%@;", [self hexStringFromColor:color]];
    tempString = [tempString stringByReplacingOccurrencesOfString:@"color:#000000;" withString:fontColor];

    tempString = [tempString stringByReplacingOccurrencesOfString:@"font-size:16px;" withString:fontSize];
    CGSize imageSize = CGSizeMake(20+([font pointSize]-16), 20+([font pointSize]-16));
    NSString * imageString = [NSString stringWithFormat:@"width:%dpx;height:%dpx;", (int)imageSize.width, (int)imageSize.height];
    tempString = [tempString stringByReplacingOccurrencesOfString:@"width:20px;height:20px;" withString:imageString];
    
    NSString * fontFamilyString = [NSString stringWithFormat:@"font-family:'%@';", fontName];
    tempString = [tempString stringByReplacingOccurrencesOfString:@"font-family:'.SF UI Text';" withString:fontFamilyString];
    
    return tempString;
}

+(NSString *)convertSubstituedToHTML:(NSString *)substitute withFont:(UIFont *)font textColor:(UIColor *)color emojiRatio:(CGFloat)ratio {
    NSDictionary * optionsDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                  font, MESubstituteOptionFont,
                                  color, MESubstituteOptionTextColor,
                                  [NSNumber numberWithFloat:ratio], MESubstituteOptionEmojiSizeRatio, nil];
    return [METextInputView convertSubstituteToHTML:substitute options:optionsDict];
}

+(NSString *)convertSubstituteToHTML:(NSString *)substitute options:(NSDictionary *)options {
    BOOL shouldScanForLinks = NO;
    BOOL useParagraphBlocks = NO;
    UIColor * textColor = [UIColor blackColor];
    UIFont * textFont = [UIFont systemFontOfSize:16];
    NSString * linkStyle = @"";
    CGFloat emojiRatio = 1.0f;
    
    if ([options objectForKey:MESubstituteOptionShouldScanForLinks] && [[options objectForKey:MESubstituteOptionShouldScanForLinks] isKindOfClass:[NSNumber class]]) {
        shouldScanForLinks = [(NSNumber *)[options objectForKey:MESubstituteOptionShouldScanForLinks] boolValue];
    }

    if ([options objectForKey:MESubstituteOptionUseParagraphBlocks] && [[options objectForKey:MESubstituteOptionUseParagraphBlocks] isKindOfClass:[NSNumber class]]) {
        useParagraphBlocks = [(NSNumber *)[options objectForKey:MESubstituteOptionUseParagraphBlocks] boolValue];
    }
    
    if ([options objectForKey:MESubstituteOptionFont] && [[options objectForKey:MESubstituteOptionFont] isKindOfClass:[UIFont class]]) {
        textFont = [options objectForKey:MESubstituteOptionFont];
    }
    
    if ([options objectForKey:MESubstituteOptionTextColor] && [[options objectForKey:MESubstituteOptionTextColor] isKindOfClass:[UIColor class]]) {
        textColor = [options objectForKey:MESubstituteOptionTextColor];
    }
    
    if ([options objectForKey:MESubstituteOptionLinkStyle] && [[options objectForKey:MESubstituteOptionLinkStyle] isKindOfClass:[NSString class]]) {
        linkStyle = [options objectForKey:MESubstituteOptionLinkStyle];
    }
    
    if ([options objectForKey:MESubstituteOptionEmojiSizeRatio] && [[options objectForKey:MESubstituteOptionEmojiSizeRatio] isKindOfClass:[NSNumber class]]) {
        emojiRatio = [(NSNumber *)[options objectForKey:MESubstituteOptionEmojiSizeRatio] floatValue];
        //NSLog(@"got ratio of %f", emojiRatio);
    }
    
    //first lets make a copy and then determine if we should scan for links
    
    NSString * replaceSubstitute = [NSString stringWithString:substitute];
    
    if (shouldScanForLinks == YES) {
    
        NSError *error = NULL;
        NSString *pattern = @"[(.+?)";
        pattern = [NSString stringWithFormat: @"\\%@", pattern];
        pattern = [NSString stringWithFormat: @"%@\\", pattern];
        pattern = [NSString stringWithFormat: @"%@]", pattern];
        
        NSRange range = NSMakeRange(0, substitute.length);
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
        NSArray *totalMatches = [regex matchesInString:substitute options:NSMatchingReportProgress range:range];
        NSMutableDictionary * replacementDict = [NSMutableDictionary dictionary];
        
        for (NSTextCheckingResult * match1 in totalMatches) {
            NSString * matchString = [substitute substringWithRange:match1.range];
            [replacementDict setObject:matchString forKey:[NSString stringWithFormat:@"%lu", (unsigned long)[matchString hash]]];
            replaceSubstitute = [replaceSubstitute stringByReplacingOccurrencesOfString:matchString withString:[NSString stringWithFormat:@"%lu", (unsigned long)[matchString hash]]];
        }
        
        NSDataDetector *linkDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:nil];
        NSArray *matches = [linkDetector matchesInString:replaceSubstitute options:0 range:NSMakeRange(0, [replaceSubstitute length])];
        
        NSUInteger offset = 0;
        for (NSTextCheckingResult *match in matches) {
            if ([match resultType] == NSTextCheckingTypeLink) {
                NSUInteger urlEnd = match.range.location+match.range.length+offset;
                if (urlEnd < replaceSubstitute.length) {
                    NSString * nextCharUrl = [replaceSubstitute substringWithRange:NSMakeRange(urlEnd, 1)];
                    if (![nextCharUrl isEqualToString:@"]"]) {
                        NSString * linkString = [NSString stringWithFormat:@"<a href='%@' style='%@'>%@</a>", match.URL.absoluteString, linkStyle, match.URL.absoluteString];
                        replaceSubstitute = [replaceSubstitute stringByReplacingCharactersInRange:NSMakeRange(match.range.location+offset, match.range.length) withString:linkString];
                        offset += (linkString.length - match.range.length);
                    }
                }
            }
        }
        
        // put back the substituted emoji
        
        for (NSString * key in [replacementDict allKeys]) {
            replaceSubstitute = [replaceSubstitute stringByReplacingOccurrencesOfString:key withString:[replacementDict objectForKey:key]];
        }
    
    }
 
    // do our first render to HTML
    NSString * firstConvert = [METextInputView convertSubstituedToHTML:replaceSubstitute withFont:textFont textColor:textColor];
    

    // figure out if we need to increase the ratio size
    
    if (emojiRatio > 1.0f) {
        CGSize defaultImageSize = CGSizeMake(20+([textFont pointSize]-16), 20+([textFont pointSize]-16));
        NSString * defaultImageString = [NSString stringWithFormat:@"width:%dpx;height:%dpx;", (int)defaultImageSize.width, (int)defaultImageSize.height];
        CGFloat baseSize = (20 + ([textFont pointSize]-16));
        CGSize imageSize = CGSizeMake(baseSize*emojiRatio ,baseSize*emojiRatio);
        NSString * imageString = [NSString stringWithFormat:@"width:%dpx;height:%dpx;", (int)imageSize.width, (int)imageSize.height];
        firstConvert = [firstConvert stringByReplacingOccurrencesOfString:defaultImageString withString:imageString];
    }
    
    return firstConvert;
}


+(NSString *)convertSubstituedToHTML:(NSString *)substitute withFont:(UIFont *)font textColor:(UIColor *)color linkStyle:(NSString *)linkStyle {
    NSDictionary * optionsDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                  font, MESubstituteOptionFont,
                                  color, MESubstituteOptionTextColor,
                                  linkStyle, MESubstituteOptionLinkStyle,
                                  [NSNumber numberWithBool:YES], MESubstituteOptionShouldScanForLinks, nil];
    return [METextInputView convertSubstituteToHTML:substitute options:optionsDict];
}


+(NSString *)convertSubstituedToHTML:(NSString *)substitute withFontName:(NSString *)fontName pointSize:(CGFloat)pointSize textColor:(UIColor *)color {
    NSString * tempString = [METextInputView convertSubstituedToHTML:substitute];
    NSString * fontSize = [NSString stringWithFormat:@"font-size:%dpx;",(int)floorf(pointSize)];
    NSString * fontColor = [NSString stringWithFormat:@"color:%@;", [self hexStringFromColor:color]];
    tempString = [tempString stringByReplacingOccurrencesOfString:@"color:#000000;" withString:fontColor];
    
    tempString = [tempString stringByReplacingOccurrencesOfString:@"font-size:16px;" withString:fontSize];
    CGSize imageSize = CGSizeMake(20+(pointSize-16), 20+(pointSize-16));
    NSString * imageString = [NSString stringWithFormat:@"width:%dpx;height:%dpx;", (int)imageSize.width, (int)imageSize.height];
    tempString = [tempString stringByReplacingOccurrencesOfString:@"width:20px;height:20px;" withString:imageString];
    
    NSString * fontFamilyString = [NSString stringWithFormat:@"font-family:'%@';", fontName];
    tempString = [tempString stringByReplacingOccurrencesOfString:@"font-family:'.SF UI Text';" withString:fontFamilyString];
    
    return tempString;
}


-(NSString * )stripTags:(NSString *)fragment {
    fragment = [fragment stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    fragment = [fragment stringByReplacingOccurrencesOfString:@"<br />" withString:@"\u2028"];
    NSError *error = NULL;
    NSString *pattern = @"(<span[^>]*>)";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    fragment = [regex stringByReplacingMatchesInString:fragment options:0 range:NSMakeRange(0, fragment.length) withTemplate:@""];
    fragment = [fragment stringByReplacingOccurrencesOfString:@"</span>" withString:@""];
    regex = [NSRegularExpression regularExpressionWithPattern:@"(<p[^>]*>)" options:NSRegularExpressionCaseInsensitive error:&error];
    fragment = [regex stringByReplacingMatchesInString:fragment options:0 range:NSMakeRange(0, fragment.length) withTemplate:@""];
    fragment = [fragment stringByReplacingOccurrencesOfString:@"</p>" withString:@""];
    return fragment;
}

-(NSString *)convertHTMLToSubstitue:(NSString *)htmlFragment {
    NSString * htmlReplace = htmlFragment;
    htmlReplace = [self stripTags:htmlReplace];
    NSError *error = NULL;
    NSRegularExpression * regex = [NSRegularExpression regularExpressionWithPattern:@"(<img[^>]*>)" options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray * matches = [regex matchesInString:htmlReplace options:NSMatchingReportProgress range:NSMakeRange(0, htmlReplace.length)];
    
    for (NSTextCheckingResult * match in matches) {
        regex = [NSRegularExpression regularExpressionWithPattern:@"(<img[^>]*>)" options:NSRegularExpressionCaseInsensitive error:&error];
        NSArray * matches2 = [regex matchesInString:htmlReplace options:NSMatchingReportProgress range:NSMakeRange(0, htmlReplace.length)];
        
        NSTextCheckingResult * firstResult = (NSTextCheckingResult *)[matches2 objectAtIndex:0];
        NSString * imgStr = [htmlReplace substringWithRange:firstResult.range];
        
        NSRegularExpression * regex2 = [NSRegularExpression regularExpressionWithPattern:@"(\\s+)(\\S+)=[\"']?((?:.(?![\"']?\\s+(?:\\S+)=|[>\"']))+.)[\"']?" options:NSRegularExpressionCaseInsensitive error:&error];
        NSArray * matches3 = [regex2 matchesInString:imgStr options:NSMatchingReportProgress range:NSMakeRange(0, imgStr.length)];
        
        NSString * exportName = @"e";
        NSString * exportID = @"0";
        NSString * exportLink;
        NSString * exportSRC;
        NSString * rawId;
        
        BOOL isGif = NO;
        for (NSTextCheckingResult * match1 in matches3) {
            NSString * piec = [[imgStr substringWithRange:match1.range] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSArray *parts = [piec componentsSeparatedByString:@"="];
            if (parts.count > 1) {
                NSString * atrName = [parts objectAtIndex:0];
                if ([atrName isEqualToString:@"name"]) {
                    exportName = [[parts objectAtIndex:1] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                    if ([exportName isEqualToString:@"gif"]) {
                        isGif = YES;
                    }
                }
                
                if ([atrName isEqualToString:@"id"]) {
                    exportID = [[parts objectAtIndex:1] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                    rawId = exportID;
                    exportID = [METextInputView encodeNumber:(int)[exportID integerValue]];
                }
                
                if ([atrName isEqualToString:@"link"]) {
                    exportLink = [[parts objectAtIndex:1] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                }
                
                if ([atrName isEqualToString:@"src"]) {
                    exportSRC = [[parts objectAtIndex:1] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                }
                
            }
        }
        
        if (isGif == YES) {
            //exportID = rawId;
            exportName = @"gif";
        } else {
            exportName = @"e";
        }
        
        if (exportLink.length < 7) {
            exportLink = nil;
        }
        
        if (exportLink != nil) {
            htmlReplace = [htmlReplace stringByReplacingCharactersInRange:firstResult.range withString:[NSString stringWithFormat:@"[%@.%@ %@]", exportName,exportID, exportLink]];
        } else {
            htmlReplace = [htmlReplace stringByReplacingCharactersInRange:firstResult.range withString:[NSString stringWithFormat:@"[%@.%@]", exportName,exportID]];
        }
        
        
    }

    NSData *stringData = [[htmlReplace stringByReplacingOccurrencesOfString:@" " withString:@"&nbsp;"] dataUsingEncoding:NSUnicodeStringEncoding];
    NSAttributedString *decodedString;
    decodedString = [[NSAttributedString alloc] initWithData:stringData
                                                     options:@{NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType}
                                          documentAttributes:NULL
                                                       error:NULL];
    
    NSString * replaceSpaces  = [decodedString.string stringByReplacingOccurrencesOfString:@" " withString:@" "];
    
    return replaceSpaces;

}

+ (NSString *)hexStringFromColor:(UIColor *)color
{
    CGColorSpaceModel colorSpace = CGColorSpaceGetModel(CGColorGetColorSpace(color.CGColor));
    const CGFloat *components = CGColorGetComponents(color.CGColor);
    
    CGFloat r = 0.0, g = 0.0, b = 0.0, a;
    
    if (colorSpace == kCGColorSpaceModelMonochrome) {
        r = components[0];
        g = components[0];
        b = components[0];
        a = components[1];
    }
    else if (colorSpace == kCGColorSpaceModelRGB) {
        r = components[0];
        g = components[1];
        b = components[2];
        a = components[3];
    }
    
    return [NSString stringWithFormat:@"#%02lX%02lX%02lX",
            lroundf(r * 255),
            lroundf(g * 255),
            lroundf(b * 255)];
}

+(BOOL)detectMakemojiMessage:(NSString *)message {
    
    NSString *pattern = @"[(.+?)";
    pattern = [NSString stringWithFormat: @"\\%@", pattern];
    pattern = [NSString stringWithFormat: @"%@\\", pattern];
    pattern = [NSString stringWithFormat: @"%@]", pattern];
    
    NSError *error = NULL;
    NSRange range = NSMakeRange(0, message.length);
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray *totalMatches = [regex matchesInString:message options:NSMatchingReportProgress range:range];
    
    if (totalMatches.count > 0) {
        // possible message
        return YES;
    }
    
    return NO;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(meTextInputView:scrollViewDidScroll:)]) {
        [self.delegate meTextInputView:self scrollViewDidScroll:scrollView];
    }
}

-(void)setDefaultParagraphStyle:(NSString *)style {
    NSMutableDictionary *defaults = [NSMutableDictionary dictionary];
    DTCSSStylesheet *styleSheet = [[DTCSSStylesheet alloc] initWithStyleBlock:style];
    [defaults setObject:styleSheet forKey:DTDefaultStyleSheet];
    [self.textView setTextDefaults:defaults];
}

-(CGSize)contentSize {
    return self.textView.contentSize;
}

-(void)setFont:(UIFont *)font {
    UIFontDescriptor * descriptor = font.fontDescriptor;
    NSDictionary * attributes = descriptor.fontAttributes;
    CGFloat fontSize = [[attributes objectForKey:@"NSFontSizeAttribute"] floatValue];
    NSString * fontWeight = [attributes objectForKey:@"NSCTFontUIUsageAttribute"];
    [self setFontSize:fontSize];
    [self setDefaultFontFamily:font.familyName];
    self.textView.defaultFontSize = fontSize;
    self.textView.font = [UIFont systemFontOfSize:self.fontSize];
    self.textView.maxImageDisplaySize = CGSizeMake((20+(self.fontSize-16)*self.emojiRatio), (20+(self.fontSize-16)*self.emojiRatio));
    self.placeholderLabel.font = [UIFont systemFontOfSize:fontSize];
    [self.placeholderLabel sizeToFit];
    self.placeholderLabel.frame = CGRectMake(self.textView.attributedTextContentView.edgeInsets.left+4+self.textView.frame.origin.x, self.textView.attributedTextContentView.edgeInsets.top+self.textView.frame.origin.y, self.placeholderLabel.frame.size.width, self.placeholderLabel.frame.size.height);
    
    NSUInteger weight = 400;
    if ([fontWeight isEqualToString:@"CTFontRegularUsage"]) {
        weight = 400;
    } else if ([fontWeight isEqualToString:@"CTFontUltraLightUsage"]) {
        weight = 200;
    } else if ([fontWeight isEqualToString:@"CTFontThinUsage"]) {
        weight = 100;
    } else if ([fontWeight isEqualToString:@"CTFontLightUsage"]) {
        weight = 300;
    } else if ([fontWeight isEqualToString:@"CTFontMediumUsage"]) {
        weight = 500;
    } else if ([fontWeight isEqualToString:@"CTFontSemiboldUsage"]) {
        weight = 600;
    } else if ([fontWeight isEqualToString:@"CTFontEmphasizedUsage"]) {
        weight = 700;
    } else if ([fontWeight isEqualToString:@"CTFontHeavyUsage"]) {
        weight = 800;
    }
    
    [self setDefaultParagraphStyle:[NSString stringWithFormat:@"p {font-weight: %lu;}", (unsigned long)weight]];
}


@end
