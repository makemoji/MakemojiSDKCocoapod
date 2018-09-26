//
//  MECollectionViewCellSpec.m
//  Makemoji-SDK
//
//  Created by David Muñoz - Simplex Software on 13/6/17.
//  Copyright © 2017 Makemoji. All rights reserved.
//

#import "Specta.h"
#import "Expecta.h"
#import "MECollectionViewCell.h"

SpecBegin(MECollectionViewCell)

describe(@"MECollectionViewCell", ^{
    
    __block MECollectionViewCell *classUnderTest;
    
    beforeAll(^{
        
    });
    
    beforeEach(^{
        classUnderTest = [[MECollectionViewCell alloc]init];
    });
    
    it(@"cell max width", ^{
        //given
        CGFloat width = 100;
        
        //when
        CGFloat receivedWidth = [classUnderTest cellMaxWidth:width];
        
        //then
        expect(receivedWidth).to.equal(100);
    });
    
    it(@"cell max width negative case", ^{
        //given
        CGFloat width = -100;
        
        //when
        CGFloat receivedWidth = [classUnderTest cellMaxWidth:width];
        
        //then
        expect(receivedWidth).to.equal(-100);
    });
    
    it(@"cell max width 0 case", ^{
        //given
        CGFloat width = 0;
        
        //when
        CGFloat receivedWidth = [classUnderTest cellMaxWidth:width];
        
        //then
        expect(receivedWidth).to.equal(0);
    });
    
    it(@"height with initial size", ^{
        //given
        CGSize  size = CGSizeMake(100,100) ;
        
        //when
        CGFloat receivedSize = [classUnderTest heightWithInitialSize:size];
        
        //then
        expect(receivedSize).to.equal(100);
    });
    
    it(@"height with initial size negative case", ^{
        //given
        CGSize  size = CGSizeMake(-100,-100) ;
        
        //when
        CGFloat receivedSize = [classUnderTest heightWithInitialSize:size];
        
        //then
        expect(receivedSize).to.equal(-100);
    });
    
    it(@"height with initial size negative case", ^{
        //given
        CGSize  size = CGSizeMake(0,0) ;
        
        //when
        CGFloat receivedSize = [classUnderTest heightWithInitialSize:size];
        
        //then
        expect(receivedSize).to.equal(0);
    });
    
    it(@"suggested frame size to fit entire string constrainted to width", ^{
        //given
        CGFloat width = 100;
        
        //when
        CGSize receivedSize = [classUnderTest suggestedFrameSizeToFitEntireStringConstraintedToWidth:width];
        
        //then
        expect(receivedSize).to.equal(CGSizeMake(0, 0));
    });
    
    it(@"suggested frame size to fit entire string constrainted to width 0 case", ^{
        //given
        CGFloat width = 0;
        
        //when
        CGSize receivedSize = [classUnderTest suggestedFrameSizeToFitEntireStringConstraintedToWidth:width];
        
        //then
        expect(receivedSize).to.equal(CGSizeMake(0, 0));
    });
    
    it(@"suggested frame size to fit entire string constrainted to width negative case", ^{
        //given
        CGFloat width = -100;
        
        //when
        CGSize receivedSize = [classUnderTest suggestedFrameSizeToFitEntireStringConstraintedToWidth:width];
        
        //then
        expect(receivedSize).to.equal(CGSizeMake(0, 0));
    });
    
    afterEach(^{
        
    });
    
    afterAll(^{
        
    });
});

SpecEnd
