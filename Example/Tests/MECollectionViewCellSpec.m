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
    
    beforeAll(^{
        
    });
    
    beforeEach(^{
        
    });
    
    it(@"cell max width", ^{
        //given
        CGFloat width = 100;
        MECollectionViewCell *cell = [[MECollectionViewCell alloc]init];
        
        //when
        CGFloat receivedWidth = [cell cellMaxWidth:width];
        
        //then
        expect(receivedWidth).to.equal(100);
    });
    
    it(@"cell max width negative case", ^{
        //given
        CGFloat width = -100;
        MECollectionViewCell *cell = [[MECollectionViewCell alloc]init];
        
        //when
        CGFloat receivedWidth = [cell cellMaxWidth:width];
        
        //then
        expect(receivedWidth).to.equal(-100);
    });
    
    it(@"cell max width 0 case", ^{
        //given
        CGFloat width = 0;
        MECollectionViewCell *cell = [[MECollectionViewCell alloc]init];
        
        //when
        CGFloat receivedWidth = [cell cellMaxWidth:width];
        
        //then
        expect(receivedWidth).to.equal(0);
    });
    
    it(@"height with initial size", ^{
        //given
        CGSize  size = CGSizeMake(100,100) ;
        MECollectionViewCell *cell = [[MECollectionViewCell alloc]init];
        
        //when
        CGFloat receivedSize = [cell heightWithInitialSize:size];
        
        //then
        expect(receivedSize).to.equal(100);
    });
    
    it(@"height with initial size negative case", ^{
        //given
        CGSize  size = CGSizeMake(-100,-100) ;
        MECollectionViewCell *cell = [[MECollectionViewCell alloc]init];
        
        //when
        CGFloat receivedSize = [cell heightWithInitialSize:size];
        
        //then
        expect(receivedSize).to.equal(-100);
    });
    
    it(@"height with initial size negative case", ^{
        //given
        CGSize  size = CGSizeMake(0,0) ;
        MECollectionViewCell *cell = [[MECollectionViewCell alloc]init];
        
        //when
        CGFloat receivedSize = [cell heightWithInitialSize:size];
        
        //then
        expect(receivedSize).to.equal(0);
    });
    
    it(@"suggested frame size to fit entire string constrainted to width", ^{
        //given
        CGFloat width = 100;
        MECollectionViewCell *cell = [[MECollectionViewCell alloc]init];
        
        //when
        CGSize receivedSize = [cell suggestedFrameSizeToFitEntireStringConstraintedToWidth:width];
        
        //then
        expect(receivedSize).to.equal(CGSizeMake(0, 0));
    });
    
    it(@"suggested frame size to fit entire string constrainted to width 0 case", ^{
        //given
        CGFloat width = 0;
        MECollectionViewCell *cell = [[MECollectionViewCell alloc]init];
        
        //when
        CGSize receivedSize = [cell suggestedFrameSizeToFitEntireStringConstraintedToWidth:width];
        
        //then
        expect(receivedSize).to.equal(CGSizeMake(0, 0));
    });
    
    it(@"suggested frame size to fit entire string constrainted to width negative case", ^{
        //given
        CGFloat width = -100;
        MECollectionViewCell *cell = [[MECollectionViewCell alloc]init];
        
        //when
        CGSize receivedSize = [cell suggestedFrameSizeToFitEntireStringConstraintedToWidth:width];
        
        //then
        expect(receivedSize).to.equal(CGSizeMake(0, 0));
    });
    
    afterEach(^{
        
    });
    
    afterAll(^{
        
    });
});

SpecEnd
