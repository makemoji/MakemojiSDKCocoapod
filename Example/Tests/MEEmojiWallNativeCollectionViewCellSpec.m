//
//  MEEmojiWallNativeCollectionViewCellSpec.m
//  Makemoji-SDK
//
//  Created by David Muñoz - Simplex Software on 14/6/17.
//  Copyright © 2017 Makemoji. All rights reserved.
//

#import "Specta.h"
#import "Expecta.h"
#import "OCMock.h"
#import "MEEmojiWallNativeCollectionViewCell.h"

SpecBegin(MEEmojiWallNativeCollectionViewCell)

describe(@"MEEmojiWallNativeCollectionViewCell.h", ^{
    
    __block MEEmojiWallNativeCollectionViewCell *classUnderTest;
    
    beforeAll(^{
    });
    
    beforeEach(^{
        classUnderTest= [[MEEmojiWallNativeCollectionViewCell alloc]init];

    });
    
    it(@"set data", ^{
        //given
        
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"test",@"character", nil];
        //when
        [classUnderTest setData:dict];
        
        //then
        expect(classUnderTest.emojiView.text).to.equal(@"test");
    });
    
    it(@"set data empty string", ^{
        //given
        
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"",@"character", nil];
        //when
        [classUnderTest setData:dict];
        
        //then
        expect(classUnderTest.emojiView.text).to.equal(@"");
    });
    
    it(@"set data special characters string", ^{
        //given
        
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"!# ~ñÑ",@"character", nil];
        //when
        [classUnderTest setData:dict];
        
        //then
        expect(classUnderTest.emojiView.text).to.equal(@"!# ~ñÑ");
    });
    
    
    afterEach(^{
        classUnderTest = nil;
    });
    
    afterAll(^{
        
    });
});

SpecEnd
