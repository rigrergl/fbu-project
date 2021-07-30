//
//  VenueAnnotation.h
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/30/21.
//

#import <MapKit/MapKit.h>
#import "FoursquareVenue.h"

NS_ASSUME_NONNULL_BEGIN

@interface VenueAnnotation : MKPointAnnotation

@property (nonatomic, strong) FoursquareVenue *_Nullable venue;

@end

NS_ASSUME_NONNULL_END
