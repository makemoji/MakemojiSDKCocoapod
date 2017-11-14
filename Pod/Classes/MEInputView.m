//
//  MECategoryInputView.m
//  Makemoji
//
//  Created by steve on 1/20/15.
//  Copyright (c) 2015 Makemoji. All rights reserved.
//

#import "MakemojiSDK.h"
#import "MEInputView.h"
#import "MEAPIManager.h"
#import "MECategoryCollectionViewCell.h"
#import "MEKeyboardCollectionViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "MEKeyboardPopupView.h"
#import "MEKeyboardPhraseCollectionViewCell.h"
#import "MEGifCategoryCollectionViewCell.h"
#import "MEGifCollectionViewCell.h"
#import "MEInputAccessoryView.h"

@interface MEInputView () <UICollectionViewDataSource, UICollectionViewDelegate>
    @property NSMutableArray * emoji;
    @property NSMutableArray * recentEmoji;
    @property NSMutableArray * categories;
    @property NSMutableDictionary * categoryEmoji;
    @property NSMutableArray * trendingEmoji;
    @property NSMutableArray * gifCategories;
    @property NSString * selected;
    @property NSString * selectedCategoryString;
    @property NSArray * unlockedGroups;
    @property NSURLSessionDataTask * categoriesTask;
    @property NSURLSessionDataTask * emojiWallTask;
@end


@implementation MEInputView

- (id)init {
    return [self initWithFrame:CGRectZero];
}

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        [[MEAPIManager client] beginImageViewSessionWithTag:@"InputView"];
        self.recentEmoji = [NSMutableArray array];
        self.trendingEmoji = [NSMutableArray array];
        self.categoryEmoji = [NSMutableDictionary dictionary];
        self.categories = [NSMutableArray array];
        self.gifCategories = [NSMutableArray array];
        self.lockedImagePath = @"";
        
        CGFloat inputHeight = 216;
        CGFloat collectionHeight = 180;
        if ([[UIScreen mainScreen] bounds].size.height >= 736.0) {
            inputHeight = 226;
            collectionHeight = 190;
        }
        
        self.selected = @"favorite";
        self.backgroundColor = [UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1];
        
        UICollectionViewFlowLayout * newLayout3 = [[UICollectionViewFlowLayout alloc] init];

        
        newLayout3.itemSize = CGSizeMake(100, collectionHeight/4);
        [newLayout3 setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        newLayout3.minimumInteritemSpacing = 2.0f;
        newLayout3.minimumLineSpacing = 4.0f;
        self.gifCategoryView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, collectionHeight) collectionViewLayout:newLayout3];
        [self.gifCategoryView setBackgroundColor:[UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1]];
        [self addSubview:self.gifCategoryView];
        self.gifCategoryView.showsHorizontalScrollIndicator = NO;
        self.gifCategoryView.dataSource = self;
        //self.gifCategoryView.contentInset = UIEdgeInsetsMake(30, 0, 0, 0);
        
        [self.gifCategoryView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [self.gifCategoryView registerClass:[MEGifCategoryCollectionViewCell class] forCellWithReuseIdentifier:@"GifCategory"];
        [self.gifCategoryView setDelegate:self];
        [self.gifCategoryView setBackgroundColor:[UIColor clearColor]];
        self.gifCategoryView.pagingEnabled = NO;
        [self sendSubviewToBack:self.gifCategoryView];
        self.gifCategoryView.hidden = YES;
        
        
        
        UICollectionViewFlowLayout * newLayout = [[UICollectionViewFlowLayout alloc] init];
        
        CGFloat itemWidth = frame.size.width / 4;
        
        newLayout.itemSize = CGSizeMake(itemWidth, 88);
        [newLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        newLayout.minimumInteritemSpacing = 0.0f;
        newLayout.minimumLineSpacing = 0.0f;
        self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, collectionHeight) collectionViewLayout:newLayout];
        [self.collectionView setBackgroundColor:[UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1]];
        [self addSubview:self.collectionView];
        self.collectionView.showsHorizontalScrollIndicator = NO;
        self.collectionView.dataSource = self;
        //self.collectionView.contentInset = UIEdgeInsetsMake(0, 1, 0, 1);

        [self.collectionView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [self.collectionView registerClass:[MECategoryCollectionViewCell class] forCellWithReuseIdentifier:@"Category"];
        [self.collectionView setDelegate:self];
        [self.collectionView setBackgroundColor:[UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1]];
        self.collectionView.pagingEnabled = YES;
        
        UICollectionViewFlowLayout * newLayout2 = [[UICollectionViewFlowLayout alloc] init];
        CGFloat modifier = 8;
        if (self.frame.size.width <= 320) {
            modifier = 7;
        }
        newLayout2.itemSize = CGSizeMake((frame.size.width/modifier),34);
        
        [newLayout2 setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        newLayout2.minimumInteritemSpacing = 0;
        newLayout2.minimumLineSpacing = 0;
        self.emojiView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, collectionHeight) collectionViewLayout:newLayout2];
        [self.emojiView setBackgroundColor:[UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1]];
        [self addSubview:self.emojiView];

        //self.emojiView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        [self.emojiView setShowsHorizontalScrollIndicator:NO];
        [self.emojiView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
        [self.emojiView registerClass:[MEKeyboardCollectionViewCell class] forCellWithReuseIdentifier:@"Emoji"];
        [self.emojiView registerClass:[MEKeyboardPhraseCollectionViewCell class] forCellWithReuseIdentifier:@"Phrase"];
        [self.emojiView registerClass:[MEGifCollectionViewCell class] forCellWithReuseIdentifier:@"GIF"];
        [self.emojiView setBackgroundColor:[UIColor clearColor]];
        self.emojiView.pagingEnabled = YES;
        [self.emojiView setHidden:YES];
        [self.emojiView setDelegate:self];
        
        self.emojiView.dataSource = self;
        [self sendSubviewToBack:self.emojiView];

        [self.emojiView addObserver:self forKeyPath:@"contentSize" options:0 context:NULL];
        
        [self.collectionView reloadData];
        
        self.deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.deleteButton setImage:[[UIImage imageNamed:@"Makemoji.bundle/MEDeleteIcon" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        //[self.deleteButton setBackgroundColor:[UIColor colorWithRed:0.72 green:0.74 blue:0.76 alpha:1]];
        [self.deleteButton setFrame:CGRectMake(frame.size.width-100, self.collectionView.frame.size.height, 50, 40)];
        [self.deleteButton addTarget:self action:@selector(deleteButtonTapped) forControlEvents:UIControlEventTouchDown];
        [self.deleteButton addTarget:self action:@selector(deleteButtonRelease) forControlEvents:UIControlEventTouchUpInside];
        [self.deleteButton.imageView setTintColor:[UIColor colorWithRed:0.309 green:0.33 blue:0.364 alpha:1]];
        [self addSubview:self.deleteButton];
        
        
        self.globeButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.globeButton setTitle:@"ABC" forState:UIControlStateNormal];
        [self.globeButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [self.globeButton setTitleColor:[UIColor colorWithRed:0.309 green:0.33 blue:0.364 alpha:1]  forState:UIControlStateNormal];
        //[self.globeButton setImage:[UIImage imageNamed:@"Geography"] forState:UIControlStateNormal];
        //[self.globeButton setBackgroundColor:[UIColor colorWithRed:0.72 green:0.74 blue:0.76 alpha:1]];
        [self.globeButton setFrame:CGRectMake(0, self.collectionView.frame.size.height, 50, 40)];
        [self.globeButton.titleLabel setTintColor:[UIColor colorWithRed:0.309 green:0.33 blue:0.364 alpha:1]];
        [self.globeButton addTarget:self action:@selector(globeButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.globeButton];
        
        self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(138, self.collectionView.frame.size.height, 100, 40)];
        self.pageControl.numberOfPages = 0;
        self.pageControl.currentPageIndicatorTintColor = [UIColor darkGrayColor];
        self.pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
        
        [self addSubview:self.pageControl];
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(14, 6, frame.size.width, 19)];
        self.titleLabel.textAlignment = NSTextAlignmentLeft;
        self.titleLabel.font = [UIFont boldSystemFontOfSize:13];
        [self.titleLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        self.titleLabel.text = @"";
        self.titleLabel.alpha = 0.0;
        self.titleLabel.textColor = [UIColor colorWithWhite:0.65 alpha:1];
        
        [self addSubview:self.titleLabel];

        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(unlockedNewCategory:)
                                                     name:MECategoryUnlockedSuccessNotification
                                                   object:nil];
        
    }
    return self;
}

-(void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    [self getRecentData];
    [self loadData];
}

-(void)loadData {
    NSString * url = @"emoji/categories";
    MEAPIManager * manager = [MEAPIManager client];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [self.categoriesTask cancel];
    [self.emojiWallTask cancel];
    
    [self loadFromDisk:[[MEAPIManager client] cacheNameWithChannel:@"categories"]];
    
    self.categoriesTask = [manager GET:url parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSError * error;
        NSData * jsonData = [NSJSONSerialization dataWithJSONObject:responseObject options:kNilOptions error:&error];
        NSString *path = [[self applicationDocumentsDirectory].path
                          stringByAppendingPathComponent:[[MEAPIManager client] cacheNameWithChannel:@"categories"]];
        [[NSFileManager defaultManager] createFileAtPath:path
                                                contents:jsonData
                                              attributes:nil];
        [[MEAPIManager client] setCategories:[NSArray arrayWithArray:responseObject]];
        NSMutableArray * lockedCat = [NSMutableArray array];
        for (NSDictionary * catDict in responseObject) {
            if ([catDict objectForKey:@"locked"] && [[catDict objectForKey:@"locked"] boolValue] == YES){
                [lockedCat addObject:[catDict objectForKey:@"id"]];
            }
        }
        [[MEAPIManager client] setLockedCategories:[NSArray arrayWithArray:lockedCat]];
        
        self.categories = responseObject;
        self.unlockedGroups = [MakemojiSDK unlockedGroups];
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [self.emojiView reloadData];
        });

        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        //NSLog(@"Error: %@", error);
    }];
    
    [self loadFromDisk:[[MEAPIManager client] cacheNameWithChannel:@"wall"]];
    
}

-(void)unlockedNewCategory:(NSNotification *)note {
    self.unlockedGroups = [MakemojiSDK unlockedGroups];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    [self updatePageControl];
}

-(void)dealloc {
    [[MEAPIManager client] endImageViewSession];
    self.delegate = nil;
    self.emojiView.delegate = nil;
    self.gifCategoryView.delegate = nil;
    self.collectionView.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.emojiView removeObserver:self forKeyPath:@"contentSize"];
}

-(void)loadFromDisk:(NSString *)filename {
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){

    
    NSString *path = [[self applicationDocumentsDirectory].path
                      stringByAppendingPathComponent:filename];
    NSError * error;
    
    NSData * data = [NSData dataWithContentsOfFile:path];
    
    if (data != nil) {
    
        id jsonResponse = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path]
                                        options:kNilOptions
                                          error:&error];
        
        if (jsonResponse != nil) {
            if ([filename containsString:@"categories"]) {
                self.categories = jsonResponse;
            } else if ([filename containsString:@"wall"]) {
                self.trendingEmoji = [jsonResponse objectForKey:@"Trending"];
                self.categoryEmoji = jsonResponse;
            } else if ([filename containsString:@"used"]) {
                self.recentEmoji = jsonResponse;
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [self.emojiView reloadData];
        });
    }
        
    });
}

-(void)setupContentOffset {
    if (self.emojiView.contentSize.width > 0) {
        CGFloat contentSizePages = (self.emojiView.contentSize.width / self.frame.size.width);
        CGFloat ceilPages = ceilf(contentSizePages);
        CGFloat remainderPages = ceilPages - contentSizePages;
        CGFloat remainderOffset = self.frame.size.width * remainderPages;
        self.emojiView.contentInset = UIEdgeInsetsMake(0, 0, 0, floorf(remainderOffset));
    }
}

- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                   inDomains:NSUserDomainMask] lastObject];
}

-(void)getRecentData {
    NSString * url = [NSString stringWithFormat:@"emoji/index/used/255/1/%@", [[MEUserManager sharedManager] userId]];
    [self loadFromDisk:[[MEAPIManager client] cacheNameWithChannel:@"used"]];
    MEAPIManager * manager = [MEAPIManager client];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager GET:url parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSError * error;
        NSData * jsonData = [NSJSONSerialization dataWithJSONObject:responseObject options:kNilOptions error:&error];
        NSString *path = [[self applicationDocumentsDirectory].path
                          stringByAppendingPathComponent:[[MEAPIManager client] cacheNameWithChannel:@"used"]];
        [[NSFileManager defaultManager] createFileAtPath:path
                                                contents:jsonData
                                              attributes:nil];
        
        self.recentEmoji = responseObject;
        if ([self.selected isEqualToString:@"favorite"]) {
            [self.emojiView reloadData];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        //NSLog(@"Error: %@", error);
    }];

}

-(void)deleteButtonTapped {
    [self.delegate performSelector:@selector(deleteButtonTapped) withObject:nil];
}

-(void)deleteButtonRelease {
    [self.delegate performSelector:@selector(deleteButtonRelease) withObject:nil];
}

-(void)globeButtonTapped {
    [self.delegate performSelector:@selector(globeButtonTapped) withObject:nil];
}

-(void)goBack {
    CGFloat collectionHeight = 180;
    if ([[UIScreen mainScreen] bounds].size.height >= 736.0) {
        collectionHeight = 190;
    }
    
    self.collectionView.hidden = NO;
    [UIView animateWithDuration:0.20
                          delay:0
                        options:(UIViewAnimationOptionAllowUserInteraction|
                                 UIViewAnimationOptionBeginFromCurrentState)
                     animations:^(void) {
                         [self.collectionView setFrame:CGRectMake(0, 0, self.collectionView.frame.size.width, self.collectionView.frame.size.height)];
                         [self.titleLabel setAlpha:0];

                     }

                     completion:^(BOOL finished) {
                         
                     }];
    [self.gifCategoryView setHidden:YES];
    CGRect emojiFrame = self.emojiView.frame;
    emojiFrame.size.height = collectionHeight;
    self.emojiView.frame = emojiFrame;
    [self.emojiView setHidden:YES];
    self.selectedCategory = nil;
    self.pageControl.numberOfPages = 0;
    [self.emojiView reloadData];
}

-(void)layoutSubviews {
    [super layoutSubviews];
    [self.deleteButton setFrame:CGRectMake(self.frame.size.width-50, self.collectionView.frame.size.height, 50, 40)];
}

-(void)updatePageControl {
    CGFloat contentSizePages = (self.emojiView.contentSize.width / self.frame.size.width);
    CGFloat ceilPages = ceilf(contentSizePages);
    [self setupContentOffset];
    
    self.pageControl.numberOfPages = ceilPages;
    
    if (self.pageControl.numberOfPages <= 1 || self.selectedCategory == nil || self.pageControl.numberOfPages > 10) {
        self.pageControl.hidden = YES;
    } else {
        self.pageControl.hidden = NO;
    }
}

#pragma mark - UICollectionViewDataSource
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (collectionView == self.collectionView) {
        self.titleLabel.frame = CGRectMake(14, 6, self.collectionView.frame.size.width, self.titleLabel.frame.size.height);
        self.titleLabel.backgroundColor =[UIColor clearColor];
        NSString * catString = [[self.categories objectAtIndex:indexPath.row] objectForKey:@"name"];
        catString = [catString stringByReplacingOccurrencesOfString:@" " withString:@"_"];

        NSNumber * locked = [[self.categories objectAtIndex:indexPath.row] objectForKey:@"locked"];
        
        if (locked != nil && [locked isEqualToNumber:[NSNumber numberWithInteger:1]]) {
            if (![self.unlockedGroups containsObject:[[self.categories objectAtIndex:indexPath.row] objectForKey:@"name"]]) {
                NSDictionary *userInfo = @{@"category": [[self.categories objectAtIndex:indexPath.row] objectForKey:@"name"]};
                [[NSNotificationCenter defaultCenter] postNotificationName:MECategorySelectedLockedCategory object:nil userInfo:userInfo];
                return;
            }
        }
        
        self.selectedCategoryString = catString;
        [UIView animateWithDuration:0.20
                              delay:0
                            options:(UIViewAnimationOptionAllowUserInteraction|
                                     UIViewAnimationOptionBeginFromCurrentState)
                         animations:^(void) {
                             [self.collectionView setFrame:CGRectMake(-self.collectionView.frame.size.width, 0, self.collectionView.frame.size.width, self.collectionView.frame.size.height)];
                             [self.titleLabel setAlpha:1];
                             
                         }
                         completion:^(BOOL finished) {
                             
                         }];
        self.titleLabel.text = [[[self.categories objectAtIndex:indexPath.row] objectForKey:@"name"] uppercaseString];
        self.titleLabel.layer.shadowRadius = 0;
        self.titleLabel.layer.shadowOpacity = 0;
        self.titleLabel.layer.shadowOffset = CGSizeMake(0, 0);
        self.titleLabel.textColor = [UIColor colorWithWhite:0.65 alpha:1];
        self.selectedCategory = indexPath;
        [self.delegate performSelector:@selector(didSelectCategory) withObject:nil];
        
        [self.emojiView setHidden:NO];
        [self.emojiView reloadData];

    } else {
        
        NSString * selectedCategory = [[self.categories objectAtIndex:self.selectedCategory.row] objectForKey:@"name"];
        MEKeyboardCollectionViewCell * cell = (MEKeyboardCollectionViewCell *)[self.emojiView cellForItemAtIndexPath:indexPath];
        
        if ([self.selected isEqualToString:@"favorite"]) {
            [self.delegate performSelector:@selector(didSelectEmoji:image:) withObject:[self.recentEmoji objectAtIndex:indexPath.row] withObject:cell.inputButton.imageView.image];
        }
        
        if ([self.selected isEqualToString:@"trending"]) {
            [self.delegate performSelector:@selector(didSelectEmoji:image:) withObject:[self.trendingEmoji objectAtIndex:indexPath.row] withObject:cell.inputButton.imageView.image];
        }
  
        if ([self.selected isEqualToString:@"category"]) {
            NSDictionary * emoji  = [[self.categoryEmoji objectForKey:selectedCategory] objectAtIndex:indexPath.item];
            
            if ([selectedCategory isEqualToString:@"Phrases"]) {
                [self.delegate performSelector:@selector(didSelectEmoji:image:) withObject:[[self.categoryEmoji objectForKey:selectedCategory] objectAtIndex:indexPath.row] withObject:[UIImage new]];
                return;
            }
            
            [self.delegate performSelector:@selector(didSelectEmoji:image:) withObject:[[self.categoryEmoji objectForKey:selectedCategory] objectAtIndex:indexPath.row] withObject:cell.inputButton.imageView.image];
        }
    
    }
    
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{

    if (self.gifCategoryView == collectionView) {
        return [self.gifCategories count];
    }
    
    if (self.collectionView == collectionView) {
        return [self.categories count];
    }
    
    if ([self.selected isEqualToString:@"favorite"]) {
        return [self.recentEmoji count];
    }
 
    if ([self.selected isEqualToString:@"trending"]) {
        return [self.trendingEmoji count];
    }
    
    if ([self.selected isEqualToString:@"category"]) {
        NSString * selectedCategory = [[self.categories objectAtIndex:self.selectedCategory.row] objectForKey:@"name"];
        return [[self.categoryEmoji objectForKey:selectedCategory]  count];
    }
    
    return 0;
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pageWidth = self.emojiView.frame.size.width;
    float currentPage = self.emojiView.contentOffset.x / pageWidth;
    
    if (0.0f != fmodf(currentPage, 1.0f))
    {
        self.pageControl.currentPage = currentPage + 1;
    }
    else
    {
        self.pageControl.currentPage = currentPage;
    }

}

-(void)selectSection:(NSString *)section {
    self.selected = section;
    [self getRecentData];
    CGFloat collectionHeight = 180;
    if ([[UIScreen mainScreen] bounds].size.height >= 736.0) {
        collectionHeight = 190;
    }

    CGRect emojiFrame = self.emojiView.frame;
    emojiFrame.size.height = collectionHeight;
    self.emojiView.frame = emojiFrame;
    self.titleLabel.layer.shadowRadius = 0;
    self.titleLabel.layer.shadowOpacity = 0;
    self.titleLabel.layer.shadowOffset = CGSizeMake(0, 0);
    self.titleLabel.textColor = [UIColor colorWithWhite:0.65 alpha:1];
    
    if ([self.selected isEqualToString:@"favorite"]) {
        self.collectionView.hidden = YES;
        self.gifCategoryView.hidden = YES;
        self.emojiView.hidden = NO;
        self.titleLabel.alpha = 1.0;
        self.titleLabel.text = @"RECENTLY USED";
        
    }
    
    if ([self.selected isEqualToString:@"trending"]) {
        self.collectionView.hidden = YES;
        self.gifCategoryView.hidden = YES;
        self.emojiView.hidden = NO;
        self.titleLabel.alpha = 1.0;
        self.titleLabel.text = @"TRENDING";
    }

    if ([self.selected isEqualToString:@"category"]) {
        if (self.selectedCategory != nil) {
            self.collectionView.hidden = YES;
            self.emojiView.hidden = NO;
            [self.collectionView reloadData];
            self.pageControl.numberOfPages = 0;
            NSString * catTitle = [[self.categories objectAtIndex:self.selectedCategory.row] objectForKey:@"name"];
            self.titleLabel.text = [catTitle uppercaseString];
            self.titleLabel.alpha = 1.0;
        } else {
            self.collectionView.hidden = NO;
            self.emojiView.hidden = YES;
            self.titleLabel.alpha = 0.0;
        }
    }
    
    [self.emojiView reloadData];
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    
    if (collectionView == self.collectionView) {
        MECategoryCollectionViewCell *photoCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Category" forIndexPath:indexPath];
        NSDictionary * cat = [self.categories objectAtIndex:indexPath.row];
        [photoCell setBackgroundColor:[UIColor clearColor]];
        photoCell.imageView.image = nil;
        [photoCell.imageView sd_setImageWithURL:[NSURL URLWithString:[cat objectForKey:@"image_url"]]
                            placeholderImage:[UIImage imageNamed:@"Makemoji.bundle/MEPlaceholder" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil]];
        photoCell.titleLabel.font = [UIFont systemFontOfSize:13];
        photoCell.titleLabel.textColor = [UIColor colorWithWhite:0.65 alpha:1];
        photoCell.titleLabel.text = [[cat objectForKey:@"name"] uppercaseString];

        if ([cat objectForKey:@"locked"] &&
            [[cat objectForKey:@"locked"] boolValue] == YES &&
            [self.unlockedGroups containsObject:[cat objectForKey:@"name"]] == NO)
        {
            photoCell.lockedImageView.hidden = NO;
            photoCell.lockedImageView.image = [UIImage imageNamed:self.lockedImagePath];
        } else {
            photoCell.lockedImageView.hidden = YES;
            photoCell.lockedImageView.image = nil;
        }
        
        return photoCell;
    }
 
    NSString * selectedCategory;
    if ([self.selected isEqualToString:@"category"]) {
        selectedCategory = [[self.categories objectAtIndex:self.selectedCategory.row] objectForKey:@"name"];
        if ([selectedCategory isEqualToString:@"Phrases"]) {
            MEKeyboardPhraseCollectionViewCell *photoCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Phrase" forIndexPath:indexPath];
            [photoCell setData:[[self.categoryEmoji objectForKey:selectedCategory] objectAtIndex:indexPath.row]];
            
            return photoCell;
        }
    }
    
    MEKeyboardCollectionViewCell *photoCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Emoji" forIndexPath:indexPath];
    [photoCell setBackgroundColor:[UIColor clearColor]];
    photoCell.inputButton.imageView.image = nil;
    photoCell.inputButton.gifImageView.image = nil;
    photoCell.inputButton.gifImageView.animatedImage = nil;
    
    [photoCell.inputButton.layer removeAllAnimations];
    NSDictionary * emojiDict;
    NSString * emojiId;
    
    if ([self.selected isEqualToString:@"favorite"]) {
        emojiDict = [self.recentEmoji objectAtIndex:indexPath.item];
    } else if ([self.selected isEqualToString:@"category"]) {
        selectedCategory = [[self.categories objectAtIndex:self.selectedCategory.row] objectForKey:@"name"];
        emojiDict = [[self.categoryEmoji objectForKey:selectedCategory] objectAtIndex:indexPath.item];
    } else if ([self.selected isEqualToString:@"trending"]) {
         emojiDict = [self.trendingEmoji objectAtIndex:indexPath.item];
    }
        
    emojiId = [[emojiDict objectForKey:@"id"] stringValue];
    [[MEAPIManager client] imageViewWithId:emojiId];
    
    if ([[emojiDict objectForKey:@"gif"] boolValue] == YES) {
        
        [photoCell.inputButton.gifImageView sd_setImageWithURL:[NSURL URLWithString:[emojiDict objectForKey:@"image_url"]]
                                           placeholderImage:[UIImage imageNamed:@"Makemoji.bundle/MEPlaceholder" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil]];
    } else {
        
        [photoCell.inputButton.imageView sd_setImageWithURL:[NSURL URLWithString:[emojiDict objectForKey:@"image_url"]]
                                        placeholderImage:[UIImage imageNamed:@"Makemoji.bundle/MEPlaceholder" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil]];
    
    }
    
    if ([emojiDict objectForKey:@"link_url"] != [NSNull null] && [[emojiDict objectForKey:@"link_url"] length] > 7) {
        [photoCell startLinkAnimation];
    }

    return photoCell;
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == self.collectionView) {
        CGFloat itemWidth = self.frame.size.width / 4;
        return CGSizeMake(itemWidth, 88);
    }

    if (collectionView == self.gifCategoryView) {
        CGFloat collectionHeight = 180;
        if ([[UIScreen mainScreen] bounds].size.height >= 736.0) {
            collectionHeight = 190;
        }

        CGFloat gifCatWidth = 0; //rect.size.width+10;
        gifCatWidth = self.frame.size.width/3-3;
        return CGSizeMake(gifCatWidth, (collectionHeight/3)-10-6);
    }

    CGFloat modifier = 8;
    if (self.frame.size.width <= 320) {
        modifier = 7;
    }
    
    if ([self.selected isEqualToString:@"category"]) {
        NSDictionary * catDict = [self.categories objectAtIndex:self.selectedCategory.row];
        NSString * selectedCategory = [catDict objectForKey:@"name"];
        NSDictionary * dict = [[self.categoryEmoji objectForKey:selectedCategory] objectAtIndex:indexPath.row];
        
        if ([[catDict objectForKey:@"gif"] boolValue] == YES) {
            return CGSizeMake((self.emojiView.frame.size.width/2),self.emojiView.frame.size.height);
        }
        
        NSNumber * isPhrase = [dict objectForKey:@"phrase"];
        if (isPhrase == nil) {

        } else {
            CGFloat width = ([[dict objectForKey:@"emoji"] count] * 32);
            return CGSizeMake(width, 34);
        }
    }
    
    return CGSizeMake((self.emojiView.frame.size.width/modifier),34);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    if (collectionView == self.gifCategoryView) {
        return UIEdgeInsetsMake(35, 0, 5, 0);
    }
    
    if(collectionView == self.collectionView) {
        return UIEdgeInsetsMake(0, 1, 0, 1);
    }
    
    if ([self.selected isEqualToString:@"category"] && self.categories.count > 0) {
        NSString * selectedCategory = [[self.categories objectAtIndex:self.selectedCategory.row] objectForKey:@"name"];
        
        NSDictionary * category = [self.categories objectAtIndex:self.selectedCategory.row];
        if ([[category objectForKey:@"gif"] boolValue] == YES) {
            return UIEdgeInsetsMake(0, 0, 0, 0);
        }
        
        if ([selectedCategory isEqualToString:@"Phrases"]) {
            return UIEdgeInsetsMake(31, 10, 0, 10);
        }
    }
    
    return UIEdgeInsetsMake(31, 0, 0, 0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    if (collectionView == self.collectionView) {
        return 0;
    }
    
    if (collectionView == self.gifCategoryView) {
        return 4;
    }
    
    if ([self.selected isEqualToString:@"category"] && self.categories.count > 0) {
        NSString * selectedCategory = [[self.categories objectAtIndex:self.selectedCategory.row] objectForKey:@"name"];
        
        if ([selectedCategory isEqualToString:@"Phrases"]) {
            return 2;
        }
    }
    
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    if (collectionView == self.collectionView) {
        return 0;
    }
    
    if (collectionView == self.gifCategoryView) {
        return 2;
    }
    
    if ([self.selected isEqualToString:@"category"] && self.categories.count > 0) {
        NSString * selectedCategory = [[self.categories objectAtIndex:self.selectedCategory.row] objectForKey:@"name"];
        
        if ([selectedCategory isEqualToString:@"Phrases"]) {
            return 22;
        }
    }
    
    return 0;
    
}

@end
