//
//  MELinkedImageView.m
//  Makemoji-SDK
//
//  Created by David Muñoz - Simplex Software on 14/6/17.
//  Copyright © 2017 Makemoji. All rights reserved.
//

#import "MELinkedImageView.h"
#import "Specta.h"
#import "Expecta.h"
#import "OCMock.h"

SpecBegin(MELinkedImageView)

describe(@"MELinkedImageView", ^{
    
    __block MELinkedImageView *classUnderTest;
    
    beforeAll(^{
        
    });
    
    beforeEach(^{
        classUnderTest = [[MELinkedImageView alloc]init];
    });
    
    it(@"set image url link nil links", ^{
        //given
        classUnderTest.linkedUrl = nil;
        NSString *link = @"";
        NSString *imageUrl = @"imageUrl";
        
        //when
        [classUnderTest setImageUrl:imageUrl link:link];
        
        //then
        expect(classUnderTest.linkedUrl).to.beNil();
        expect([classUnderTest.imageView.layer animationKeys]).to.beNil();
    });
    
    it(@"set image url link ", ^{
        //given
        classUnderTest.linkedUrl = nil;
        NSString *link = @"link";
        NSString *imageUrl = @"imageUrl";
        
        //when
        [classUnderTest setImageUrl:imageUrl link:link];
        
        //then
        expect(classUnderTest.linkedUrl).to.equal([NSURL URLWithString:@"link"]);
        expect([classUnderTest.imageView.layer animationKeys]).toNot.beNil();
    });
    
    afterEach(^{
        classUnderTest= nil;
    });
    
    afterAll(^{
        
    });
});

SpecEnd
