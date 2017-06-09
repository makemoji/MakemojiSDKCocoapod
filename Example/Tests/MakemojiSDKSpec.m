//
//  MakemojiSDKSpec.m
//  Makemoji-SDK
//
//  Created by David Muñoz - Simplex Software on 9/6/17.
//  Copyright © 2017 Makemoji. All rights reserved.
//


#import <Specta/Specta.h>
#import <Expecta/Expecta.h>
#import "MEApiManager.h"
#import "MakemojiSDK.h"
#import "OCMock.h"

SpecBegin(MakemojiSDK)

describe(@"MakemojiSDK.h", ^{
    
    beforeAll(^{
        
    });
    
    beforeEach(^{
        
    });
    
    it(@"set SDK key", ^{
        //given
        id meapimanagerClassMock = [OCMockObject mockForClass:[MEAPIManager class]];
        id meapimanagerPartialMock = [OCMockObject partialMockForObject:[MEAPIManager client]];
        
        [[[meapimanagerClassMock stub]andReturn:meapimanagerPartialMock] client];

        [[[meapimanagerPartialMock expect]andDo:^(NSInvocation *invocation) {
            NSString *sdkKey;
            
            [invocation getArgument:&sdkKey atIndex:2];
            
            expect(sdkKey).to.equal(@"abc123");
        }]setSdkKey:[OCMArg any]];
        
        [[[meapimanagerPartialMock expect]andDo:^(NSInvocation *invocation) {
            NSString *channel;
            
            [invocation getArgument:&channel atIndex:2];
            
            expect(channel).to.equal(@"wall");
        }]cacheNameWithChannel:[OCMArg any]];
        
        //when
        [MakemojiSDK setSDKKey:@"abc123"];
        
        [meapimanagerPartialMock stopMocking];
        [meapimanagerClassMock stopMocking];
    });
    
    it(@"set SDK key failure case", ^{
        //given
        id meapimanagerClassMock = [OCMockObject mockForClass:[MEAPIManager class]];
        id meapimanagerPartialMock = [OCMockObject partialMockForObject:[MEAPIManager client]];
        
        [[[meapimanagerClassMock stub]andReturn:meapimanagerPartialMock] client];
        
        [[[meapimanagerPartialMock stub]andDo:^(NSInvocation *invocation) {
            void (^failureBlock)(NSURLSessionDataTask *task, NSError *error) = nil;
            
            [invocation getArgument:&failureBlock atIndex:6];
            
            failureBlock(nil, nil);
        }]GET:[OCMArg any] parameters:[OCMArg any] progress:[OCMArg any] success:[OCMArg any] failure:[OCMArg any]];
        
        [[[meapimanagerPartialMock expect]andDo:^(NSInvocation *invocation) {
            NSString *sdkKey;
            
            [invocation getArgument:&sdkKey atIndex:2];
            
            expect(sdkKey).to.equal(@"abc123");
        }]setSdkKey:[OCMArg any]];
        
        [[meapimanagerPartialMock reject]cacheNameWithChannel:[OCMArg any]];
        
        //when
        [MakemojiSDK setSDKKey:@"abc123"];
        
        [meapimanagerPartialMock stopMocking];
        [meapimanagerClassMock stopMocking];
    });
    
    afterEach(^{
        
    });
    
    afterAll(^{
        
    });
});

SpecEnd
