//
//  _ApiManagerSpec.m
//  Makemoji-SDK
//
//  Created by David Muñoz - Simplex Software on 26/5/17.
//  Copyright © 2017 Makemoji. All rights reserved.
//

#import <Specta/Specta.h> 
#import <Expecta/Expecta.h> 
#import "MEApiManager.h"
#import "OCMock.h"

SpecBegin(MEApiManager)

describe(@"MEApiManager", ^{
    
    __block  id apiManagerPartialMock;
    __block  id apiManagerClassMock;
    __block  MEAPIManager *apiManagerUnderTest;
    
    beforeAll(^{

    });
    
    beforeEach(^{
        apiManagerUnderTest = nil;
        [apiManagerPartialMock stopMocking];
        [apiManagerClassMock stopMocking];
    });
    
    
    it(@"cache name with channel", ^{
        //given
        NSString *channelTestName = @"testChannel";
        apiManagerUnderTest = [MEAPIManager client];
        apiManagerUnderTest.channel = channelTestName;
        
        //when
        NSString *resultTestChannel = [apiManagerUnderTest cacheNameWithChannel:@"testCacheName"];
        
        //then
        
        expect(resultTestChannel).to.equal(@"testChannel-testCacheName.json");
    });

    
    it(@"cacheNameWithChannel empty channel string", ^{
        //Given
        NSString *channelTestName = @"";
        apiManagerUnderTest = [MEAPIManager client];
        apiManagerUnderTest.channel = channelTestName;
        
        //when
        
        NSString *resultTestChannel = [apiManagerUnderTest cacheNameWithChannel:@"testCacheName"];
        
        //then
        expect(resultTestChannel).to.equal(@"testCacheName.json");
    });
    
    it(@"image view with id single call", ^{
        //given
        apiManagerUnderTest = [MEAPIManager client];
        apiManagerUnderTest.imageViewSessionStart = nil;
        apiManagerUnderTest.imageViews = nil;
        
        //when
        [apiManagerUnderTest imageViewWithId:@"1001"];
        
        //then
        expect(apiManagerUnderTest.imageViews.count).to.equal(1);
        
        NSString *emojiId = [[apiManagerUnderTest.imageViews objectForKey:@"1001"]objectForKey:@"emoji_id"];
        expect(emojiId).to.equal(@"1001");
        
        NSString *emojiViewCount = [[apiManagerUnderTest.imageViews objectForKey:@"1001"]objectForKey:@"views"];
        expect(emojiViewCount).to.equal(@"1");
        
    });
    
    it(@"test image view with id mulple calls multiples emoji id", ^{
        //given
        apiManagerUnderTest = [MEAPIManager client];
        apiManagerUnderTest.imageViewSessionStart = nil;
        apiManagerUnderTest.imageViews = nil;
        
        //when
        [apiManagerUnderTest imageViewWithId:@"1001"];
        [apiManagerUnderTest imageViewWithId:@"1001"];
        [apiManagerUnderTest imageViewWithId:@"1002"];
        [apiManagerUnderTest imageViewWithId:@"1003"];
        
        //then
        expect(apiManagerUnderTest.imageViews.count).to.equal(3);
        
        NSString *emojiId = [[apiManagerUnderTest.imageViews objectForKey:@"1001"] objectForKey:@"emoji_id"];
        expect(emojiId).to.equal(@"1001");
        
        emojiId = [[apiManagerUnderTest.imageViews objectForKey:@"1002"] objectForKey:@"emoji_id"];
        expect(emojiId).to.equal(@"1002");
        
        emojiId = [[apiManagerUnderTest.imageViews objectForKey:@"1003"] objectForKey:@"emoji_id"];
        expect(emojiId).to.equal(@"1003");
        
        NSString *emojiViewCount = [[apiManagerUnderTest.imageViews objectForKey:@"1001"] objectForKey:@"views"];
        expect(emojiViewCount).to.equal(@"2");
        
        emojiViewCount = [[apiManagerUnderTest.imageViews objectForKey:@"1002"] objectForKey:@"views"];
        expect(emojiViewCount).to.equal(@"1");

        emojiViewCount = [[apiManagerUnderTest.imageViews objectForKey:@"1003"] objectForKey:@"views"];
        expect(emojiViewCount).to.equal(@"1");

    });
    it(@"image view with id after thirty seconds should end session", ^{
    
        //given
        apiManagerUnderTest = [MEAPIManager client];
        apiManagerClassMock = OCMClassMock([MEAPIManager class]);
        apiManagerPartialMock = OCMPartialMock(apiManagerUnderTest);
        
        OCMStub([apiManagerClassMock client]).andReturn(apiManagerPartialMock);
        OCMStub([apiManagerPartialMock endImageViewSession]).andDo(nil);
        
        apiManagerUnderTest.imageViewSessionStart = [[NSDate date] dateByAddingTimeInterval:-31];
        apiManagerUnderTest.imageViews = nil;
        
        //when
        [apiManagerUnderTest imageViewWithId:@"1001"];
        
        //then
        OCMVerify([apiManagerPartialMock endImageViewSession]);
        
    });
    
    it(@"image view with id before thirty seconds should not end session", ^{
        //given
        apiManagerUnderTest = [MEAPIManager client];
        apiManagerClassMock = OCMClassMock([MEAPIManager class]);
        apiManagerPartialMock = OCMPartialMock(apiManagerUnderTest);
        
        OCMStub([MEAPIManager client]).andReturn(apiManagerPartialMock);
        
        apiManagerUnderTest.imageViewSessionStart = [[NSDate date] dateByAddingTimeInterval:-15];
        apiManagerUnderTest.imageViews = nil;
        
        //when
        [apiManagerUnderTest imageViewWithId:@"1001"];
        
        //then
        OCMReject([apiManagerPartialMock endImageViewSession]);
    });
    
    it(@"end image view session", ^{
        //given
        apiManagerUnderTest = [MEAPIManager client];
        apiManagerClassMock = OCMClassMock([MEAPIManager class]);
        apiManagerPartialMock = OCMPartialMock(apiManagerUnderTest);
        
        OCMStub([MEAPIManager client]).andReturn(apiManagerPartialMock);
        apiManagerUnderTest.imageViews = nil;
        
        [apiManagerUnderTest imageViewWithId:@"1001"];
        
        [[[apiManagerPartialMock expect] andDo:^(NSInvocation *invocation) {
           __unsafe_unretained NSString *url = nil;
           __unsafe_unretained NSDictionary *dictionary = nil;
            
            [invocation getArgument:&url atIndex:2];
            [invocation getArgument:&dictionary atIndex:3];
            
            expect(url).to.equal(@"emoji/viewTrack");
            expect([[dictionary objectForKey:@"1001"]objectForKey:@"emoji_id"]).to.equal(@"1001");
            expect([[dictionary objectForKey:@"1001"] objectForKey:@"views"]).to.equal(@"1");
            
        }]POST:[OCMArg any] parameters:[OCMArg any] progress:[OCMArg any] success:[OCMArg any] failure:[OCMArg any]];
        
        //when
        [apiManagerPartialMock endImageViewSession];
        
        //then
        OCMVerify([apiManagerPartialMock POST:[OCMArg any] parameters:[OCMArg any] progress:[OCMArg any] success:[OCMArg any] failure:[OCMArg any]]);
    });

    
   it(@"click with emoji single emoji", ^{
       
        //given
        apiManagerUnderTest = [MEAPIManager client];
        apiManagerUnderTest.emojiClicks = nil;
        
        NSMutableDictionary *emoji = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
                                      @"65243", @"id",
                                      @"Music", @"category_name",
                                      @"0",@"gif",
                                      @"0",@"category_image",
                                      nil];
        
        //when
        [apiManagerUnderTest clickWithEmoji:emoji];
        
        //then
        NSDictionary *generatedDict = [apiManagerUnderTest.emojiClicks objectAtIndex:0];
        expect(apiManagerUnderTest.emojiClicks.count).to.equal((long)1);
        expect([generatedDict objectForKey:@"id"]).to.equal([emoji objectForKey:@"id"]);
        expect([generatedDict objectForKey:@"category_name"]).to.equal([emoji objectForKey:@"category_name"]);
        expect([generatedDict objectForKey:@"gif"]).to.equal([emoji objectForKey:@"gif"]);
        expect([generatedDict objectForKey:@"category_image"]).to.equal([emoji objectForKey:@"category_image"]);
        expect([generatedDict objectForKey:@"click"]).toNot.beNil();
    });
    
    it(@"click with emoji with all attributes", ^{
        
        //given
        apiManagerUnderTest = [MEAPIManager client];
        apiManagerUnderTest.emojiClicks = nil;
        
        NSMutableDictionary *emoji = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"http://testurl.com" ,@"link_url",
                                      @"65243", @"id",
                                      @"test",@"access",
                                      @"123",@"origin_id",
                                      @"remoji", @"remoji",
                                      @"shares", @"shares",
                                      @"legacy",@"legacy",
                                      @"created",@"created",
                                      @"deleted",@"deleted",
                                      @"likes",@"likes",
                                      @"username",@"username",
                                      @"https://d1tvcfe0bfyi6u.cloudfront.net/emoji/65243-large@2x.png",@"image_url",
                                      @"Music", @"category_name",
                                      @"0",@"gif",
                                      @"RadioTower",@"flashtag",
                                      @"Radio Tower",@"name",
                                      @"0",@"category_image",
                                      nil];
        
        //when
        [apiManagerUnderTest clickWithEmoji:emoji];
        
        //then
        NSDictionary *dictGenerated = [apiManagerUnderTest.emojiClicks objectAtIndex:0];
        
        expect(dictGenerated).toNot.equal(emoji);
        
        expect([dictGenerated objectForKey:@"legacy"]).to.beNil();
        expect([dictGenerated objectForKey:@"img_url"]).to.beNil();
        expect([dictGenerated objectForKey:@"username"]).to.beNil();
        expect([dictGenerated objectForKey:@"access"]).to.beNil();
        expect([dictGenerated objectForKey:@"origin_id"]).to.beNil();
        expect([dictGenerated objectForKey:@"likes"]).to.beNil();
        expect([dictGenerated objectForKey:@"deleted"]).to.beNil();
        expect([dictGenerated objectForKey:@"created"]).to.beNil();
        expect([dictGenerated objectForKey:@"remoji"]).to.beNil();
        expect([dictGenerated objectForKey:@"shares"]).to.beNil();
        expect([dictGenerated objectForKey:@"link_url"]).to.beNil();
        expect([dictGenerated objectForKey:@"name"]).to.beNil();
        expect([dictGenerated objectForKey:@"flashtag"]).to.beNil();
    });
    
    it(@"click with emoji count more than 25", ^{
       //given
        apiManagerUnderTest = [MEAPIManager client];
        apiManagerClassMock = OCMClassMock([MEAPIManager class]);
        apiManagerPartialMock = OCMPartialMock(apiManagerUnderTest);
        
        OCMStub([apiManagerClassMock client]).andReturn(apiManagerPartialMock);
        
        apiManagerUnderTest.emojiClicks = nil;
        
        NSMutableDictionary *emoji = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"http://testurl.com" ,@"link_url",
                                      @"65243", @"id",
                                      @"test",@"access",
                                      @"123",@"origin_id",
                                      @"remoji", @"remoji",
                                      @"shares", @"shares",
                                      @"legacy",@"legacy",
                                      @"created",@"created",
                                      @"deleted",@"deleted",
                                      @"likes",@"likes",
                                      @"username",@"username",
                                      @"https://d1tvcfe0bfyi6u.cloudfront.net/emoji/65243-large@2x.png",@"image_url",
                                      @"Music", @"category_name",
                                      @"0",@"gif",
                                      @"RadioTower",@"flashtag",
                                      @"Radio Tower",@"name",
                                      @"0",@"category_image",
                                      nil];
    
        [[[apiManagerPartialMock expect]andDo:^(NSInvocation *invocation) {
            __unsafe_unretained NSString* url;
            __unsafe_unretained NSMutableDictionary* emojiDict;
            
            [invocation getArgument:&url atIndex:2];
            [invocation getArgument:&emojiDict atIndex:3];
            
            expect(url).to.equal(@"emoji/clickTrackBatch");
            expect([emojiDict objectForKey:@"emoji"]).toNot.beNil();
            
            NSError *error;
            NSData *data = [[emojiDict objectForKey:@"emoji"] dataUsingEncoding:NSUTF8StringEncoding];
            NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            
            expect([jsonArray count]).to.equal(26);
            
            for(NSDictionary *dict in jsonArray){
                expect([dict objectForKey:@"category_name"]).to.equal([emoji objectForKey:@"category_name"]);
                expect([dict objectForKey:@"id"]).to.equal([emoji objectForKey:@"id"]);
                expect([dict objectForKey:@"category_image"]).to.equal([emoji objectForKey:@"category_image"]);
                expect([dict objectForKey:@"gif"]).to.equal([emoji objectForKey:@"gif"]);
            }
        }]POST:[OCMArg any] parameters:[OCMArg any] progress:[OCMArg any] success:[OCMArg any] failure:[OCMArg any]];
        
        //when
        for (int i = 0 ; i<=25; i++){
            [apiManagerPartialMock clickWithEmoji:emoji];
        }
        
        //then
        expect([apiManagerPartialMock emojiClicks]).to.beNil();
    });
    
    
    afterEach(^{
    });
    
    afterAll(^{
    });
});

SpecEnd
