//
//  MEEmojiWallSpec.m
//  Makemoji-SDK
//
//  Created by David Muñoz - Simplex Software on 31/5/17.
//  Copyright © 2017 Makemoji. All rights reserved.
//
#import <Specta/Specta.h>
#import <Expecta/Expecta.h>
#import "MEEmojiWall.h"
#import "MEApimanager.h"
#import "OCMock.h"

SpecBegin(MEEmojiWall)

describe(@"MEEmojiWall", ^{
    
    __block MEEmojiWall *classUndertest ;
    
    beforeAll(^{
        
    });
    
    beforeEach(^{
        classUndertest = [[MEEmojiWall alloc]init];

    });
    
    it(@"set up layout with size", ^{
        //given
        classUndertest.navigationHeight = 50;
        
        UICollectionViewFlowLayout * navigationLayout = [[UICollectionViewFlowLayout alloc] init];
        navigationLayout.itemSize = CGSizeMake(0,0);
        [navigationLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        navigationLayout.minimumInteritemSpacing = 0;
        navigationLayout.minimumLineSpacing = 0;

        classUndertest.navigationCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:navigationLayout];
        classUndertest.emojiCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:navigationLayout];
        
        //when
        [classUndertest setupLayoutWithSize:CGSizeMake(100, 100)];
        
        //then
        expect(classUndertest.navigationCollectionView.frame).toNot.beNil();
        expect([classUndertest.navigationCollectionView frame]).to.equal(CGRectMake(0, 50, 100,50));
        
        expect(classUndertest.emojiCollectionView.frame).toNot.beNil();
        expect(classUndertest.emojiCollectionView.frame).to.equal(CGRectMake(0, 0, 100,50));
    });
    

    it(@"load emoji succesfully case", ^{
       //given
        
        
        NSMutableDictionary *emojiTest1 = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"(no summary)",@"link_url",
                                           @"52297",@"id",
                                           @"https://d1tvcfe0bfyi6u.cloudfront.net/emoji/52297-large@2x.png", @"image_url",
                                           @"",@"alt",
                                           @"Aquarius" ,@"flashtag",
                                           @"Aquarius", @"Name",
                                           @"tags",@"Aquarius,sign,astrology",
                                           nil];
        
        NSDictionary *emojiTest2 = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"(no summary)",@"link_url",
                                    @"52298",@"id",
                                    @"https://d1tvcfe0bfyi6u.cloudfront.net/emoji/52298-large@2x.png", @"image_url",
                                    @"",@"alt",
                                    @"Aquarius1" ,@"flashtag",
                                    @"Aquarius1", @"Name",
                                    @"tags",@"Aquarius1,sign,astrology",
                                    nil];
        
        NSArray *arrayTest = [[NSArray alloc]initWithObjects:emojiTest1,emojiTest2, nil];
        NSDictionary *dictionaryToSend = [[NSDictionary alloc]initWithObjectsAndKeys:arrayTest,@"Dating", nil];
        
        MEAPIManager *apiManager = [MEAPIManager client];
        id mock = OCMClassMock([MEAPIManager class]);
        id partialMock = OCMPartialMock(apiManager);
        classUndertest = [[MEEmojiWall alloc]init];
        id wallPartialMock = OCMPartialMock(classUndertest);
        OCMStub([mock client]).andReturn(partialMock);

        
        [[[partialMock expect] andDo:^(NSInvocation *invocation) {
            void (^successBlock)(NSURLSessionDataTask *task, id responseObject) = nil;
            NSArray *url;
            [invocation getArgument:&successBlock atIndex:5];
            [invocation getArgument:&url atIndex:2];
            NSURLSessionDataTask *datataskfortest =[[NSURLSessionDataTask alloc]init];
            
            successBlock(datataskfortest, dictionaryToSend);
            
        }] GET:[OCMArg any] parameters:[OCMArg any]  progress:[OCMArg any]  success:[OCMArg any]  failure:[OCMArg any] ];
        
        //WHEN
        [wallPartialMock loadEmoji];
        
        
        //THEN
        expect([[wallPartialMock categoryDictionary]count]).to.equal(1);
        expect([[wallPartialMock categoryDictionary]objectForKey:@"Dating"]).to.equal([dictionaryToSend objectForKey:@"Dating"]);
        
        [wallPartialMock stopMocking];
        [partialMock stopMocking];
        [mock stopMocking];
    });

    it(@"load emoji failure case", ^{
        
        MEAPIManager *apiManager = [MEAPIManager client];
        id mock = [OCMockObject mockForClass:[MEAPIManager class]]; //OCMClassMock([MEAPIManager class]);
        id partialMock =[OCMockObject partialMockForObject:apiManager]; //[OCMPartialMock(apiManager);
        classUndertest = [[MEEmojiWall alloc]init];
        
        id protocolMock = OCMProtocolMock(@protocol(MEEmojiWallDelegate));
        classUndertest.delegate = protocolMock;
        
        id wallPartialMock = OCMPartialMock(classUndertest);
        
        //OCMStub([mock client]).andReturn(partialMock);
        [[[mock expect]andReturn:partialMock] client];
        
        [[[partialMock expect] andDo:^(NSInvocation *invocation) {
            void (^failureBlock)(NSURLSessionDataTask *task, NSError *error) = nil;
            NSArray *url;
            [invocation getArgument:&failureBlock atIndex:6];
            [invocation getArgument:&url atIndex:2];
            NSURLSessionDataTask *datataskfortest =[[NSURLSessionDataTask alloc]init];
            NSError *error = [[NSError alloc]init];
            failureBlock(datataskfortest, error);
            
        }] GET:[OCMArg any] parameters:[OCMArg any]  progress:[OCMArg any]  success:[OCMArg any]  failure:[OCMArg any] ];
        
        OCMStub([protocolMock meEmojiWall:[OCMArg any] failedLoadingEmoji:[OCMArg any]]).andDo(nil);
        
        //WHEN
        [wallPartialMock loadEmoji];
        
        
        //THEN
        
        OCMVerify([protocolMock meEmojiWall:[OCMArg any] failedLoadingEmoji:[OCMArg any]]);

        [wallPartialMock stopMocking];
        [partialMock stopMocking];
        [mock stopMocking];
        [protocolMock stopMocking];
    });

    it(@"load category no emojies", ^{
        //Given
        classUndertest.categories = nil;
        NSMutableArray *categoriesArray = [[NSMutableArray alloc]initWithObjects:@"category1",@"category2", nil];
        classUndertest.categories = categoriesArray;
        classUndertest.shouldDisplayUsedEmoji = NO;
        classUndertest.shouldDisplayUnicodeEmoji = NO;
        classUndertest.shouldDisplayTrendingEmoji = NO;
        id partialMock = [OCMockObject partialMockForObject:classUndertest];
        
        [[[partialMock stub] andDo:nil] loadEmoji];
        
        //when
        [classUndertest loadedCategoryData];
        
        //then
        expect(classUndertest.categories).to.equal(categoriesArray);
        
        [partialMock stopMocking];
    });
    
    it(@"load cateogory with one emoji", ^{
        //Given
        classUndertest.categories = nil;
        NSMutableArray *categoriesArray = [[NSMutableArray alloc]initWithObjects:@"category1",@"category2", nil];
        NSDictionary *unicodeEmojiDict = [NSDictionary dictionaryWithObjectsAndKeys:@"http://",@"image_url",@"Osemoji",@"name", nil];
        NSDictionary *usedEmojiDict = [NSDictionary dictionaryWithObjectsAndKeys:@"http://",@"image_url",@"Used",@"name", nil];
        NSDictionary *trendingEmojiDict = [NSDictionary dictionaryWithObjectsAndKeys:@"http://",@"image_url",@"Trending",@"name", nil];
        
        classUndertest.categories = categoriesArray;
        classUndertest.shouldDisplayUsedEmoji = YES;
        classUndertest.shouldDisplayUnicodeEmoji = NO;
        classUndertest.shouldDisplayTrendingEmoji = NO;
        
        id partialMock = [OCMockObject partialMockForObject:classUndertest];
        [[[partialMock stub]andDo:nil] loadEmoji];
        //when
        [classUndertest loadedCategoryData];
        
        //then
        expect(classUndertest.categories).toNot.equal(categoriesArray);
        expect(classUndertest.categories).toNot.contain(unicodeEmojiDict);
        expect(classUndertest.categories).to.contain(usedEmojiDict);
        expect(classUndertest.categories).toNot.contain(trendingEmojiDict);
    });
    

    it(@"load category with all emojies", ^{
        //Given
        classUndertest.categories = nil;
        NSMutableArray *categoriesArray = [[NSMutableArray alloc]initWithObjects:@"category1",@"category2", nil];
        NSDictionary *unicodeEmojiDict = [NSDictionary dictionaryWithObjectsAndKeys:@"http://",@"image_url",@"Osemoji",@"name", nil];
        NSDictionary *usedEmojiDict = [NSDictionary dictionaryWithObjectsAndKeys:@"http://",@"image_url",@"Used",@"name", nil];
        NSDictionary *trendingEmojiDict = [NSDictionary dictionaryWithObjectsAndKeys:@"http://",@"image_url",@"Trending",@"name", nil];
        
        classUndertest.categories = categoriesArray;
        classUndertest.shouldDisplayUsedEmoji = YES;
        classUndertest.shouldDisplayUnicodeEmoji = YES;
        classUndertest.shouldDisplayTrendingEmoji = YES;
        
        
        id partialMock = [OCMockObject partialMockForObject:classUndertest];
        [[[partialMock stub]andDo:nil] loadEmoji];
        
        //when
        [classUndertest loadedCategoryData];
        
        //then
        expect(classUndertest.categories).toNot.equal(categoriesArray);
        expect(classUndertest.categories).to.contain(unicodeEmojiDict);
        expect(classUndertest.categories).to.contain(usedEmojiDict);
        expect(classUndertest.categories).to.contain(trendingEmojiDict);
    });
    
    afterEach(^{
        classUndertest = nil;

    });
    
    afterAll(^{
        
    });
});

SpecEnd;
