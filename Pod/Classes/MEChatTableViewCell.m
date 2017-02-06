
#import "MEChatTableViewCell.h"
#import "MakemojiSDK.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import "MELinkedImageView.h"
#import <DTCoreText/DTCoreText.h>

static CGFloat verticalPadding = 10.0f;
static CGFloat insidePadding = 6.0f;
static CGFloat horizontalPadding = 10.0f;
static CGFloat sideIndent = 50.0f;


@interface MEChatTableViewCell () <DTAttributedTextContentViewDelegate>
    @property (nonatomic, readonly) DTAttributedTextContentView *attributedTextContextView;
    @property NSString * htmlString;
    @property (nonatomic) NSInteger rowNumber;
    @property (nonatomic, strong) NSAttributedString *attributedString;
    - (void)setHTMLString:(NSString *)html options:(NSDictionary*) options;
@end

@implementation MEChatTableViewCell
{
    DTAttributedTextContentView *_attributedTextContextView;
    NSUInteger _htmlHash; // preserved hash to avoid relayouting for same HTML
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self)
    {
        [self initializer];
    }
    
    return self;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        [self initializer];
    }
    
    return self;
}

- (void)initializer {
    UIImageView * backingImage = [[UIImageView alloc] initWithFrame:CGRectZero];
    backingImage.layer.cornerRadius = 15.0;
    backingImage.backgroundColor = [UIColor lightGrayColor];
    backingImage.opaque = YES;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.caretView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.caretView.contentMode = UIViewContentModeScaleAspectFill;
    [self.caretView setImage:[UIImage imageNamed:@"Makemoji.bundle/MEChatBotLeft" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil]];
    [self.caretView setFrame:CGRectMake(0, 40, 22, 22)];
    
    self.bubbleView = backingImage;
    [self.bubbleView setFrame:CGRectZero];
    [self.contentView addSubview:self.bubbleView];
    [self.contentView sendSubviewToBack:self.bubbleView];
    [self.contentView addSubview:self.caretView];
    [self.contentView sendSubviewToBack:self.caretView];
    self.attachmentView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.attachmentView.hidden = YES;
    self.attachmentView.contentMode = UIViewContentModeScaleAspectFill;
    self.attachmentView.clipsToBounds = YES;
    self.attachmentView.layer.cornerRadius = 10.0;
    [self.contentView addSubview:self.attachmentView];
    self.cellDisplay = MECellDisplayDefault;
    self.rowNumber = 0;
    
    self.messageView = [[UIView alloc] initWithFrame:CGRectZero];
    self.messageView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:self.messageView];

}

- (UIEdgeInsets)layoutMargins {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
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

- (void)dealloc {
    //NSLog(@"dealloc cell");
    self.attributedTextContextView.delegate = nil;
}

-(CGFloat)cellMaxWidth:(CGFloat)width {
    width = width - sideIndent - (insidePadding*4)  - (horizontalPadding*2);
    return width;
}

-(CGFloat)heightWithInitialSize:(CGSize)size {
    CGSize newSize = CGSizeMake(size.width, size.height+(verticalPadding*2)+(insidePadding*2));
    return newSize.height;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (!self.superview)
    {
        return;
    }

    CGSize sizeForHTML = CGSizeZero;
    CGRect bounds = self.contentView.bounds;
    CGFloat maxBubbleWidth = bounds.size.width-(horizontalPadding*2)-sideIndent;
    CGFloat maxTextWidth = maxBubbleWidth - (insidePadding*4);
    CGFloat textWidth = maxTextWidth;
    CGFloat bubbleWidth = maxBubbleWidth;
    
    DTCoreTextLayoutFrame *tmpLayoutFrame = [self.attributedTextContextView.layouter layoutFrameWithRect:CGRectMake(0, 0, maxTextWidth, bounds.size.height) range:NSMakeRange(0, 0)];
    tmpLayoutFrame.numberOfLines = self.attributedTextContextView.layoutFrame.numberOfLines;
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
  
    if (sizeForHTML.width < textWidth) {
        textWidth = sizeForHTML.width;
        bubbleWidth = textWidth + (insidePadding*4);
    }
    
    CGFloat offset = 0;
    if (sizeForHTML.height < 40) {
        offset = 2;
    }
    self.bubbleView.hidden = NO;
    self.caretView.hidden = NO;
    if (self.imageUrl.length > 0) {
        sizeForHTML.height = 150;
        sizeForHTML.width = 150;
        textWidth = 150;
        bubbleWidth = textWidth + (insidePadding*4);
        self.bubbleView.hidden = YES;
        self.caretView.hidden = YES;
    }
    
    self.bubbleView.frame = CGRectMake(horizontalPadding, verticalPadding, bubbleWidth, bounds.size.height-(verticalPadding*2));
    self.bubbleView.backgroundColor = [UIColor colorWithRed:0.898 green:0.898 blue:0.917 alpha:1];
    self.messageView.frame = CGRectMake(self.bubbleView.frame.origin.x+(insidePadding*2)+offset, self.bubbleView.frame.origin.y+insidePadding+1, textWidth, sizeForHTML.height);
    self.attributedTextContextView.frame = CGRectMake(0, 0, textWidth, sizeForHTML.height);
    
    [self.caretView setImage:[UIImage imageNamed:@"Makemoji.bundle/MEChatBotLeft" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil]];
    self.caretView.frame = CGRectMake(4.5, self.bubbleView.frame.size.height-13, 22, 23);

    if (self.imageUrl.length > 0) {
        self.attachmentView.frame = CGRectMake(self.bubbleView.frame.origin.x+(insidePadding*2), self.bubbleView.frame.origin.y+insidePadding+1, self.bubbleView.frame.size.width-(insidePadding*4), self.bubbleView.frame.size.height-(insidePadding*2)-1);
        self.attachmentView.hidden = NO;
        [self.contentView bringSubviewToFront:self.attachmentView];
    } else {
        self.attachmentView.image = nil;
        self.attachmentView.hidden = YES;
    }
    
    
    if (self.cellDisplay == MECellDisplayRight) {
  
        CGFloat offset = 0;
        offset = sideIndent;
        if (bubbleWidth < maxBubbleWidth) {
            offset = (bounds.size.width - bubbleWidth) - (horizontalPadding*2);
        }
        self.messageView.frame = CGRectMake(self.messageView.frame.origin.x+offset, self.messageView.frame.origin.y, self.messageView.frame.size.width, self.messageView.frame.size.height);
        self.attributedTextContextView.frame = CGRectMake(0, 0, self.attributedTextContextView.frame.size.width, self.attributedTextContextView.frame.size.height);
        
        self.bubbleView.frame = CGRectMake(self.bubbleView.frame.origin.x+offset, self.bubbleView.frame.origin.y, self.bubbleView.frame.size.width, self.bubbleView.frame.size.height);
        self.bubbleView.backgroundColor = [UIColor colorWithRed:0.050 green:0.525 blue:0.996 alpha:1];

        [self.caretView setImage:[UIImage imageNamed:@"Makemoji.bundle/MEChatBotRight" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil]];
        self.caretView.frame = CGRectMake((self.bubbleView.frame.size.width+self.bubbleView.frame.origin.x-horizontalPadding)-6.5, self.bubbleView.frame.size.height-13, 22, 23);
        self.attachmentView.frame = CGRectMake(self.bubbleView.frame.origin.x+(insidePadding*2), self.bubbleView.frame.origin.y+insidePadding+1, self.bubbleView.frame.size.width-(insidePadding*4), self.bubbleView.frame.size.height-(insidePadding*2));
        
    }
}

#pragma mark Properties

- (void)setHTMLString:(NSString *)html
{
    [self setHTMLString:html options:nil];
}

- (void) setHTMLString:(NSString *)html options:(NSDictionary*) options {
    
    NSUInteger newHash = [html hash];
    
    if (newHash == _htmlHash) {
        return;
    }

    _htmlHash = newHash;
    
    if (self.cellDisplay == MECellDisplayRight) {
        html = [html stringByReplacingOccurrencesOfString:@"#000000" withString:@"#ffffff" options:NSCaseInsensitiveSearch | NSRegularExpressionSearch range:NSMakeRange(0, [html length])];
    }
    
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

-(CGSize)suggestedFrameSizeToFitEntireStringConstraintedToWidth:(CGFloat)width {
    return [self.attributedTextContextView suggestedFrameSizeToFitEntireStringConstraintedToWidth:width];
}

- (DTAttributedTextContentView *)attributedTextContextView
{
    if (!_attributedTextContextView)
    {
        // don't know size jetzt because there's no string in it
        _attributedTextContextView = [[DTAttributedTextContentView alloc] initWithFrame:self.contentView.bounds];
        
        _attributedTextContextView.edgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        _attributedTextContextView.layoutOffset = CGPointMake(0, 0);
        _attributedTextContextView.shouldDrawLinks = YES;
        _attributedTextContextView.layoutFrameHeightIsConstrainedByBounds = NO;
        _attributedTextContextView.delegate = self;
        _attributedTextContextView.layoutFrame.numberOfLines = 0;
        _attributedTextContextView.opaque = NO;
        _attributedTextContextView.backgroundColor = [UIColor clearColor];
        _attributedTextContextView.clipsToBounds = NO;
        [self.messageView addSubview:_attributedTextContextView];
    }
    
    return _attributedTextContextView;
}

//needed for the menu
- (BOOL)canBecomeFirstResponder {
    return YES;
}

//what to copy
- (void)copy:(id)sender {
    if(self.htmlString){
        NSString * htmlString = [self.htmlString stringByReplacingOccurrencesOfString:@"<p dir=\"auto\" style=\"margin-bottom:16px;font-family:'.SF UI Text';font-size:16px;\">" withString:@""];
        htmlString = [htmlString stringByReplacingOccurrencesOfString:@"</p>" withString:@""];
        htmlString = [htmlString stringByReplacingOccurrencesOfString:@"color:#ffffff;" withString:@"color:#000000;"];
        NSDictionary *dict = @{(NSString *)kUTTypeText: self.attributedTextContextView.attributedString.string, (NSString *)kUTTypeHTML: htmlString};
        [[UIPasteboard generalPasteboard] setItems:@[dict]];
    } else {
        //[gpBoard setString:self.htmlString];
    }
    
}

-(void)prepareForReuse {
    [super prepareForReuse];
    _htmlHash = 0;
    self.attributedString = nil;
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
