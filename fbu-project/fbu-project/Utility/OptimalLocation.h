//
//  OptimalLocation.h
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/27/21.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "Vector3D.h"
#import "VenueAnnotation.h"

typedef void(^OptimalLocationReturnBlock)(MKPointAnnotation *_Nullable optimalUserAnnotation,
                                          VenueAnnotation *_Nullable optimalVenueAnnotation,
                                          NSArray<VenueAnnotation *> *_Nullable venueAnnotations);

extern void ComputeOptimalLocationUsingAveregeLocation(NSArray<MKPointAnnotation *> *_Nonnull userAnnotations, OptimalLocationReturnBlock _Nonnull completion);
extern MKPointAnnotation *_Nullable ComputeOptimalLocationUsingAveregeLocationIsolatedForTesting(NSArray<MKPointAnnotation *> *_Nonnull userAnnotations);
extern MKPointAnnotation *_Nullable ComputeOptimalLocationBruteForce(NSArray<MKPointAnnotation *> *_Nonnull userAnnotations);
extern CLLocationDistance AggregateDistance(MKPointAnnotation *_Nonnull targetAnnotation, NSArray<MKPointAnnotation *> *_Nonnull annotations);
extern CLLocationDistance DistanceBetweenAnnotations(MKPointAnnotation *_Nonnull annotation1, MKPointAnnotation *_Nonnull annotation2);
extern CLLocation *_Nonnull LocationWithCoordinate(CLLocationCoordinate2D coordinate);
