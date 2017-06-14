//
//  MEFlashTagCollectionViewCellSpec.m
//  Makemoji-SDK
//
//  Created by David Muñoz - Simplex Software on 14/6/17.
//  Copyright © 2017 Makemoji. All rights reserved.
//



#import "Specta.h"
#import "Expecta.h"
#import "OCMock.h"
#import "MEFlashTagCollectionViewCell.h"

SpecBegin(MEFlashTagCollectionViewCell)

describe(@"MEFlashTagCollectionViewCell", ^{
    
    __block MEFlashTagCollectionViewCell *classUnderTest ;
    
    beforeAll(^{
        
    });
    
    beforeEach(^{
        classUnderTest = [[MEFlashTagCollectionViewCell alloc]init];
    });
    
    it(@"set data without flashtag", ^{
        //given
        NSDictionary *dict = [NSDictionary dictionary];
        
        //when
        [classUnderTest setData:dict];
        
        //then
        expect([classUnderTest.imageView.layer animationKeys]).to.beNil();
        
    });
    
    it(@"set data with string flashtag", ^{
        //given
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                              @"flashtag" , @"flashtag",
                              nil];
        
        //when
        [classUnderTest setData:dict];
        
        //then
        expect([classUnderTest.imageView.layer animationKeys]).toNot.beNil();
        
    });
    
    it(@"set data with number flashtag", ^{
        //given
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                               [NSNumber numberWithInt:1001],@"flashtag" ,
                              nil];
        
        //when
        [classUnderTest setData:dict];
        
        //then
        expect([classUnderTest.imageView.layer animationKeys]).toNot.beNil();
        
    });
    
    it(@"set data with nil flashtag", ^{
        //given
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                              @"",@"flashtag" ,
                              nil];
        
        //when
        [classUnderTest setData:dict];
        
        //then
        expect([classUnderTest.imageView.layer animationKeys]).to.beNil();
        
    });

    it(@"set data with string flashtag and null link_url", ^{
        //given
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                              @"flashtag" , @"flashtag",
                              [NSNull null], @"link_url",
                              nil];
        
        //when
        [classUnderTest setData:dict];
        
        //then
        expect([classUnderTest.imageView.layer animationKeys]).to.beNil();
        
    });
    
    it(@"set data with NUMBER flashtag and null link_url", ^{
        //given
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithInt:1001], @"flashtag",
                              [NSNull null], @"link_url",
                              nil];
        
        //when
        [classUnderTest setData:dict];
        
        //then
        expect([classUnderTest.imageView.layer animationKeys]).to.beNil();
        
    });
    afterEach(^{
        classUnderTest = nil;
    });
    
    afterAll(^{
        
    });
});

SpecEnd
