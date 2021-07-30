//
//  FoursquareVenue.m
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/29/21.
//

#import "FoursquareVenue.h"
#import "DictionaryConstants.h"

static NSString * VENUE_DICTIONARY_KEY = @"venue";
static NSString * NAME_DICTIONARY_KEY = @"name";
static NSString * ID_DICTIONARY_KEY = @"id";
static NSString * LOCATION_DICTIONARY_KEY = @"location";
static NSString * LATITUDE_DICTIONARY_KEY = @"lat";
static NSString * LONGITUDE_DICTIONARY_KEY = @"lng";

@implementation FoursquareVenue

+ (nonnull NSString *)parseClassName {
    return FOURSUQARE_VENUE_PARSE_CLASS_NAME;
}

- (instancetype)initWithDictionary:(NSDictionary *_Nullable)dictionary {
    self  = [super init];
    
    if (self) {
        NSDictionary *venueDictionary = dictionary[VENUE_DICTIONARY_KEY];
        self.name = venueDictionary[NAME_DICTIONARY_KEY];
        self.venueId = venueDictionary[ID_DICTIONARY_KEY];
        
        NSDictionary *locationDictionary = venueDictionary[LOCATION_DICTIONARY_KEY];
        self.latitude = [locationDictionary[LATITUDE_DICTIONARY_KEY] doubleValue];
        self.longitude = [locationDictionary[LONGITUDE_DICTIONARY_KEY] doubleValue];
    }
    
    return self;
}

+ (NSMutableArray<FoursquareVenue *> *_Nullable)venuesWithArray:(NSArray<NSDictionary *> *_Nullable)dictionaries {
    NSMutableArray<FoursquareVenue *> *venues = [[NSMutableArray alloc] initWithCapacity:dictionaries.count];
    for (NSDictionary *dictionary in dictionaries) {
        FoursquareVenue *venue = [[FoursquareVenue alloc] initWithDictionary:dictionary];
        [venues addObject:venue];
    }
    
    return venues;
}

@end
