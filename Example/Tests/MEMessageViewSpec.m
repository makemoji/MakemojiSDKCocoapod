//
//  MEMessageViewSpec.m
//  Makemoji-SDK
//
//  Created by David Muñoz - Simplex Software on 14/6/17.
//  Copyright © 2017 Makemoji. All rights reserved.
//
#import "Specta.h"
#import "Expecta.h"
#import "OCMock.h"
#import "MEMessageView.h"

SpecBegin(MEMessageView)

describe(@"MEMessageView", ^{
    
    beforeAll(^{
        
    });
    
    beforeEach(^{
        
    });
    
    it(@"suggested frame size to fit entire string constrainted to width", ^{
        //given
        MEMessageView *classUnderTest = [[MEMessageView alloc]init];
        int width = 100;
        //when
        CGSize receivedSize = [classUnderTest suggestedFrameSizeToFitEntireStringConstraintedToWidth:width];
        
        //then
        expect(receivedSize).to.equal(CGSizeMake(0,0));
    });
    
    it(@"suggested size for text for size", ^{
        //given
        MEMessageView *classUnderTest = [[MEMessageView alloc]init];
        CGSize size = CGSizeMake(100, 100);
        //when
        CGSize receivedSize = [classUnderTest suggestedSizeForTextForSize:size];
        
        //then
        expect(receivedSize).to.equal(CGSizeMake(0,0));
    });
    
    afterEach(^{
        
    });
    
    afterAll(^{
        
    });
});

SpecEnd
