//
//  NSString_MEUtilitiesSpec.m
//  Makemoji-SDK
//
//  Created by David Muñoz - Simplex Software on 29/5/17.
//  Copyright © 2017 Makemoji. All rights reserved.
//

#import <Specta/Specta.h>
#import <Expecta/Expecta.h>
#import "NSString+MEUtilities.h"
#import "OCMock.h"

SpecBegin(NSString_MEUtilities)

describe(@"NSString+MEUtilities", ^{
    
    beforeAll(^{
        
    });
    
    beforeEach(^{
        
    });
    
    it(@"sha1", ^{
       //given
        NSString *testString = @"testString";
        
        //when
        NSString *resultString = [testString sha1];
        
        //then
        expect(resultString).to.equal(@"956265657d0b637ef65b9b59f9f858eecf55ed6a");
    });
    
    it(@"sha1 special character", ^{
       
        //given
        NSString *testString = @"testString#¢#¢éLÑlcñx!!2ñdai!DSAáêü";
        
        //when
        NSString *resultString = [testString sha1];
        
        //then
        expect(resultString).to.equal(@"e399b5308b370ee0d709d36621a18b94fae3e6cb");
        
    });
    
    it(@"ends with character positive case", ^{
       
        //given
        NSString *testString = @"testString";
        
        //when
        BOOL endWithLetter = [testString endsWithCharacter:'g'];
       
        //then
        expect(endWithLetter).to.beTruthy();
    });
    
    it(@"ends with character negative case", ^{
        
        //given
        NSString *testString = @"testString";
        
        //when
        BOOL endWithLetter = [testString endsWithCharacter:'z'];
        
        //then
        expect(endWithLetter).to.beFalsy();
    });
    
    it(@"ends with character empty string case", ^{
        
        //given
        NSString *testString = @"";
        
        //when
        BOOL endWithLetter = [testString endsWithCharacter:'g'];
        
        //then
        expect(endWithLetter).to.beFalsy();
    });
    
    it(@"ends with special character case", ^{
        
        //given
        NSString *testString = @"testStri~";
        
        //when
        BOOL endWithLetter = [testString endsWithCharacter:'~'];
        
        //then
        expect(endWithLetter).to.beTruthy();
    });
    
    afterEach(^{
        
    });
    
    afterAll(^{
        
    });
});

SpecEnd;
