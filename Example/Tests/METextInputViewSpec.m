//
//  METextInputViewSpec.m
//  Makemoji-SDK
//
//  Created by David Muñoz - Simplex Software on 31/5/17.
//  Copyright © 2017 Makemoji. All rights reserved.
//

#import "METextInputView.h"
#import <Specta/Specta.h>
#import <Expecta/Expecta.h>
#import "MEApimanager.h"
#import "OCMock.h"
#import "MakemojiSDK.h"
#import "DTRichTextEditorView.h"
SpecBegin(METextInputView)

describe(@"METextInputView", ^{
    
    beforeAll(^{
        
    });
    
    beforeEach(^{
        
    });
    
    it(@"detect emoji message with no emoji case", ^{
       
        //given
        NSString *messageWithNoEmoji = @"This is a message";
        
        //when
        BOOL haveEmoji = [METextInputView detectMakemojiMessage:messageWithNoEmoji];
        
        //then
        expect(haveEmoji).to.beFalsy();
        
    });
    
    it(@"detect emoji message with emoji case", ^{
        //given
        NSString *messageWithNoEmoji = @"This is a message with [emoji]";
        
        //when
        BOOL haveEmoji = [METextInputView detectMakemojiMessage:messageWithNoEmoji];
        
        //then
        expect(haveEmoji).to.beTruthy();

    });
    
    it(@"number of characters in substitute with no match", ^{
       
        //given
        NSString *messageToTest = @"message with no matches";
        
        //when
        NSUInteger replacesCount = [METextInputView numberOfCharactersInSubstitute:messageToTest];
        
        //then
        expect((int)replacesCount).to.equal(messageToTest.length);
    });
    
    it(@"number of characters in substitue with matches case", ^{
        //given
        NSString *messageToTest = @"[two][matches]";
        
        //when
        NSUInteger replacesCount = [METextInputView numberOfCharactersInSubstitute:messageToTest];
        
        //then
        expect((int)replacesCount).to.equal(2);
    });
    
    it(@"set channel different channel case", ^{
        //given
        MEAPIManager *apiManager = [MEAPIManager client];
        apiManager.channel = @"apichannel";
        id classMock = OCMClassMock([MakemojiSDK class]);
        METextInputView *textInputView = [[METextInputView alloc]init];

        [[[classMock expect]andDo:^(NSInvocation *invocation) {
            __unsafe_unretained NSString *channelReceived;
            [invocation getArgument:&channelReceived atIndex:2];
            
            expect(channelReceived).to.equal(@"inputtextchannel");
        }]setChannel:[OCMArg any]];
        
        //when
        [textInputView setChannel:@"inputtextchannel"];
        
        //then
        OCMVerify([classMock setChannel:[OCMArg any]]);
        
        [classMock stopMocking];
    });
    
    it(@"set channel same channel case", ^{
        //given
        MEAPIManager *apiManager = [MEAPIManager client];
        apiManager.channel = @"samechannel";
        id classMock = OCMClassMock([MakemojiSDK class]);
        METextInputView *textInputView = [[METextInputView alloc]init];
        
        
        //when
        [textInputView setChannel:@"samechannel"];
        
        //then
        OCMReject([classMock setChannel:[OCMArg any]]);
        [classMock stopMocking];
    });
    
    it(@"set channel empty string case", ^{
        //given
        MEAPIManager *apiManager = [MEAPIManager client];
        apiManager.channel = @"channel";
        id classMock = OCMClassMock([MakemojiSDK class]);
        METextInputView *textInputView = [[METextInputView alloc]init];
        
        [[[classMock expect]andDo:^(NSInvocation *invocation) {
            __unsafe_unretained NSString *channelReceived;
            [invocation getArgument:&channelReceived atIndex:2];
            
            expect(channelReceived).to.equal(@"");
        }]setChannel:[OCMArg any]];
        
        //when
        [textInputView setChannel:@""];
        
        //then
        OCMVerify([classMock setChannel:[OCMArg any]]);
        
        [classMock stopMocking];
        
    });
    
    it(@"set default font size less than 16 ", ^{
        //given
        METextInputView *inputTextview = [[METextInputView alloc]init];
        
        
        //when
        [inputTextview setDefaultFontSize:10];
        
        //then
        expect(inputTextview.fontSize).to.equal(16);
        expect(inputTextview.placeholderLabel.font.pointSize).to.equal(16);
        
    });
    
    it(@"set default font size greater than 16 ", ^{
        //given
        METextInputView *inputTextview = [[METextInputView alloc]init];
        
        
        //when
        [inputTextview setDefaultFontSize:20];
        
        //then
        expect(inputTextview.fontSize).to.equal(20);
        expect(inputTextview.placeholderLabel.font.pointSize).to.equal(20);
        
    });
    
    afterEach(^{
        
    });
    
    afterAll(^{
        
    });
});

SpecEnd
