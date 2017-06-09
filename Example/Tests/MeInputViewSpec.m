//
//  MeInputViewSpec.m
//  Makemoji-SDK
//
//  Created by David Muñoz - Simplex Software on 9/6/17.
//  Copyright © 2017 Makemoji. All rights reserved.
//

#import "Specta.h"
#import "Expecta.h"
#import "MeInputview.h"
#import "MEAPIManager.h"
#import "OCMock.h"
#import "MakemojiSDK.h"
SpecBegin(MeInputview)

describe(@"MeInputview", ^{
    __block MEInputView *classUnderTest;
    beforeAll(^{
        
    });
    
    beforeEach(^{
        classUnderTest = [[MEInputView alloc]init];

    });
    
    it(@"go back", ^{
        
        //when
        [classUnderTest goBack];
        
        //then
        expect(classUnderTest.gifCategoryView.isHidden).to.beTruthy();
        expect(classUnderTest.emojiView.isHidden).to.beTruthy();
        expect(classUnderTest.collectionView.isHidden).to.beFalsy();
        expect(classUnderTest.selectedCategory).to.beNil();
        expect(classUnderTest.pageControl.numberOfPages).to.equal(0);
        
    });
    
    it(@"select section favorite", ^{
        
        //given
        NSString *category = @"favorite";
        //when
        [classUnderTest selectSection:category];
    
        //then
        expect(classUnderTest.collectionView.isHidden).to.beTruthy();
        expect(classUnderTest.gifCategoryView.isHidden).to.beTruthy();
        expect(classUnderTest.emojiView.isHidden).to.beFalsy();
        expect(classUnderTest.titleLabel.alpha).to.equal(1.0);
        expect(classUnderTest.titleLabel.text).to.equal(@"RECENTLY USED");
    });

    it(@"select section trending", ^{
        
        //given
        NSString *category = @"trending";
        //when
        [classUnderTest selectSection:category];
        
        //then
        expect(classUnderTest.collectionView.isHidden).to.beTruthy();
        expect(classUnderTest.gifCategoryView.isHidden).to.beTruthy();
        expect(classUnderTest.emojiView.isHidden).to.beFalsy();
        expect(classUnderTest.titleLabel.alpha).to.equal(1.0);
        expect(classUnderTest.titleLabel.text).to.equal(@"TRENDING");
    });
    
    it(@"select section category", ^{
        
        //given
        NSString *category = @"category";
        //when
        [classUnderTest selectSection:category];
        
        //then
        expect(classUnderTest.collectionView.isHidden).to.beFalsy();
        expect(classUnderTest.emojiView.isHidden).to.beTruthy();
        expect(classUnderTest.titleLabel.alpha).to.equal(0.0);
    });

    it(@"load data successful case", ^{
    
        //given
        id apimanagerClassMock = [OCMockObject mockForClass:[MEAPIManager class]];
        id apimanagerPartialMock = [OCMockObject partialMockForObject:[MEAPIManager client]];
        id makemojiSDKClassMock = [OCMockObject mockForClass:[MakemojiSDK class]];
        
        [[[makemojiSDKClassMock stub]andDo:nil] unlockedGroups];
        [[[apimanagerClassMock stub]andReturn:apimanagerPartialMock] client];
        
        
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
        

        
        
        [[[apimanagerPartialMock stub]andDo:^(NSInvocation *invocation) {
            void (^successBlock)(NSURLSessionDataTask *task, id responseObject) = nil;

            [invocation getArgument:&successBlock atIndex:5];
            NSURLSessionDataTask *datataskfortest =[[NSURLSessionDataTask alloc]init];

            successBlock(datataskfortest, dictionaryToSend);
        }] GET:[OCMArg any] parameters:[OCMArg any] progress:[OCMArg any] success:[OCMArg any] failure:[OCMArg any]];
        
        
        //when
        [classUnderTest loadData];
        
        //then
        OCMVerify([makemojiSDKClassMock unlockedGroups]);
        
        [makemojiSDKClassMock stopMocking];
        [apimanagerPartialMock stopMocking];
        [apimanagerClassMock stopMocking];
    });

    it(@"load data failure case", ^{
        //given
        id apimanagerClassMock = [OCMockObject mockForClass:[MEAPIManager class]];
        id apimanagerPartialMock = [OCMockObject partialMockForObject:[MEAPIManager client]];
        id makemojiSDKClassMock = [OCMockObject mockForClass:[MakemojiSDK class]];
        
        [[[makemojiSDKClassMock stub]andDo:nil] unlockedGroups];
        [[[apimanagerClassMock stub]andReturn:apimanagerPartialMock] client];
        
        [[[apimanagerPartialMock stub]andDo:^(NSInvocation *invocation) {
            void (^failureBlock)(NSURLSessionDataTask *task, NSError *error) = nil;
            
            [invocation getArgument:&failureBlock atIndex:6];
            
            failureBlock(nil, nil);
        }] GET:[OCMArg any] parameters:[OCMArg any] progress:[OCMArg any] success:[OCMArg any] failure:[OCMArg any]];
        
        OCMReject([makemojiSDKClassMock unlockedGroups]);

        
        //when
        [classUnderTest loadData];
        
        //then
        
        [makemojiSDKClassMock stopMocking];
        [apimanagerPartialMock stopMocking];
        [apimanagerClassMock stopMocking];

    });
    
    afterEach(^{
        classUnderTest = nil;
    });
    
    afterAll(^{
        
    });
});

SpecEnd
