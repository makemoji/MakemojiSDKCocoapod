//
//  MEReactionCollectionViewCell.m
//  Makemoji-SDK
//
//  Created by David Muñoz - Simplex Software on 14/6/17.
//  Copyright © 2017 Makemoji. All rights reserved.
//

#import "Specta.h"
#import "Expecta.h"
#import "OCMock.h"
#import "MEReactionCollectionViewCell.h"
SpecBegin(MEReactionCollectionViewCellSpec)

describe(@"MEReactionCollectionViewCellSpec", ^{
    
    __block MEReactionCollectionViewCell *classUnderTest;
    
    beforeAll(^{
        
    });
    
    beforeEach(^{
        classUnderTest = [[MEReactionCollectionViewCell alloc]init];
    });
    
    it(@"set reaction data with total number", ^{
        //given
        classUnderTest.textColor = [UIColor redColor];
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithInt:1],@"total",
                              nil];
        //when
        [classUnderTest setReactionData:dict];
        
        //then
        expect(classUnderTest.unicodeEmoji.hidden).to.beTruthy();
        expect(classUnderTest.totalLabel.text).to.equal(@"1");
        expect(classUnderTest.imageView.alpha).to.equal(1.0f);
    });
    
    it(@"set reaction data with character and total number", ^{
        //given
        classUnderTest.textColor = [UIColor redColor];
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithInt:1],@"total",
                              @"character",@"character",
                              nil];
        //when
        [classUnderTest setReactionData:dict];
        
        //then
        expect(classUnderTest.unicodeEmoji.text).to.equal(@"character");
        expect(classUnderTest.unicodeEmoji.hidden).to.beFalsy();
        expect(classUnderTest.totalLabel.text).to.equal(@"1");
        expect(classUnderTest.imageView.alpha).to.equal(1.0f);
    });
    
    it(@"set reaction data with character , total number and imageurl", ^{
        //given
        classUnderTest.textColor = [UIColor redColor];
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithInt:0],@"total",
                              @"image_url",@"image_url",
                              @"character",@"character",
                              nil];
        //when
        [classUnderTest setReactionData:dict];
        
        //then
        expect(classUnderTest.unicodeEmoji.text).to.equal(@"character");
        expect(classUnderTest.unicodeEmoji.hidden).to.beFalsy();
        expect(classUnderTest.unicodeEmoji.alpha).to.equal(0.5f);
        expect(classUnderTest.totalLabel.text).to.beNil();
        expect(classUnderTest.imageView.alpha).to.equal(0.5f);
    });
    
    it(@"set reaction data with character , total number, imageurl and currentUser", ^{
        //given
        classUnderTest.textColor = [UIColor redColor];
        classUnderTest.highlightColor = [UIColor yellowColor];
        NSDictionary *dictCurrentUser = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:1] forKey:@"emoji_id"];
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithInt:1],@"total",
                              dictCurrentUser, @"currentUser",
                              @"image_url",@"image_url",
                              @"character",@"character",
                              [NSNumber numberWithInt:1],@"emoji_id",
                              nil];
        //when
        [classUnderTest setReactionData:dict];
        
        //then
        expect(classUnderTest.unicodeEmoji.text).to.equal(@"character");
        expect(classUnderTest.unicodeEmoji.hidden).to.beFalsy();
        expect(classUnderTest.unicodeEmoji.alpha).to.equal(1.0f);
        expect(classUnderTest.totalLabel.text).equal(@"1");
        expect(classUnderTest.totalLabel.textColor).to.equal([UIColor yellowColor]);
        expect(classUnderTest.imageView.alpha).to.equal(1.0f);
    });
    
    it(@"set reaction data with character , total number, imageurl and currentUser with different emojies id", ^{
        //given
        classUnderTest.textColor = [UIColor redColor];
        classUnderTest.highlightColor = [UIColor yellowColor];
        NSDictionary *dictCurrentUser = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:1] forKey:@"emoji_id"];
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithInt:1],@"total",
                              dictCurrentUser, @"currentUser",
                              @"image_url",@"image_url",
                              @"character",@"character",
                              [NSNumber numberWithInt:2],@"emoji_id",
                              nil];
        //when
        [classUnderTest setReactionData:dict];
        
        //then
        expect(classUnderTest.unicodeEmoji.text).to.equal(@"character");
        expect(classUnderTest.unicodeEmoji.hidden).to.beFalsy();
        expect(classUnderTest.unicodeEmoji.alpha).to.equal(1.0f);
        expect(classUnderTest.totalLabel.text).equal(@"1");
        expect(classUnderTest.totalLabel.textColor).to.equal([UIColor redColor]);
        expect(classUnderTest.imageView.alpha).to.equal(1.0f);
    });

    afterEach(^{
        classUnderTest = nil;
    });
    
    afterAll(^{
        
    });
});

SpecEnd
