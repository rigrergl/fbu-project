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
#import "OptimalLocation.h"
#import "Vector3D.h"
#import "FoursquareVenue.h"

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

- (void)testPostAndRemoveLike {
    XCTestExpectation *postAndRemoveExpectation = [self expectationWithDescription:@"Post Like expectation"];
    PFUser *currentUser = [PFUser currentUser];
    
    [Like removeLikeFrom:currentUser to:currentUser completion:^(BOOL succeeded, NSError *_Nullable error){
        BOOL flag = (error == nil && succeeded);
        XCTAssert(flag);
        
        [Like postLikeFrom:currentUser to:currentUser completion:^(BOOL succeeded, NSError *_Nullable error){
            BOOL flag = (error == nil && succeeded);
            XCTAssert(flag);
            [postAndRemoveExpectation fulfill];
        }];
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
        CLLocationDistance newUsersDistance = DistanceBetweenUsers([PFUser new], [PFUser new]);
        CLLocationDistance nilUsersDistance = DistanceBetweenUsers(nil, nil);
        CLLocationDistance zeroDistance = DistanceBetweenUsers([PFUser currentUser], [PFUser currentUser]);
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            XCTAssert(newUsersDistance == CLLocationDistanceMax);
            XCTAssert(nilUsersDistance == CLLocationDistanceMax);
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

#pragma mark - Testing OptimalLocation

- (void)testComputeOptimalLocationUsingAveregeLocation {
    //nil input == nil output
    MKPointAnnotation *nilInputResult = ComputeOptimalLocationUsingAveregeLocationIsolatedForTesting(nil);
    XCTAssert(nilInputResult == nil);
    
    //array of 1 annotation should return that annotation
    MKPointAnnotation *singleAnnotation = [MKPointAnnotation new];
    NSArray<MKPointAnnotation *> *oneAnnotationArray = @[singleAnnotation];
    MKPointAnnotation *oneAnnotationArrayResult = ComputeOptimalLocationUsingAveregeLocationIsolatedForTesting(oneAnnotationArray);
    XCTAssert([oneAnnotationArrayResult isEqual:singleAnnotation]);
    
    //5 coordinates in the US with one clearly in the middle, make sure that one is returned
    CLLocation *centerLocation = [[CLLocation alloc] initWithLatitude:33.162941 longitude:-96.673237];
    CLLocation *westLocation = [[CLLocation alloc] initWithLatitude:33.162941 longitude:-96.685941];
    CLLocation *northLocation = [[CLLocation alloc] initWithLatitude:33.175620 longitude:-96.672260];
    CLLocation *southLocation = [[CLLocation alloc] initWithLatitude:33.155169 longitude:-96.673074];
    CLLocation *eastLocation = [[CLLocation alloc] initWithLatitude:33.163487 longitude:-96.655484];
    
    NSArray<CLLocation *> *locations = @[centerLocation, westLocation, northLocation, southLocation, eastLocation];
    NSMutableArray<MKPointAnnotation *> *annotations = [[NSMutableArray alloc] initWithCapacity:locations.count];
    for (CLLocation *location in locations) {
        MKPointAnnotation *annotation = [MKPointAnnotation new];
        annotation.coordinate = location.coordinate;
        [annotations addObject:annotation];
    }
    
    __block MKPointAnnotation *optimalAnnotation;
    [self measureBlock:^{
        optimalAnnotation = ComputeOptimalLocationUsingAveregeLocationIsolatedForTesting(annotations);
    }];
    XCTAssert(optimalAnnotation.coordinate.latitude == centerLocation.coordinate.latitude);
    XCTAssert(optimalAnnotation.coordinate.longitude == centerLocation.coordinate.longitude);
}

- (void)testComputeOptimalLocationBruteForce {
    //nil input == nil output
    MKPointAnnotation *nilInputResult = ComputeOptimalLocationBruteForce(nil);
    XCTAssert(nilInputResult == nil);
    
    //array of 1 annotation should return that annotation
    MKPointAnnotation *singleAnnotation = [MKPointAnnotation new];
    NSArray<MKPointAnnotation *> *oneAnnotationArray = @[singleAnnotation];
    MKPointAnnotation *oneAnnotationArrayResult = ComputeOptimalLocationBruteForce(oneAnnotationArray);
    XCTAssert([oneAnnotationArrayResult isEqual:singleAnnotation]);
    
    //5 coordinates in the US with one clearly in the middle, make sure that one is returned
    CLLocation *centerLocation = [[CLLocation alloc] initWithLatitude:33.162941 longitude:-96.673237];
    CLLocation *westLocation = [[CLLocation alloc] initWithLatitude:33.162941 longitude:-96.685941];
    CLLocation *northLocation = [[CLLocation alloc] initWithLatitude:33.175620 longitude:-96.672260];
    CLLocation *southLocation = [[CLLocation alloc] initWithLatitude:33.155169 longitude:-96.673074];
    CLLocation *eastLocation = [[CLLocation alloc] initWithLatitude:33.163487 longitude:-96.655484];
    
    NSArray<CLLocation *> *locations = @[centerLocation, westLocation, northLocation, southLocation, eastLocation];
    NSMutableArray<MKPointAnnotation *> *annotations = [[NSMutableArray alloc] initWithCapacity:locations.count];
    for (CLLocation *location in locations) {
        MKPointAnnotation *annotation = [MKPointAnnotation new];
        annotation.coordinate = location.coordinate;
        [annotations addObject:annotation];
    }
    
    __block MKPointAnnotation *optimalAnnotation;
    [self measureBlock:^{
        optimalAnnotation = ComputeOptimalLocationBruteForce(annotations);
    }];
    XCTAssert(optimalAnnotation.coordinate.latitude == centerLocation.coordinate.latitude);
    XCTAssert(optimalAnnotation.coordinate.longitude == centerLocation.coordinate.longitude);
}

- (void)testAggregateDistance {
    //nil input --> CLLocationDistanceMax output
    CLLocationDistance testNil = AggregateDistance(nil, nil);
    XCTAssert(testNil == CLLocationDistanceMax);
    
    //test with array of some other input type
    NSArray<NSString *> *nonAnnotationArray = @[@"hello", @"world"];
    MKPointAnnotation *dummyAnnotation = [MKPointAnnotation new];
    CLLocationDistance testTypeSafety = AggregateDistance(dummyAnnotation, nonAnnotationArray);
    XCTAssert(testTypeSafety == CLLocationDistanceMax);
}

- (void)testDistanceBetweenAnnotations {
    //test nil inputs --> nil output
    CLLocationDistance nilInputResult = DistanceBetweenAnnotations(nil, nil);
    XCTAssert(nilInputResult == CLLocationDistanceMax);
    
    //make CLLocation objects, get distance using CLLocation method, create annotations from CLLocations and plug into DistanceBetweenAnnotations, make sure that both results are equal
    CLLocation *originalLocation1 = [[CLLocation alloc] initWithLatitude:45 longitude:-48];
    CLLocation *originalLocation2 = [[CLLocation alloc] initWithLatitude:-34 longitude:58];
    CLLocationDistance expectedDistance =  [originalLocation1 distanceFromLocation:originalLocation2];
    
    MKPointAnnotation *annotation1 = [MKPointAnnotation new];
    annotation1.coordinate = originalLocation1.coordinate;
    MKPointAnnotation *annotation2 = [MKPointAnnotation new];
    annotation2.coordinate = originalLocation2.coordinate;
    CLLocationDistance resultDistance = DistanceBetweenAnnotations(annotation1, annotation2);
    
    XCTAssert(resultDistance == expectedDistance);
}

- (void)testLocationWithCoordinate {
    //create a CLLocation, plug the location's coordinates into LocationWithCoordiates, make sure output location coordinates are the same as original location coordinates
    
    CLLocationCoordinate2D originalCoordinate = CLLocationCoordinate2DMake(67, -9);
    CLLocation *originalLocation = [[CLLocation alloc] initWithLatitude:originalCoordinate.latitude longitude:originalCoordinate.longitude];
    
    CLLocation *resultLocation = LocationWithCoordinate(originalCoordinate);
    XCTAssert(resultLocation.coordinate.latitude == originalLocation.coordinate.latitude);
    XCTAssert(resultLocation.coordinate.longitude == originalLocation.coordinate.longitude);
}

#pragma mark - Testing Vector3D

- (void)testMeanVector {
    NSMutableArray<Vector3D *> *test = nil;
    XCTAssert([Vector3D MeanVector:test] == nil);
    
    test = [[NSMutableArray alloc] init];
    [test addObject:[[Vector3D alloc] init:0 y:0 z:0]];
    [test addObject:[[Vector3D alloc] init:0 y:0 z:0]];
    [test addObject:[[Vector3D alloc] init:0 y:0 z:0]];
    
    Vector3D *result = [Vector3D MeanVector:test];
    XCTAssert([result isEqual:test[0]]);
}

- (void)testVectorFromCoordinate {
    //test back and forth conversion
    CLLocationCoordinate2D testCoordinate = CLLocationCoordinate2DMake(34, 98);
    Vector3D *resultVector = [Vector3D VectorFromCoordinate:testCoordinate];
    CLLocationCoordinate2D resultCoordinate = [Vector3D CoordinateFromVector:resultVector];
    
    XCTAssert(testCoordinate.latitude == resultCoordinate.latitude);
    XCTAssert(testCoordinate.longitude == resultCoordinate.longitude);
}

- (void)testCoordinateFromVector {
    Vector3D *testVector = [[Vector3D alloc] init:.73 y:.55 z:.23];
    CLLocationCoordinate2D resultCoordinate = [Vector3D CoordinateFromVector:testVector];
    Vector3D *resultVector = [Vector3D VectorFromCoordinate:resultCoordinate];
    
    CGFloat vectorAccuracy = 0.05;
    XCTAssertEqualWithAccuracy(resultVector.x, testVector.x, vectorAccuracy);
    XCTAssertEqualWithAccuracy(resultVector.y, testVector.y, vectorAccuracy);
    XCTAssertEqualWithAccuracy(resultVector.z, testVector.z, vectorAccuracy);
}

- (void)testVector3DEqual {
    Vector3D *test1 = [[Vector3D alloc] init:5 y:-9 z:7.9];
    Vector3D *test2 = [[Vector3D alloc] init:5 y:-9 z:7.9];
    Vector3D *test3 = [[Vector3D alloc] init:5 y:-9 z:7.8];
    
    XCTAssert([test1 isEqual:test2]);
    XCTAssert([test1 isEqual:test1]);
    XCTAssert(![test1 isEqual:nil]);
    XCTAssert(![test1 isEqual:test3]);
}

#pragma mark - Testing Foursquare api

- (void)testStringFromCoordinate {
    CLLocationCoordinate2D testCoordinate = CLLocationCoordinate2DMake(1.283644, 103.860753);
    NSString *exptectedString = @"1.283644,103.860753";
    NSString *actualString = [APIManager stringFromCoordinate:testCoordinate];
    XCTAssert([exptectedString isEqualToString:actualString]);
    
    CLLocationCoordinate2D negativeCoordinate = CLLocationCoordinate2DMake(-1.283644, -103.860753);
    exptectedString = @"-1.283644,-103.860753";
    actualString = [APIManager stringFromCoordinate:negativeCoordinate];
    XCTAssert([exptectedString isEqualToString:actualString]);
}

- (void)testFoursquareAPI {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Fetch venues expectation"];
    CLLocationCoordinate2D singaporeCoordinate = CLLocationCoordinate2DMake(1.283644, 103.860753);
    
    [APIManager VenuesNear:singaporeCoordinate query:@"park" completion:^(NSArray<FoursquareVenue *> *_Nullable venues){
        XCTAssert(venues);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:nil];
}

@end
