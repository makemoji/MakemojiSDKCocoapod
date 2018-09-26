//
//  MEKeyboardPhraseCollectionViewCellSpec.m
//  Makemoji-SDK
//
//  Created by David Muñoz - Simplex Software on 14/6/17.
//  Copyright © 2017 Makemoji. All rights reserved.
//

#import "MEKeyboardPhraseCollectionViewCell.h"
#import "Specta.h"
#import "Expecta.h"
#import "OCMock.h"

SpecBegin(MEKeyboardPhraseCollectionViewCell)

describe(@"MEKeyboardPhraseCollectionViewCell", ^{
    
    __block MEKeyboardPhraseCollectionViewCell *classUnderTest;
    
    beforeAll(^{
        
    });
    
    beforeEach(^{
        classUnderTest = [[MEKeyboardPhraseCollectionViewCell alloc]init];
    });

    it(@"set data nil case", ^{
        
        //given
        NSDictionary *dict = [NSDictionary dictionary];
        
        //when
        [classUnderTest setData:dict];
        
        //then
        expect([classUnderTest.imageViews count]).to.equal(0);
    });
    
    it(@"set data with 1 no native emoji", ^{
        
        //given
        NSDictionary *dictEmoji = [NSDictionary dictionaryWithObjectsAndKeys:
                                   @"image_url",@"image_url",
                                   nil];
        
        NSDictionary *dictData = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSArray arrayWithObject:dictEmoji],@"emoji",
                              nil];
        
        //when
        [classUnderTest setData:dictData];
        
        //then
        expect([classUnderTest.imageViews count]).to.equal(1);
    });
    
    it(@"set data with 1 native emoji", ^{
        
        //given
        NSDictionary *dictEmoji = [NSDictionary dictionaryWithObjectsAndKeys:
                                   @"native",@"native",
                                   @"character", @"character",
                                   nil];
        
        NSDictionary *dictData = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSArray arrayWithObject:dictEmoji],@"emoji",
                                  nil];
        
        //when
        [classUnderTest setData:dictData];
        
        //then
        expect([classUnderTest.imageViews count]).to.equal(1);
    });
    
    it(@"set data with 1 native emoji and 1 no native emoji", ^{
        
        //given
        NSDictionary *dictNativeEmoji = [NSDictionary dictionaryWithObjectsAndKeys:
                                   @"native",@"native",
                                   @"character", @"character",
                                   nil];
        NSDictionary *dictNoNativeEmoji = [NSDictionary dictionaryWithObjectsAndKeys:
                                   @"image_url",@"image_url",
                                   nil];
        
        NSDictionary *dictData = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSArray arrayWithObjects:dictNativeEmoji,dictNoNativeEmoji,nil],@"emoji",
                                  nil];
        
        //when
        [classUnderTest setData:dictData];
        
        //then
        expect([classUnderTest.imageViews count]).to.equal(2);
    });
    it(@"set data with nested 2 native emoji and 2 no native emoji", ^{
        
        //given
        NSDictionary *dictNativeEmoji = [NSDictionary dictionaryWithObjectsAndKeys:
                                         @"native",@"native",
                                         @"character", @"character",
                                         nil];
        NSDictionary *dictNoNativeEmoji = [NSDictionary dictionaryWithObjectsAndKeys:
                                           @"image_url",@"image_url",
                                           nil];
        
        NSDictionary *dictData = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSArray arrayWithObjects:dictNativeEmoji,dictNoNativeEmoji,dictNativeEmoji,dictNoNativeEmoji,nil],@"emoji",
                                  nil];
        
        //when
        [classUnderTest setData:dictData];
        
        //then
        expect([classUnderTest.imageViews count]).to.equal(4);
    });
    afterEach(^{
        classUnderTest = nil;
        
    });
    
    afterAll(^{
        
    });
});

SpecEnd
