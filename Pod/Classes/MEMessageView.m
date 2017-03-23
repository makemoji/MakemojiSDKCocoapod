//
//  MEMessageView.m
//  MakemojiSDK
//
//  Created by steve on 3/7/16.
//  Copyright © 2016 Makemoji. All rights reserved.
//

#import "MEMessageView.h"
#import "MakemojiSDK.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import "MELinkedImageView.h"
#import <DTCoreText/DTCoreText.h>

@interface MEMessageView () <DTAttributedTextContentViewDelegate, MELinkedImageViewDelegate>
@property (nonatomic) DTAttributedTextContentView *attributedTextContextView;
@property NSString * htmlString;
@property NSMutableDictionary * cachedSizes;
@property (nonatomic, strong) NSAttributedString *attributedString;
- (void)setHTMLString:(NSString *)html options:(NSDictionary*) options;
@end

@implementation MEMessageView {
    DTAttributedTextContentView *_attributedTextContextView;
    NSUInteger _htmlHash; // preserved hash to avoid relayouting for same HTML
}

@synthesize numberOfLines = _numberOfLines;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        ___useiOS6Attributes = YES;
        self.clipsToBounds = YES;
        self.edgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        self.translatesAutoresizingMaskIntoConstraints = YES;
        self.cachedSizes = [NSMutableDictionary dictionary];
    }
    return self;
}

- (UIEdgeInsets)layoutMargins {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

-(void)setNumberOfLines:(NSInteger)numberOfLines {
    _numberOfLines = numberOfLines;
    if (self.attributedTextContextView) {
        self.attributedTextContextView.layoutFrame.numberOfLines = numberOfLines;
    }
}

-(NSInteger)numberOfLines {
    if (!_numberOfLines) { _numberOfLines = 0; }
    return  _numberOfLines;
}


- (UIView *)attributedTextContentView:(DTAttributedTextContentView *)attributedTextContentView viewForAttachment:(DTTextAttachment *)attachment frame:(CGRect)frame {
    MELinkedImageView * imageView = [[MELinkedImageView alloc] initWithFrame:frame];
    NSDictionary * dict = [attachment attributes];
    NSString * link = @"";
    if ([dict objectForKey:@"link"]) { link = [dict objectForKey:@"link"]; }
    [imageView setImageUrl:[attachment.contentURL absoluteString] link:link];
    [imageView setDelegate:self];
    return imageView;
}

- (UIView *)attributedTextContentView:(DTAttributedTextContentView *)attributedTextContentView viewForLink:(NSURL *)url identifier:(NSString *)identifier frame:(CGRect)frame {
    DTLinkButton *button = [[DTLinkButton alloc] initWithFrame:frame];
    button.URL = url;
    button.minimumHitSize = CGSizeMake(25, 25); // adjusts it's bounds so that button is always large enough
    button.GUID = identifier;
    [button addTarget:self action:@selector(linkPushed:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

-(void)meLinkedImageView:(MELinkedImageView *)messageView didTapHypermoji:(NSString*)urlString {
    __weak MEMessageView * weakSelf = self;
    if (self.delegate && [self.delegate respondsToSelector:@selector(meMessageView:didTapHypermoji:)]) {
        [self.delegate meMessageView:weakSelf didTapHypermoji:urlString];
    }
}

- (void)linkPushed:(id)sender {
    __weak MEMessageView * weakSelf = self;
    DTLinkButton * linkButton = (DTLinkButton *)sender;
    if (self.delegate && [self.delegate respondsToSelector:@selector(meMessageView:didTapHyperlink:)]) {
        [self.delegate meMessageView:weakSelf didTapHyperlink:linkButton.URL.absoluteString];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{

        NSDictionary *userInfo = @{@"url": linkButton.URL.absoluteString};
        [[NSNotificationCenter defaultCenter] postNotificationName:MEHyperlinkClicked object:weakSelf userInfo:userInfo];
    });
}

- (void)dealloc {
    if (_attributedTextContextView.delegate)
        _attributedTextContextView.delegate = nil;
    self.delegate = nil;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (!self.superview) { return; }
    self.attributedTextContextView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    self.attributedTextContextView.layoutFrame.numberOfLines = self.numberOfLines;
}

#pragma mark Properties

- (void)setHTMLString:(NSString *)html
{
    if (self.numberOfLines > 0) {
        [html stringByReplacingOccurrencesOfString:@"<br />" withString:@"<p></p>"];
    }
    
    [self setHTMLString:html options:nil];
}

- (void)setHTMLString:(NSString *)html options:(NSDictionary*) options {
    NSUInteger newHash = [html hash];

    if (newHash == _htmlHash) {
        return;
    }
    
    _htmlHash = newHash;
    
    self.htmlString = html;
    NSData *data = [html dataUsingEncoding:NSUTF8StringEncoding];
    NSAttributedString *string = [[NSAttributedString alloc] initWithHTMLData:data options:options documentAttributes:NULL];
    self.attributedString = string;
    [self setNeedsLayout];
}

- (void)setAttributedString:(NSAttributedString *)attributedString
{
    // passthrough
    self.attributedTextContextView.attributedString = attributedString;
}

- (NSAttributedString *)attributedString
{
    // passthrough
    return _attributedTextContextView.attributedString;
}

-(CGSize)intrinsicContentSize {
    return self.attributedTextContextView.intrinsicContentSize;
}

-(CGSize)suggestedFrameSizeToFitEntireStringConstraintedToWidth:(CGFloat)width {
    return [self suggestedSizeForTextForSize:CGSizeMake(width, CGFLOAT_MAX)];
}

- (DTAttributedTextContentView *)attributedTextContextView
{
    if (!_attributedTextContextView)
    {
        // don't know size jetzt because there's no string in it
        _attributedTextContextView = [[DTAttributedTextContentView alloc] initWithFrame:self.bounds];
        
        _attributedTextContextView.edgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        _attributedTextContextView.layoutOffset = CGPointMake(0, 0);
        _attributedTextContextView.shouldDrawLinks = YES;
        _attributedTextContextView.shouldDrawImages = YES;
        _attributedTextContextView.shouldLayoutCustomSubviews = YES;
        _attributedTextContextView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _attributedTextContextView.layoutFrameHeightIsConstrainedByBounds = NO;
        _attributedTextContextView.delegate = self;
        _attributedTextContextView.layoutFrame.numberOfLines = self.numberOfLines;
        _attributedTextContextView.layoutFrame.lineBreakMode = NSLineBreakByTruncatingTail;
        _attributedTextContextView.opaque = NO;
        _attributedTextContextView.backgroundColor = [UIColor clearColor];
        _attributedTextContextView.clipsToBounds = NO;
        _attributedTextContextView.translatesAutoresizingMaskIntoConstraints = YES;
        [self addSubview:_attributedTextContextView];
    }
    
    return _attributedTextContextView;
}

//needed for the menu
- (BOOL)canBecomeFirstResponder {
    return YES;
}

-(UIEdgeInsets)edgeInsets {
 return self.attributedTextContextView.edgeInsets;
}

-(void)setEdgeInsets:(UIEdgeInsets)edgeInsets {
    self.attributedTextContextView.edgeInsets = edgeInsets;
}

//what to copy
- (void)copy:(id)sender {
    if (self.htmlString){
        NSString * htmlString = [self.htmlString stringByReplacingOccurrencesOfString:@"<p dir=\"auto\" style=\"margin-bottom:16px;font-family:'.SF UI Text';font-size:16px;\">" withString:@""];
        htmlString = [htmlString stringByReplacingOccurrencesOfString:@"</p>" withString:@""];
        htmlString = [htmlString stringByReplacingOccurrencesOfString:@"color:#ffffff;" withString:@"color:#000000;"];
        NSDictionary *dict = @{(NSString *)kUTTypeText: self.attributedTextContextView.attributedString.string, (NSString *)kUTTypeHTML: htmlString};
        [[UIPasteboard generalPasteboard] setItems:@[dict]];
    } else {
        //[gpBoard setString:self.htmlString];
    }
    
}

-(UIView *)textContentView {
    return  (UIView *)self.attributedTextContextView;
}

-(CGSize)suggestedSizeForTextForSize:(CGSize)size {

    CGSize sizeForHTML = CGSizeZero;
    NSUInteger hash = [self.htmlString hash];
    NSString * cacheKey = [NSString stringWithFormat:@"%lu-%@", (unsigned long)hash, NSStringFromCGSize(size)];

    if ([self.cachedSizes objectForKey:cacheKey]) {
        NSString * size  = [self.cachedSizes objectForKey:cacheKey];
        return CGSizeFromString(size);
    }
    
    DTCoreTextLayoutFrame *tmpLayoutFrame = [self.attributedTextContextView.layouter layoutFrameWithRect:CGRectMake(0, 0, size.width, size.height) range:NSMakeRange(0, 0)];
    tmpLayoutFrame.numberOfLines = self.numberOfLines;
    tmpLayoutFrame.lineBreakMode = self.attributedTextContextView.layoutFrame.lineBreakMode;
    tmpLayoutFrame.truncationString = self.attributedTextContextView.layoutFrame.truncationString;
    
    NSArray * visibleLines = [tmpLayoutFrame lines];
    
    if (visibleLines.count > 0) {
        DTCoreTextLayoutLine * line = [visibleLines objectAtIndex:0];
        sizeForHTML = line.frame.size;
        sizeForHTML.height = 0;
        for (DTCoreTextLayoutLine * line2  in visibleLines) {
            if (sizeForHTML.width < line2.frame.size.width) {
                sizeForHTML.width = line2.frame.size.width;
            }
            sizeForHTML.height += line2.frame.size.height;
        }
    }
    
    [self.cachedSizes setObject:NSStringFromCGSize(sizeForHTML) forKey:cacheKey];
    
    return sizeForHTML;
}

//what this cell can do: only copy
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (action == @selector(cut:))
        return NO;
    else if (action == @selector(copy:))
        return YES;
    else if (action == @selector(paste:))
        return NO;
    else if (action == @selector(select:) || action == @selector(selectAll:))
        return NO;
    else return [super canPerformAction:action withSender:sender];
}

@synthesize attributedTextContextView = _attributedTextContextView;


@end
