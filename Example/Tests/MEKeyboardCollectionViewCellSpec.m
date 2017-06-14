//
//  MEKeyboardCollectionViewCellSpec.m
//  Makemoji-SDK
//
//  Created by David Muñoz - Simplex Software on 14/6/17.
//  Copyright © 2017 Makemoji. All rights reserved.
//
#import "MEKeyboardCollectionViewCell.h"
#import "Specta.h"
#import "Expecta.h"
SpecBegin(MEKeyboardCollectionViewCell)

describe(@"MEKeyboardCollectionViewCell.h", ^{
    
    beforeAll(^{
        
    });
    
    beforeEach(^{
        
    });
    
    it(@"start link animation", ^{
        
        MEKeyboardCollectionViewCell *classUnderTest = [[MEKeyboardCollectionViewCell alloc]init];
        expect([classUnderTest.inputButton.layer animationKeys]).to.beNil();
        
        //when
        [classUnderTest startLinkAnimation];
        expect([classUnderTest.inputButton.layer animationKeys]).toNot.beNil();
    });
    
    afterEach(^{
        
    });
    
    afterAll(^{
        
    });
});

SpecEnd
