#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, MECellDisplay)
{
    MECellDisplayDefault = 0,
    MECellDisplayLeft, // display the bubble on the left hand side
    MECellDisplayRight // display the bubble on the right hand side
};

@interface MEChatTableViewCell : UITableViewCell

// the iMessage like bubble
@property (nonatomic) UIImageView *bubbleView;

// the tail for the bubble
@property (nonatomic) UIImageView *caretView;
@property (nonatomic) NSString *imageUrl;
@property (nonatomic) UIImageView *attachmentView;
@property (nonatomic) MECellDisplay cellDisplay;
@property (nonatomic) UIView *messageView;

// set HTML for the cell
- (void)setHTMLString:(NSString *)html;

- (CGFloat)cellMaxWidth:(CGFloat)width;
- (CGFloat)heightWithInitialSize:(CGSize)size;

// estimate the width of a cell with HTML constrained to width. includes bubble padding. yes this is misspelled but it follows the DT naming
- (CGSize)suggestedFrameSizeToFitEntireStringConstraintedToWidth:(CGFloat)width;

@end
