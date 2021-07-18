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
#import "APIManager+Tests.h"
#import "LikedGenre.h"

@interface fbu_projectTests : XCTestCase

@end

@implementation fbu_projectTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testLikedGenre {
    XCTestExpectation *expectation = [self expectationWithDescription:@"LikedGenre expectation"];
    [LikedGenre postLikedGenre:@"test" forUser:[PFUser currentUser] withCompletion:^(LikedGenre *_Nullable newLikedGenre, NSError *_Nullable error){
        XCTAssert(error == nil);
        if (newLikedGenre) {
            [LikedGenre deleteLikedGenre:newLikedGenre withCompletion:^(BOOL succeeded, NSError *_Nullable error){
                XCTAssert(succeeded);
                XCTAssert(error == nil);
                [expectation fulfill];
            }];
        }
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:nil];
}

- (void)testBase64URLSafeEncode {
    NSString *originalString = @"jlvdjklnvz939484587jfvjsbfjn:rsgfdl958583dfljdbjn";
    NSString *expectedEncoding = @"amx2ZGprbG52ejkzOTQ4NDU4N2pmdmpzYmZqbjpyc2dmZGw5NTg1ODNkZmxqZGJqbg";
    
    NSString *result = [APIManager base64URLSafeEncode:originalString];
    BOOL flag = [result isEqualToString:expectedEncoding];
    XCTAssert(flag);
}

- (void)testGenerateSpotifyToken {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Fetch Spotify Token expectation"];
    
    [APIManager generateSpotifyToken:^(NSString *_Nullable spotifyToken, NSError *_Nullable error){
        XCTAssert(error == nil);
        XCTAssert(spotifyToken != nil);
        XCTAssert([spotifyToken isKindOfClass:[NSString class]]);

        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:nil];
}

- (void)testFetchGenres {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Fetch Genres expectation"];
    
    [APIManager fetchGenres:^(NSArray *_Nullable genres, NSError *_Nullable error){
        XCTAssert(error == nil);
        XCTAssert(genres != nil);
        //confirm entries are indeed genre strings
        for (NSString *genre in genres) {
            XCTAssert(genre != nil);
            XCTAssert([genre isKindOfClass: [NSString class]]);
        }
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:nil];
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
