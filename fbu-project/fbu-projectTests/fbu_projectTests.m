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
#import "UserSorter.h"
#import "LikedInstrument.h"
#import "AudioAnalyzer.h"

@interface fbu_projectTests : XCTestCase

@end

@implementation fbu_projectTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testInstrumentDisplayName {
    NSString *pianoDisplayName = [LikedInstrument getDisplayNameForInstrument:PIANO_IDENTIFIER];
    XCTAssert([pianoDisplayName isEqualToString:PIANO_DISPLAY_NAME]);
    
    NSString *celloDisplayName = [LikedInstrument getDisplayNameForInstrument:CELLO_IDENTIFIER];
    XCTAssert([celloDisplayName isEqualToString:CELLO_DISPLAY_NAME]);
    
    NSString *clarinetDisplayName = [LikedInstrument getDisplayNameForInstrument:CLARINET_IDENTIFIER];
    XCTAssert([clarinetDisplayName isEqualToString:CLARINET_DISPLAY_NAME]);
    
    NSString *fluteDisplayName = [LikedInstrument getDisplayNameForInstrument:FLUTE_IDENTIFIER];
    XCTAssert([fluteDisplayName isEqualToString:FLUTE_DISPLAY_NAME]);
    
    NSString *electricGuitarDisplayName = [LikedInstrument getDisplayNameForInstrument:ELECTRIC_GUITAR_IDENTIFIER];
    XCTAssert([electricGuitarDisplayName isEqualToString:ELECTRIC_GUITAR_DISPLAY_NAME]);
    
    NSString *organDisplayName = [LikedInstrument getDisplayNameForInstrument:ORGAN_IDENTIFIER];
    XCTAssert([organDisplayName isEqualToString:ORGRAN_DISPLAY_NAME]);
    
    NSString *acousticGuitarDisplayName = [LikedInstrument getDisplayNameForInstrument:ACOUSTIC_GUITAR_IDENTIFIER];
    XCTAssert([acousticGuitarDisplayName isEqualToString:ACOUSTIC_GUITAR_DISPLAY_NAME]);
    
    NSString *saxophoneDisplayName = [LikedInstrument getDisplayNameForInstrument:SAXOPHONE_IDENTIFIER];
    XCTAssert([saxophoneDisplayName isEqualToString:SAXOPHONE_DISPLAY_NAME]);
    
    NSString *trumpetDisplayName = [LikedInstrument getDisplayNameForInstrument:TRUMPET_IDENTIFIER];
    XCTAssert([trumpetDisplayName isEqualToString:TRUMPET_DISPLAY_NAME]);
    
    NSString *violinDisplayName = [LikedInstrument getDisplayNameForInstrument:VIOLIN_IDENTIFIER];
    XCTAssert([violinDisplayName isEqualToString:VIOLIN_DISPLAY_NAME]);
    
    NSString *voiceDisplayName = [LikedInstrument getDisplayNameForInstrument:HUMAN_SINGING_VOICE_IDENTIFIER];
    XCTAssert([voiceDisplayName isEqualToString:HUMAN_SINGING_VOICE_DISPLAY_NAME]);
    
    NSString *nilTest = [LikedInstrument getDisplayNameForInstrument:nil];
    XCTAssert(nilTest == nil);
    
    NSString *emptyTest = [LikedInstrument getDisplayNameForInstrument:@""];
    XCTAssert(emptyTest == nil);
    
    NSString *gibberishTest = [LikedInstrument getDisplayNameForInstrument:@"agjlhfg"];
    XCTAssert(gibberishTest == nil);
}

- (void)testLikedGenre {
    XCTestExpectation *expectation = [self expectationWithDescription:@"LikedGenre expectation"];
    [LikedGenre postLikedGenre:@"test" forUser:[PFUser currentUser] completion:^(LikedGenre *_Nullable newLikedGenre, NSError *_Nullable error){
        XCTAssert(error == nil);
        if (newLikedGenre) {
            [LikedGenre deleteLikedGenre:newLikedGenre completion:^(BOOL succeeded, NSError *_Nullable error){
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
    [Like postLikeFrom:currentUser to:currentUser completion:^(BOOL succeeded, NSError *_Nullable error){
        BOOL flag = (error == nil && succeeded);
        XCTAssert(flag);
        [postLikeExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:nil];
}

- (void)testRemoveLike {
    XCTestExpectation *removeLikeExpectation = [self expectationWithDescription:@"Remove Like expectation"];
    PFUser *currentUser = [PFUser currentUser];
    [Like removeLikeFrom:currentUser to:currentUser completion:^(BOOL succeeded, NSError *_Nullable error){
        BOOL flag = (error == nil && succeeded);
        XCTAssert(flag);
        [removeLikeExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:nil];
}

- (void)testPostUnlike {
    XCTestExpectation *postUnLikeExpectation = [self expectationWithDescription:@"Post Like expectation"];
    PFUser *currentUser = [PFUser currentUser];
    [UnLike postUnLikeFrom:currentUser to:currentUser completion:^(BOOL succeeded, NSError *_Nullable error){
        BOOL flag = (error == nil && succeeded);
        XCTAssert(flag);
        [postUnLikeExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:nil];
}

- (void)testRemoveUnLike {
    XCTestExpectation *removeUnLikeExpectation = [self expectationWithDescription:@"Remove Like expectation"];
    PFUser *currentUser = [PFUser currentUser];
    [UnLike removeUnLikeFrom:currentUser to:currentUser completion:^(BOOL succeeded, NSError * _Nullable error){
        BOOL flag = (error == nil && succeeded);
        XCTAssert(flag);
        [removeUnLikeExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:nil];
}

- (void)testPostMatch {
    XCTestExpectation *postMatchExpectation = [self expectationWithDescription:@"Post Match expectation"];
    PFUser *currentUser = [PFUser currentUser];
    [Match postMatchBetween:currentUser andUser:currentUser completion:^(BOOL succeeded, NSError *_Nullable error){
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

#pragma mark - Testing UserSorter

- (void)testNotLikedUsers {
    XCTestExpectation *expectation = [self expectationWithDescription:@"NotLikedUsers expectation"];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray<PFUser *>*notLikedUsers = NotLikedUsers();
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            if ([PFUser currentUser] == nil) {
                XCTAssert(notLikedUsers == nil);
            } else {
                XCTAssert(notLikedUsers != nil);
            }
            [expectation fulfill];
        });
    });
    
    [self waitForExpectationsWithTimeout:10 handler:nil];
}

- (void)testLocationForUser {
    XCTestExpectation *expectation = [self expectationWithDescription:@"LocationForUser expectation"];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        CLLocation *nilUserLocation = LocationForUser(nil);
        CLLocation *newUserLocation = LocationForUser([PFUser new]);
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            XCTAssert(nilUserLocation == nil);
            XCTAssert(newUserLocation == nil);
            [expectation fulfill];
        });
    });
    
    [self waitForExpectationsWithTimeout:10 handler:nil];
}

- (void)testDistanceBetweenUsers {
    XCTestExpectation *expectation = [self expectationWithDescription:@"LocationForUser expectation"];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        double newUsersDistance = DistanceBetweenUsers([PFUser new], [PFUser new]);
        double nilUsersDistance = DistanceBetweenUsers(nil, nil);
        double zeroDistance = DistanceBetweenUsers([PFUser currentUser], [PFUser currentUser]);
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            XCTAssert(newUsersDistance == CGFLOAT_MAX);
            XCTAssert(nilUsersDistance == CGFLOAT_MAX);
            XCTAssert(zeroDistance == 0.0);
            [expectation fulfill];
        });
    });
    
    [self waitForExpectationsWithTimeout:10 handler:nil];
}

- (void)testPointsForDistance {
    double negativeDistancePoints = PointsForDistance(-1);
    XCTAssert(negativeDistancePoints == 0);
}

- (void)testSetWithGenreTitles {
    NSSet<NSString *> *nilSet = SetWithGenreTitles(nil);
    XCTAssert(nilSet == nil);
    
    NSMutableArray<LikedGenre *> *likedGenresArray = [[NSMutableArray alloc] initWithCapacity:3];
    
    NSSet<NSString *> *emptySet = SetWithGenreTitles(likedGenresArray);
    XCTAssert(emptySet != nil);
    XCTAssert([emptySet count] == 0);
    
    LikedGenre *likedGenre = [LikedGenre new];
    likedGenre.title = @"genre1";
    [likedGenresArray addObject:likedGenre];
    
    likedGenre = [LikedGenre new];
    likedGenre.title = @"genre2";
    [likedGenresArray addObject:likedGenre];
    
    likedGenre = [LikedGenre new];
    likedGenre.title = @"genre3";
    [likedGenresArray addObject:likedGenre];
    
    NSSet<NSString *> *normalSet = SetWithGenreTitles(likedGenresArray);
    for (LikedGenre *likedGenre in likedGenresArray) {
        XCTAssert([normalSet containsObject: likedGenre.title]);
    }
}

- (void)testPointsForCommonGenres {
    NSInteger nilPoints = PointsForCommonGenres(nil, nil);
    XCTAssert(nilPoints == 0);
    
    NSInteger zeroPoints = PointsForCommonGenres([PFUser new], [PFUser new]);
    XCTAssert(zeroPoints == 0);
}

- (void)testPointsForMatchingInstrumentsInRecording {
    NSInteger nilPoints = PointsForMatchingInstrumentsInRecording(nil);
    XCTAssert(nilPoints == 0);
    
    NSInteger zeroPoints = PointsForMatchingInstrumentsInRecording([PFUser new]);
    XCTAssert(zeroPoints == 0);
}


@end
