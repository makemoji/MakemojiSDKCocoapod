//
//  MEEmojiWall.m
//  MakemojiSDK
//
//  Created by steve on 1/22/16.
//  Copyright © 2016 Makemoji. All rights reserved.
//

#import "MEEmojiWall.h"
#import "MEEmojiWallNavigationCollectionViewCell.h"
#import "MEEmojiWallCollectionViewCell.h"
#import "MEAPIManager.h"
#import "MEEmojiWallNativeCollectionViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface MEEmojiWall ()
@property BOOL shouldDisplaySearch;
@end

@implementation MEEmojiWall

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    self.title = @"Choose Emoji";
    self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.extendedLayoutIncludesOpaqueBars = NO;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.shouldDisplaySearch = NO;
    self.categoryDictionary = [NSMutableDictionary dictionary];
    self.selectedCategory = @"Trending";
    self.navigationHeight = 38.0f;
    self.didDisplayOnce = NO;
    self.shouldDisplayUsedEmoji = YES;
    self.shouldDisplayUnicodeEmoji = YES;
    self.shouldDisplayTrendingEmoji = YES;
    self.videoTextColor = [UIColor whiteColor];
    self.playOverlayTint = [UIColor whiteColor];
    self.enableUpdates = YES;
    return self;
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

- (void)viewDidLoad {
    [super viewDidLoad];
    self.emojiSize = CGSizeMake(self.view.frame.size.width/5,self.view.frame.size.height/7);

    if (self.navigationCellClass == nil) {
        self.navigationCellClass = @"MEEmojiWallNavigationCollectionViewCell";
    }
    
    [self.view setBackgroundColor:[UIColor colorWithWhite:0 alpha:1]];
    
    UICollectionViewFlowLayout * navigationLayout = [[UICollectionViewFlowLayout alloc] init];
    navigationLayout.itemSize = CGSizeMake(self.navigationHeight,self.navigationHeight);
    [navigationLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    navigationLayout.minimumInteritemSpacing = 0;
    navigationLayout.minimumLineSpacing = 0;

    self.navigationCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:navigationLayout];
    [self.navigationCollectionView registerClass:NSClassFromString(self.navigationCellClass) forCellWithReuseIdentifier:@"Category"];
    [self.navigationCollectionView setDelegate:self];
    [self.navigationCollectionView setBackgroundColor:[UIColor clearColor]];
    self.navigationCollectionView.showsHorizontalScrollIndicator = NO;
    self.navigationCollectionView.dataSource = self;
    [self.view addSubview:self.navigationCollectionView];

    CGRect frame = [[UIScreen mainScreen] bounds];
    
    UICollectionViewFlowLayout * newLayout2 = [[UICollectionViewFlowLayout alloc] init];
    newLayout2.itemSize = CGSizeMake(frame.size.width,frame.size.height);
    [newLayout2 setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    newLayout2.minimumInteritemSpacing = 0;
    newLayout2.minimumLineSpacing = 0;
    self.emojiCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:newLayout2];
    self.emojiCollectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    [self.emojiCollectionView setShowsHorizontalScrollIndicator:NO];
    [self.emojiCollectionView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    self.emojiCollectionView.pagingEnabled = YES;
    [self.emojiCollectionView registerClass:[MEEmojiWallCollectionViewCell class] forCellWithReuseIdentifier:@"Emoji"];
    [self.emojiCollectionView setBackgroundColor:[UIColor clearColor]];
    [self.emojiCollectionView setDelegate:self];
    self.emojiCollectionView.dataSource = self;
    [self.view addSubview:self.emojiCollectionView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didSelectEmoji:)
                                                 name:@"MEEmojiSelected"
                                               object:nil];

}

-(void)loadCategories {
    [self loadFromDisk:[[MEAPIManager client] cacheNameWithChannel:@"categories"]];

    if (self.enableUpdates == YES) {
        NSString * url = @"emoji/categories";
        MEAPIManager * manager = [MEAPIManager client];
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        [manager GET:url parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
            NSError * error;
            NSData * jsonData = [NSJSONSerialization dataWithJSONObject:responseObject options:kNilOptions error:&error];
            NSString *path = [[self applicationDocumentsDirectory].path
                              stringByAppendingPathComponent:[[MEAPIManager client] cacheNameWithChannel:@"categories"]];
            [[NSFileManager defaultManager] createFileAtPath:path
                                                    contents:jsonData
                                                  attributes:nil];
            
            if (![self.categories isEqualToArray:responseObject]) {
                self.categories = responseObject;
                [self loadedCategoryData];
            }
            
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            //NSLog(@"%@", error);
            if ([self.delegate respondsToSelector:@selector(meEmojiWall:failedLoadingEmoji:)]) {
                [self.delegate meEmojiWall:self failedLoadingEmoji:error];
            }
        }];
    }
}

-(void)downloadFlashtags {
    MEAPIManager * manager = [MEAPIManager client];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager GET:@"emoji/allflashtags" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSError * error;
        NSData * jsonData = [NSJSONSerialization dataWithJSONObject:responseObject options:kNilOptions error:&error];
        NSString *path = [[self applicationDocumentsDirectory].path
                          stringByAppendingPathComponent:[[MEAPIManager client] cacheNameWithChannel:@"flashtags"]];
        [[NSFileManager defaultManager] createFileAtPath:path contents:jsonData attributes:nil];
        self.flashTags = [NSMutableArray arrayWithArray:responseObject];
        //NSLog(@"%@", responseObject);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        //NSLog(@"Error: %@", error);
    }];
}

-(void)didSelectEmoji:(NSNotification *)note {
    NSDictionary * emojiDict = note.userInfo;
    [self trackShareWithEmojiId:[emojiDict objectForKey:@"emoji_id"] type:[emojiDict objectForKey:@"emoji_type"]];
    NSMutableArray * usedArr = [NSMutableArray arrayWithArray:[self.categoryDictionary objectForKey:@"Used"]];
    [usedArr removeObject:[emojiDict objectForKey:@"original"]];
    [usedArr addObject:[emojiDict objectForKey:@"original"]];
    [self.categoryDictionary setObject:usedArr forKey:@"Used"];
    if ([self.delegate respondsToSelector:@selector(meEmojiWall:didSelectEmoji:)]) {
        [self.delegate meEmojiWall:self didSelectEmoji:emojiDict];
    }
}

-(void)setupLayoutWithSize:(CGSize)size {
    [self.navigationCollectionView setFrame:CGRectMake(0, size.height-self.navigationHeight, size.width, self.navigationHeight)];
    [self.emojiCollectionView setFrame:CGRectMake(0, 0, size.width, size.height-self.navigationHeight)];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.didDisplayOnce == NO) { [self loadCategories]; self.didDisplayOnce = YES; }
    [self setupLayoutWithSize:self.view.frame.size];
    if (self.shouldDisplaySearch == YES) {
        [self downloadFlashtags];
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *reusableview = nil;
    if (collectionView == self.navigationCollectionView) {
        return reusableview;
    }
    return reusableview;
}

-(NSArray *)getRecentlyUsedEmoji {
    return [NSArray array];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if (collectionView == self.navigationCollectionView) {
        return CGSizeZero;
    }
    return CGSizeZero;
}

-(void)loadEmoji {
    
    if ([self.delegate respondsToSelector:@selector(meEmojiWall:startedLoadingEmoji:)]) {
        [self.delegate meEmojiWall:self startedLoadingEmoji:self.categories];
    }

    [self loadFromDisk:[[MEAPIManager client] cacheNameWithChannel:@"emojiwall"]];

    if (self.enableUpdates == YES) {
    
        MEAPIManager * manager = [MEAPIManager client];
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        
        [manager GET:@"emoji/emojiWall/wall" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
            NSError * error;
            NSData * jsonData = [NSJSONSerialization dataWithJSONObject:responseObject options:kNilOptions error:&error];
            NSString *path = [[self applicationDocumentsDirectory].path
                              stringByAppendingPathComponent:[[MEAPIManager client] cacheNameWithChannel:@"emojiwall"]];
            [[NSFileManager defaultManager] createFileAtPath:path
                                                    contents:jsonData
                                                  attributes:nil];
            
            if ([self.delegate respondsToSelector:@selector(meEmojiWall:finishedLoadingEmoji:)]) {
                [self.delegate meEmojiWall:self finishedLoadingEmoji:responseObject];
            }

            if (self.categoryDictionary != responseObject) {
                self.categoryDictionary = [NSMutableDictionary dictionaryWithDictionary:responseObject];
                [self.emojiCollectionView reloadData];
            }
            
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            if ([self.delegate respondsToSelector:@selector(meEmojiWall:failedLoadingEmoji:)]) {
                [self.delegate meEmojiWall:self failedLoadingEmoji:error];
            }
        }];
    }
}

-(void)loadedCategoryData {
    NSMutableArray * arr = [NSMutableArray arrayWithArray:self.categories];
    
    if (self.shouldDisplayUnicodeEmoji == YES) {
        [arr insertObject:[NSDictionary dictionaryWithObjectsAndKeys:@"http://",@"image_url",@"Osemoji",@"name", nil] atIndex:0];
    }
    
    if (self.shouldDisplayUsedEmoji == YES) {
        [arr insertObject:[NSDictionary dictionaryWithObjectsAndKeys:@"http://",@"image_url",@"Used",@"name", nil] atIndex:0];
    }
    
    if (self.shouldDisplayTrendingEmoji == YES) {
        [arr insertObject:[NSDictionary dictionaryWithObjectsAndKeys:@"http://",@"image_url",@"Trending",@"name", nil] atIndex:0];
    }
    
    self.categories = arr;
    [self.navigationCollectionView reloadData];
    [self.navigationCollectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] animated:YES scrollPosition:UICollectionViewScrollPositionNone];
    [self loadEmoji];
}

-(void)loadFromDisk:(NSString *)filename {
    NSString *path;
    NSString *buildpath = [[NSBundle mainBundle] pathForResource:[filename stringByDeletingPathExtension] ofType:@"json"];
    NSString *cachePath = [[self applicationDocumentsDirectory].path stringByAppendingPathComponent:filename];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:buildpath]) {
        path = buildpath;
        [[SDImageCache sharedImageCache] addReadOnlyCachePath:[[NSBundle mainBundle] bundlePath]];
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:cachePath] && self.enableUpdates == YES) {
        path = cachePath;
    }
    
    NSError * error;
    NSData * data = [NSData dataWithContentsOfFile:path];

    if (data != nil) {

        id jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        if (jsonResponse != nil) {
            
            if ([filename containsString:@"categories"]) {
                if (![self.categories isEqualToArray:jsonResponse]) {
                    self.categories = jsonResponse;
                    [self loadedCategoryData];
                }
            } else {

                self.categoryDictionary = [NSMutableDictionary dictionaryWithDictionary:jsonResponse];
                
                if ([self.delegate respondsToSelector:@selector(meEmojiWall:finishedLoadingEmoji:)]) {
                    [self.delegate meEmojiWall:self finishedLoadingEmoji:jsonResponse];
                }
                
                [self.emojiCollectionView reloadData];
            }
        }
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == self.navigationCollectionView) {
        NSDictionary * dict = [self.categories objectAtIndex:indexPath.row];
        self.selectedCategoryIndex = indexPath;
        NSString * catString = [dict objectForKey:@"name"];
        self.selectedCategory = catString;
        NSIndexPath * newIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:1];

        [self.emojiCollectionView scrollToItemAtIndexPath:newIndexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
        [self.emojiCollectionView reloadData];
        
        if ([self.delegate respondsToSelector:@selector(meEmojiWall:didSelectCategory:)]) {
            [self.delegate meEmojiWall:self didSelectCategory:dict];
        }
        
        return;
    }
    return;
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.delegate = nil;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (collectionView == self.navigationCollectionView) {
        MEEmojiWallNavigationCollectionViewCell *photoCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Category" forIndexPath:indexPath];
        NSDictionary * dict = [self.categories objectAtIndex:indexPath.row];
        NSString * imageName = [NSString stringWithFormat:@"Makemoji.bundle/MENav-%@", [[[dict objectForKey:@"name"] lowercaseString] stringByReplacingOccurrencesOfString:@" " withString:@""]];
        UIImage * catImage = [UIImage imageNamed:imageName inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
        photoCell.imageView.image = nil;
        if (catImage != nil) {
            [photoCell.imageView setImage:[UIImage imageNamed:imageName inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil]];
        } else {
            [photoCell.imageView sd_setImageWithURL:[self urlForPath:[dict objectForKey:@"image_url"]] placeholderImage:[UIImage imageNamed:@"Makemoji.bundle/MEPlaceholder" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil]];
        }

        photoCell.backgroundColor = [UIColor clearColor];
        photoCell.layer.cornerRadius = 15;
        return photoCell;
    }
    
    NSDictionary * selectedCategory = [self.categories objectAtIndex:indexPath.row];
    NSArray * categoryEmoji = [self.categoryDictionary objectForKey:[selectedCategory objectForKey:@"name"]];
    MEEmojiWallCollectionViewCell * emojiCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Emoji" forIndexPath:indexPath];
    emojiCell.videoTextColor = self.videoTextColor;
    emojiCell.playOverlayTint = self.playOverlayTint;
    emojiCell.selectedCategory = [selectedCategory objectForKey:@"name"];
    [emojiCell setItemSize:self.emojiSize];
    [emojiCell setEmojiData:categoryEmoji];
    return emojiCell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    if (collectionView == self.navigationCollectionView) {
        return 1;
    }
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (collectionView == self.navigationCollectionView) {
        return [self.categories count];
    }
    
    if (section == 0) { return 0; }
    
    return [self.categories count];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.emojiCollectionView) {
        [self scrollToCenterItem];
    }
}

-(void)scrollToCenterItem {
    NSArray * visibleIndexes = [self.emojiCollectionView indexPathsForVisibleItems];
    if (visibleIndexes.count > 0) {
        CGRect visibleRect = (CGRect){.origin = self.emojiCollectionView.contentOffset, .size = self.emojiCollectionView.bounds.size};
        CGPoint visiblePoint = CGPointMake(CGRectGetMidX(visibleRect), CGRectGetMidY(visibleRect));
        NSIndexPath *visibleIndexPath = [self.emojiCollectionView indexPathForItemAtPoint:visiblePoint];
        NSDictionary * dict = [self.categories objectAtIndex:visibleIndexPath.row];
        
        NSIndexPath * translatedIndedPath = [NSIndexPath indexPathForRow:visibleIndexPath.row inSection:0];
        if (translatedIndedPath.row != self.selectedCategoryIndex.row) {
            self.selectedCategoryIndex = translatedIndedPath;
            if ([self.delegate respondsToSelector:@selector(meEmojiWall:didSelectCategory:)]) {
                [self.delegate meEmojiWall:self didSelectCategory:dict];
            }
        }
        [self.navigationCollectionView selectItemAtIndexPath:translatedIndedPath animated:YES scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == self.navigationCollectionView) {
        return CGSizeMake(self.navigationHeight,self.navigationHeight);
    }

    if (indexPath.section == 0) {
        return CGSizeZero;
    }
    
    CGRect frame = [[UIScreen mainScreen] bounds];
    
    CGFloat width = frame.size.width;
    if (width > frame.size.height) { width = frame.size.height; }
    if (self.shouldDisplaySearch == YES) {
         return CGSizeMake(collectionView.frame.size.width,collectionView.frame.size.height-50);
    }
    return CGSizeMake(collectionView.frame.size.width,collectionView.frame.size.height);
}

- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

-(void)trackShareWithEmojiId:(NSString *)emojiId type:(NSString *)type {
    MEAPIManager *manager = [MEAPIManager client];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSString * user_id;
    if (user_id == nil) { user_id = @"0"; }
    NSString * url = [NSString stringWithFormat:@"emoji/share/%@/%@/%@", user_id, emojiId, type];
    [manager GET:url parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {

    } failure:^(NSURLSessionDataTask *task, NSError *error) {

    }];
}

@end
