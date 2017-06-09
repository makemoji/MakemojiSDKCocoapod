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
#import "MEInputAccessoryView.h"
#import "DTTextAttachment.h"
#import "DTHTMLElement.h"
#import "DTImageTextAttachment.h"
#import "DTRichTextEditor.h"
#import "MESimpleTableViewCell.h"

SpecBegin(METextInputView)

describe(@"METextInputView", ^{
    
    __block METextInputView *classUndertest ;
    __block id nsDataMock;
    __block id accesoryMock;
    __block MEInputAccessoryView *accesoryView;

    beforeAll(^{
        
        //This nsdata mock us to avoid the loadFromDisk method, that will be crashing everytime because the app is not running while the test are
        nsDataMock = [OCMockObject mockForClass:[NSData class]];
        accesoryView = [[MEInputAccessoryView alloc] init];
    
        //this MEApi manager mock is to avoid the GET method that is called on the MEInputAccessoryView init
        id meApiManagerClassMock =[OCMockObject mockForClass:[MEAPIManager class]];
        id meApiManagerPartialMock = [OCMockObject partialMockForObject:[MEAPIManager client]];
    
        [[[meApiManagerClassMock stub]andReturn:meApiManagerPartialMock]client];
        [[[meApiManagerPartialMock stub]andDo:nil] GET:[OCMArg any] parameters:[OCMArg any] progress:[OCMArg any] success:[OCMArg any] failure:[OCMArg any]];
        
        //This partial mock of the accesoryView is to avoid the loadData from executing, because it randomly crashes, and in this class we're not testing that class.
        accesoryMock = [OCMockObject partialMockForObject:accesoryView];
        OCMStub([accesoryMock loadData]).andDo(nil); 
        [[[nsDataMock stub]andReturn:nil] dataWithContentsOfFile:[OCMArg any]];
        classUndertest = [[METextInputView alloc]init];
        classUndertest.meAccessory = accesoryMock;

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

        [[[classMock expect]andDo:^(NSInvocation *invocation) {
            __unsafe_unretained NSString *channelReceived;
            [invocation getArgument:&channelReceived atIndex:2];
            
            expect(channelReceived).to.equal(@"inputtextchannel");
        }]setChannel:[OCMArg any]];
        
        //when
        [classUndertest setChannel:@"inputtextchannel"];
        
        //then
        OCMVerify([classMock setChannel:[OCMArg any]]);
        
        [classMock stopMocking];
    });
    
    it(@"set channel same channel case", ^{
        //given
        MEAPIManager *apiManager = [MEAPIManager client];
        apiManager.channel = @"samechannel";
        id classMock = OCMClassMock([MakemojiSDK class]);
        
        //when
        [classUndertest setChannel:@"samechannel"];
        
        //then
        OCMReject([classMock setChannel:[OCMArg any]]);
        [classMock stopMocking];
    });
    
    it(@"set channel empty string case", ^{
        //given
        MEAPIManager *apiManager = [MEAPIManager client];
        apiManager.channel = @"channel";
        id classMock = OCMClassMock([MakemojiSDK class]);
        
        [[[classMock expect]andDo:^(NSInvocation *invocation) {
            __unsafe_unretained NSString *channelReceived;
            [invocation getArgument:&channelReceived atIndex:2];
            
            expect(channelReceived).to.equal(@"");
        }]setChannel:[OCMArg any]];
        
        //when
        [classUndertest setChannel:@""];
        
        //then
        OCMVerify([classMock setChannel:[OCMArg any]]);
        
        [classMock stopMocking];
        
    });
    
    it(@"set default font size less than 16 ", ^{
        
        //when
        [classUndertest setDefaultFontSize:10];
        
        //then
        expect(classUndertest.fontSize).to.equal(16);
        expect(classUndertest.placeholderLabel.font.pointSize).to.equal(16);
        
    });
    
    it(@"set default font size greater than 16 ", ^{
        //when
        [classUndertest setDefaultFontSize:20];
        
        //then
        expect(classUndertest.fontSize).to.equal(20);
        expect(classUndertest.placeholderLabel.font.pointSize).to.equal(20);
        
    });
    
    
    it(@"set font regular font", ^{
        //given
        id partialMock = OCMPartialMock(classUndertest);
        UIFont *font = [UIFont systemFontOfSize:10];
        
        
        [[[partialMock expect] andDo:^(NSInvocation *invocation) {
            __unsafe_unretained NSString *fontWeight;
            
            [invocation getArgument:&fontWeight atIndex:2];
            
            expect(fontWeight).to.equal(@"p {font-weight: 400;}");
        }]setDefaultParagraphStyle:[OCMArg any]];
        
        //when
        [partialMock setFont:font];
        
        //then
        OCMVerify([partialMock setDefaultParagraphStyle:[OCMArg any]]);
        
        [partialMock stopMocking];
    });
    
    it(@"set font ultra light font", ^{
        //given
        id partialMock = OCMPartialMock(classUndertest);
        
        UIFont *font = [UIFont systemFontOfSize:10 weight:UIFontWeightUltraLight];
        
        [[[partialMock expect] andDo:^(NSInvocation *invocation) {
            __unsafe_unretained NSString *fontWeight;
            
            [invocation getArgument:&fontWeight atIndex:2];
            
            expect(fontWeight).to.equal(@"p {font-weight: 200;}");
        }]setDefaultParagraphStyle:[OCMArg any]];
        
        //when
        [partialMock setFont:font];
        
        //then
        OCMVerify([partialMock setDefaultParagraphStyle:[OCMArg any]]);
      
        [partialMock stopMocking];

    });
    
    it(@"set font thin font", ^{
        //given
        id partialMock = OCMPartialMock(classUndertest);
        
        UIFont *font = [UIFont systemFontOfSize:10 weight:UIFontWeightThin];
        
        [[[partialMock expect] andDo:^(NSInvocation *invocation) {
            __unsafe_unretained NSString *fontWeight;
            
            [invocation getArgument:&fontWeight atIndex:2];
            
            expect(fontWeight).to.equal(@"p {font-weight: 100;}");
        }]setDefaultParagraphStyle:[OCMArg any]];
        
        //when
        [partialMock setFont:font];
        
        //then
        OCMVerify([partialMock setDefaultParagraphStyle:[OCMArg any]]);
        
        [partialMock stopMocking];
    });
    
    it(@"set font light font", ^{
        //given
        id partialMock = OCMPartialMock(classUndertest);
        
        UIFont *font = [UIFont systemFontOfSize:10 weight:UIFontWeightLight];
        
        [[[partialMock expect] andDo:^(NSInvocation *invocation) {
            __unsafe_unretained NSString *fontWeight;
            
            [invocation getArgument:&fontWeight atIndex:2];
            
            expect(fontWeight).to.equal(@"p {font-weight: 300;}");
        }]setDefaultParagraphStyle:[OCMArg any]];
        
        //when
        [partialMock setFont:font];
        
        //then
        OCMVerify([partialMock setDefaultParagraphStyle:[OCMArg any]]);
        
        [partialMock stopMocking];
    });
    
    it(@"set font medium font", ^{
        //given
        id partialMock = OCMPartialMock(classUndertest);
        
        UIFont *font = [UIFont systemFontOfSize:10 weight:UIFontWeightMedium];
        
        [[[partialMock expect] andDo:^(NSInvocation *invocation) {
            __unsafe_unretained NSString *fontWeight;
            
            [invocation getArgument:&fontWeight atIndex:2];
            
            expect(fontWeight).to.equal(@"p {font-weight: 500;}");
        }]setDefaultParagraphStyle:[OCMArg any]];
        
        //when
        [partialMock setFont:font];
        
        //then
        OCMVerify([partialMock setDefaultParagraphStyle:[OCMArg any]]);
        
        [partialMock stopMocking];
    });
    
    it(@"set font heavy light font", ^{
        //given

        id partialMock = OCMPartialMock(classUndertest);
        
        UIFont *font = [UIFont systemFontOfSize:10 weight:UIFontWeightHeavy];
        
        [[[partialMock expect] andDo:^(NSInvocation *invocation) {
            __unsafe_unretained NSString *fontWeight;
            
            [invocation getArgument:&fontWeight atIndex:2];
            
            expect(fontWeight).to.equal(@"p {font-weight: 800;}");
        }]setDefaultParagraphStyle:[OCMArg any]];
        
        //when
        [partialMock setFont:font];
        
        //then
        OCMVerify([partialMock setDefaultParagraphStyle:[OCMArg any]]);
        
        [partialMock stopMocking];
    });
    
    
    it(@"detach text input view negative case", ^{
        //given
        UIView *view = [[UIView alloc]init];
        id partialMock = OCMPartialMock(view);
        classUndertest.textInputContainerView = partialMock;
        [classUndertest.textInputContainerView addObserver:classUndertest forKeyPath:@"frame" options:0 context:nil];

        OCMReject([partialMock bringSubviewToFront:[OCMArg any]]);
        
        //when
        [classUndertest detachTextInputView:NO];
    });
    
    it(@"detach text input view positive case", ^{
        
        //given
        
        UIView *view = [[UIView alloc]init];
        id partialMock = OCMPartialMock(view);
        classUndertest.textInputContainerView = partialMock;
        [classUndertest.textInputContainerView addObserver:classUndertest forKeyPath:@"frame" options:0 context:nil];
        
        UIView *solidBackgroundView = [[UIView alloc]init];
        id partialSolidBackground = OCMPartialMock(solidBackgroundView);
        classUndertest.textSolidBackgroundView = partialSolidBackground;
     
        //when
        [classUndertest detachTextInputView:YES];
        
        //then
        OCMVerify([partialMock bringSubviewToFront:[OCMArg any]]);
        OCMVerify([partialMock setBackgroundColor:[OCMArg any]]);
        OCMVerify([partialSolidBackground setBackgroundColor:[OCMArg any]]);

        expect(classUndertest.frame).to.equal(CGRectMake(0, 577, 375, 46));

        
        [partialMock stopMocking];
        [partialSolidBackground stopMocking];
    });
 
   it(@"send message negative case", ^{
        //given
        id partialSUTMock = OCMPartialMock(classUndertest);
       
        OCMStub([partialSUTMock setAttributedString:[OCMArg any]]).andDo(nil);

        id meApiManagerClassMock = OCMClassMock([MEAPIManager class]);
       
        OCMReject([meApiManagerClassMock client]);

        //when
        [classUndertest sendMessage];
        
        [partialSUTMock stopMocking];
        [meApiManagerClassMock stopMocking];
    });



it(@"send message positive case", ^{
        //given
        id accesoryClassMock = [OCMockObject mockForClass:[MEInputAccessoryView class]];
        [[[accesoryClassMock stub] andDo:nil] willMoveToSuperview:[OCMArg any]];
    
        DTRichTextEditorView *currentView = [[DTRichTextEditorView alloc]init];
        DTTextAttachment *text = [[DTTextAttachment alloc]init];
        text.attributes =  @{@"id" : @"952",
                              @"name" : @"Outraged",
                              @"src" : @"https://d1tvcfe0bfyi6u.cloudfront.net/emoji/952-large@2x.png",
                              @"link" : @""};
        
        DTHTMLElement * newElement = [[DTHTMLElement alloc] initWithName:@"img" attributes:text.attributes];

        DTImageTextAttachment * imageAttachment = [[DTImageTextAttachment alloc] initWithElement:newElement options:nil];
        UIImage * tmpImage = [UIImage imageWithCGImage:[[[UIImage alloc] init] CGImage] scale:2.0 orientation:UIImageOrientationUp];
        
        
        imageAttachment.image = tmpImage;
        
        imageAttachment.verticalAlignment = DTTextAttachmentVerticalAlignmentCenter;
        
        NSAttributedString *atributedString = [NSAttributedString attributedStringWithAttachment:imageAttachment];
        
        currentView.attributedString = atributedString;
        classUndertest.attributedString = currentView.attributedString;
        id meApiManagerClassMock = [OCMockObject mockForClass:[MEAPIManager class]];
        id meApiManagerPartialMock = [OCMockObject partialMockForObject:[MEAPIManager client]];
        
        [[[meApiManagerClassMock stub] andReturn:meApiManagerPartialMock] client];
        
        
        [[[meApiManagerPartialMock expect] andDo:^(NSInvocation *invocation) {
            __unsafe_unretained NSMutableDictionary *dict;
            NSString *url;
            
            [invocation getArgument:&url atIndex:2];
            [invocation getArgument:&dict atIndex:3];
            
            expect(url).to.equal(@"messages/create");
            expect([dict objectForKey:@"message"]).to.equal(@"<img style=\"vertical-align:middle;\" src=\"https://d1tvcfe0bfyi6u.cloudfront.net/emoji/952-large@2x.png\" id=\"952\" name=\"Outraged\" link=\"\" />");

        }]POST:[OCMArg any] parameters:[OCMArg any] progress:[OCMArg any] success:[OCMArg any] failure:[OCMArg any]];
        
        //when
        [classUndertest sendMessage];

        //then
        OCMVerify([meApiManagerPartialMock POST:[OCMArg any] parameters:[OCMArg any] progress:[OCMArg any] success:[OCMArg any] failure:[OCMArg any]]);
        
        [meApiManagerPartialMock stopMocking];
        [meApiManagerClassMock stopMocking];
    });

   it(@"send message positive empty string case", ^{
        //given

        DTRichTextEditorView *currentView = [[DTRichTextEditorView alloc]init];
        currentView.attributedText = [[NSAttributedString alloc] initWithString:@" "];
        classUndertest.attributedString = currentView.attributedString;
        id meApiManagerClassMock = [OCMockObject mockForClass:[MEAPIManager class]];
        id meApiManagerPartialMock = [OCMockObject partialMockForObject:[MEAPIManager client]];
        
        [[[meApiManagerClassMock stub] andReturn:meApiManagerPartialMock] client];
       
        [[[meApiManagerPartialMock expect] andDo:^(NSInvocation *invocation) {
            __unsafe_unretained NSMutableDictionary *dict;
            NSString *url;
            
            [invocation getArgument:&url atIndex:2];
            [invocation getArgument:&dict atIndex:3];
            
            expect(url).to.equal(@"messages/create");
            expect([dict objectForKey:@"message"]).to.equal(@"");
            
        }]POST:[OCMArg any] parameters:[OCMArg any] progress:[OCMArg any] success:[OCMArg any] failure:[OCMArg any]];
        
        //when
        [classUndertest sendMessage];
        
        //then
        OCMVerify([meApiManagerPartialMock POST:[OCMArg any] parameters:[OCMArg any] progress:[OCMArg any] success:[OCMArg any] failure:[OCMArg any]]);
        
        [meApiManagerPartialMock stopMocking];
        [meApiManagerClassMock stopMocking];
    });
    
    it(@"send message positive simple string case", ^{
        //given
        MEInputAccessoryView *accesoryView = [[MEInputAccessoryView alloc]init];
        id accesoryPartialMock = [OCMockObject partialMockForObject:accesoryView];
        
        [[[accesoryPartialMock stub]andDo:nil]willMoveToSuperview:[OCMArg any]];
       
        DTRichTextEditorView *currentView = [[DTRichTextEditorView alloc]init];
        currentView.attributedText = [[NSAttributedString alloc] initWithString:@"testString"];
        classUndertest.attributedString = currentView.attributedString;
        id meApiManagerClassMock = [OCMockObject mockForClass:[MEAPIManager class]];
        id meApiManagerPartialMock = [OCMockObject partialMockForObject:[MEAPIManager client]];
        
        [[[meApiManagerClassMock stub] andReturn:meApiManagerPartialMock] client];
        
        [[[meApiManagerPartialMock expect] andDo:^(NSInvocation *invocation) {
            __unsafe_unretained NSMutableDictionary *dict;
            NSString *url;
            
            [invocation getArgument:&url atIndex:2];
            [invocation getArgument:&dict atIndex:3];
            
            expect(url).to.equal(@"messages/create");
            expect([dict objectForKey:@"message"]).to.equal(@"");
            
        }]POST:[OCMArg any] parameters:[OCMArg any] progress:[OCMArg any] success:[OCMArg any] failure:[OCMArg any]];
        
        //when
        [classUndertest sendMessage];
        
        //then
        OCMVerify([meApiManagerPartialMock POST:[OCMArg any] parameters:[OCMArg any] progress:[OCMArg any] success:[OCMArg any] failure:[OCMArg any]]);
        
        [meApiManagerPartialMock stopMocking];
        [meApiManagerClassMock stopMocking];
    });

    
    it(@"cell height for html  MESimpleTableViewCell", ^{
        
        //given
        NSMutableArray *cachedHeights= [[NSMutableArray alloc]init];
        id cachedHeightsPartialMock = [OCMockObject partialMockForObject:cachedHeights];
        classUndertest.cachedHeights = cachedHeightsPartialMock;
        
        [[[cachedHeightsPartialMock expect]andDo:^(NSInvocation *invocation) {
            __unsafe_unretained NSNumber *number;
            
            [invocation getArgument:&number atIndex:2];
            expect([number floatValue]).to.equal(53.15625);
        }]insertObject:[OCMArg any] atIndex:0];
        //when
        [classUndertest cellHeightForHTML:@"testtest" atIndexPath:[NSIndexPath indexPathForItem:(NSInteger)0 inSection:(NSInteger)0] maxCellWidth:10 cellStyle:MECellStyleSimple];
        
        //then
        OCMVerify([cachedHeightsPartialMock insertObject:[OCMArg any] atIndex:0]);
        
    });
    
    it(@"cell height for html  MESimpleTableViewCell with cached heights", ^{
        
        //given
        NSMutableArray *cachedHeights= [[NSMutableArray alloc]init];
        id cachedHeightsPartialMock = [OCMockObject partialMockForObject:cachedHeights];
        classUndertest.cachedHeights = cachedHeightsPartialMock;
        
        [classUndertest.cachedHeights insertObject:[NSNumber numberWithDouble:50] atIndex:0];
        
        //when
        CGFloat value = [classUndertest cellHeightForHTML:@"testtest" atIndexPath:[NSIndexPath indexPathForItem:(NSInteger)0 inSection:(NSInteger)0] maxCellWidth:10 cellStyle:MECellStyleSimple];
        
        //then
        OCMVerify([[cachedHeightsPartialMock ignoringNonObjectArgs] objectAtIndex:0]);
        expect(value).to.equal(50);
        
    });
    
    it(@"cell heigth for html MECellStyleChat", ^{
        //given
        NSMutableArray *cachedHeights= [[NSMutableArray alloc]init];
        id cachedHeightsPartialMock = [OCMockObject partialMockForObject:cachedHeights];
        classUndertest.cachedHeights = cachedHeightsPartialMock;
        
        [[[cachedHeightsPartialMock expect]andDo:^(NSInvocation *invocation) {
            __unsafe_unretained NSNumber *number;
            
            [invocation getArgument:&number atIndex:2];
            expect([number floatValue]).to.equal(32);
        }]insertObject:[OCMArg any] atIndex:0];
        //when
        [classUndertest cellHeightForHTML:@"testtest" atIndexPath:[NSIndexPath indexPathForItem:(NSInteger)0 inSection:(NSInteger)0] maxCellWidth:10 cellStyle:MECellStyleChat];
        
        //then
        OCMVerify([cachedHeightsPartialMock insertObject:[OCMArg any] atIndex:0]);
        

    });
    
    it(@"cell heigth for html MECellStyleChat with cached heights", ^{
        //given
        NSMutableArray *cachedHeights= [[NSMutableArray alloc]init];
        id cachedHeightsPartialMock = [OCMockObject partialMockForObject:cachedHeights];
        classUndertest.cachedHeights = cachedHeightsPartialMock;
        
        [classUndertest.cachedHeights insertObject:[NSNumber numberWithDouble:50] atIndex:0];
        
        //when
        CGFloat value = [classUndertest cellHeightForHTML:@"testtest" atIndexPath:[NSIndexPath indexPathForItem:(NSInteger)0 inSection:(NSInteger)0] maxCellWidth:10 cellStyle:MECellStyleChat];
        
        //then
        OCMVerify([[cachedHeightsPartialMock ignoringNonObjectArgs] objectAtIndex:0]);
        expect(value).to.equal(50);
    });
    
    it(@"convert sustituedToHtml simple string case", ^{
      
        //given
        NSString *testString = @"testString";
    
        //when
        NSString *resultString = [METextInputView convertSubstituedToHTML:testString];
        
        
        //then
        expect(resultString).to.equal(@"<p dir=\"auto\" style=\"font-family:'.SF UI Text';font-size:16px;\"><span style=\"color:#000000;\">testString</span></p>");
    });
    
    it(@"convert sustituedToHtml space and break string case", ^{
        
        //given
        NSString *testString = @"test\n String\n ";
        
        //when
        NSString *resultString = [METextInputView convertSubstituedToHTML:testString];
        
        
        //then
        expect(resultString).to.equal(@"<p dir=\"auto\" style=\"font-family:'.SF UI Text';font-size:16px;\"><span style=\"color:#000000;\">test<br /> String<br /> </span></p>");
    });
    
    
    it(@"convert sustituedToHtml space and break string and emoji case", ^{
        
        //given
        NSString *testString = @"test\n String\n [e.FM]";
        
        //when
        NSString *resultString = [METextInputView convertSubstituedToHTML:testString];
        
        
        //then
        expect(resultString).to.equal(@"<p dir=\"auto\" style=\"font-family:'.SF UI Text';font-size:16px;\"><span style=\"color:#000000;\">test<br /> String<br /> <img style=\"vertical-align:middle;width:20px;height:20px;\" src=\"https://d1tvcfe0bfyi6u.cloudfront.net/emoji/952-large@2x.png\" id=\"952\" link=\"\" name=\"e\" /></span></p>");
    });
    
    it(@"convert sustituedToHtml space and break string case with emoji and link", ^{
        
        //given
        NSString *testString = @"test\n String\n [e.FM http:\\emojilinktest.com]";
        
        //when
        NSString *resultString = [METextInputView convertSubstituedToHTML:testString];
        
        
        //then
        expect(resultString).to.equal(@"<p dir=\"auto\" style=\"font-family:'.SF UI Text';font-size:16px;\"><span style=\"color:#000000;\">test<br /> String<br /> <img style=\"vertical-align:middle;width:20px;height:20px;\" src=\"https://d1tvcfe0bfyi6u.cloudfront.net/emoji/952-large@2x.png\" id=\"952\" link=\"http:\\emojilinktest.com\" name=\"e\" /></span></p>");
    });
    
    it(@"convert sustituedToHtml space and break string case with emoji and link and emoji without link", ^{
        
        //given
        NSString *testString = @"test\n String\n [e.FM http:\\emojilinktest.com] [e.EMe]";
        
        //when
        NSString *resultString = [METextInputView convertSubstituedToHTML:testString];
        
        
        //then
        expect(resultString).to.equal(@"<p dir=\"auto\" style=\"font-family:'.SF UI Text';font-size:16px;\"><span style=\"color:#000000;\">test<br /> String<br /> <img style=\"vertical-align:middle;width:20px;height:20px;\" src=\"https://d1tvcfe0bfyi6u.cloudfront.net/emoji/952-large@2x.png\" id=\"952\" link=\"http:\\emojilinktest.com\" name=\"e\" /> <img style=\"vertical-align:middle;width:20px;height:20px;\" src=\"https://d1tvcfe0bfyi6u.cloudfront.net/emoji/55220-large@2x.png\" id=\"55220\" link=\"\" name=\"e\" /></span></p>");
    });
    
    it(@"convert sustituedToHtml space and break string and gif case", ^{
        
        //given
        NSString *testString = @"test\n String\n [gif.FM]";
        
        //when
        NSString *resultString = [METextInputView convertSubstituedToHTML:testString];
        
        //then
        expect(resultString).to.equal(@"<p dir=\"auto\" style=\"font-family:'.SF UI Text';font-size:16px;\"><span style=\"color:#000000;\">test<br /> String<br /> <img style=\"vertical-align:middle;width:20px;height:20px;\" src=\"https://d1tvcfe0bfyi6u.cloudfront.net/emoji/952-40x40@2x.gif\" id=\"952\" link=\"\" name=\"gif\" /></span></p>");
    });
    
    
    it(@"convert sustituedToHtml space and break string case with gif and link", ^{
        
        //given
        NSString *testString = @"test\n String\n [gif.FM http:\\emojilinktest.com]";
        
        //when
        NSString *resultString = [METextInputView convertSubstituedToHTML:testString];
        
        
        //then
        expect(resultString).to.equal(@"<p dir=\"auto\" style=\"font-family:'.SF UI Text';font-size:16px;\"><span style=\"color:#000000;\">test<br /> String<br /> <img style=\"vertical-align:middle;width:20px;height:20px;\" src=\"https://d1tvcfe0bfyi6u.cloudfront.net/emoji/952-40x40@2x.gif\" id=\"952\" link=\"http:\\emojilinktest.com\" name=\"gif\" /></span></p>");
    });
    
    it(@"convert substitued to HTML with paragraph blocks", ^{
        //given
        NSString *testString = @"test string";
        
        //when
        NSString *resultString = [METextInputView convertSubstituedToHTMLWithParagraphBlocks:testString];
        
        
        //then
        expect(resultString).to.equal(@"<p dir=\"auto\" style=\"font-family:'.SF UI Text';font-size:16px; color:#000000; margin:0px; \"><span>test string</span></p>");
    });
    
    it(@"convert substitued to HTML with paragraph blocks with characters", ^{
        //given
        NSString *testString = @"\u2028 test\n string ";
        
        //when
        NSString *resultString = [METextInputView convertSubstituedToHTMLWithParagraphBlocks:testString];

        //then
        expect(resultString).to.equal(@"<p dir=\"auto\" style=\"font-family:'.SF UI Text';font-size:16px; color:#000000; margin:0px; \"><span></span></p><p dir=\"auto\" style=\"font-family:'.SF UI Text';font-size:16px; color:#000000; margin:0px;\"><span> test</span></p><p dir=\"auto\" style=\"font-family:'.SF UI Text';font-size:16px; color:#000000; margin:0px;\"><span> string </span></p>");
    });
    
    it(@"convert substitued to HTML with paragraph blocks with characters and emoji", ^{
        //given
        NSString *testString = @"\u2028 test\n string [e.FM]";
        
        //when
        NSString *resultString = [METextInputView convertSubstituedToHTMLWithParagraphBlocks:testString];
        
        //then
        expect(resultString).to.equal(@"<p dir=\"auto\" style=\"font-family:'.SF UI Text';font-size:16px; color:#000000; margin:0px; \"><span></span></p><p dir=\"auto\" style=\"font-family:'.SF UI Text';font-size:16px; color:#000000; margin:0px;\"><span> test</span></p><p dir=\"auto\" style=\"font-family:'.SF UI Text';font-size:16px; color:#000000; margin:0px;\"><span> string <img style=\"vertical-align:middle;width:20px;height:20px;\" src=\"https://d1tvcfe0bfyi6u.cloudfront.net/emoji/952-large@2x.png\" id=\"952\" link=\"\" name=\"e\" /></span></p>");
    });
    
    it(@"convert substitued to HTML with paragraph blocks with characters and emoji with link", ^{
        //given
        NSString *testString = @"\u2028 test\n string [e.FM http:\\emojilinktest.com]";
        
        //when
        NSString *resultString = [METextInputView convertSubstituedToHTMLWithParagraphBlocks:testString];
        
        //then
        expect(resultString).to.equal(@"<p dir=\"auto\" style=\"font-family:'.SF UI Text';font-size:16px; color:#000000; margin:0px; \"><span></span></p><p dir=\"auto\" style=\"font-family:'.SF UI Text';font-size:16px; color:#000000; margin:0px;\"><span> test</span></p><p dir=\"auto\" style=\"font-family:'.SF UI Text';font-size:16px; color:#000000; margin:0px;\"><span> string <img style=\"vertical-align:middle;width:20px;height:20px;\" src=\"https://d1tvcfe0bfyi6u.cloudfront.net/emoji/952-large@2x.png\" id=\"952\" link=\"http:\\emojilinktest.com\" name=\"e\" /></span></p>");
    });
    
    it(@"convert substitued to HTML with paragraph blocks with characters and gif", ^{
        //given
        NSString *testString = @"\u2028 test\n string [gif.FM]";
        
        //when
        NSString *resultString = [METextInputView convertSubstituedToHTMLWithParagraphBlocks:testString];
        
        //then
        expect(resultString).to.equal(@"<p dir=\"auto\" style=\"font-family:'.SF UI Text';font-size:16px; color:#000000; margin:0px; \"><span></span></p><p dir=\"auto\" style=\"font-family:'.SF UI Text';font-size:16px; color:#000000; margin:0px;\"><span> test</span></p><p dir=\"auto\" style=\"font-family:'.SF UI Text';font-size:16px; color:#000000; margin:0px;\"><span> string <img style=\"vertical-align:middle;width:20px;height:20px;\" src=\"https://d1tvcfe0bfyi6u.cloudfront.net/emoji/952-40x40@2x.gif\" id=\"952\" link=\"\" name=\"gif\" /></span></p>");
    });
    
    it(@"convert substitued to HTML with paragraph blocks with characters and gif with link", ^{
        //given
        NSString *testString = @"\u2028 test\n string [gif.FM http:\\emojilinktest.com]";
        
        //when
        NSString *resultString = [METextInputView convertSubstituedToHTMLWithParagraphBlocks:testString];
        
        //then
        expect(resultString).to.equal(@"<p dir=\"auto\" style=\"font-family:'.SF UI Text';font-size:16px; color:#000000; margin:0px; \"><span></span></p><p dir=\"auto\" style=\"font-family:'.SF UI Text';font-size:16px; color:#000000; margin:0px;\"><span> test</span></p><p dir=\"auto\" style=\"font-family:'.SF UI Text';font-size:16px; color:#000000; margin:0px;\"><span> string <img style=\"vertical-align:middle;width:20px;height:20px;\" src=\"https://d1tvcfe0bfyi6u.cloudfront.net/emoji/952-40x40@2x.gif\" id=\"952\" link=\"http:\\emojilinktest.com\" name=\"gif\" /></span></p>");
    });
    
    /////
    it(@"convert substitued to HTML with paragraph blocks emoji and link and emoji without link", ^{
        
        //given
        NSString *testString = @"test\n String\n [e.FM http:\\emojilinktest.com] [e.FM http:\\emojilinktest.com] [e.EMe]";
        
        //when
        NSString *resultString = [METextInputView convertSubstituedToHTMLWithParagraphBlocks:testString];
        
        
        //then
        expect(resultString).to.equal(@"<p dir=\"auto\" style=\"font-family:'.SF UI Text';font-size:16px; color:#000000; margin:0px; \"><span>test</span></p><p dir=\"auto\" style=\"font-family:'.SF UI Text';font-size:16px; color:#000000; margin:0px;\"><span> String</span></p><p dir=\"auto\" style=\"font-family:'.SF UI Text';font-size:16px; color:#000000; margin:0px;\"><span> <img style=\"vertical-align:middle;width:20px;height:20px;\" src=\"https://d1tvcfe0bfyi6u.cloudfront.net/emoji/952-large@2x.png\" id=\"952\" link=\"http:\\emojilinktest.com\" name=\"e\" /> <img style=\"vertical-align:middle;width:20px;height:20px;\" src=\"https://d1tvcfe0bfyi6u.cloudfront.net/emoji/952-large@2x.png\" id=\"952\" link=\"http:\\emojilinktest.com\" name=\"e\" /> <img style=\"vertical-align:middle;width:20px;height:20px;\" src=\"https://d1tvcfe0bfyi6u.cloudfront.net/emoji/55220-large@2x.png\" id=\"55220\" link=\"\" name=\"e\" /></span></p>");
    });
    
    it(@"convert substitued to HTML with paragraph blocks with font and text color", ^{
        //given
        NSString *testString = @"testString";
        UIFont *testFont = [UIFont boldSystemFontOfSize:12];
        UIColor *color  = [UIColor redColor];
        
        
        //when
        NSString *resultString = [METextInputView convertSubstituedToHTMLWithParagraphBlocks:testString withFont:testFont textColor:color];
        
        //then
        
        expect(resultString).to.equal(@"<p dir=\"auto\" style=\"font-family:'.SF UI Text';font-size:12px; color:#FF0000; margin:0px; \"><span>testString</span></p>");
        
    });
    
    it(@"convert substitued to HTML with font text color", ^{
        
        //given
        NSString *testString = @"testString";
        UIFont *testFont = [UIFont boldSystemFontOfSize:12];
        UIColor *color  = [UIColor redColor];
        
        
        //when
        NSString *resultString = [METextInputView convertSubstituedToHTML:testString withFont:testFont textColor:color];
        
        //then
        expect(resultString).to.equal(@"<p dir=\"auto\" style=\"font-family:'.SF UI Text';font-size:12px;\"><span style=\"color:#FF0000;\">testString</span></p>");
    });
    
    it(@"convert substitued to HTML with font name point size text color", ^{
        //given
        NSString *testString = @"testString";
        NSString *fontName =@"OpenSans";
        UIColor *color  = [UIColor redColor];
        
        
        //when
        NSString *resultString = [METextInputView convertSubstituedToHTML:testString withFontName:fontName pointSize:15 textColor:color];
        
        //then
        expect(resultString).to.equal(@"<p dir=\"auto\" style=\"font-family:'OpenSans';font-size:15px;\"><span style=\"color:#FF0000;\">testString</span></p>");
        
    });
    
    it(@"convert substitued to HTML with font text color emoji ratio", ^{
        //given
        NSString *testString = @"testString";
        UIFont *testFont = [UIFont boldSystemFontOfSize:12];
        UIColor *color  = [UIColor redColor];
        CGFloat emojiRatio = 2.5;

        id inputTextviewClassMock = [OCMockObject mockForClass:[METextInputView class]];
        
        [[[inputTextviewClassMock expect] andDo:^(NSInvocation *invocation) {
            __unsafe_unretained NSDictionary *dict;
            [invocation getArgument:&dict atIndex:3];
            UIColor *color = [dict objectForKey:@"MESubstituteOptionTextColor"];
            UIFont *font = [dict objectForKey:@"MESubstituteOptionFont"];
            CGFloat ratio = [[dict objectForKey:@"MESubstituteOptionEmojiSizeRatio"] floatValue];
            
            expect(color).to.equal([UIColor redColor]);
            expect(font).to.equal([UIFont boldSystemFontOfSize:12]);
            expect(ratio).to.equal(2.5);
        }] convertSubstituteToHTML:[OCMArg any] options:[OCMArg any]];
        
        //when
        [METextInputView convertSubstituedToHTML:testString withFont:testFont textColor:color emojiRatio:emojiRatio];
        
        //then
        OCMVerify([inputTextviewClassMock convertSubstituteToHTML:[OCMArg any] options:[OCMArg any]]);
    });
    
    it(@"convert substitued to HTML with font text color link style", ^{
        //given
        NSString *testString = @"testString";
        UIFont *testFont = [UIFont boldSystemFontOfSize:12];
        UIColor *color  = [UIColor redColor];
        NSString *linkStyle = @"linkStyle";
        
        id inputTextviewClassMock = [OCMockObject mockForClass:[METextInputView class]];
        
        [[[inputTextviewClassMock expect] andDo:^(NSInvocation *invocation) {
            __unsafe_unretained NSDictionary *dict;
            [invocation getArgument:&dict atIndex:3];
            UIColor *color = [dict objectForKey:@"MESubstituteOptionTextColor"];
            UIFont *font = [dict objectForKey:@"MESubstituteOptionFont"];
            BOOL shouldScan = [dict objectForKey:@"MESubstituteOptionShouldScanForLinks"];
            NSString *link = [dict objectForKey:@"MESubstituteOptionLinkStyle"];

            expect(color).to.equal([UIColor redColor]);
            expect(font).to.equal([UIFont boldSystemFontOfSize:12]);
            expect(link).to.equal(@"linkStyle");
            expect(shouldScan).to.beTruthy();
        }] convertSubstituteToHTML:[OCMArg any] options:[OCMArg any]];
        
        //when
        [METextInputView convertSubstituedToHTML:testString withFont:testFont textColor:color linkStyle:linkStyle];
        
        //then
        OCMVerify([inputTextviewClassMock convertSubstituteToHTML:[OCMArg any] options:[OCMArg any]]);
    });
    
    it(@"convert substitute to HTML options without options", ^{
        //given
        NSString *testString = @"testString";
        
        //when
        NSDictionary * optionsDict = [NSDictionary dictionaryWithObjectsAndKeys:nil];
        
        NSString *resultString = [METextInputView convertSubstituteToHTML:testString options:optionsDict];
       
        //then

        expect(resultString).to.equal([NSString stringWithFormat:@"%@%@%@" ,@"<p dir=\"auto\" style=\"font-family:'.SF UI Text';font-size:16px;\"><span style=\"color:#000000;\">",testString,@"</span></p>"]);
    });
    
    it(@"convert substitute to HTML options without options with textfont and color", ^{
        //given
        id inputTextviewClassMock = [OCMockObject mockForClass:[METextInputView class]];
        NSString *testString = @"testString";
        UIFont *testFont = [UIFont boldSystemFontOfSize:12];
        UIColor *color  = [UIColor redColor];

        [[[inputTextviewClassMock expect] andDo:^(NSInvocation *invocation) {
            UIFont *receivedFont;
            UIColor *receivedColor;
            NSString *receivedString;
            
            [invocation getArgument:&receivedString atIndex:2];
            [invocation getArgument:&receivedFont atIndex:3];
            [invocation getArgument:&receivedColor atIndex:4];
            
            expect(receivedString).to.equal(@"testString");
            expect(receivedFont).to.equal([UIFont boldSystemFontOfSize:12]);
            expect(receivedColor).to.equal([UIColor redColor]);
        }] convertSubstituedToHTML:[OCMArg any] withFont:[OCMArg any] textColor:[OCMArg any]];
        //when
        NSDictionary * optionsDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                      testFont, MESubstituteOptionFont,
                                      color, MESubstituteOptionTextColor,
                                      nil];
        
        [METextInputView convertSubstituteToHTML:testString options:optionsDict];
        
        //then
        OCMVerify([inputTextviewClassMock convertSubstituedToHTML:[OCMArg any] withFont:[OCMArg any] textColor:[OCMArg any]]);
        
    });
    
    it(@"convert substitute to HTML options without options with textfont, color, and link", ^{
        //given
        id inputTextviewClassMock = [OCMockObject mockForClass:[METextInputView class]];
        UIFont *testFont = [UIFont systemFontOfSize:10];
        NSString *testString = @"http:\\emojilinktest.com test";
        UIColor *color  = [UIColor redColor];
        
        [[[inputTextviewClassMock expect] andDo:^(NSInvocation *invocation) {
            __unsafe_unretained UIFont *receivedFont;
            __unsafe_unretained UIColor *receivedColor;
            __unsafe_unretained NSString *receivedString;
            
            [invocation getArgument:&receivedString atIndex:2];
            [invocation getArgument:&receivedFont atIndex:3];
            [invocation getArgument:&receivedColor atIndex:4];

            expect(receivedString).to.equal(@"http:\\<a href='http://emojilinktest.com' style=''>http://emojilinktest.com</a> test");
            expect(receivedFont).to.equal([UIFont systemFontOfSize:10]);
            expect(receivedColor).to.equal([UIColor redColor]);
        }] convertSubstituedToHTML:[OCMArg any] withFont:[OCMArg any] textColor:[OCMArg any]];
        //when
        NSDictionary * optionsDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                      testFont, MESubstituteOptionFont,
                                      color, MESubstituteOptionTextColor,
                                       [NSNumber numberWithBool:YES], MESubstituteOptionShouldScanForLinks,
                                      nil];
        
        [METextInputView convertSubstituteToHTML:testString options:optionsDict];
        
        //then
        OCMVerify([inputTextviewClassMock convertSubstituedToHTML:[OCMArg any] withFont:[OCMArg any] textColor:[OCMArg any]]);
        
    });
    
    it(@"convert substitute to HTML options without options with textfont, color, and link", ^{
        //given
        id inputTextviewClassMock = [OCMockObject mockForClass:[METextInputView class]];
        UIFont *testFont = [UIFont systemFontOfSize:10];
        NSString *testString = @"http:\\emojilinktest.com";
        UIColor *color  = [UIColor redColor];
        
        [[[inputTextviewClassMock expect] andDo:^(NSInvocation *invocation) {
            __unsafe_unretained UIFont *receivedFont;
            __unsafe_unretained UIColor *receivedColor;
            __unsafe_unretained NSString *receivedString;
            
            [invocation getArgument:&receivedString atIndex:2];
            [invocation getArgument:&receivedFont atIndex:3];
            [invocation getArgument:&receivedColor atIndex:4];
            
            expect(receivedString).to.equal(@"http:\\emojilinktest.com");
            expect(receivedFont).to.equal([UIFont systemFontOfSize:10]);
            expect(receivedColor).to.equal([UIColor redColor]);
        }] convertSubstituedToHTML:[OCMArg any] withFont:[OCMArg any] textColor:[OCMArg any]];
        //when
        NSDictionary * optionsDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                      testFont, MESubstituteOptionFont,
                                      color, MESubstituteOptionTextColor,
                                      [NSNumber numberWithBool:YES], MESubstituteOptionShouldScanForLinks,
                                      nil];
        
        [METextInputView convertSubstituteToHTML:testString options:optionsDict];
        
        //then
        OCMVerify([inputTextviewClassMock convertSubstituedToHTML:[OCMArg any] withFont:[OCMArg any] textColor:[OCMArg any]]);
        
    });
    
    it(@"convert substitute to HTML options without options with textfont, color,link and emoji ratio", ^{
        //given
        id inputTextviewClassMock = [OCMockObject mockForClass:[METextInputView class]];
        UIFont *testFont = [UIFont systemFontOfSize:10];
        NSString *testString = @"http:\\emojilinktest.com";
        UIColor *color  = [UIColor redColor];
        CGFloat emojiRatio = 2.43;
        
        //when
        NSDictionary * optionsDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                      testFont, MESubstituteOptionFont,
                                      color, MESubstituteOptionTextColor,
                                      [NSNumber numberWithBool:YES], MESubstituteOptionShouldScanForLinks,
                                      [NSNumber numberWithFloat:emojiRatio],MESubstituteOptionEmojiSizeRatio,
                                      nil];
        
      NSString *string =  [METextInputView convertSubstituteToHTML:testString options:optionsDict];
        
        //then
        OCMVerify([inputTextviewClassMock convertSubstituedToHTML:[OCMArg any] withFont:[OCMArg any] textColor:[OCMArg any]]);
        expect(string).to.equal(@"<p dir=\"auto\" style=\"font-family:'.SF UI Text';font-size:10px;\"><span style=\"color:#FF0000;\">http:\\emojilinktest.com</span></p>");
    });
    
    it(@"convert substitute to HTML options without options with textfont, color,offset link and emoji ratio", ^{
        //given
        id inputTextviewClassMock = [OCMockObject mockForClass:[METextInputView class]];
        UIFont *testFont = [UIFont systemFontOfSize:10];
        NSString *testString = @"http:\\emojilinktest.com test";
        UIColor *color  = [UIColor redColor];
        CGFloat emojiRatio = 2.43;
        
        //when
        NSDictionary * optionsDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                      testFont, MESubstituteOptionFont,
                                      color, MESubstituteOptionTextColor,
                                      [NSNumber numberWithBool:YES], MESubstituteOptionShouldScanForLinks,
                                      [NSNumber numberWithFloat:emojiRatio],MESubstituteOptionEmojiSizeRatio,
                                      nil];
        
        NSString *string =  [METextInputView convertSubstituteToHTML:testString options:optionsDict];
        
        //then
        OCMVerify([inputTextviewClassMock convertSubstituedToHTML:[OCMArg any] withFont:[OCMArg any] textColor:[OCMArg any]]);
        expect(string).to.equal(@"<p dir=\"auto\" style=\"font-family:'.SF UI Text';font-size:10px;\"><span style=\"color:#FF0000;\">http:\\<a href='http://emojilinktest.com' style=''>http://emojilinktest.com</a> test</span></p>");
    });
    
    it(@"convert substitute to HTML options without options with textfont, color,offset link, emoji ratio and emoji", ^{
        //given
        id inputTextviewClassMock = [OCMockObject mockForClass:[METextInputView class]];
        UIFont *testFont = [UIFont systemFontOfSize:10];
        NSString *testString = @"http:\\emojilinktest.com test [e.FM]";
        NSString *linkStyle = @"linkStyle";
        UIColor *color  = [UIColor redColor];
        CGFloat emojiRatio = 2.43;
        
        //when
        NSDictionary * optionsDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                      testFont, MESubstituteOptionFont,
                                      color, MESubstituteOptionTextColor,
                                      [NSNumber numberWithBool:YES], MESubstituteOptionShouldScanForLinks,
                                      [NSNumber numberWithFloat:emojiRatio],MESubstituteOptionEmojiSizeRatio,
                                      linkStyle,MESubstituteOptionLinkStyle,
                                      nil];
        
        NSString *string =  [METextInputView convertSubstituteToHTML:testString options:optionsDict];
        //then
        OCMVerify([inputTextviewClassMock convertSubstituedToHTML:[OCMArg any] withFont:[OCMArg any] textColor:[OCMArg any]]);
        expect(string).to.equal(@"<p dir=\"auto\" style=\"font-family:'.SF UI Text';font-size:10px;\"><span style=\"color:#FF0000;\">http:\\<a href='http://emojilinktest.com' style='linkStyle'>http://emojilinktest.com</a> test <img style=\"vertical-align:middle;width:34px;height:34px;\" src=\"https://d1tvcfe0bfyi6u.cloudfront.net/emoji/952-large@2x.png\" id=\"952\" link=\"\" name=\"e\" /></span></p>");
    });
    
    it(@"convert substitute to HTML options without options with textfont, color,offset link, emoji ratio, emoji and paragraph block", ^{
        //given
        id inputTextviewClassMock = [OCMockObject mockForClass:[METextInputView class]];
        UIFont *testFont = [UIFont systemFontOfSize:10];
        NSString *testString = @"http:\\emojilinktest.com test [e.FM]";
        NSString *linkStyle = @"linkStyle";
        UIColor *color  = [UIColor redColor];
        CGFloat emojiRatio = 2.43;
        
        //when
        NSDictionary * optionsDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                      testFont, MESubstituteOptionFont,
                                      color, MESubstituteOptionTextColor,
                                      [NSNumber numberWithBool:YES], MESubstituteOptionShouldScanForLinks,
                                      [NSNumber numberWithBool:YES], MESubstituteOptionUseParagraphBlocks,
                                      [NSNumber numberWithFloat:emojiRatio],MESubstituteOptionEmojiSizeRatio,
                                      linkStyle,MESubstituteOptionLinkStyle,
                                      nil];
        
        NSString *string =  [METextInputView convertSubstituteToHTML:testString options:optionsDict];
        //then
        OCMVerify([inputTextviewClassMock convertSubstituedToHTML:[OCMArg any] withFont:[OCMArg any] textColor:[OCMArg any]]);
        expect(string).to.equal(@"<p dir=\"auto\" style=\"font-family:'.SF UI Text';font-size:10px;\"><span style=\"color:#FF0000;\">http:\\<a href='http://emojilinktest.com' style='linkStyle'>http://emojilinktest.com</a> test <img style=\"vertical-align:middle;width:34px;height:34px;\" src=\"https://d1tvcfe0bfyi6u.cloudfront.net/emoji/952-large@2x.png\" id=\"952\" link=\"\" name=\"e\" /></span></p>");
    });

    
    it(@"transform HTML with font and text color", ^{
       //given
        NSString *testString =@"<p dir=\"auto\" style=\"font-family:'.SF UI Text';font-size:10px;\"><span style=\"color:#FF0000;\">http:\\<a href='http://emojilinktest.com' style='linkStyle'>http://emojilinktest.com</a> test <img style=\"vertical-align:middle;width:34px;height:34px;\" src=\"https://d1tvcfe0bfyi6u.cloudfront.net/emoji/952-large@2x.png\" id=\"952\" link=\"\" name=\"e\" /></span></p>";
        UIFont *font = [UIFont boldSystemFontOfSize:25];
        UIColor *color = [UIColor yellowColor];
        
        //when
        NSString *string = [METextInputView transformHTML:testString withFont:font textColor:color];

        //then
        expect(string).to.equal(@"<p dir=\"auto\" style=\"font-family:'.SF UI Display';font-size:25px;\"><span style=\"color:#FFFF00;\">http:\\<a href='http://emojilinktest.com' style='linkStyle'>http://emojilinktest.com</a> test <img style=\"vertical-align:middle;width:34px;height:34px;\" src=\"https://d1tvcfe0bfyi6u.cloudfront.net/emoji/952-large@2x.png\" id=\"952\" link=\"\" name=\"e\" /></span></p>");
    });
    
    it(@"transform HTML with font and text color", ^{
        //given
        NSString *testString =@"testString";
        UIFont *font = [UIFont boldSystemFontOfSize:25];
        UIColor *color = [UIColor yellowColor];
        
        //when
        NSString *string = [METextInputView transformHTML:testString withFont:font textColor:color];
        
        //then
        expect(string).to.equal(@"testString");
    });
    

    it(@"set selected text range", ^{
        
        //given
        UITextPosition *start =0;
        UITextPosition *end = 0;
        UITextRange *textRange = [DTTextRange textRangeFromStart:start toEnd:end];
        id classMock = [OCMockObject mockForClass:[DTTextRange class]];
        
        [[[classMock expect]andDo:^(NSInvocation *invocation) {
            UITextPosition *positionStart;
            UITextPosition *positionEnd;
            
            
            [invocation getArgument:&positionStart atIndex:2];
            [invocation getArgument:&positionEnd atIndex:3];
            
            expect(positionStart).to.equal(textRange.start);
            expect(positionEnd).to.equal(textRange.end);
        }] textRangeFromStart:[OCMArg any] toEnd:[OCMArg any]];

        //when
        [classUndertest setSelectedTextRange:textRange animated:YES];
        
    });
    
    it(@"content size", ^{
        
        //when
        CGSize size = [classUndertest contentSize];
        
        //then
        expect(size).toNot.beNil();
    });
    
    it(@"substitute character count no attachment", ^{
        
        
        //when
        NSUInteger result = [classUndertest substituteCharacterCount];
        
        //then
        expect((int)result).to.equal(0);
    });
    
    it(@"substitute character count with emoji id", ^{
        
        //given
        
        id partialMock = [OCMockObject partialMockForObject:classUndertest];
        NSMutableArray *arrayToReturn = [[NSMutableArray alloc]init];
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"1001",@"id", nil];
        DTImageTextAttachment *attachment = [[DTImageTextAttachment alloc]init];
        attachment.attributes = dict;
        [arrayToReturn addObject:attachment];
        [[[partialMock stub] andReturn:arrayToReturn] textAttachments];
        
        //when
        NSUInteger result = [partialMock substituteCharacterCount];
        
        //then
        expect((int)result).to.equal(5);
    });
    
    it(@"substitute character count with link", ^{
        
        //given
        id partialMock = [OCMockObject partialMockForObject:classUndertest];
        NSMutableArray *arrayToReturn = [[NSMutableArray alloc]init];
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"http:\\linkemojitest.com" ,@"link", nil];
        DTImageTextAttachment *attachment = [[DTImageTextAttachment alloc]init];
        attachment.attributes = dict;
        [arrayToReturn addObject:attachment];
        [[[partialMock stub] andReturn:arrayToReturn] textAttachments];
        
        //when
        NSUInteger result = [partialMock substituteCharacterCount];
        
        //then
        expect((int)result).to.equal(24);
    });
    
    
    it(@"substitute character count with emoji id and link", ^{
        
        //given
        id partialMock = [OCMockObject partialMockForObject:classUndertest];
        NSMutableArray *arrayToReturn = [[NSMutableArray alloc]init];
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"1001",@"id", @"http:\\linkemojitest.com" ,@"link", nil];
        DTImageTextAttachment *attachment = [[DTImageTextAttachment alloc]init];
        attachment.attributes = dict;
        [arrayToReturn addObject:attachment];
        [[[partialMock stub] andReturn:arrayToReturn] textAttachments];
        
        //when
        NSUInteger result = [partialMock substituteCharacterCount];
        
        //then
        expect((int)result).to.equal(29);
    });
    
    afterEach(^{
        
    });
    
    afterAll(^{
    });
});

SpecEnd
