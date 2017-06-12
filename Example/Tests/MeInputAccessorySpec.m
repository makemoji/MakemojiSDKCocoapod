//
//  MeInputAccessorySpec.m
//  Makemoji-SDK
//
//  Created by David Muñoz - Simplex Software on 12/6/17.
//  Copyright © 2017 Makemoji. All rights reserved.
//

#import "Specta.h"
#import "Expecta.h"
#import "MeInputAccessoryView.h"
#import "OCMock.h"
#import "MEAPIManager.h"
#import "MEInputView.h"
#import "DTHTMLElement.h"

SpecBegin(MeInputAccessoryView)

describe(@"MeInputAccessoryView", ^{
    
    __block MEInputAccessoryView *classUnderTest;
    beforeAll(^{
        
    });
    
    beforeEach(^{
        id meapimanagerClassMock  = [OCMockObject mockForClass:[MEAPIManager class]];
        id meapiManagerPartialMock = [OCMockObject partialMockForObject:[MEAPIManager client]];
        [[[meapimanagerClassMock stub]andReturn:meapiManagerPartialMock]client ];

        [[[meapiManagerPartialMock stub]andDo:nil]GET:[OCMArg any] parameters:[OCMArg any] progress:[OCMArg any] success:[OCMArg any] failure:[OCMArg any]];
        classUnderTest = [[MEInputAccessoryView alloc]init];

        [meapimanagerClassMock stopMocking];
        [meapiManagerPartialMock stopMocking];
    });
    
    it(@"load data succesful case", ^{
        
        //given
        UICollectionViewFlowLayout * navigationLayout = [[UICollectionViewFlowLayout alloc] init];
        navigationLayout.itemSize = CGSizeMake(0,0);
        [navigationLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        navigationLayout.minimumInteritemSpacing = 0;
        navigationLayout.minimumLineSpacing = 0;

        
        id meapimanagerClassMock  = [OCMockObject mockForClass:[MEAPIManager class]];
        id meapiManagerPartialMock = [OCMockObject partialMockForObject:[MEAPIManager client]];
        id inputViewPartialMock = [OCMockObject partialMockForObject:[[MEInputView alloc]init]];
        id emojiViewPartialMock = [OCMockObject partialMockForObject:[[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:navigationLayout]];
        
        [[[meapimanagerClassMock stub]andReturn:meapiManagerPartialMock]client ];
        classUnderTest.meInputView = inputViewPartialMock;
        classUnderTest.emojiView = emojiViewPartialMock;
        [[[emojiViewPartialMock expect]andDo:nil]reloadData];
        
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
        NSDictionary *dictionaryToSend = [[NSDictionary alloc]initWithObjectsAndKeys:arrayTest,@"Trending", nil];
        
        [[[meapiManagerPartialMock expect] andDo:^(NSInvocation *invocation) {
            __unsafe_unretained NSString *url;
            void (^successBlock)(NSURLSessionDataTask *task, id responseObject) = nil;

            NSURLSessionDataTask *datataskfortest =[[NSURLSessionDataTask alloc]init];

            [invocation getArgument:&successBlock atIndex:5];
            [invocation getArgument:&url atIndex:2];
            
            successBlock(datataskfortest, dictionaryToSend);

            expect(url).to.equal(@"emoji/emojiWall?channel=channel");
            
        }]GET:[OCMArg any] parameters:[OCMArg any] progress:[OCMArg any] success:[OCMArg any] failure:[OCMArg any]];
        
        //when
        [classUnderTest loadData];

         waitUntil(^(DoneCallback done) {
             OCMVerify([emojiViewPartialMock reloadData]);
             done();
             
             [emojiViewPartialMock stopMocking];
             [inputViewPartialMock stopMocking];
             [meapiManagerPartialMock stopMocking];
             [meapimanagerClassMock stopMocking];

         });
        //then
        
        OCMVerify([inputViewPartialMock loadData]);
    });
    
    
    it(@"load data failure case", ^{
        
        //given
        UICollectionViewFlowLayout * navigationLayout = [[UICollectionViewFlowLayout alloc] init];
        navigationLayout.itemSize = CGSizeMake(0,0);
        [navigationLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        navigationLayout.minimumInteritemSpacing = 0;
        navigationLayout.minimumLineSpacing = 0;
        
        
        id meapimanagerClassMock  = [OCMockObject mockForClass:[MEAPIManager class]];
        id meapiManagerPartialMock = [OCMockObject partialMockForObject:[MEAPIManager client]];
        id inputViewPartialMock = [OCMockObject partialMockForObject:[[MEInputView alloc]init]];
        id emojiViewPartialMock = [OCMockObject partialMockForObject:[[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:navigationLayout]];
        
        [[[meapimanagerClassMock stub]andReturn:meapiManagerPartialMock]client ];
        classUnderTest.meInputView = inputViewPartialMock;
        classUnderTest.emojiView = emojiViewPartialMock;
        [[[emojiViewPartialMock expect]andDo:nil]reloadData];
        
        [[[meapiManagerPartialMock expect] andDo:^(NSInvocation *invocation) {
            __unsafe_unretained NSString *url;
            void (^failureBlock)(NSURLSessionDataTask *task, NSError *error) = nil;
            
            [invocation getArgument:&failureBlock atIndex:6];
            [invocation getArgument:&url atIndex:2];
            
            failureBlock(nil, nil);
            expect(url).to.equal(@"emoji/emojiWall?channel=channel");
            
        }]GET:[OCMArg any] parameters:[OCMArg any] progress:[OCMArg any] success:[OCMArg any] failure:[OCMArg any]];
        
        //when
        [classUnderTest loadData];
        
        waitUntil(^(DoneCallback done) {
            OCMReject([emojiViewPartialMock reloadData]);
            done();
            
        });
    
        //then
        OCMReject([inputViewPartialMock loadData]);
    });
    
    it(@"did select category", ^{
        //given
        expect(classUnderTest.backButton.alpha).to.equal(0);
        
        //when
        [classUnderTest didSelectCategory];
        
        //then
        expect(classUnderTest.backButton.alpha).to.equal(1);
    });
    
    it(@"reset flashtags", ^{
        //given
        classUnderTest.currentToggle = @"toggle";
        classUnderTest.flashtagButton.backgroundColor = [UIColor yellowColor];
        
        //when
        [classUnderTest resetFlashtags];
        
        //then
        expect(classUnderTest.currentToggle).to.equal(@"");
        expect(classUnderTest.flashtagButton.backgroundColor).to.equal([UIColor clearColor]);
        
    });
    
    it(@"did select emoji with gif", ^{
        
        //given
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:1],@"gif", nil];
        id partialMock = [OCMockObject partialMockForObject:classUnderTest];
        
        [[[partialMock expect]andDo:nil]didSelectGif:[OCMArg any]];
        
        //when
        [classUnderTest didSelectEmoji:dict image:[[UIImage alloc] init]];
        
        //then
        OCMVerify([partialMock didSelectGif:[OCMArg any]]);
        
    });
    
    it(@"did select emoji", ^{
        //given
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNull null], @"link_url",
                              [NSNull null], @"flashtag",
                              @"", @"image_url",
                              [NSNumber numberWithInt:1001],@"id",
                              nil];
        id partialMock = [OCMockObject partialMockForObject:classUnderTest];
        
        OCMReject([partialMock didSelectGif:[OCMArg any]]);

        id meapimanagerClassMock = [OCMockObject mockForClass:[MEAPIManager class]];
        id meapimanagerPartialMock = [OCMockObject partialMockForObject:[MEAPIManager client]];
        [[[meapimanagerClassMock stub]andReturn:partialMock]client];
        
        [[[meapimanagerPartialMock expect]andDo:^(NSInvocation *invocation) {
            __unsafe_unretained NSDictionary *receivedDict;
            
            [invocation getArgument:&receivedDict atIndex:2];
            
            expect(receivedDict).to.equal(dict);
        }] clickWithEmoji:[OCMArg any]];
        
        //when
        [classUnderTest didSelectEmoji:dict image:[[UIImage alloc] init]];
        
        //then
    });
    
   
    it(@"did select gif without link url" , ^{
       //given
        id meapimanagerClassMock = [OCMockObject mockForClass:[MEAPIManager class]];
        id meapimanagerPartialMock = [OCMockObject partialMockForObject:[MEAPIManager client]];
        [[[meapimanagerClassMock stub]andReturn:meapimanagerPartialMock]client];
        NSDictionary *dict  = [NSDictionary dictionaryWithObjectsAndKeys:
                               @"40x40_url",@"40x40_url",
                               [NSNumber numberWithInt:1001],@"id",
                               [NSNull null],@"link_url",
                               @"imgurl", @"image_url",
                               nil];
        [[[meapimanagerPartialMock expect] andDo:^(NSInvocation *invocation) {
            __unsafe_unretained NSDictionary *receivedDict ;
            
            [invocation getArgument:&receivedDict atIndex:2];
            expect(receivedDict).toNot.beNil();
            expect(receivedDict).to.equal(dict);
        }]clickWithEmoji:[OCMArg any]];

        
        //when
        [classUnderTest didSelectGif:dict];
        
        //then
        
    });
    
    it(@"did select gif with link url" , ^{
        //given
        id meapimanagerClassMock = [OCMockObject mockForClass:[MEAPIManager class]];
        id meapimanagerPartialMock = [OCMockObject partialMockForObject:[MEAPIManager client]];
        [[[meapimanagerClassMock stub]andReturn:meapimanagerPartialMock]client];
        NSDictionary *dict  = [NSDictionary dictionaryWithObjectsAndKeys:
                               @"40x40_url",@"40x40_url",
                               [NSNumber numberWithInt:1001],@"id",
                               @"link_url",@"link_url",
                               @"imgurl", @"image_url",
                               nil];
        [[[meapimanagerPartialMock expect] andDo:^(NSInvocation *invocation) {
            __unsafe_unretained NSDictionary *receivedDict ;
            
            [invocation getArgument:&receivedDict atIndex:2];
            expect(receivedDict).toNot.beNil();
            expect(receivedDict).to.equal(dict);
        }]clickWithEmoji:[OCMArg any]];
        
        
        //when
        [classUnderTest didSelectGif:dict];
        
        [meapimanagerClassMock stopMocking];
        [meapimanagerPartialMock stopMocking];
    });
    
    it(@"intro bar animation with animation", ^{
        //given
        classUnderTest.titleLabel.alpha = 1;
        classUnderTest.emojiView.frame = CGRectMake(100, 100, 100, 100);
        classUnderTest.flashtagCollectionView.frame = CGRectMake(100, 100, 100, 100);
        
        //when
        [classUnderTest introBarAnimation:YES];
        
        //then
        expect(classUnderTest.titleLabel.alpha).to.equal(0);
        expect(classUnderTest.emojiView.frame).toNot.equal(CGRectMake(100, 100, 100, 100));
        expect(classUnderTest.flashtagCollectionView.frame).toNot.equal(CGRectMake(100, 100, 100, 100));
    });
    
    
    it(@"intro bar animation without animation", ^{
        //given
        classUnderTest.titleLabel.alpha = 1;
        classUnderTest.emojiView.frame = CGRectMake(100, 100, 100, 100);
        classUnderTest.flashtagCollectionView.frame = CGRectMake(100, 100, 100, 100);
        
        //when
        [classUnderTest introBarAnimation:NO];
        
        //then
        expect(classUnderTest.titleLabel.alpha).to.equal(0);
        expect(classUnderTest.emojiView.frame).toNot.equal(CGRectMake(100, 100, 100, 100));
        expect(classUnderTest.flashtagCollectionView.frame).toNot.equal(CGRectMake(100, 100, 100, 100));
    });
    
    afterEach(^{
        classUnderTest = nil;
    });
    
    afterAll(^{
        
    });
});

SpecEnd
