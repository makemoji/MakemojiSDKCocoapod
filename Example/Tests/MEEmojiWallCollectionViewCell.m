//
//  MEEmojiWallCollectionViewCell.m
//  Makemoji-SDK
//
//  Created by David Muñoz - Simplex Software on 14/6/17.
//  Copyright © 2017 Makemoji. All rights reserved.
//

#import "Specta.h"
#import "Expecta.h"
#import "OCMock.h"
#import "MEEmojiWallCollectionViewCell.h"

SpecBegin(MEEmojiWallCollectionViewCellSpec)

describe(@"MEEmojiWallCollectionViewCellSpec", ^{
    
    __block MEEmojiWallCollectionViewCell *classUnderTest;
    
    beforeAll(^{
        
    });
    
    beforeEach(^{
        classUnderTest = [[MEEmojiWallCollectionViewCell alloc]init];
    });
    
    it(@"set emoji data nil case", ^{
        //given
        UICollectionViewFlowLayout * navigationLayout = [[UICollectionViewFlowLayout alloc] init];
        navigationLayout.itemSize = CGSizeMake(0,0);
        [navigationLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        navigationLayout.minimumInteritemSpacing = 0;
        navigationLayout.minimumLineSpacing = 0;
        

        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:navigationLayout];
        id collectionViewMock = [OCMockObject partialMockForObject:collectionView];
        
        [[[collectionViewMock stub] andDo:nil] reloadData];
        classUnderTest.emojiCollectionView = collectionViewMock;
        
        //when
        [classUnderTest setEmojiData:nil];
        
        //then
        [[collectionViewMock verify]reloadData];
        expect(classUnderTest.emoji.count).to.equal(0);
    });
    
    it(@"set emoji data with video case", ^{
        //given
        UICollectionViewFlowLayout * navigationLayout = [[UICollectionViewFlowLayout alloc] init];
        navigationLayout.itemSize = CGSizeMake(0,0);
        [navigationLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        navigationLayout.minimumInteritemSpacing = 0;
        navigationLayout.minimumLineSpacing = 0;
        
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:navigationLayout];
        id collectionViewMock = [OCMockObject partialMockForObject:collectionView];
        
        [[[collectionViewMock stub] andDo:nil] reloadData];
        classUnderTest.emojiCollectionView = collectionViewMock;
        
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithInt:1] ,@"video",
                              nil];
        NSArray *array = [NSArray arrayWithObject:dict];
        //when
        [classUnderTest setEmojiData:array];
        
        //then
        [[collectionViewMock verify]reloadData];
        expect(classUnderTest.emoji.count).to.equal(1);
        expect(classUnderTest.isVideoCollection).to.beTruthy();
    });
    
    it(@"set emoji data without video case", ^{
        //given
        UICollectionViewFlowLayout * navigationLayout = [[UICollectionViewFlowLayout alloc] init];
        navigationLayout.itemSize = CGSizeMake(0,0);
        [navigationLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        navigationLayout.minimumInteritemSpacing = 0;
        navigationLayout.minimumLineSpacing = 0;
        
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:navigationLayout];
        id collectionViewMock = [OCMockObject partialMockForObject:collectionView];
        
        [[[collectionViewMock stub] andDo:nil] reloadData];
        classUnderTest.emojiCollectionView = collectionViewMock;
        
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithInt:0] ,@"video",
                              nil];
        NSArray *array = [NSArray arrayWithObject:dict];
        //when
        [classUnderTest setEmojiData:array];
        
        //then
        [[collectionViewMock verify]reloadData];
        expect(classUnderTest.emoji.count).to.equal(1);
        expect(classUnderTest.isVideoCollection).to.beFalsy();
    });
    it(@"set emoji data same emoji case", ^{
        //given
        UICollectionViewFlowLayout * navigationLayout = [[UICollectionViewFlowLayout alloc] init];
        navigationLayout.itemSize = CGSizeMake(0,0);
        [navigationLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        navigationLayout.minimumInteritemSpacing = 0;
        navigationLayout.minimumLineSpacing = 0;
        
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:navigationLayout];
        id collectionViewMock = [OCMockObject partialMockForObject:collectionView];
        
        [[[collectionViewMock stub] andDo:nil] reloadData];
        classUnderTest.emojiCollectionView = collectionViewMock;
        
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithInt:0] ,@"video",
                              nil];
        NSArray *array = [NSArray arrayWithObject:dict];
        [classUnderTest setEmoji:array];
        
        //when
        [classUnderTest setEmojiData:array];
        
        //then
        [[collectionViewMock reject]reloadData];
        expect(classUnderTest.emoji.count).to.equal(1);
        expect(classUnderTest.isVideoCollection).to.beFalsy();
    });

    
    afterEach(^{
        
    });
    
    afterAll(^{
        
    });
});

SpecEnd
