//
//  MEPhraseCollectionViewCellSpec.m
//  Makemoji-SDK
//
//  Created by David Muñoz - Simplex Software on 14/6/17.
//  Copyright © 2017 Makemoji. All rights reserved.
//

#import "MEPhraseCollectionViewCell.h"
#import "Specta.h"
#import "Expecta.h"
#import "OCMock.h"

SpecBegin(MEPhraseCollectionViewCell)

describe(@"MEPhraseCollectionViewCell", ^{
    __block MEPhraseCollectionViewCell *classUnderTest;
    
    beforeAll(^{
        
    });
    
    beforeEach(^{
        classUnderTest = [[MEPhraseCollectionViewCell alloc]init];
    });
    
    it(@"set data nil flashtag", ^{
        //given
        NSDictionary *dict = [NSDictionary dictionary];
        
        //when
        [classUnderTest setData: dict];
        
        //then
        expect(classUnderTest.flashTagLabel.text).to.beNil();
    });
    
    
    it(@"set data 0 length flashtag", ^{
        //given
        NSDictionary *dict = [NSDictionary dictionaryWithObject:@"" forKey:@"flashtag"];
        
        //when
        [classUnderTest setData: dict];
        
        //then
        expect(classUnderTest.flashTagLabel.text).to.beNil();
    });
    
    it(@"set data with native emoji and number Flashtag", ^{
        //given
        NSDictionary *dictNativeEmoji = [NSDictionary dictionaryWithObjectsAndKeys:
                                         @"native",@"native",
                                         @"character", @"character",nil];
              
        NSDictionary *dictData = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSArray arrayWithObjects:dictNativeEmoji,nil],@"emoji",
                                  [NSNumber numberWithInt:1001],@"flashtag",
                                  nil];
        
        //when
        [classUnderTest setData:dictData];
        
        //then
        expect(classUnderTest.flashTagLabel.text).toNot.beNil();
        expect(classUnderTest.imageViews.count).to.equal(1);
    });
    
    it(@"set data with no native emoji", ^{
        //given
        NSDictionary *dictNoNativeEmoji = [NSDictionary dictionaryWithObjectsAndKeys:
                                           @"image_url",@"image_url",
                                           nil];
        
        NSDictionary *dictData = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSArray arrayWithObjects:dictNoNativeEmoji,nil],@"emoji",
                                  [NSNumber numberWithInt:1001],@"flashtag",
                                  nil];
        
        //when
        [classUnderTest setData:dictData];
        
        //then
        expect(classUnderTest.flashTagLabel.text).toNot.beNil();
        expect(classUnderTest.imageViews.count).to.equal(1);
    });
    
    it(@"set data with  1 no native emoji and 1 no native emoji", ^{
        //given
        NSDictionary *dictNoNativeEmoji = [NSDictionary dictionaryWithObjectsAndKeys:
                                           @"image_url",@"image_url",
                                           nil];
        NSDictionary *dictNativeEmoji = [NSDictionary dictionaryWithObjectsAndKeys:
                                         @"native",@"native",
                                         @"character", @"character",nil];

        
        NSDictionary *dictData = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSArray arrayWithObjects:dictNoNativeEmoji,dictNativeEmoji,nil],@"emoji",
                                  [NSNumber numberWithInt:1001],@"flashtag",
                                  nil];
        
        //when
        [classUnderTest setData:dictData];
        
        //then
        expect(classUnderTest.flashTagLabel.text).toNot.beNil();
        expect(classUnderTest.imageViews.count).to.equal(2);
    });
    it(@"set data with nested emojies", ^{
        //given
        NSDictionary *dictNoNativeEmoji = [NSDictionary dictionaryWithObjectsAndKeys:
                                           @"image_url",@"image_url",
                                           nil];
        NSDictionary *dictNativeEmoji = [NSDictionary dictionaryWithObjectsAndKeys:
                                         @"native",@"native",
                                         @"character", @"character",nil];
        
        
        NSDictionary *dictData = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSArray arrayWithObjects:dictNoNativeEmoji,dictNativeEmoji,dictNoNativeEmoji,dictNativeEmoji,nil],@"emoji",
                                  [NSNumber numberWithInt:1001],@"flashtag",
                                  nil];
        
        //when
        [classUnderTest setData:dictData];
        
        //then
        expect(classUnderTest.flashTagLabel.text).toNot.beNil();
        expect(classUnderTest.imageViews.count).to.equal(4);
    });

    afterEach(^{
        classUnderTest = nil;
    });
    
    afterAll(^{
     
    });
});

SpecEnd
