//
//  MEReactionView.m
//  MakemojiSDK
//
//  Created by steve on 5/11/16.
//  Copyright © 2016 Makemoji. All rights reserved.
//

#import "MEReactionView.h"
#import "MEAPIManager.h"
#import "NSString+MEUtilities.h"
#import "MEReactionCollectionViewCell.h"

NSString * const MEReactionNotification = @"MEReactionNotification";

@interface MEReactionView ()
    @property NSString * sha1ContentId;
    @property NSURLSessionDataTask * currentTask;
@end


@implementation MEReactionView

@synthesize contentId = _contentId;

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self)
    {
        [self initializer];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        [self initializer];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame contentId:(NSString *)contentId
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self initializer];
        self.contentId = contentId;
    }
    
    return self;
}

-(void)setContentId:(NSString *)contentId {
    _contentId = contentId;
    
    if (contentId != nil) {
        self.sha1ContentId = [self.contentId sha1];
    } else {
        self.sha1ContentId = nil;
    }
    [self getData];
}

-(NSString *)contentId {
    return _contentId;
}


- (void)initializer {
    self.cellBorderColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1];
    self.cellHighlightColor = [UIColor colorWithRed:0.28 green:0.79 blue:0.96 alpha:1];
    self.cellTextColor = [UIColor grayColor];
    self.reactions = [NSMutableArray array];
    UICollectionViewFlowLayout * navigationLayout = [[UICollectionViewFlowLayout alloc] init];
    navigationLayout.itemSize = CGSizeMake(80,30);
    [navigationLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    navigationLayout.minimumInteritemSpacing = 2;
    navigationLayout.minimumLineSpacing = 2;

    self.reactionCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width-30, 30) collectionViewLayout:navigationLayout];
    [self.reactionCollectionView registerClass:[MEReactionCollectionViewCell class] forCellWithReuseIdentifier:@"Reaction"];
    [self.reactionCollectionView setDelegate:self];
    [self.reactionCollectionView setBackgroundColor:[UIColor clearColor]];
    self.reactionCollectionView.showsHorizontalScrollIndicator = NO;
    self.reactionCollectionView.dataSource = self;
    [self addSubview:self.reactionCollectionView];
    
    self.wallTriggerView = [[UIButton alloc] init];
    [self.wallTriggerView setImage:[[UIImage imageNamed:@"Makemoji.bundle/MEReactionAdd" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    self.wallTriggerView.imageEdgeInsets = UIEdgeInsetsMake(3, 6, 3, 6);
    self.wallTriggerView.layer.borderWidth = 1;
    self.wallTriggerView.layer.borderColor = [[UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1] CGColor];
    self.wallTriggerView.tintColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1];
    self.wallTriggerView.layer.cornerRadius = 5;
    [self.wallTriggerView addTarget:self action:@selector(openWall:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.wallTriggerView];
    
}

-(void)openWall:(id)sender {
    MEEmojiWall * emojiWall = [[MEEmojiWall alloc] initWithNibName:nil bundle:nil];
    emojiWall.delegate = self;
    
    if (self.viewController != nil) {
        [self.viewController presentModalViewController:emojiWall animated:YES];
    }
}

-(void)meEmojiWall:(MEEmojiWall *)emojiWall didSelectEmoji:(NSDictionary*)emoji {
    [emojiWall dismissViewControllerAnimated:YES completion:^{

    }];
    int index = 0;
    BOOL found = NO;
    for (NSDictionary * dict in self.reactions) {
        if ([[dict objectForKey:@"emoji_id"] isEqualToNumber:[emoji objectForKey:@"emoji_id"]]) {
            found = YES;
            break;
        }
        index++;
    }
    
    NSNumber * num = [NSNumber numberWithInteger:0];
    if (found == YES) {
        num = [[self.reactions objectAtIndex:index] objectForKey:@"total"];
    }
    
    NSString * type = @"makemoji";
    if ([[emoji objectForKey:@"emoji_type"] isEqualToString:@"native"]) {
        type = @"unicode";
    }
    
    NSString * character = @"";
    
    if ([[emoji objectForKey:@"original"] objectForKey:@"character"] != nil) {
        character = [[emoji objectForKey:@"original"] objectForKey:@"character"];
    }
    
    NSDictionary * reaction = @{@"emoji_id" : [emoji objectForKey:@"emoji_id"],
                                @"image_url" : [[emoji objectForKey:@"original"] objectForKey:@"image_url"],
                                @"emoji_type" : type,
                                @"character" : character,
                                @"total" : num
                                };
    
    [self didSelectReaction:reaction];
    [self.reactionCollectionView reloadData];
}

-(void)didSelectReaction:(NSDictionary *)reaction {
    NSMutableDictionary * selectedReaction = [NSMutableDictionary dictionaryWithDictionary:reaction];
    
    NSNumber * num = [selectedReaction objectForKey:@"total"];
    
    
    if (self.currentUserReaction != nil && [self.currentUserReaction isKindOfClass:[NSDictionary class]] && [[self.currentUserReaction objectForKey:@"emoji_id"] isKindOfClass:[NSNumber class]] ) {
        if ([[self.currentUserReaction objectForKey:@"emoji_id"] isEqualToNumber:[selectedReaction objectForKey:@"emoji_id"]]) {
            num =  [NSNumber numberWithInteger:[num integerValue]-1];
            self.currentUserReaction = [NSDictionary dictionary];
        } else {
            
            int index = 0;
            for (NSDictionary * dict in self.reactions) {
                if ([[dict objectForKey:@"emoji_id"] isEqualToNumber:[self.currentUserReaction objectForKey:@"emoji_id"]]) {
                    break;
                }
                index++;
            }
            
            NSMutableDictionary * previousUp = [NSMutableDictionary dictionaryWithDictionary:[self.reactions objectAtIndex:index]];
            NSNumber * prevNumber = [previousUp objectForKey:@"total"];
            prevNumber = [NSNumber numberWithInteger:[prevNumber integerValue]-1];
            [previousUp setObject:prevNumber forKey:@"total"];
            [self.reactions replaceObjectAtIndex:index withObject:previousUp];
            
            num =  [NSNumber numberWithInteger:[num integerValue]+1];
            self.currentUserReaction = [NSDictionary dictionaryWithDictionary:selectedReaction];
        }
        
        
    } else {
        num =  [NSNumber numberWithInteger:[num integerValue]+1];
        self.currentUserReaction = [NSDictionary dictionaryWithDictionary:selectedReaction];
    }
    
    [selectedReaction setObject:num forKey:@"total"];
    
    int index2 = 0;
    BOOL found = NO;
    for (NSDictionary * dict in self.reactions) {
        if ([[dict objectForKey:@"emoji_id"] isEqualToNumber:[selectedReaction objectForKey:@"emoji_id"]]) {
            found = YES;
            break;
        }
        index2++;
    }
    
    if (found == YES) {
        [self.reactions replaceObjectAtIndex:index2 withObject:selectedReaction];
    } else {
        [self.reactions addObject:selectedReaction];
    }
    
    NSSortDescriptor * brandDescriptor = [[NSSortDescriptor alloc] initWithKey:@"total" ascending:NO];
    NSArray * sortDescriptors = [NSArray arrayWithObject:brandDescriptor];
    self.reactions = [NSMutableArray arrayWithArray:[self.reactions sortedArrayUsingDescriptors:sortDescriptors]];
    
    MEAPIManager *manager = [MEAPIManager client];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSString * url = [NSString stringWithFormat:@"reactions/create/%@", self.sha1ContentId];
    [manager POST:url parameters:selectedReaction success:^(NSURLSessionDataTask *task, id responseObject) {
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
    }];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:MEReactionNotification object:nil userInfo:selectedReaction];
    });
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self didSelectReaction:[self.reactions objectAtIndex:indexPath.row]];
    [self.reactionCollectionView reloadData];

    [UIView transitionWithView:collectionView
                      duration:.25
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        
                    } completion:^(BOOL finished) {

                    }];
    
    return;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.reactions count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableDictionary * selectedReaction = [NSMutableDictionary dictionaryWithDictionary:[self.reactions objectAtIndex:indexPath.row]];
    [selectedReaction setObject:self.currentUserReaction forKey:@"currentUser"];
    
    MEReactionCollectionViewCell * emojiCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Reaction" forIndexPath:indexPath];
    emojiCell.highlightColor = self.cellHighlightColor;
    emojiCell.borderColor = self.cellBorderColor;
    emojiCell.textColor = self.cellTextColor;
    [emojiCell setReactionData:selectedReaction];
    return emojiCell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGRect viewFrame = self.frame;
    NSDictionary * selectedReaction = [self.reactions objectAtIndex:indexPath.row];
    CGFloat maxWidth = (self.reactionCollectionView.frame.size.width/5) - 10;
    CGFloat itemWidth = maxWidth-4;
    if (itemWidth < (viewFrame.size.height*2)) { itemWidth = (viewFrame.size.height*2); }
    if ([[selectedReaction objectForKey:@"total"] isKindOfClass:[NSNumber class]]) {
        NSNumber * num = [selectedReaction objectForKey:@"total"];
        if ([num isEqualToNumber:[NSNumber numberWithInteger:0]]) {
            itemWidth = viewFrame.size.height + 6;
        }
    }
    
    return CGSizeMake(floorf(itemWidth),viewFrame.size.height);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 2;
}

-(void)dealloc {
    if (self.currentTask != nil) {
        [self.currentTask cancel];
    }
    self.reactionCollectionView.delegate = nil;
    self.reactionCollectionView.dataSource = nil;
    self.viewController = nil;
}

- (void)getData {
    if (self.currentTask != nil) { [self.currentTask cancel]; }
    if (self.contentId == nil) { return; }

    NSString * url = [NSString stringWithFormat:@"reactions/get/%@", self.sha1ContentId];
    
    MEAPIManager * manager = [MEAPIManager client];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    __weak MEReactionView * weakself = self;
    self.currentTask =
    [manager GET:url parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {

        NSDictionary * responseDictionary = [NSDictionary dictionaryWithDictionary:responseObject];
        if ([responseDictionary objectForKey:@"reactions"]) {
            weakself.reactions = [NSMutableArray arrayWithArray:[responseDictionary objectForKey:@"reactions"]];
        }
        
        if ([responseDictionary objectForKey:@"currentUser"]) {
            weakself.currentUserReaction = [responseDictionary objectForKey:@"currentUser"];
        }
        
        [weakself.reactionCollectionView reloadData];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {

    }];

}

-(void)layoutSubviews {
    [super layoutSubviews];
    CGFloat currentHeight = self.frame.size.height;
    if (self.frame.size.height > 40) { currentHeight = 40; }
    [self.reactionCollectionView setFrame:CGRectMake(0, 0, self.frame.size.width-currentHeight-6-2, currentHeight)];
    [self.wallTriggerView setFrame:CGRectMake(self.frame.size.width-currentHeight-6-2, 0, currentHeight+6, currentHeight)];
}


@end
