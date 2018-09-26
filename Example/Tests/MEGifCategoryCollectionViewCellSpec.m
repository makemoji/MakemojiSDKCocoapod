//
//  MEGifCategoryCollectionViewCellSpec.m
//  Makemoji-SDK
//
//  Created by David Muñoz - Simplex Software on 14/6/17.
//  Copyright © 2017 Makemoji. All rights reserved.
//

#import "Specta.h"
#import "Expecta.h"
#import "OCMock.h"
#import "MEGifCategoryCollectionViewCell.h"

SpecBegin(MEGifCategoryCollectionViewCell)

describe(@"MEGifCategoryCollectionViewCell", ^{
    
    beforeAll(^{
        
    });
    
    beforeEach(^{
        
    });
    it(@"randomize gradient", ^{
       
        //given
        MEGifCategoryCollectionViewCell *classUnderTest = [[MEGifCategoryCollectionViewCell alloc]init];
        
        //when
        [classUnderTest randomizeGradient];
    });
    
    afterEach(^{
        
    });
    
    afterAll(^{
        
    });
});

SpecEnd
