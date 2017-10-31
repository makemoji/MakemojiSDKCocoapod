//
//  MEEmojiWallCollectionViewCell.m
//  MakemojiSDK
//
//  Created by steve on 4/9/16.
//  Copyright © 2016 Makemoji. All rights reserved.
//

#import "MEEmojiWallCollectionViewCell.h"
#import "MEEmojiWallEmojiCollectionViewCell.h"
#import "MEEmojiWallNativeCollectionViewCell.h"
#import "MEEmojiWallVideoCollectionViewCell.h"
#import "MEGifCollectionViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "MEAPIManager.h"

@implementation MEEmojiWallCollectionViewCell

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


- (void)initializer {
    self.emoji = [NSArray array];
    self.isVideoCollection = NO;
    self.videoTextColor = [UIColor whiteColor];
    self.playOverlayTint = [UIColor whiteColor];
    self.selectedCategory = @"";
    UICollectionViewFlowLayout * newLayout2 = [[UICollectionViewFlowLayout alloc] init];
    newLayout2.itemSize = CGSizeMake(self.contentView.frame.size.width/5,self.contentView.frame.size.height/7);
    self.itemSize = CGSizeMake(self.contentView.frame.size.width/5,self.contentView.frame.size.height/7);
    [newLayout2 setScrollDirection:UICollectionViewScrollDirectionVertical];
    newLayout2.minimumInteritemSpacing = 0;
    newLayout2.minimumLineSpacing = 0;
    
    self.emojiCollectionView = [[UICollectionView alloc] initWithFrame:self.contentView.frame collectionViewLayout:newLayout2];
    self.emojiCollectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    [self.emojiCollectionView setShowsHorizontalScrollIndicator:NO];
    [self.emojiCollectionView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [self.emojiCollectionView registerClass:[MEEmojiWallEmojiCollectionViewCell class] forCellWithReuseIdentifier:@"Emoji"];
    [self.emojiCollectionView registerClass:[MEEmojiWallNativeCollectionViewCell class] forCellWithReuseIdentifier:@"Native"];
    [self.emojiCollectionView registerClass:[MEEmojiWallVideoCollectionViewCell class] forCellWithReuseIdentifier:@"Video"];
    [self.emojiCollectionView registerClass:[MEGifCollectionViewCell class] forCellWithReuseIdentifier:@"GIF"];
    [self.emojiCollectionView setBackgroundColor:[UIColor clearColor]];
    [self.emojiCollectionView setDelegate:self];
    self.emojiCollectionView.dataSource = self;
    [self.contentView addSubview:self.emojiCollectionView];
    [[MEAPIManager client] beginImageViewSessionWithTag:@"wall"];
}

-(void)setEmojiData:(NSArray *)emoji {
    if (self.emoji != emoji) {
        self.emoji = emoji;
        if (self.emoji.count > 0) {
            NSDictionary * firstEmoji = [self.emoji objectAtIndex:0];
            if ([firstEmoji objectForKey:@"video"] != nil && [[firstEmoji objectForKey:@"video"] integerValue] == 1) {
                self.isVideoCollection = YES;
            } else {
                self.isVideoCollection = NO;
            }
        }
        [self.emojiCollectionView reloadData];
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.emoji count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary * dict = [self.emoji objectAtIndex:indexPath.row];
    
    if ([self.selectedCategory isEqualToString:@"Osemoji"]) {
        MEEmojiWallNativeCollectionViewCell * emojiCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Native" forIndexPath:indexPath];
        [emojiCell setData:dict];
        return emojiCell;
    }

    if (self.isVideoCollection == YES) {
        MEEmojiWallVideoCollectionViewCell * emojiCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Video" forIndexPath:indexPath];
        [[MEAPIManager client] imageViewWithId:[dict objectForKey:@"id"]];
        [emojiCell.previewImage sd_setImageWithURL:[self urlForPath:[dict objectForKey:@"image_url"]] placeholderImage:[UIImage imageNamed:@"Makemoji.bundle/MEPlaceholder" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil]];
        [emojiCell.emojiLabel setText:[dict objectForKey:@"name"]];
        emojiCell.emojiLabel.textColor = self.videoTextColor;
        emojiCell.playOverlay.tintColor = self.playOverlayTint;
        return emojiCell;
    }
    
    if ([[dict objectForKey:@"gif"] boolValue] == YES) {
        MEGifCollectionViewCell * emojiCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"GIF" forIndexPath:indexPath];
        [[MEAPIManager client] imageViewWithId:[dict objectForKey:@"id"]];
        [emojiCell.imageView sd_setImageWithURL:[self urlForPath:[dict objectForKey:@"image_url"]] placeholderImage:[UIImage imageNamed:@"Makemoji.bundle/MEPlaceholder" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil]];
        return emojiCell;
    }
    
    
    MEEmojiWallEmojiCollectionViewCell * emojiCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Emoji" forIndexPath:indexPath];
   [[MEAPIManager client] imageViewWithId:[dict objectForKey:@"id"]];
    [emojiCell.imageView sd_setImageWithURL:[self urlForPath:[dict objectForKey:@"image_url"]] placeholderImage:[UIImage imageNamed:@"Makemoji.bundle/MEPlaceholder" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil]];
    return emojiCell;
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
        NSDictionary * emojiDict = [self.emoji objectAtIndex:indexPath.row];
    
        NSMutableDictionary * outputDict = [NSMutableDictionary dictionary];
    
        [outputDict setObject:[emojiDict objectForKey:@"id"] forKey:@"emoji_id"];
        [outputDict setObject:[emojiDict objectForKey:@"name"] forKey:@"name"];
        [outputDict setObject:emojiDict forKey:@"original"];
    
        if ([self.selectedCategory isEqualToString:@"Osemoji"]) {
            [outputDict setObject:@"native" forKey:@"emoji_type"];
            [outputDict setObject:[emojiDict objectForKey:@"character"] forKey:@"unicode_character"];
        } else {
            [outputDict setObject:@"makemoji" forKey:@"emoji_type"];
            [outputDict setObject:[[self urlForPath:[emojiDict objectForKey:@"image_url"]] absoluteString] forKey:@"image_url"];
            NSString * path = [[SDImageCache sharedImageCache] defaultCachePathForKey:[[self urlForPath:[emojiDict objectForKey:@"image_url"]] absoluteString]];
            NSData * data = [NSData dataWithContentsOfFile:path];
            if (!data)
                return;
            [outputDict setObject:[UIImage imageWithData:data] forKey:@"image_object"];
        }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MEEmojiSelected" object:nil userInfo:outputDict];
    });
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {

    if (self.isVideoCollection == YES) {
        return CGSizeMake(self.contentView.frame.size.width/4,self.contentView.frame.size.height/5);
    }
    
    return self.itemSize;

}

-(NSURL*)urlForPath:(NSString *)path {
    NSURL * url;
    if (![path hasPrefix:@"https://"]) {
        url = [NSURL fileURLWithPath:[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:path]];
    } else {
        url = [NSURL URLWithString:path];
    }
    return url;
}

-(void)prepareForReuse {
    self.emoji = [NSArray array];
    self.isVideoCollection = NO;
}

-(void)dealloc {
    self.emojiCollectionView.delegate = nil;
    self.emojiCollectionView.dataSource= nil;
    [[MEAPIManager client] endImageViewSession];
}

@end
