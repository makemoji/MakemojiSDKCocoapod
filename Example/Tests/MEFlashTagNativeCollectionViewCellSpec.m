//
//  MEFlashTagNativeCollectionViewCellSpec.m
//  Makemoji-SDK
//
//  Created by David Muñoz - Simplex Software on 14/6/17.
//  Copyright © 2017 Makemoji. All rights reserved.
//

#import "MEFlashTagNativeCollectionViewCell.h"
#import "Specta.h"
#import "Expecta.h"
#import "OCMock.h"

SpecBegin(MEFlashTagNativeCollectionViewCell)

describe(@"MEFlashTagNativeCollectionViewCell.h", ^{
    
    __block MEFlashTagNativeCollectionViewCell *classUnderTest;
    
    beforeAll(^{
        
    });
    
    beforeEach(^{
        classUnderTest = [[MEFlashTagNativeCollectionViewCell alloc]init];
    });
    
    it(@"set data with string flashtag", ^{
        //given
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                              @"flashtag",@"flashtag",
                              @"character",@"character",
                              nil];
        
        //when
        [classUnderTest setData:dict];
        
        //then
        expect(classUnderTest.emojiView.text).to.equal(@"character");
    });
    it(@"set data with number flashtag", ^{
        //given
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithInt:1001],@"flashtag",
                              @"character",@"character",
                              nil];
        
        //when
        [classUnderTest setData:dict];
        
        //then
        expect(classUnderTest.emojiView.text).to.equal(@"character");
    });
    
    it(@"set data with nil flashtag", ^{
        //given
        NSDictionary *dict = [NSDictionary dictionary];
        
        //when
        [classUnderTest setData:dict];
        
        //then
        expect(classUnderTest.emojiView.text).to.beNil();
    });
    
    afterEach(^{
        classUnderTest = nil;
    });
    
    afterAll(^{
        
    });
});

SpecEnd
