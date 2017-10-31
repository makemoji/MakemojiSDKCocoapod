//
//  MEReactionCollectionViewCell.m
//  MakemojiSDK
//
//  Created by steve on 6/11/16.
//  Copyright © 2016 Makemoji. All rights reserved.
//

#import "MEReactionCollectionViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface MEReactionCollectionViewCell ()
    @property NSDictionary * reaction;
@end

@implementation MEReactionCollectionViewCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initializer];
    }
    return self;
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

-(void)initializer {
    self.borderColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1];
    self.highlightColor = [UIColor colorWithRed:0.28 green:0.79 blue:0.96 alpha:1];
    self.textColor = [UIColor grayColor];
    self.unicodeEmoji = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    self.unicodeEmoji.hidden = YES;
    self.unicodeEmoji.font = [UIFont systemFontOfSize:(self.contentView.frame.size.height-6)-2];
    self.unicodeEmoji.adjustsFontSizeToFitWidth = YES;
    self.unicodeEmoji.minimumScaleFactor = 0.8;
    self.unicodeEmoji.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:self.unicodeEmoji];
    
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    [self.imageView setContentMode:UIViewContentModeScaleAspectFit];
    
    self.backgroundColor = [UIColor clearColor];
    self.layer.borderWidth = 1.0;
    self.layer.borderColor = [self.borderColor CGColor];
    self.layer.cornerRadius = 5;
    [self.contentView addSubview:self.imageView];
    
    self.totalLabel = [[UILabel alloc] init];
    self.totalLabel.textColor = self.textColor;
    self.totalLabel.font = [UIFont boldSystemFontOfSize:14];
    self.totalLabel.adjustsFontSizeToFitWidth = YES;
    self.totalLabel.minimumScaleFactor = 0.7;
    self.totalLabel.hidden = YES;
    self.totalLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:self.totalLabel];
    
}


-(void)layoutSubviews {
    [super layoutSubviews];
    self.imageView.frame = CGRectMake(0, 0, self.contentView.frame.size.height-6, self.contentView.frame.size.height-6);
    self.imageView.center = self.contentView.center;
    self.unicodeEmoji.frame = CGRectMake(0, 0, self.contentView.frame.size.height-6, self.contentView.frame.size.height-6);
    self.unicodeEmoji.center = self.contentView.center;
    
    [self.totalLabel sizeToFit];
    self.totalLabel.frame = CGRectMake(self.imageView.frame.size.width+5, 0, self.contentView.frame.size.width-self.imageView.frame.size.width-7, self.contentView.frame.size.height);
    
    if (self.totalLabel.text != nil ) {
        self.imageView.frame = CGRectMake(3, 3, self.contentView.frame.size.height-6, self.contentView.frame.size.height-6);
        self.unicodeEmoji.frame = CGRectMake(3, 3, self.contentView.frame.size.height-6, self.contentView.frame.size.height-6);
    }
}

-(void)setReactionData:(NSDictionary *)reaction {
     self.reaction = reaction;

    if ([self.reaction objectForKey:@"character"] != nil) {
        self.unicodeEmoji.text = [self.reaction objectForKey:@"character"];
        self.unicodeEmoji.hidden = NO;
    } else {
       self.unicodeEmoji.hidden = YES;
    }
    
    
    if ([self.reaction objectForKey:@"image_url"] != nil) {
        [self.imageView sd_setImageWithURL:[reaction objectForKey:@"image_url"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            
         }];
    }
        
    if ([[self.reaction objectForKey:@"total"] isKindOfClass:[NSNumber class]]) {
        NSNumber * total = [self.reaction objectForKey:@"total"];
        if ([total isEqualToNumber:[NSNumber numberWithInteger:0]]) {
            self.totalLabel.text = nil;
            self.totalLabel.hidden = YES;
            self.unicodeEmoji.alpha = 0.5f;
            self.imageView.alpha = 0.5f;
        } else {
            self.totalLabel.text = [self abbreviateNumber:(int)[total integerValue]];
            self.totalLabel.hidden = NO;
            self.unicodeEmoji.alpha = 1.0f;
            self.imageView.alpha = 1;
        }
    }
    
    if ([[reaction objectForKey:@"currentUser"] isKindOfClass:[NSDictionary class]]) {
        if ([[[reaction objectForKey:@"currentUser"] objectForKey:@"emoji_id"] isEqualToNumber:[reaction objectForKey:@"emoji_id"]]) {
            self.totalLabel.textColor = self.highlightColor;
            self.layer.borderColor = [self.highlightColor CGColor];
        } else {
            self.totalLabel.textColor = self.textColor;
            self.layer.borderColor = [self.borderColor CGColor];
        }

    }
}

-(NSString *)abbreviateNumber:(int)num {
    
    NSString *abbrevNum;
    float number = (float)num;
    
    //Prevent numbers smaller than 1000 to return NULL
    if (num >= 1000) {
        NSArray *abbrev = @[@"K", @"M", @"B"];
        
        for (int i = (int)abbrev.count - 1; i >= 0; i--) {
            
            // Convert array index to "1000", "1000000", etc
            int size = pow(10,(i+1)*3);
            
            if(size <= number) {
                // Removed the round and dec to make sure small numbers are included like: 1.1K instead of 1K
                number = number/size;
                NSString *numberString = [self floatToString:number];
                
                // Add the letter for the abbreviation
                abbrevNum = [NSString stringWithFormat:@"%@%@", numberString, [abbrev objectAtIndex:i]];
            }
            
        }
    } else {
        
        // Numbers like: 999 returns 999 instead of NULL
        abbrevNum = [NSString stringWithFormat:@"%d", (int)number];
    }
    
    return abbrevNum;
}

- (NSString *) floatToString:(float) val {
    NSString *ret = [NSString stringWithFormat:@"%.1f", val];
    unichar c = [ret characterAtIndex:[ret length] - 1];
    
    while (c == 48) { // 0
        ret = [ret substringToIndex:[ret length] - 1];
        c = [ret characterAtIndex:[ret length] - 1];
        
        //After finding the "." we know that everything left is the decimal number, so get a substring excluding the "."
        if(c == 46) { // .
            ret = [ret substringToIndex:[ret length] - 1];
        }
    }
    
    return ret;
}

-(void)prepareForReuse {
    self.reaction = nil;
    self.totalLabel.hidden = YES;
    self.totalLabel.text = nil;
    self.imageView.image = nil;
    self.imageView.alpha = 1;
    self.imageView.hidden = NO;
    self.layer.borderColor = [[UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1] CGColor];
}

@end
