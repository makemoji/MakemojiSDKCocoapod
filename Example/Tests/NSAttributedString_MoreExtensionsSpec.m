//
//  NSAttributedString_MoreExtensionsSpec.m
//  Makemoji-SDK
//
//  Created by David Muñoz - Simplex Software on 14/6/17.
//  Copyright © 2017 Makemoji. All rights reserved.
//
#import "NSAttributedString_MoreExtensions.h"
#import "Specta.h"
#import "Expecta.h"
#import "OCMock.h"

SpecBegin(NSAttributedString_MoreExtensions)

describe(@"NSAttributedString_MoreExtensions", ^{
    
    beforeAll(^{
        
    });
    
    beforeEach(^{
        
    });
    
    it(@"all attachments", ^{
        //given
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@"test test"];
        
        NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
        textAttachment.image = [UIImage imageNamed:@"test.png"];
        
        NSAttributedString *attrStringWithImage = [NSAttributedString attributedStringWithAttachment:textAttachment];
        
        [attributedString replaceCharactersInRange:NSMakeRange(4, 1) withAttributedString:attrStringWithImage];
        
        //when
        NSArray *array = [attributedString allAttachments];
        
        //then
        expect([array count]).to.equal(1);
        
    });
    
    afterEach(^{
        
    });
    
    afterAll(^{
        
    });
});

SpecEnd
