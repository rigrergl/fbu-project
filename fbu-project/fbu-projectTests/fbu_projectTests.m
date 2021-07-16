//
//  fbu_projectTests.m
//  fbu-projectTests
//
//  Created by Rigre Reinier Garciandia Larquin on 7/12/21.
//

#import <XCTest/XCTest.h>
#import "CommonQueries.h"
#import "Like.h"
#import "UnLike.h"
#import "Match.h"
#import "APIManager.h"

@interface fbu_projectTests : XCTestCase

@end

@implementation fbu_projectTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testFormatArtistName {
    NSString *testString = @" joHn   MayeR ";
    NSString *resultString = [APIManager formatArtistName:testString];
    NSString *expectedString = @"john_mayer";
    XCTAssert([resultString isEqualToString:expectedString]);
    
    testString = @"THe Beatles ";
    resultString = [APIManager formatArtistName:testString];
    expectedString = @"the_beatles";
    XCTAssert([resultString isEqualToString:expectedString]);
    
    testString = @"ColdPlay";
    resultString = [APIManager formatArtistName:testString];
    expectedString = @"coldplay";
    XCTAssert([resultString isEqualToString:expectedString]);

}

- (void)testMatchingUsers {
    XCTestExpectation *expectation = [self expectationWithDescription:@"MatchingUsers expectation"];
    
    MatchingUsers(^(NSArray *_Nullable matchedUsers,NSArray *_Nullable matches, NSError *_Nullable error){
        BOOL flag = (error == nil && matches && matches.count >= 0);
        XCTAssert(flag);

        [expectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:10 handler:nil];
}

- (void)testPostLike {
    XCTestExpectation *postLikeExpectation = [self expectationWithDescription:@"Post Like expectation"];
    PFUser *currentUser = [PFUser currentUser];
    [Like postLikeFrom:currentUser to:currentUser withCompletion:^(BOOL succeeded, NSError *_Nullable error){
        BOOL flag = (error == nil && succeeded);
        XCTAssert(flag);
        [postLikeExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:nil];
}

- (void)testRemoveLike {
    XCTestExpectation *removeLikeExpectation = [self expectationWithDescription:@"Remove Like expectation"];
    PFUser *currentUser = [PFUser currentUser];
    [Like removeLikeFrom:currentUser to:currentUser withCompletion:^(BOOL succeeded, NSError *_Nullable error){
        BOOL flag = (error == nil && succeeded);
        XCTAssert(flag);
        [removeLikeExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:nil];
}

- (void)testPostUnlike {
    XCTestExpectation *postUnLikeExpectation = [self expectationWithDescription:@"Post Like expectation"];
    PFUser *currentUser = [PFUser currentUser];
    [UnLike postUnLikeFrom:currentUser to:currentUser withCompletion:^(BOOL succeeded, NSError *_Nullable error){
        BOOL flag = (error == nil && succeeded);
        XCTAssert(flag);
        [postUnLikeExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:nil];
}

- (void)testRemoveUnLike {
    XCTestExpectation *removeUnLikeExpectation = [self expectationWithDescription:@"Remove Like expectation"];
    PFUser *currentUser = [PFUser currentUser];
    [UnLike removeUnLikeFrom:currentUser to:currentUser withCompletion:^(BOOL succeeded, NSError * _Nullable error){
        BOOL flag = (error == nil && succeeded);
        XCTAssert(flag);
        [removeUnLikeExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:nil];
}

- (void)testPostMatch {
    XCTestExpectation *postMatchExpectation = [self expectationWithDescription:@"Post Match expectation"];
    PFUser *currentUser = [PFUser currentUser];
    [Match postMatchBetween:currentUser andUser:currentUser withCompletion:^(BOOL succeeded, NSError *_Nullable error){
        BOOL flag = (error == nil && succeeded);
        XCTAssert(flag);
        [postMatchExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:nil];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
