//
//  FoursquareVenue.h
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/29/21.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface FoursquareVenue : PFObject<PFSubclassing>

@property (nonatomic, copy) NSString *_Nullable name;
@property (nonatomic, copy) NSString *_Nullable venueId;
@property (nonatomic, assign) CLLocationDegrees latitude;
@property (nonatomic, assign) CLLocationDegrees longitude;
@property (nonatomic, strong) NSString *_Nonnull eventId;

- (instancetype)initWithDictionary:(NSDictionary *_Nullable)dictionary;
+ (NSMutableArray<FoursquareVenue *> *_Nullable)venuesWithArray:(NSArray<NSDictionary *> *_Nullable)dictionaries;

@end

NS_ASSUME_NONNULL_END
