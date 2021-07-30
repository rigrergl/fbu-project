//
//  APIManager.h
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/16/21.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "FoursquareVenue.h"

NS_ASSUME_NONNULL_BEGIN

@interface APIManager : NSObject

+ (void)fetchGenres:(PFArrayResultBlock _Nullable)completion;
+ (void)VenuesNear:(CLLocationCoordinate2D)coordinate
             query:(NSString *_Nullable)query
        completion:(void (^_Nonnull)(NSArray<FoursquareVenue *> *_Nullable))completion;
+ (NSString *)stringFromCoordinate:(CLLocationCoordinate2D)coordinate;

@end

NS_ASSUME_NONNULL_END
