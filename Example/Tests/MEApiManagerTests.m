//
//  Tests.m
//  Tests
//
//  Created by David on 24/5/17.
//
//

#import <XCTest/XCTest.h>
#import "MEAPIManager.h"
#import "OCMock.h"

@interface ApiManagerTests : XCTestCase

@property (nonatomic, strong) MEAPIManager *apiManagerUnderTest;

@property (nonatomic) id apiManagerPartialMock;
@property (nonatomic) id apiManagerClassMock;

@end

@implementation ApiManagerTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    _apiManagerUnderTest = nil;
    [_apiManagerClassMock stopMocking];
    [_apiManagerPartialMock stopMocking];
    
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)createClientTest {
    //given
    XCTAssertNil(_apiManagerUnderTest);
    
    //when
    _apiManagerUnderTest = [MEAPIManager client];

    //then
    XCTAssertNotNil(_apiManagerUnderTest);
}

-(void)testCacheNameWithChannel
{
    //Given
    NSString *channelTestName = @"testChannel";
    _apiManagerUnderTest = [MEAPIManager client];
    _apiManagerUnderTest.channel = channelTestName;
    
    //when
    NSString *resultTestChannel = [_apiManagerUnderTest cacheNameWithChannel:@"testCacheName"];
    
    //then
    
    XCTAssertEqualObjects(@"testChannel-testCacheName.json", resultTestChannel);
}

-(void)testCacheNameWithChannelEmptyChannelString{
    //Given
    NSString *channelTestName = @"";
    _apiManagerUnderTest = [MEAPIManager client];
    _apiManagerUnderTest.channel = channelTestName;
    //when
    NSString *resultTestChannel = [_apiManagerUnderTest cacheNameWithChannel:@"testCacheName"];
    
    //then
    
    XCTAssertEqualObjects(@"testCacheName.json", resultTestChannel);
}

-(void)testImageViewWithIdSingleCall {
    
    //given
    _apiManagerUnderTest = [MEAPIManager client];
    _apiManagerUnderTest.imageViewSessionStart = nil;
    _apiManagerUnderTest.imageViews = nil;
    
    //when
    [_apiManagerUnderTest imageViewWithId:@"1001"];
    
    //then
    XCTAssertEqual(_apiManagerUnderTest.imageViews.count,1);
    
    NSString *emojiId = [[_apiManagerUnderTest.imageViews objectForKey:@"1001"] objectForKey:@"emoji_id"];
    XCTAssertEqualObjects(@"1001", emojiId);
 

    NSString *emojiViewCount = [[_apiManagerUnderTest.imageViews objectForKey:@"1001"] objectForKey:@"views"];
    XCTAssertEqualObjects(@"1", emojiViewCount);
}

-(void)testImageViewWithIdMultipleCallsSameEmojiId {
    
    //given
    _apiManagerUnderTest = [MEAPIManager client];
    _apiManagerUnderTest.imageViewSessionStart = nil;
    _apiManagerUnderTest.imageViews = nil;
    
    //when
    [_apiManagerUnderTest imageViewWithId:@"1001"];
    [_apiManagerUnderTest imageViewWithId:@"1001"];
    [_apiManagerUnderTest imageViewWithId:@"1001"];
    [_apiManagerUnderTest imageViewWithId:@"1001"];

    //then
    XCTAssertEqual(_apiManagerUnderTest.imageViews.count,1);
    
    NSString *emojiId = [[_apiManagerUnderTest.imageViews objectForKey:@"1001"] objectForKey:@"emoji_id"];
    XCTAssertEqualObjects(@"1001", emojiId);
    
    
    NSString *emojiViewCount = [[_apiManagerUnderTest.imageViews objectForKey:@"1001"] objectForKey:@"views"];
    XCTAssertEqualObjects(@"4", emojiViewCount);
}

-(void)testImageViewWithIdMultipleCallsMultipleEmojiId {
    
    //given
    _apiManagerUnderTest = [MEAPIManager client];
    _apiManagerUnderTest.imageViewSessionStart = nil;
    _apiManagerUnderTest.imageViews = nil;
    
    //when
    [_apiManagerUnderTest imageViewWithId:@"1"];
    [_apiManagerUnderTest imageViewWithId:@"1"];
    [_apiManagerUnderTest imageViewWithId:@"2"];
    [_apiManagerUnderTest imageViewWithId:@"3"];
    
    //then
    XCTAssertEqual(_apiManagerUnderTest.imageViews.count,3);
    
    NSString *emojiId = [[_apiManagerUnderTest.imageViews objectForKey:@"1"] objectForKey:@"emoji_id"];
    XCTAssertEqualObjects(@"1", emojiId);
    
    emojiId = [[_apiManagerUnderTest.imageViews objectForKey:@"2"] objectForKey:@"emoji_id"];
    XCTAssertEqualObjects(@"2", emojiId);
    
    emojiId = [[_apiManagerUnderTest.imageViews objectForKey:@"3"] objectForKey:@"emoji_id"];
    XCTAssertEqualObjects(@"3", emojiId);
    
    NSString *emojiViewCount = [[_apiManagerUnderTest.imageViews objectForKey:@"1"] objectForKey:@"views"];
    XCTAssertEqualObjects(@"2", emojiViewCount);
    
    emojiViewCount = [[_apiManagerUnderTest.imageViews objectForKey:@"2"] objectForKey:@"views"];
    XCTAssertEqualObjects(@"1", emojiViewCount);
    
    emojiViewCount = [[_apiManagerUnderTest.imageViews objectForKey:@"3"] objectForKey:@"views"];
    XCTAssertEqualObjects(@"1", emojiViewCount);
}


-(void)testImageViewWithIdAfterThirtySecondsShouldEndSession{
    
    //given
    _apiManagerUnderTest = [MEAPIManager client];
    _apiManagerClassMock = OCMClassMock([MEAPIManager class]);
    _apiManagerPartialMock = OCMPartialMock(_apiManagerUnderTest);
    
    OCMStub([_apiManagerClassMock client]).andReturn(_apiManagerPartialMock);
    OCMStub([_apiManagerPartialMock endImageViewSession]).andDo(nil);
    
    
    _apiManagerUnderTest.imageViewSessionStart = [[NSDate date] dateByAddingTimeInterval:-31];
    _apiManagerUnderTest.imageViews = nil;
    
    //when
    [_apiManagerUnderTest imageViewWithId:@"123"];
    
    //then
    OCMVerify([_apiManagerPartialMock endImageViewSession]);
    
}


-(void)testImageViewWithIdBeforeThirtySecondsShouldNotEndSession{
    
    //given
    _apiManagerUnderTest = [MEAPIManager client];
    _apiManagerClassMock = OCMClassMock([MEAPIManager class]);
    _apiManagerPartialMock = OCMPartialMock(_apiManagerUnderTest);
    OCMStub([_apiManagerClassMock client]).andReturn(_apiManagerPartialMock);
    
    _apiManagerUnderTest.imageViewSessionStart = [[NSDate date] dateByAddingTimeInterval:-15];
    _apiManagerUnderTest.imageViews = nil;
    OCMReject([_apiManagerPartialMock endImageViewSession]);
    
    //when
    [_apiManagerUnderTest imageViewWithId:@"123"];
    
}

-(void)testEndImageViewSession {
    
    //given
    _apiManagerUnderTest = [MEAPIManager client];
    _apiManagerClassMock = OCMClassMock([MEAPIManager class]);
    _apiManagerPartialMock = OCMPartialMock(_apiManagerUnderTest);
    OCMStub([_apiManagerClassMock client]).andReturn(_apiManagerPartialMock);

    [_apiManagerUnderTest imageViewWithId:@"1001"];
    
    
    [[[_apiManagerPartialMock expect] andDo:^(NSInvocation *invocation) {
        NSString *url;
        NSDictionary *dictionary ;
        
        [invocation getArgument:&url  atIndex:2];
        [invocation getArgument:&dictionary atIndex:3];
        
        
        XCTAssertEqualObjects(@"emoji/viewTrack",url);
        XCTAssertEqualObjects(@"1001" , [[dictionary objectForKey:@"1001"] objectForKey:@"emoji_id"]);
        XCTAssertEqualObjects(@"1", [[dictionary objectForKey:@"1001"] objectForKey:@"views"]);
        
    }] POST:[OCMArg any] parameters:[OCMArg any] progress:[OCMArg any] success:[OCMArg any] failure:[OCMArg any]];
    
    //WHEN
    [_apiManagerPartialMock endImageViewSession];
    
    //then
    OCMVerify([_apiManagerPartialMock POST:[OCMArg any]  parameters:[OCMArg any]  progress:[OCMArg any]  success:[OCMArg any]  failure:[OCMArg any] ]);
}

-(void)testClickWithEmojiSingleEmoji{
    
    //given
    _apiManagerUnderTest = [MEAPIManager client];
    _apiManagerUnderTest.emojiClicks = nil;
    
    NSMutableDictionary *emoji = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
                                  @"65243", @"id",
                                  @"Music", @"category_name",
                                  @"0",@"gif",
                                  @"0",@"category_image",
                                  nil];
                             

    
    //when
    [_apiManagerUnderTest clickWithEmoji:emoji];

    //then
    NSDictionary *generatedDict = [_apiManagerUnderTest.emojiClicks objectAtIndex:0];
    XCTAssertEqual(_apiManagerUnderTest.emojiClicks.count, (long)1);
    XCTAssertEqualObjects([emoji objectForKey:@"id"], [generatedDict objectForKey:@"id"]);
    XCTAssertEqualObjects([emoji objectForKey:@"category_name"], [generatedDict objectForKey:@"category_name"]);
    XCTAssertEqualObjects([emoji objectForKey:@"gif"], [generatedDict objectForKey:@"gif"]);
    XCTAssertEqualObjects([emoji objectForKey:@"category_image"], [generatedDict objectForKey:@"category_image"]);
    XCTAssertNotNil([generatedDict objectForKey:@"click"]);

}

-(void)testClickWithEmojiWithAllAttributes{
    
    //given
    _apiManagerUnderTest = [MEAPIManager client];
    _apiManagerUnderTest.emojiClicks = nil;
    
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
    [_apiManagerUnderTest clickWithEmoji:emoji];
    
    //then
    XCTAssertNotEqual([_apiManagerUnderTest.emojiClicks objectAtIndex:0],emoji);
    XCTAssertNil([[_apiManagerUnderTest.emojiClicks objectAtIndex:0] objectForKey:@"legacy"]);
    XCTAssertNil([[_apiManagerUnderTest.emojiClicks objectAtIndex:0] objectForKey:@"image_url"]);
    XCTAssertNil([[_apiManagerUnderTest.emojiClicks objectAtIndex:0] objectForKey:@"username"]);
    XCTAssertNil([[_apiManagerUnderTest.emojiClicks objectAtIndex:0] objectForKey:@"access"]);
    XCTAssertNil([[_apiManagerUnderTest.emojiClicks objectAtIndex:0] objectForKey:@"origin_id"]);
    XCTAssertNil([[_apiManagerUnderTest.emojiClicks objectAtIndex:0] objectForKey:@"likes"]);
    XCTAssertNil([[_apiManagerUnderTest.emojiClicks objectAtIndex:0] objectForKey:@"deleted"]);
    XCTAssertNil([[_apiManagerUnderTest.emojiClicks objectAtIndex:0] objectForKey:@"created"]);
    XCTAssertNil([[_apiManagerUnderTest.emojiClicks objectAtIndex:0] objectForKey:@"remoji"]);
    XCTAssertNil([[_apiManagerUnderTest.emojiClicks objectAtIndex:0] objectForKey:@"shares"]);
    XCTAssertNil([[_apiManagerUnderTest.emojiClicks objectAtIndex:0] objectForKey:@"link_url"]);
    XCTAssertNil([[_apiManagerUnderTest.emojiClicks objectAtIndex:0] objectForKey:@"name"]);
    XCTAssertNil([[_apiManagerUnderTest.emojiClicks objectAtIndex:0] objectForKey:@"flashtag"]);
}

-(void)testClickWithEmojiCountMoreThan25{
    
    //given
    _apiManagerUnderTest = [MEAPIManager client];
    _apiManagerClassMock = OCMClassMock([MEAPIManager class]);
    _apiManagerPartialMock = OCMPartialMock(_apiManagerUnderTest);
    
    OCMStub([_apiManagerClassMock client]).andReturn(_apiManagerPartialMock);
    
    _apiManagerUnderTest.emojiClicks = nil;
    
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
    
    
    [[[_apiManagerPartialMock expect] andDo:^(NSInvocation *invocation) {
        NSString *url;
        NSMutableDictionary *emojiDict;
        [invocation getArgument:&url atIndex:2];
        [invocation getArgument:&emojiDict atIndex:3];
        
        XCTAssertEqualObjects(@"emoji/clickTrackBatch", url);
        XCTAssertNotNil([emojiDict objectForKey:@"emoji"]);
        
        NSError *error;
        NSData* data = [[emojiDict objectForKey:@"emoji"] dataUsingEncoding:NSUTF8StringEncoding];
        NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        

        XCTAssertEqual(26, [jsonArray count]);
        
        for (NSDictionary *dict in jsonArray) {
            XCTAssertEqualObjects([emoji objectForKey:@"category_name"], [dict objectForKey:@"category_name"]);
            XCTAssertEqualObjects([emoji objectForKey:@"id"], [dict objectForKey:@"id"]);
            XCTAssertEqualObjects([emoji objectForKey:@"category_image"], [dict objectForKey:@"category_image"]);
            XCTAssertEqualObjects([emoji objectForKey:@"gif"], [dict objectForKey:@"gif"]);

        }
        
    }] POST:[OCMArg any] parameters:[OCMArg any] progress:[OCMArg any] success:[OCMArg any] failure:[OCMArg any]];
    
    //when
    for (int i = 0; i<=25; i++) {
        [_apiManagerPartialMock clickWithEmoji:emoji];
    }
    
    //then
    XCTAssertNil([_apiManagerPartialMock emojiClicks]);
    
}

-(void)testBeginImageViewSessionWithTag{
    //given
    _apiManagerUnderTest = [MEAPIManager client];
    _apiManagerUnderTest.imageViewSessionStart = nil;
    
    
    //when
    [_apiManagerUnderTest beginImageViewSessionWithTag:@"testTag"];
    
    
    //then
    XCTAssertNotNil(_apiManagerUnderTest.imageViewSessionStart);
}

-(void)testBeginImageViewSessionWithTagNotNullDateCase{
    //given
    _apiManagerUnderTest = [MEAPIManager client];
    NSDate *currentDate = [NSDate date];
    _apiManagerUnderTest.imageViewSessionStart = currentDate;
    
    
    //when
    
    [_apiManagerUnderTest beginImageViewSessionWithTag:@"testTag"];
    
    
    //then
    XCTAssertEqual(currentDate,_apiManagerUnderTest.imageViewSessionStart);

    
}
@end
