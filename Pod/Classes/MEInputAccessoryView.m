//
//  MEInputAccessoryView.m
//  Makemoji
//
//  Created by steve on 1/8/15.
//  Copyright (c) 2015 Makemoji. All rights reserved.
//

#import "MEInputAccessoryView.h"
#import "DTRichTextEditor.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "NSString+MEUtilities.h"
#import "MEKeyboardCollectionViewCell.h"
#import "MEFlashTagCollectionViewCell.h"
#import "MEAPIManager.h"
#import "MEFlashTagNativeCollectionViewCell.h"


@interface MEInputAccessoryView () <UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, weak) DTRichTextEditorView *currentView;
@property (nonatomic) NSMutableArray *flashTags;
@property (nonatomic) NSMutableString *plainText;
@property (nonatomic) NSMutableArray *usedFlashtags;
@property (nonatomic) NSMutableArray *lastFlashTag;
@property (nonatomic) BOOL hasShuffled;
@property NSString *currentFlashtagSearch;
@property BOOL flashtagDetected;
@property UITextRange *flashStartRange;
@property (nonatomic) UIView *containerView;
@property UIView *leftBackgroundView;
@property NSMutableArray *emoji;
@property NSMutableArray *trendingEmoji;
@property NSTimer *deleteTimer;
@property CGFloat expandedHeight;
@property CGFloat collapsedHeight;
@property BOOL expanded;
@property UIColor *highlightColor;
@property CGFloat leftSideWidth;
@property NSURLSessionDataTask *emojiWallTask;
@property (nonatomic) UITextAutocorrectionType previousAutocorrectionType;
@end

@implementation MEInputAccessoryView

@synthesize disableNavigation = _disableNavigation, disableSearch = _disableSearch;

- (id)init {
    return [self initWithFrame:CGRectZero];
}

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        self.expandedHeight = 46;
        self.collapsedHeight = 46;
        self.leftSideWidth = 44;
        self.expanded = NO;
        self.flashtagOnly = NO;
        self.currentToggle = @"";
        self.flashtagDetected = NO;
        self.disableNavigation = NO;
        self.disableSearch = NO;
        self.flashTags = [NSMutableArray array];
        self.highlightColor = [UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1];
        self.clipsToBounds = YES;

        CGFloat inputHeight = 216;
        CGFloat collectionHeight = 180;
        if ([[UIScreen mainScreen] bounds].size.height >= 736.0) {
            inputHeight = 226;
            collectionHeight = 190;
        }
        
        
        self.meInputView = [[MEInputView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, inputHeight)];
        self.meInputView.delegate = self;
 
        
        [self setBackgroundColor:[UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1]];
        self.translatesAutoresizingMaskIntoConstraints = YES;
        [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        
        self.containerView = [[UIView alloc] initWithFrame:CGRectMake(-98, 0, 159, self.collapsedHeight)];
        self.containerView.translatesAutoresizingMaskIntoConstraints = YES;
        self.containerView.backgroundColor = [UIColor colorWithRed:0.86 green:0.86 blue:0.86 alpha:1.0];
        [self.containerView setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleWidth];
        
        
        CAGradientLayer *gradient = [CAGradientLayer layer];
        [gradient setName:@"grad"];
        gradient.frame = self.containerView.bounds;
        gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1] CGColor], (id)[[UIColor colorWithRed:0.86 green:0.86 blue:0.86 alpha:1.0] CGColor], nil];
        [self.containerView.layer insertSublayer:gradient atIndex:0];
        
        CALayer * lineLayer = [CALayer layer];
        [lineLayer setName:@"line"];
        lineLayer.frame = CGRectMake(158, 0, 1, self.collapsedHeight);
        lineLayer.backgroundColor = [[UIColor colorWithRed:0.86 green:0.86 blue:0.86 alpha:1.0] CGColor];
        [self.containerView.layer addSublayer:lineLayer];
        
        
        self.leftBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(self.containerView.frame.origin.x-200, 0, 200, self.collapsedHeight)];
        self.leftBackgroundView.backgroundColor = [UIColor colorWithRed:0.86 green:0.86 blue:0.86 alpha:1.0];
        CAGradientLayer * gradient2 = [CAGradientLayer layer];
        [gradient2 setName:@"grad2"];
        gradient2.frame = self.leftBackgroundView.bounds;
        gradient2.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1] CGColor], (id)[[UIColor colorWithRed:0.86 green:0.86 blue:0.86 alpha:1.0] CGColor], nil];
        [self.leftBackgroundView.layer insertSublayer:gradient2 atIndex:0];
        
        [self.leftBackgroundView setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleWidth];
        
        
        self.flashtagButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.flashtagButton setImage:[UIImage imageNamed:@"MESearchIcon"] forState:UIControlStateNormal];
        self.flashtagButton.accessibilityLabel = @"Search";
        [self.flashtagButton setTintColor:[UIColor darkGrayColor]];
        [self.flashtagButton setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin];
        [self.flashtagButton setFrame:CGRectMake(120, 0, 39, self.collapsedHeight)];
        [self.flashtagButton addTarget:self action:@selector(flashtagTapped) forControlEvents:UIControlEventTouchUpInside];
        self.flashtagButton.contentEdgeInsets = UIEdgeInsetsMake(12.5, 7.5, 12.5, 7.5);
        
        
        self.favoriteButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.favoriteButton setImage:[UIImage imageNamed:@"MERecent"] forState:UIControlStateNormal];
        self.favoriteButton.accessibilityLabel = @"Recent";
        [self.favoriteButton setTintColor:[UIColor darkGrayColor]];
        [self.favoriteButton setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin];
        [self.favoriteButton setFrame:CGRectMake(80, 0, 39, self.collapsedHeight)];
        //[self.favoriteButton addSubview:[self borderView]];
        self.favoriteButton.contentEdgeInsets = UIEdgeInsetsMake(12.5, 7.5, 12.5, 7.5);
        [self.favoriteButton addTarget:self action:@selector(favoriteTapped) forControlEvents:UIControlEventTouchUpInside];
        
        
        self.trendingButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.trendingButton setImage:[UIImage imageNamed:@"METrendingIcon"] forState:UIControlStateNormal];
        self.trendingButton.accessibilityLabel = @"Trending";
        [self.trendingButton setTintColor:[UIColor darkGrayColor]];
        [self.trendingButton setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin];
        [self.trendingButton setFrame:CGRectMake(40, 0, 39, self.collapsedHeight)];
        //[self.trendingButton addSubview:[self borderView]];
        self.trendingButton.contentEdgeInsets = UIEdgeInsetsMake(12.5, 7.5, 12.5, 7.5);
        [self.trendingButton addTarget:self action:@selector(trendingTapped) forControlEvents:UIControlEventTouchUpInside];
        
        self.gridButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.gridButton setImage:[UIImage imageNamed:@"MEGridIcon"] forState:UIControlStateNormal];
        self.gridButton.accessibilityLabel = @"Categories";
        [self.gridButton setTintColor:[UIColor darkGrayColor]];
        //[self.gridButton setBackgroundColor:[UIColor redColor]];
        [self.gridButton setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin];
        [self.gridButton setFrame:CGRectMake(0, 0, 39, self.collapsedHeight)];
        [self.gridButton addTarget:self action:@selector(categoryTapped) forControlEvents:UIControlEventTouchUpInside];
        //[self.gridButton addSubview:[self borderView]];
        self.gridButton.contentEdgeInsets = UIEdgeInsetsMake(12.5, 7.5, 12.5, 7.5);
        
        self.plainText = [[NSMutableString alloc] initWithString:@""];
        self.usedFlashtags = [NSMutableArray array];
        
        [self.containerView addSubview:self.flashtagButton];
        [self.containerView addSubview:self.favoriteButton];
        [self.containerView addSubview:self.trendingButton];
        [self.containerView addSubview:self.gridButton];

        UIPanGestureRecognizer * swipeGestureRight = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipeNav:)];
        [self.containerView addGestureRecognizer:swipeGestureRight];
        
        [self addSubview:self.leftBackgroundView];
        
        self.backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.backButton setImage:[UIImage imageNamed:@"MEBackIcon"] forState:UIControlStateNormal];
        [self.backButton setFrame:CGRectMake(10, 0, 20, 45)];
        [self.backButton setAlpha:0.0];
        [self.backButton addTarget:self action:@selector(backButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.backButton];
        CGPoint newCenter = self.center;
        newCenter.y = 0;
        self.containerView.center = newCenter;
        [self addSubview:self.containerView];
        
        [self.containerView bringSubviewToFront:self.gridButton];
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(14, 25, frame.size.width, 19)];
        self.titleLabel.textAlignment = NSTextAlignmentLeft;
        self.titleLabel.font = [UIFont boldSystemFontOfSize:13];
        [self.titleLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        self.titleLabel.text = @"Trending";
        self.titleLabel.alpha = 0;
        self.titleLabel.textColor = [UIColor colorWithWhite:0.65 alpha:1];
        
        [self addSubview:self.titleLabel];
        
        
        UICollectionViewFlowLayout * newLayout3 = [[UICollectionViewFlowLayout alloc] init];
        newLayout3.itemSize = CGSizeMake((frame.size.width/3),34);
        
        [newLayout3 setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        newLayout3.minimumInteritemSpacing = 2;
        newLayout3.minimumLineSpacing = 2;
        self.flashtagCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, self.leftSideWidth, frame.size.width-self.leftSideWidth, self.collapsedHeight) collectionViewLayout:newLayout3];
        [self.flashtagCollectionView setBackgroundColor:[UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1]];
        self.flashtagCollectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        [self.flashtagCollectionView setShowsHorizontalScrollIndicator:NO];
        [self.flashtagCollectionView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
        [self.flashtagCollectionView registerClass:[MEFlashTagCollectionViewCell class] forCellWithReuseIdentifier:@"Flashtag"];
        [self.flashtagCollectionView registerClass:[MEFlashTagNativeCollectionViewCell class] forCellWithReuseIdentifier:@"Native"];
        //[self.flashtagCollectionView registerClass:[MEPhraseCollectionViewCell class] forCellWithReuseIdentifier:@"Phrase"];
        
        [self.flashtagCollectionView setBackgroundColor:[UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1.0]];
        self.flashtagCollectionView.allowsMultipleSelection = NO;
        self.flashtagCollectionView.pagingEnabled = YES;
        [self.flashtagCollectionView setDelegate:self];
        
        self.flashtagCollectionView.dataSource = self;
        [self addSubview:self.flashtagCollectionView];
        [self bringSubviewToFront:self.flashtagCollectionView];
        self.flashtagCollectionView.hidden = YES;
        
        
        UICollectionViewFlowLayout * newLayout2 = [[UICollectionViewFlowLayout alloc] init];
        CGFloat modifier = 8;
        if (self.frame.size.width <= 320) {
            modifier = 7;
        }
        newLayout2.itemSize = CGSizeMake((frame.size.width/modifier),34);
        
        [newLayout2 setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        newLayout2.minimumInteritemSpacing = 0;
        newLayout2.minimumLineSpacing = 0;
        self.emojiView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, self.leftSideWidth, frame.size.width-self.leftSideWidth, self.collapsedHeight) collectionViewLayout:newLayout2];
        [self.emojiView setBackgroundColor:[UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1]];
        
        
        self.emojiView.contentInset = UIEdgeInsetsMake(4, 0, 0, 0);
        [self.emojiView setShowsHorizontalScrollIndicator:NO];
        self.emojiView.allowsMultipleSelection = NO;
        [self.emojiView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
        [self.emojiView registerClass:[MEKeyboardCollectionViewCell class] forCellWithReuseIdentifier:@"Emoji"];
        [self.emojiView setBackgroundColor:[UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1.0]];
        self.emojiView.pagingEnabled = NO;
        [self.emojiView setDelegate:self];
        
        self.emojiView.dataSource = self;
        [self addSubview:self.emojiView];
        [self bringSubviewToFront:self.emojiView];
        
        UIPanGestureRecognizer * swipeGestureRight2 = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipeNav:)];
        //swipeGestureRight.direction = UISwipeGestureRecognizerDirectionRight;
        swipeGestureRight2.delegate = self;
        [self.emojiView addGestureRecognizer:swipeGestureRight2];
        
        if (self.flashtagOnly == YES) {
            self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, 0);
        }
        
        self.emojiView.frame = CGRectMake(68, 0, self.frame.size.width-self.leftSideWidth, self.containerView.frame.size.height);
        self.flashtagCollectionView.frame = CGRectMake(68, 0, self.frame.size.width-self.leftSideWidth, self.containerView.frame.size.height);
        self.containerView.frame = CGRectMake(-96, 0, 159, self.containerView.frame.size.height);
        
    }
    return self;
}

-(void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    if (self.trendingEmoji.count == 0) {
        [self loadData];
    }
}

-(void)loadData {
    NSString * url = [NSString stringWithFormat:@"emoji/emojiWall?channel=%@", [MEAPIManager client].channel];
    if (self.emojiWallTask) { [self.emojiWallTask cancel]; }
    
    self.trendingEmoji = [NSMutableArray array];
    __weak MEInputAccessoryView * weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.emojiView reloadData];
    });
    
    [self loadFromDisk:[[MEAPIManager client] cacheNameWithChannel:@"wall"]];
    
    MEAPIManager * manager = [MEAPIManager client];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    self.emojiWallTask = [manager GET:url parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {

        NSError * error;
        NSData * jsonData = [NSJSONSerialization dataWithJSONObject:responseObject options:kNilOptions error:&error];
        NSString *path = [[self applicationDocumentsDirectory].path
                          stringByAppendingPathComponent:[[MEAPIManager client] cacheNameWithChannel:@"wall"]];
        [[NSFileManager defaultManager] createFileAtPath:path
                                                contents:jsonData
                                              attributes:nil];
        
        if ([responseObject objectForKey:@"Trending"] && [[responseObject objectForKey:@"Trending"] count] > 0) {

            self.trendingEmoji = [responseObject objectForKey:@"Trending"];
            __weak MEInputAccessoryView * weakSelf = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.emojiView reloadData];
                //NSLog(@"loaded trending");
            });
        }
        
        NSArray * allKeys = [responseObject allKeys];
        for (NSString * cat in allKeys) {
            if (![cat isEqualToString:@"Trending"] && ![cat isEqualToString:@"Used"]) {
                NSArray * catArr = [responseObject objectForKey:cat];
                for (NSDictionary * catDict in catArr) {
                    [self.flashTags addObject:catDict];
                }
            }
        }
        
        [self.meInputView loadData];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        //NSLog(@"Error: %@", error);
    }];
    

    
}

-(CGSize)intrinsicContentSize {
    CGFloat inputHeight = 216;
    CGFloat collectionHeight = 180;
    if ([[UIScreen mainScreen] bounds].size.height >= 736.0) {
        inputHeight = 226;
        collectionHeight = 190;
    }
    return CGSizeMake([[UIScreen mainScreen] bounds].size.width, inputHeight);
}


-(void)setNavigationBackgroundColor:(UIColor *)color {
    self.leftBackgroundView.backgroundColor = color;
    self.containerView.backgroundColor = color;
    self.leftBackgroundView.layer.sublayers = nil;
    for (CALayer * layer in [self.containerView.layer sublayers]) {
        if ([layer.name isEqualToString:@"grad"]) {
            [layer setHidden:YES];
        } else if ([layer.name isEqualToString:@"line"]) {
            [layer setHidden:YES];
        }
    }
    for (CALayer * layer in [self.leftBackgroundView.layer sublayers]) {
        if ([layer.name isEqualToString:@"grad2"]) {
            [layer setHidden:YES];
        }
    }
    
}


-(void)setDisableNavigation:(BOOL)disableNavigation {
    _disableNavigation = disableNavigation;
}

-(BOOL)disableNavigation {
    return _disableNavigation;
}



-(void)setDisableSearch:(BOOL)disableSearch {
    _disableSearch = disableSearch;
    if (disableSearch == YES) {
        self.disableNavigation = YES;
        self.leftBackgroundView.layer.sublayers = nil;
        self.leftBackgroundView.backgroundColor = self.emojiView.backgroundColor;
        self.containerView.backgroundColor = self.emojiView.backgroundColor;
        for (CALayer * layer in [self.containerView.layer sublayers]) {
            if ([layer.name isEqualToString:@"grad"]) {
                [layer setHidden:YES];
            } else if ([layer.name isEqualToString:@"line"]) {
                [layer setHidden:YES];
            }
        }
        
        for (CALayer * layer in [self.leftBackgroundView.layer sublayers]) {
            if ([layer.name isEqualToString:@"grad2"]) {
                [layer setHidden:YES];
            }
        }
        
        [self.flashtagButton setImage:nil forState:UIControlStateNormal];
        self.leftSideWidth = 0;
    } else {
        self.leftSideWidth = 44;
    }
}

-(BOOL)disableSearch {
    return _disableSearch;
}


-(void)setNavigationHighlightColor:(UIColor *)color {
    self.highlightColor = color;
}


-(void)fastCollapseAnimation {
    if (self.flashtagOnly == YES || self.disableNavigation == YES) {
        return;
    }
    self.emojiView.scrollEnabled = YES;
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:5 options:UIViewAnimationOptionCurveEaseInOut animations:^ {
        self.containerView.frame = CGRectMake(-118, 0, 159, self.containerView.frame.size.height);
        for (CALayer * layer in [self.containerView.layer sublayers]) {
            if ([layer.name isEqualToString:@"grad"]) {
                layer.frame = self.containerView.bounds;
            } else if ([layer.name isEqualToString:@"line"]) {
                layer.frame = CGRectMake(158, 0, 1, self.collapsedHeight);
            }
        }
        self.currentToggle = @"";
        
        [self.favoriteButton setBackgroundColor:[UIColor clearColor]];
        [self.trendingButton setBackgroundColor:[UIColor clearColor]];
        [self.flashtagButton setBackgroundColor:[UIColor clearColor]];
        [self.gridButton setBackgroundColor:[UIColor clearColor]];
        self.backButton.alpha = 0;
        [CATransaction begin];
        [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
        [self.currentView setInputView:nil animated:NO];
        [CATransaction commit];
        [self.currentView reloadInputViews];
        self.leftBackgroundView.frame = CGRectMake(self.containerView.frame.origin.x-200, 0, 200, self.collapsedHeight);
        self.emojiView.frame = CGRectMake(self.leftSideWidth, 0, self.frame.size.width-self.leftSideWidth, self.collapsedHeight);
        self.flashtagCollectionView.frame = CGRectMake(self.leftSideWidth, 0, self.frame.size.width-self.leftSideWidth, self.collapsedHeight);
    } completion:^(BOOL finished) {
        
    }];
}

-(void)expandAnimation {
    if (self.flashtagOnly == YES || self.disableNavigation == YES) { return; }
    if (self.containerView.frame.origin.x != (self.frame.size.width/2)-(159/2)) {
        
        self.leftBackgroundView.frame = CGRectMake(self.containerView.frame.origin.x-200, 0, 200, self.collapsedHeight);
        self.emojiView.bounces = NO;
        [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:5 options:UIViewAnimationOptionCurveEaseInOut animations:^ {
            
            self.containerView.frame = CGRectMake((self.frame.size.width/2)-(159/2), 0, 219, self.containerView.frame.size.height);
            for (CALayer * layer in [self.containerView.layer sublayers]) {
                if ([layer.name isEqualToString:@"grad"]) {
                    layer.frame = self.containerView.bounds;
                } else if ([layer.name isEqualToString:@"line"]) {
                    layer.frame = CGRectMake(218, 0, 1, self.collapsedHeight);
                }
            }
            
            self.leftBackgroundView.frame = CGRectMake(self.containerView.frame.origin.x-200, 0, 200, self.collapsedHeight);
            //self.containerView.center = self.center;
            self.emojiView.frame = CGRectMake(self.containerView.frame.size.width+self.containerView.frame.origin.x, 0, self.frame.size.width, self.collapsedHeight);
            self.flashtagCollectionView.frame = CGRectMake(self.containerView.frame.size.width+self.containerView.frame.origin.x, 0, self.frame.size.width, self.collapsedHeight);
        } completion:^(BOOL finished) {
            self.emojiView.bounces = YES;
        }];
    }
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //    NSLog(@"%@", NSStringFromCGPoint(scrollView.contentOffset));
    //
    //    if (scrollView.contentOffset.x < -10 && self.expanded == NO) {
    //        //[self didSwipeNav:nil];
    //        return;
    //    }
    //
    //    if (self.expanded == YES && scrollView.contentOffset.x > 0) {
    //        self.expanded = NO;
    //        [self fastCollapseAnimation];
    //    }
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

-(void)didSwipeNav:(UIPanGestureRecognizer*)gestureRecognizer; {
    if (self.flashtagOnly == YES || self.disableNavigation == YES) { return; }
    
    CGPoint translation = [gestureRecognizer translationInView:self];
    CGFloat velocityX = [gestureRecognizer velocityInView:self].x;
    CGFloat startingPoint = -118;
    CGFloat maxX = (self.frame.size.width/2)-(159/2);
    
    CGFloat newX = startingPoint + translation.x;
    if (translation.x < 0) { newX = maxX + translation.x; }
    
    CGFloat startingWidth = 159;
    CGFloat endingWidth = 219;
    CGFloat currentWidth = endingWidth;
    CGFloat rangePercentage = (newX - startingPoint) / (maxX - startingPoint);
    
    currentWidth = startingWidth + ((endingWidth - startingWidth) * rangePercentage);
    
    if (gestureRecognizer.view == self.emojiView && translation.x < 0 ) {
        return;
    }
    
    if (gestureRecognizer.view == self.emojiView && self.emojiView.contentOffset.x > 0) {
        return;
    }
    self.emojiView.scrollEnabled = NO;
    
    if (translation.x > 0 && velocityX > 1000) {
        [self expandAnimation];
        return;
    }
    
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        if (rangePercentage > 0.33 && translation.x > 0) {
            [self expandAnimation];
            return;
        } else {
            [self fastCollapseAnimation];
            return;
        }
    }
    
    if (newX > maxX) {
        newX = maxX;
        currentWidth = endingWidth;
    }
    
    if (newX < startingPoint) {
        newX = startingPoint;
        currentWidth = startingWidth;
    }
    
    self.containerView.frame = CGRectMake(newX, 0, currentWidth, self.containerView.frame.size.height);
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    for (CALayer * layer in [self.containerView.layer sublayers]) {
        if ([layer.name isEqualToString:@"grad"]) {
            layer.frame = self.containerView.bounds;
        } else if ([layer.name isEqualToString:@"line"]) {
            layer.frame = CGRectMake(self.containerView.frame.size.width-1, 0, 1, self.collapsedHeight);
        }
    }
    [CATransaction commit];
    
    self.leftBackgroundView.frame = CGRectMake(self.containerView.frame.origin.x-200, 0, 200, self.collapsedHeight);
    self.emojiView.frame = CGRectMake(self.containerView.frame.size.width+self.containerView.frame.origin.x, 0, self.frame.size.width, self.collapsedHeight);
    self.flashtagCollectionView.frame = CGRectMake(self.containerView.frame.size.width+self.containerView.frame.origin.x, 0, self.frame.size.width, self.collapsedHeight);
    
}

-(void)setTextView:(id)textView {
    self.currentView = (DTRichTextEditorView *)textView;
}

- (void)meInputView:(MEInputView *)inputView globeButtonTapped:(UIButton *)globeButton {
    [self globeButtonTapped];
}

- (void)meInputView:(MEInputView *)inputView deleteButtonRelease:(UIButton *)deleteButton {
    [self deleteButtonRelease];
}

- (void)meInputView:(MEInputView *)inputView deleteButtonTapped:(UIButton *)deleteButton {
    [self deleteButtonTapped];
}

- (void)meInputView:(MEInputView *)inputView didSelectCategory:(NSString *)category {
    [self didSelectCategory];
}

- (void)meInputView:(MEInputView *)inputView didSelectEmoji:(NSDictionary *)emoji image:(UIImage *)image {
    [self didSelectEmoji:emoji image:image];
}

-(void)deleteButtonTapped {
    [self.currentView deleteBackward];
    self.deleteTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(deleteRepeat) userInfo:nil repeats:YES];
}

-(void)deleteButtonRelease {
    [self.deleteTimer invalidate];
    self.deleteTimer = nil;
}

-(void)deleteRepeat {
    [self.currentView deleteBackward];
}

-(void)dealloc {
    [self.emojiWallTask cancel];
    self.emojiWallTask = nil;
    self.meInputView = nil;
    self.emojiView.delegate = nil;
    self.flashtagCollectionView.delegate = nil;
}

-(void)resetFlashtags {
    self.currentToggle = @"";
    self.flashtagDetected = NO;
    self.flashStartRange = nil;
    [self.flashtagButton setBackgroundColor:[UIColor clearColor]];
    self.lastFlashTag = [NSMutableArray array];
}

-(void)globeButtonTapped {
    self.currentToggle = @"";
    [self.favoriteButton setBackgroundColor:[UIColor clearColor]];
    [self.trendingButton setBackgroundColor:[UIColor clearColor]];
    [self.flashtagButton setBackgroundColor:[UIColor clearColor]];
    [self.gridButton setBackgroundColor:[UIColor clearColor]];
    self.backButton.alpha = 0;
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.expandedHeight);
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    [self.currentView setInputView:nil animated:NO];
    [CATransaction commit];
    [self.currentView reloadInputViews];
}



-(void)backButtonTapped {
    if ([self.currentToggle isEqualToString:@"category"]) {
        [self.meInputView goBack];
    }
    
    __weak MEInputAccessoryView * weakSelf = self;
    [UIView animateWithDuration:0.20 animations:^{
        weakSelf.backButton.alpha = 0;
    }];
}

-(UIView *)borderView {
    UIView * borderView = [[UIView alloc] initWithFrame:CGRectMake(self.flashtagButton.frame.size.width, 0, 1, self.flashtagButton.frame.size.height)];
    [borderView setBackgroundColor:[UIColor colorWithRed:0.67 green:0.69 blue:0.71 alpha:1.0]];
    return borderView;
}

-(void)didSelectCategory {
    __weak MEInputAccessoryView * weakSelf = self;
    [UIView animateWithDuration:0.20 animations:^{
        weakSelf.backButton.alpha = 1;
    }];
}

-(void)didSelectGif:(NSDictionary *)gif {
   
    NSString * link = @"";
    link = @"";
    if ([gif objectForKey:@"link_url"] != [NSNull null]) {
        link = [gif objectForKey:@"link_url"];
    }
    
    NSDictionary * attributes = @{@"src" : [gif objectForKey:@"40x40_url"],
                                  @"width" : [NSString stringWithFormat:@"%f", self.currentView.maxImageDisplaySize.width],
                                  @"height" : [NSString stringWithFormat:@"%f", self.currentView.maxImageDisplaySize.height],
                                  @"id" : [[gif objectForKey:@"id"] stringValue],
                                  @"name" : @"gif", @"link" : link
                                  };

    
    DTHTMLElement * newElement = [[DTHTMLElement alloc] initWithName:@"img" attributes:attributes];
    DTImageTextAttachment * imageAttachment = [[DTImageTextAttachment alloc] initWithElement:newElement options:nil];
    imageAttachment.verticalAlignment = DTTextAttachmentVerticalAlignmentCenter;
    [self.currentView replaceRange:self.currentView.selectedTextRange withAttachment:imageAttachment inParagraph:NO];

    if ([self.currentView.editorViewDelegate respondsToSelector:@selector(editorViewDidChange:)]) {
        [self.currentView.editorViewDelegate  editorViewDidChange:self.currentView];
    }
    
    if (self.currentView.isFirstResponder == NO) {
        if ([self.currentView.editorViewDelegate respondsToSelector:@selector(editorViewDidChangeSelection:)]) {
            [self.currentView becomeFirstResponder];
        }
    }
    
    MEAPIManager *manager = [MEAPIManager client];
    [manager clickWithEmoji:gif];

    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *userInfo = @{@"url": [gif objectForKey:@"image_url"]};
        [[NSNotificationCenter defaultCenter] postNotificationName:@"METextInputGIFInserted" object:self userInfo:userInfo];
    });
    
}

-(void)didSelectEmoji:(NSDictionary *)emoji image:(UIImage *)image {
    self.flashtagDetected = NO;
    self.flashStartRange = nil;
    
    if ([emoji objectForKey:@"gif"] != nil && [[emoji objectForKey:@"gif"] integerValue] == 1) {
        [self didSelectGif:emoji];
        return;
    }
    
    MEAPIManager *manager = [MEAPIManager client];
    [manager clickWithEmoji:emoji];
    
    NSString * link = @"";
    if ([emoji objectForKey:@"link_url"] != [NSNull null]) {
        link = [emoji objectForKey:@"link_url"];
    }
    
    NSString * flashtag = @"";
    if ([emoji objectForKey:@"flashtag"] != [NSNull null]) {
        flashtag = [emoji objectForKey:@"flashtag"];
    }
    
    NSString * imageUrl = [emoji objectForKey:@"image_url"];
    NSNumber * isPhrase = [emoji objectForKey:@"phrase"];
    
    if (isPhrase != nil) {
        NSString * link;
        NSUInteger sint = 0;
        for (NSDictionary * emdict in [emoji objectForKey:@"emoji"]) {
            
            NSNumber * native = [emdict objectForKey:@"native"];
            
            if (native == nil) {
                
                link = @"";
                if ([emdict objectForKey:@"link_url"] != [NSNull null]) {
                    link = [emdict objectForKey:@"link_url"];
                }
                
                NSDictionary * attributes = @{@"src" : [emdict objectForKey:@"image_url"], @"width" : [NSString stringWithFormat:@"%f", self.currentView.maxImageDisplaySize.width], @"height" : [NSString stringWithFormat:@"%f", self.currentView.maxImageDisplaySize.height], @"link" : link, @"id" : [[emdict objectForKey:@"id"] stringValue]};
                
                DTHTMLElement * newElement = [[DTHTMLElement alloc] initWithName:@"img" attributes:attributes];
                DTImageTextAttachment * imageAttachment = [[DTImageTextAttachment alloc] initWithElement:newElement options:nil];
                UIImage * tmpImage = [UIImage imageWithCGImage:[[UIImage imageNamed:@"MEPlaceholder"] CGImage] scale:2.0 orientation:UIImageOrientationUp];
                imageAttachment.image = tmpImage;
                imageAttachment.verticalAlignment = DTTextAttachmentVerticalAlignmentCenter;
                
                if (sint == 0) {
                    [self.currentView replaceRange:self.currentView.selectedTextRange withAttachment:imageAttachment inParagraph:NO];
                } else {
                    [self.currentView replaceRange:self.currentView.selectedTextRange withAttachment:imageAttachment inParagraph:NO];
                }
            } else {
                if (sint == 0) {
                    [self.currentView replaceRange:self.currentView.selectedTextRange withText:[emdict objectForKey:@"character"]];
                } else {
                    [self.currentView replaceRange:self.currentView.selectedTextRange withText:[emdict objectForKey:@"character"]];
                }
            }
            sint++;
            
        }
        return;
    }
    
    NSDictionary * attributes = @{@"src" : [emoji objectForKey:@"image_url"],
                                  @"link" : link,
                                  @"name" : flashtag,
                                  @"width" : [NSString stringWithFormat:@"%f", self.currentView.maxImageDisplaySize.width],
                                  @"height" : [NSString stringWithFormat:@"%f", self.currentView.maxImageDisplaySize.height],
                                  @"id" : [[emoji objectForKey:@"id"] stringValue]
                                  };
    
    DTHTMLElement * newElement = [[DTHTMLElement alloc] initWithName:@"img" attributes:attributes];
    DTImageTextAttachment * imageAttachment = [[DTImageTextAttachment alloc] initWithElement:newElement options:nil];
    UIImage * tmpImage = [UIImage imageWithCGImage:[image CGImage] scale:2.0 orientation:UIImageOrientationUp];
    
    
    imageAttachment.image = tmpImage;
    
    imageAttachment.verticalAlignment = DTTextAttachmentVerticalAlignmentCenter;
    [self.currentView replaceRange:self.currentView.selectedTextRange withAttachment:imageAttachment inParagraph:NO];
    
    if ([self.currentView.editorViewDelegate respondsToSelector:@selector(editorViewDidChange:)]) {
        [self.currentView.editorViewDelegate  editorViewDidChange:self.currentView];
    }
    
    if (self.currentView.isFirstResponder == NO) {
        if ([self.currentView.editorViewDelegate respondsToSelector:@selector(editorViewDidChangeSelection:)]) {
            [self.currentView becomeFirstResponder];
        }
    }
}

-(void)categoryTapped {
    if (!self.currentView.isFirstResponder) { [self.currentView becomeFirstResponder]; }
    
    if (![self.currentToggle isEqualToString:@"category"]) {
        //self.currentView.inputView = nil;
        self.currentToggle = @"category";
        self.titleLabel.hidden = YES;
        self.flashtagCollectionView.hidden = YES;
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
        [self.meInputView selectSection:self.currentToggle];
        [CATransaction begin];
        [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
        [self.currentView setInputView:self.meInputView animated:NO];
        [CATransaction commit];
        [self.currentView reloadInputViews];
        [self.gridButton setBackgroundColor:self.highlightColor];
        [self.favoriteButton setBackgroundColor:[UIColor clearColor]];
        [self.trendingButton setBackgroundColor:[UIColor clearColor]];
        [self.flashtagButton setBackgroundColor:[UIColor clearColor]];
        if (self.meInputView.selectedCategory != nil) {
            self.backButton.alpha = 1;
            self.meInputView.titleLabel.hidden = NO;
        }
    } else {
        self.currentToggle = @"";
        self.titleLabel.hidden = NO;
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
        [CATransaction begin];
        [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
        [self.currentView setInputView:nil animated:NO];
        [CATransaction commit];
        [self.currentView reloadInputViews];
        [self.gridButton setBackgroundColor:[UIColor clearColor]];
        __weak MEInputAccessoryView * weakSelf = self;
        [UIView animateWithDuration:0.20 animations:^{
            weakSelf.backButton.alpha = 0;
        }];
    }
}

-(void)trendingTapped {
    if (!self.currentView.isFirstResponder) { [self.currentView becomeFirstResponder]; }
    if (![self.currentToggle isEqualToString:@"trending"]) {
        //self.currentView.inputView = nil;
        self.currentToggle = @"trending";
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
        self.titleLabel.hidden = YES;
        self.flashtagCollectionView.hidden = YES;
        [self.meInputView selectSection:self.currentToggle];
        [CATransaction begin];
        [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
        [self.currentView setInputView:self.meInputView animated:NO];
        [CATransaction commit];
        [self.currentView reloadInputViews];
        [self.trendingButton setBackgroundColor:self.highlightColor];
        [self.favoriteButton setBackgroundColor:[UIColor clearColor]];
        [self.gridButton setBackgroundColor:[UIColor clearColor]];
        [self.flashtagButton setBackgroundColor:[UIColor clearColor]];
        [UIView animateWithDuration:0.20 animations:^{
            self.backButton.alpha = 0;
        }];
    } else {
        self.titleLabel.hidden = NO;
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
        self.currentToggle = @"";
        [CATransaction begin];
        [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
        [self.currentView setInputView:nil animated:NO];
        [CATransaction commit];
        [self.currentView reloadInputViews];
        [self.trendingButton setBackgroundColor:[UIColor clearColor]];
    }
}

-(void)favoriteTapped {
    if (!self.currentView.isFirstResponder) { [self.currentView becomeFirstResponder]; }
    if (![self.currentToggle isEqualToString:@"favorite"]) {
        self.currentToggle = @"favorite";
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
        self.titleLabel.hidden = YES;
        self.flashtagCollectionView.hidden = YES;
        [self.meInputView selectSection:self.currentToggle];
        [self.currentView setInputView:self.meInputView animated:NO];
        [self.currentView reloadInputViews];
        [self.favoriteButton setBackgroundColor:self.highlightColor];
        [self.gridButton setBackgroundColor:[UIColor clearColor]];
        [self.trendingButton setBackgroundColor:[UIColor clearColor]];
        [self.flashtagButton setBackgroundColor:[UIColor clearColor]];
        [UIView animateWithDuration:0.20 animations:^{
            self.backButton.alpha = 0;
        }];
    } else {
        self.currentToggle = @"";
        self.titleLabel.hidden = NO;        
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
        [CATransaction begin];
        [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
        [self.currentView setInputView:nil animated:NO];
        [CATransaction commit];
        [self.currentView reloadInputViews];
        [self.favoriteButton setBackgroundColor:[UIColor clearColor]];
    }
}

-(void)flashtagTapped {
    if (!self.currentView.isFirstResponder) { [self.currentView becomeFirstResponder]; }
    if (![self.currentToggle isEqualToString:@"flashtag"]) {
        [self fastCollapseAnimation];
        self.currentToggle = @"flashtag";
        self.flashtagCollectionView.hidden = NO;
        [self bringSubviewToFront:self.flashtagCollectionView];
        [self getTrendingFlashtags];
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
        if (![self.currentView isFirstResponder]) {
            [self.currentView becomeFirstResponder];
        }
        
        [CATransaction begin];
        [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
        [self.currentView setInputView:nil animated:NO];
        [CATransaction commit];
        [self.currentView reloadInputViews];
        
        if (self.flashtagDetected == NO) {
            [self.currentView replaceRange:self.currentView.selectedTextRange withText:@"!"];
        }

        [self.flashtagButton setBackgroundColor:self.highlightColor];
        [self.gridButton setBackgroundColor:[UIColor clearColor]];
        [self.trendingButton setBackgroundColor:[UIColor clearColor]];
        [self.favoriteButton setBackgroundColor:[UIColor clearColor]];
        [UIView animateWithDuration:0.20 animations:^{
            self.backButton.alpha = 0;
        }];
        
        self.titleLabel.hidden = YES;
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
        [self textViewDidChange:self.currentView];
        
    } else {
        self.flashtagDetected = NO;
        self.flashStartRange = nil;
        [self.flashtagButton setBackgroundColor:[UIColor clearColor]];
        self.flashtagCollectionView.hidden = YES;
        self.currentToggle = @"";
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
        self.titleLabel.hidden = NO;
        [CATransaction begin];
        [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
        [self.currentView setInputView:nil animated:NO];
        [CATransaction commit];
        [self.currentView reloadInputViews];
        [self.currentView becomeFirstResponder];
        
    }
    
}


-(void)layoutSubviews {
    [super layoutSubviews];
    if ([self.currentToggle isEqualToString:@""]) {
        self.favoriteButton.alpha = 1.0;
        self.trendingButton.alpha = 1.0;
        self.gridButton.alpha = 1.0;
        [self.flashtagButton setBackgroundColor:[UIColor clearColor]];
    }
    
    CGFloat collectionOffset = 0;
    
    self.containerView.frame = CGRectMake(self.containerView.frame.origin.x, 0, self.containerView.frame.size.width, self.containerView.frame.size.height);
}


-(void)introBarAnimation:(BOOL)animate {
    
    if (self.disableSearch == YES || self.disableNavigation) {
        animate = NO;
    }
    
    self.titleLabel.alpha = 0;
    self.emojiView.frame = CGRectMake(68, 0, self.frame.size.width-self.leftSideWidth, self.collapsedHeight);
    self.flashtagCollectionView.frame = CGRectMake(68, 0, self.frame.size.width-self.leftSideWidth, self.collapsedHeight);
    self.containerView.frame = CGRectMake(-96, 0, 159, self.containerView.frame.size.height);
    if (animate == YES) {
        [UIView animateWithDuration:1.8 delay:0 usingSpringWithDamping:0.4 initialSpringVelocity:5 options:UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionAllowUserInteraction animations:^ {
            self.containerView.frame = CGRectMake(-118, 0, 159, self.containerView.frame.size.height);
            self.emojiView.frame = CGRectMake(self.leftSideWidth, 0, self.frame.size.width-self.leftSideWidth, self.collapsedHeight);
            self.flashtagCollectionView.frame = CGRectMake(self.leftSideWidth, 0, self.frame.size.width-self.leftSideWidth, self.collapsedHeight);
        } completion:^(BOOL finished) {
            
        }];
    } else {
        self.containerView.frame = CGRectMake(-118, 0, 159, self.containerView.frame.size.height);
        self.emojiView.frame = CGRectMake(self.leftSideWidth, 0, self.frame.size.width-self.leftSideWidth, self.collapsedHeight);
        self.flashtagCollectionView.frame = CGRectMake(self.leftSideWidth, 0, self.frame.size.width-self.leftSideWidth, self.collapsedHeight);
    }
    
}

#pragma mark -

- (void)textViewDidBeginEditing:(DTRichTextEditorView *)textView
{
    //NSLog(@"textViewDidBeginEditing");
}

- (void)textViewDidEndEditing:(DTRichTextEditorView *)textView
{
    //NSLog(@"textViewDidEndEditing");
    
}

- (void)textViewDidChangeSelection:(DTRichTextEditorView *)textView {
    if (self.flashtagDetected == YES) {
        NSInteger currentCusorPosition = [textView offsetFromPosition:[textView beginningOfDocument] toPosition:textView.selectedTextRange.start];
        if (currentCusorPosition < 0) { currentCusorPosition = 0; }
        NSInteger lastFlashtagPosition = [textView offsetFromPosition:[textView beginningOfDocument] toPosition:self.flashStartRange.start];
        if (currentCusorPosition < lastFlashtagPosition && [self.currentToggle isEqualToString:@"flashtag"]) {
            self.flashtagCollectionView.hidden = YES;
            self.flashtagDetected = NO;
            self.flashStartRange = nil;
            [self.flashtagButton setBackgroundColor:[UIColor clearColor]];
            self.currentToggle = @"";
            return;
        }
    }
}


-(void)getTrendingFlashtags {
    if (self.hasShuffled == NO) {
        self.usedFlashtags = [NSMutableArray arrayWithArray:[self shuffledArray:self.trendingEmoji]];
        self.hasShuffled = YES;
    }
    
    self.lastFlashTag = self.usedFlashtags;
    [self.flashtagCollectionView reloadData];
}

- (NSArray *)shuffledArray:(NSArray *)array
{
    return [array sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        if (arc4random() % 2) {
            return NSOrderedAscending;
        } else {
            return NSOrderedDescending;
        }
    }];
}


- (void)textViewDidChange:(DTRichTextEditorView *)textView {
    if (self.disableSearch == YES) { return; }

    NSAttributedString * text = textView.attributedText;
    NSString * plainText = [[text string] stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    NSInteger currentCusorPosition = [textView offsetFromPosition:[textView beginningOfDocument] toPosition:textView.selectedTextRange.start];
    if (currentCusorPosition < 0) { currentCusorPosition = 0; }
    
    NSInteger previousCharacter = currentCusorPosition - 1;
    if (previousCharacter < 0) { previousCharacter = 0; }
    
    UITextRange * lastTypedCharRange = [DTTextRange rangeWithNSRange:NSMakeRange(previousCharacter, 1)];
    NSString * lastCharTyped = [textView plainTextForRange:lastTypedCharRange];
    
    if (![self.currentToggle isEqualToString:@"flashtag"]) {
        if (![self.currentToggle isEqualToString:@""]) {
            //NSLog(@"-- skip flashtag mode --");
            return;
        }
    }
    
    if (plainText.length > 0) {
        //NSLog(@"-- start detection --");
        
        NSString * lastCharacter = lastCharTyped;
        BOOL hasBang = [lastCharacter isEqualToString:@"!"];
        
        if (hasBang == YES) {
            //NSLog(@"-- has bang --");
            if (self.flashtagDetected == NO) {
                //NSLog(@" -- start flashtag --");
                self.flashtagDetected = YES;
                self.currentToggle = @"flashtag";
                self.flashStartRange = textView.selectedTextRange;
            } else {
                self.currentToggle = @"flashtag";
                [self getTrendingFlashtags];
            }
        } else {
            
            if (self.flashtagDetected == YES) {

                self.flashtagCollectionView.hidden = NO;
                self.currentToggle = @"flashtag";
                self.emojiView.hidden = YES;
                NSString * whiteSpace = [lastCharacter  stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                NSInteger flashEndPosition = [textView offsetFromPosition:self.flashStartRange.start toPosition:textView.selectedTextRange.start];
                //NSLog(@"%i", whiteSpace.length);
                //NSLog(@" -- flashend -- %li", flashEndPosition);
                
                NSInteger bangPosition = [textView offsetFromPosition:[textView beginningOfDocument] toPosition:self.flashStartRange.start];
                
                if (lastCharacter != nil) {
                    //NSLog(@"%hu", [lastCharacter characterAtIndex:[lastCharacter length]-1]);
                }
                
                unichar lineSeparator = 0x2028;
                
                if (lastCharacter != nil && lastCharacter.length > 0 && ([lastCharacter characterAtIndex:[lastCharacter length]-1] == '\n' || [lastCharacter characterAtIndex:[lastCharacter length]-1] == lineSeparator)) {
                    self.flashtagCollectionView.hidden = YES;
                    self.emojiView.hidden = NO;
                    self.flashtagDetected = NO;
                    self.flashStartRange = nil;
                    [self.flashtagButton setBackgroundColor:[UIColor clearColor]];
                    self.currentToggle = @"";
                    return;
                }
                
                if (flashEndPosition < 0) {
                    self.flashtagCollectionView.hidden = YES;
                    self.emojiView.hidden = NO;
                    self.flashtagDetected = NO;
                    self.flashStartRange = nil;
                    [self.flashtagButton setBackgroundColor:[UIColor clearColor]];
                    self.currentToggle = @"";
                    return;
                }
                //trendingflashtags
                
                
                NSString * flashtag = [plainText substringWithRange:NSMakeRange(bangPosition, flashEndPosition)];
                self.currentFlashtagSearch = flashtag;
                //NSLog(@" -- flashtag -- %@", flashtag);
                
                if (whiteSpace.length == 0 && flashEndPosition == 1) {
                    self.flashtagCollectionView.hidden = YES;
                    self.emojiView.hidden = NO;
                    self.flashtagDetected = NO;
                    self.flashStartRange = nil;
                    [self.flashtagButton setBackgroundColor:[UIColor clearColor]];
                    self.currentToggle = @"";
                    self.lastFlashTag = [NSMutableArray array];
                    return;
                }
                
                self.currentToggle = @"flashtag";
                self.expanded = NO;
                [self fastCollapseAnimation];
                [self.gridButton setBackgroundColor:[UIColor clearColor]];
                [self.favoriteButton setBackgroundColor:[UIColor clearColor]];
                [self.trendingButton setBackgroundColor:[UIColor clearColor]];
                [self.flashtagButton setBackgroundColor:self.highlightColor];
                
                //NSLog(@"-- possible whitespace -- %@", whiteSpace);
                
                if (whiteSpace.length == 0 && self.lastFlashTag.count > 0) {
                    //NSLog(@"-- selected flashtag --");
                    NSDictionary * flashTagDict = [self.lastFlashTag objectAtIndex:0];
                    self.flashtagDetected = NO;
                    self.flashStartRange = nil;
                    self.currentToggle = @"";
                    [self.gridButton setBackgroundColor:[UIColor clearColor]];
                    [self.favoriteButton setBackgroundColor:[UIColor clearColor]];
                    [self.trendingButton setBackgroundColor:[UIColor clearColor]];
                    [self.flashtagButton setBackgroundColor:[UIColor clearColor]];
                    
                    if (flashTagDict != nil) {
                        
                        NSString * imageUrl = [flashTagDict objectForKey:@"image_url"];
                        UITextRange * replaceRange = [DTTextRange rangeWithNSRange:NSMakeRange(bangPosition-1, flashEndPosition+1)];
                        
                        if (imageUrl.length == 0) {
                            
                            [textView replaceRange:replaceRange withText:[flashTagDict objectForKey:@"character"]];
                            
                        } else {
                            
                            NSString * link = @"";
                            if ([flashTagDict objectForKey:@"link_url"] != [NSNull null]) {
                                link = [flashTagDict objectForKey:@"link_url"];
                            }
                            
                            
                            NSDictionary * attributes = @{@"src" : [flashTagDict objectForKey:@"image_url"],
                                                          @"name" : [flashTagDict objectForKey:@"flashtag"],
                                                          @"link" : link,
                                                          @"width" : [NSString stringWithFormat:@"%f", self.currentView.maxImageDisplaySize.width],
                                                          @"height" : [NSString stringWithFormat:@"%f", self.currentView.maxImageDisplaySize.height],
                                                          @"id" : [[flashTagDict objectForKey:@"id"] stringValue]
                                                          };
                            
                            DTHTMLElement * newElement = [[DTHTMLElement alloc] initWithName:@"img" attributes:attributes];
                            DTImageTextAttachment * imageAttachment = [[DTImageTextAttachment alloc] initWithElement:newElement options:nil];
                            UIImage * tmpImage = [UIImage imageWithCGImage:[[UIImage imageNamed:@"MEPlaceholder"] CGImage] scale:2.0 orientation:UIImageOrientationUp];
                            
                            
                            imageAttachment.image = tmpImage;
                            
                            imageAttachment.verticalAlignment = DTTextAttachmentVerticalAlignmentCenter;
                            
                            
                            [textView replaceRange:replaceRange withAttachment:imageAttachment inParagraph:NO];
                        }
                    }

                    self.flashtagCollectionView.hidden = YES;
                    self.emojiView.hidden = NO;
                    self.lastFlashTag = [NSMutableArray array];
                    return;
                    
                } else {
                    if (self.currentFlashtagSearch.length > 0 && whiteSpace.length != 0 ) {
                        NSString * searchStringTrim = [flashtag stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                        
                        __weak MEInputAccessoryView *weakSelf = self;
                        
                            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"flashtag contains[c] %@", searchStringTrim];
                                weakSelf.lastFlashTag = [NSMutableArray array];

                                NSMutableArray * newResults = [NSMutableArray arrayWithArray:[weakSelf.flashTags filteredArrayUsingPredicate:predicate]];
                                
                                if (newResults.count > 0) {
                                    NSMutableArray * newArray = [NSMutableArray array];
                                    [newResults enumerateObjectsUsingBlock:^(id x, NSUInteger index, BOOL *stop){
                                        NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithDictionary:x];
                                        [dict setObject:searchStringTrim forKey:@"searched"];
                                        if ([[[dict objectForKey:@"flashtag"] lowercaseString] hasPrefix:[searchStringTrim lowercaseString]]) {
                                            [weakSelf.lastFlashTag insertObject:dict atIndex:0];
                                        } else {
                                            [weakSelf.lastFlashTag addObject:dict];
                                        }
                                    }];
                                }
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [weakSelf bringSubviewToFront:weakSelf.flashtagCollectionView];
                                    [weakSelf.flashtagCollectionView reloadData];
                                });
                            });
                        
                        
                    } else {

                        self.flashtagDetected = NO;
                        self.flashStartRange = nil;
                        self.flashtagCollectionView.hidden = YES;
                        self.emojiView.hidden = NO;
                        [self.flashtagButton setBackgroundColor:[UIColor clearColor]];
                        self.currentToggle = @"";
                        self.lastFlashTag = [NSMutableArray array];
                    }
                }
            }
        }
        
    } else {

        self.flashtagDetected = NO;
        self.flashStartRange = nil;
        self.flashtagCollectionView.hidden = YES;
        self.emojiView.hidden = NO;
        [self.flashtagButton setBackgroundColor:[UIColor clearColor]];
        self.currentToggle = @"";
        self.lastFlashTag = [NSMutableArray array];
    }
    
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (collectionView == self.emojiView) {
        return [self.trendingEmoji count];
    }
    return [self.lastFlashTag count];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (collectionView == self.emojiView) {
        
        MEKeyboardCollectionViewCell *photoCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Emoji" forIndexPath:indexPath];
        [photoCell setBackgroundColor:[UIColor clearColor]];
        [[MEAPIManager client] imageViewWithId:[[[self.trendingEmoji objectAtIndex:indexPath.item] objectForKey:@"id"] stringValue]];
        photoCell.inputButton.imageView.image = nil;
        [photoCell.inputButton.layer removeAllAnimations];
        //NSLog(@"%@", [[self.trendingEmoji objectAtIndex:indexPath.row] objectForKey:@"image_url"]);
        [photoCell.inputButton.imageView sd_setImageWithURL:[NSURL URLWithString:[[self.trendingEmoji objectAtIndex:indexPath.item] objectForKey:@"image_url"]]
                                        placeholderImage:[UIImage imageNamed:@"MEPlaceholder"]];
        
        if ([[self.trendingEmoji objectAtIndex:indexPath.item] objectForKey:@"link_url"] != [NSNull null]) {
            [photoCell startLinkAnimation];
        }
        
        return photoCell;
    }
    
    if (self.lastFlashTag.count > 0) {
        NSDictionary * dict = [self.lastFlashTag objectAtIndex:indexPath.item];
        NSString * imageUrl = [dict objectForKey:@"image_url"];
        NSNumber * isPhrase = [dict objectForKey:@"phrase"];
        
    //    if (isPhrase != nil) {
    //        MEPhraseCollectionViewCell *photoCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Phrase" forIndexPath:indexPath];
    //        [photoCell setBackgroundColor:[UIColor clearColor]];
    //        [photoCell setData:dict];
    //        photoCell.currentInput = self.currentFlashtagSearch;
    //        return photoCell;
    //    }
        
        if (imageUrl.length == 0) {
            MEFlashTagNativeCollectionViewCell *photoCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Native" forIndexPath:indexPath];
            [photoCell setBackgroundColor:[UIColor clearColor]];
            [photoCell setData:dict];
            photoCell.currentInput = self.currentFlashtagSearch;
            return photoCell;
        }
        
        MEFlashTagCollectionViewCell *photoCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Flashtag" forIndexPath:indexPath];
        [photoCell setBackgroundColor:[UIColor clearColor]];
        [[MEAPIManager client] imageViewWithId:[[dict objectForKey:@"id"] stringValue]];
        photoCell.imageView.image = nil;
        [photoCell.imageView sd_setImageWithURL:[NSURL URLWithString:[dict objectForKey:@"image_url"]]
                            placeholderImage:[UIImage imageNamed:@"MEPlaceholder"]];
        photoCell.currentInput = self.currentFlashtagSearch;
        [photoCell setData:[self.lastFlashTag objectAtIndex:indexPath.item]];

        return photoCell;
    }
    
    MEFlashTagCollectionViewCell *photoCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Flashtag" forIndexPath:indexPath];
    return photoCell;
}

-(void)loadFromDisk:(NSString *)filename {
        
    NSString *path = [[self applicationDocumentsDirectory].path
                      stringByAppendingPathComponent:filename];
    NSError * error;
    
    NSData * data = [NSData dataWithContentsOfFile:path];
    
    if (data != nil) {
        //NSLog(@"loaded from disk");
        id jsonResponse = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path]
                                                          options:kNilOptions
                                                            error:&error];
        
        if (jsonResponse != nil) {
            if ([filename containsString:@"wall"] && [jsonResponse objectForKey:@"Trending"] && [[jsonResponse objectForKey:@"Trending"] count] > 0) {
                self.trendingEmoji = [jsonResponse objectForKey:@"Trending"];
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    [self.emojiView reloadData];
                     //NSLog(@"from disk :: %@ :: loaded trending", filename);
                });
            }
            
            if ([filename containsString:@"flashtags"]) {
                self.flashTags = [NSMutableArray arrayWithArray:jsonResponse];
            }
        }
    }

}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == self.flashtagCollectionView) {
        NSDictionary * dict = [self.lastFlashTag objectAtIndex:indexPath.item];
        NSString * imageUrl = [dict objectForKey:@"image_url"];
        NSNumber * isPhrase = [dict objectForKey:@"phrase"];
        CGFloat width = 2+34+2+20;
        NSString * flash;
        if ([[dict objectForKey:@"flashtag"] isKindOfClass:[NSNumber class]]) {
            flash =[ [dict objectForKey:@"flashtag"] stringValue];
        } else {
            flash = [dict objectForKey:@"flashtag"];
        }
        
        if (isPhrase == nil) {
            
            CGSize newsize = [flash sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:14], NSFontAttributeName, nil]];
            newsize.width = newsize.width + 2 + 2;
            if (newsize.width > (self.frame.size.width/3)) {
                newsize.width = (self.frame.size.width/3);
            }
            return CGSizeMake(newsize.width+width,34);
        } else {
            CGSize newsize = [flash sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:14], NSFontAttributeName, nil]];
            if (newsize.width > 100) {
                newsize.width = 100;
            }
            width = ([[dict objectForKey:@"emoji"] count] * 32) + (newsize.width + 4);
            return CGSizeMake(width, 34);
        }
        
    }
    
    CGFloat modifier = 8;
    if (self.frame.size.width <= 320) {
        modifier = 7;
    }
    return CGSizeMake((self.frame.size.width/modifier),34);
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == self.emojiView) {

        if ([self.currentView.delegate respondsToSelector:@selector(editorViewShouldBeginEditing:)]) {
           BOOL should = [self.currentView.delegate performSelector:@selector(editorViewShouldBeginEditing:) withObject:self];
            if (should == NO) { return; }
        }
        if (!self.currentView.isFirstResponder) {
            [self.currentView becomeFirstResponder];
        }
        
        NSDictionary * dict = [self.trendingEmoji objectAtIndex:indexPath.item];
        [self didSelectEmoji:dict image:nil];
    } else {
        
        NSInteger flashEndPosition = [self.currentView offsetFromPosition:self.flashStartRange.start toPosition:self.currentView.selectedTextRange.start];
        NSInteger bangPosition = [self.currentView offsetFromPosition:[self.currentView beginningOfDocument] toPosition:self.flashStartRange.start];
        UITextRange * replaceRange = [DTTextRange rangeWithNSRange:NSMakeRange(bangPosition-1, flashEndPosition+1)];
        
        if (flashEndPosition >= 0) {
            
            NSDictionary * dict = [self.lastFlashTag objectAtIndex:indexPath.item];
            NSString * imageUrl = [dict objectForKey:@"image_url"];
            NSNumber * isPhrase = [dict objectForKey:@"phrase"];
            
            if (isPhrase != nil) {
                NSString * link;
                NSUInteger sint = 0;
                for (NSDictionary * emdict in [dict objectForKey:@"emoji"]) {
                    
                    NSNumber * native = [emdict objectForKey:@"native"];
                    
                    if (native == nil) {
                        
                        link = @"";
                        if ([emdict objectForKey:@"link_url"] != [NSNull null]) {
                            link = [emdict objectForKey:@"link_url"];
                        }
                        
                        NSDictionary * attributes = @{@"src" : [emdict objectForKey:@"image_url"],
                                                      @"name" : [emdict objectForKey:@"flashtag"],
                                                      @"width" : [NSString stringWithFormat:@"%f", self.currentView.maxImageDisplaySize.width], @"height" : [NSString stringWithFormat:@"%f", self.currentView.maxImageDisplaySize.height], @"link" : link,@"id" : [[emdict objectForKey:@"id"] stringValue]};
                        
                        DTHTMLElement * newElement = [[DTHTMLElement alloc] initWithName:@"img" attributes:attributes];
                        DTImageTextAttachment * imageAttachment = [[DTImageTextAttachment alloc] initWithElement:newElement options:nil];
                        UIImage * tmpImage = [UIImage imageWithCGImage:[[UIImage imageNamed:@"MEPlaceholder"] CGImage] scale:2.0 orientation:UIImageOrientationUp];
                        imageAttachment.image = tmpImage;
                        imageAttachment.verticalAlignment = DTTextAttachmentVerticalAlignmentCenter;
                        
                        if (sint == 0) {
                            [self.currentView replaceRange:replaceRange withAttachment:imageAttachment inParagraph:NO];
                        } else {
                            [self.currentView replaceRange:self.currentView.selectedTextRange withAttachment:imageAttachment inParagraph:NO];
                        }
                    } else {
                        if (sint == 0) {
                            [self.currentView replaceRange:replaceRange withText:[emdict objectForKey:@"character"]];
                        } else {
                            [self.currentView replaceRange:self.currentView.selectedTextRange withText:[emdict objectForKey:@"character"]];
                        }
                    }
                    sint++;
                    
                }
            } else {
                
                if (imageUrl.length == 0) {
                    [self.currentView replaceRange:replaceRange withText:[dict objectForKey:@"character"]];
                } else {
                    
                    NSString * link = @"";
                    if ([dict objectForKey:@"link_url"] != [NSNull null]) {
                        link = [dict objectForKey:@"link_url"];
                    }
                    
                    NSDictionary * attributes = @{@"src" : [dict objectForKey:@"image_url"],
                                                  @"name" : [dict objectForKey:@"flashtag"],
                                                  @"width" : [NSString stringWithFormat:@"%f", self.currentView.maxImageDisplaySize.width],@"height" : [NSString stringWithFormat:@"%f", self.currentView.maxImageDisplaySize.height],@"link" : link,@"id" : [[dict objectForKey:@"id"] stringValue]};
                    
                    DTHTMLElement * newElement = [[DTHTMLElement alloc] initWithName:@"img" attributes:attributes];
                    DTImageTextAttachment * imageAttachment = [[DTImageTextAttachment alloc] initWithElement:newElement options:nil];
                    UIImage * tmpImage = [UIImage imageWithCGImage:[[UIImage imageNamed:@"MEPlaceholder"] CGImage] scale:2.0 orientation:UIImageOrientationUp];
                    imageAttachment.image = tmpImage;
                    imageAttachment.verticalAlignment = DTTextAttachmentVerticalAlignmentCenter;
                    [self.currentView replaceRange:replaceRange withAttachment:imageAttachment inParagraph:NO];
                    
                }
            }
        }
        
        self.flashtagDetected = NO;
        self.flashStartRange = nil;
        self.currentToggle = @"";
        self.flashtagCollectionView.hidden = YES;
        self.emojiView.hidden = NO;
        [self.gridButton setBackgroundColor:[UIColor clearColor]];
        [self.favoriteButton setBackgroundColor:[UIColor clearColor]];
        [self.trendingButton setBackgroundColor:[UIColor clearColor]];
        [self.flashtagButton setBackgroundColor:[UIColor clearColor]];
        self.lastFlashTag = [NSMutableArray array];
    }
    
}

- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                   inDomains:NSUserDomainMask] lastObject];
}

@end
