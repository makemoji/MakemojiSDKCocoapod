//
//  NSString+MEUtilitiesTests.m
//  Pods
//
//  Created by David on 24/5/17.
//
//

#import <XCTest/XCTest.h>
#import "NSString+MEUtilities.h"

@interface NSString_MEUtilitiesTests : XCTestCase

@end

@implementation NSString_MEUtilitiesTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testSha1 {

    //given
    NSString *testString = @"testString";
    
    //when
    NSString *resultString = [testString sha1];
    
    //then
    XCTAssertEqualObjects(@"956265657d0b637ef65b9b59f9f858eecf55ed6a", resultString);
    
}

- (void)testSha1SpecialCharacter {
    
    //given
    NSString *testString = @"testString#¢#¢éLÑlcñx!!2ñdai!DSAáêü";
    
    //when
    NSString *resultString = [testString sha1];
    
    //then
    XCTAssertEqualObjects(@"e399b5308b370ee0d709d36621a18b94fae3e6cb", resultString);
    
}

-(void)testEndsWithCharacterPositiveCase{
    
    //Given
    NSString *testString = @"testString";
    
    //when
    
    BOOL endWithLetter = [testString endsWithCharacter:'g'];
    
    //then
    XCTAssertTrue(endWithLetter);
    
    
}

-(void)testEndsWithCharacterNegativeCase{
    
    //Given
    NSString *testString = @"testString";
    
    //when
    
    BOOL endWithLetter = [testString endsWithCharacter:'z'];
    
    //then
    XCTAssertFalse(endWithLetter);
    
}

-(void)testEndsWithCharacterEmptyString{
    
    //Given
    NSString *testString = @"";
    
    //when
    
    BOOL endWithLetter = [testString endsWithCharacter:'z'];
    
    //then
    XCTAssertFalse(endWithLetter);
    
}

-(void)testEndsWithSpecialCharacter{
    
    //Given
    NSString *testString = @"testStri~";
    
    //when
    
    BOOL endWithLetter = [testString endsWithCharacter:'~'];
    
    //then
    XCTAssertTrue(endWithLetter);
    
}

@end
