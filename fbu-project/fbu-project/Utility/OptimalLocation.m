//
//  OptimalLocation.m
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/27/21.
//

#import "OptimalLocation.h"
#import "FoursquareVenue.h"
#import "APIManager.h"

static NSString * const PARK_QUERY = @"park";
static NSString * const PLAZA_QUERY = @"plaza";

CLLocation *_Nonnull LocationWithCoordinate(CLLocationCoordinate2D coordinate) {
    return [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
}

CLLocationDistance DistanceBetweenAnnotations(MKPointAnnotation *_Nonnull annotation1, MKPointAnnotation *_Nonnull annotation2) {
    if (!annotation1 || !annotation2) {
        return CLLocationDistanceMax;
    }
    if ([annotation1 isEqual:annotation2]) {
        return 0;
    }
    
    CLLocation *location1 = LocationWithCoordinate(annotation1.coordinate);
    CLLocation *location2 = LocationWithCoordinate(annotation2.coordinate);
    
    return [location1 distanceFromLocation:location2];
}

CLLocationDistance AggregateDistance(MKPointAnnotation *_Nonnull targetAnnotation, NSArray<MKPointAnnotation *> *_Nonnull annotations) {
    if (!targetAnnotation || !annotations) {
        return CLLocationDistanceMax;
    }
    
    CLLocationDistance aggregateDistance = 0;
    
    for (MKPointAnnotation *currentAnnotation in annotations) {
        if (![currentAnnotation isKindOfClass:[MKPointAnnotation class]]) {
            return CLLocationDistanceMax;
        }
        
        CLLocationDistance distance = DistanceBetweenAnnotations(currentAnnotation, targetAnnotation);
        aggregateDistance += distance;
    }
    
    return aggregateDistance;
}

MKPointAnnotation *_Nullable ComputeOptimalLocationBruteForce(NSArray<MKPointAnnotation *> *_Nonnull userAnnotations) {
    if (!userAnnotations) {
        return nil;
    }
    
    __block CLLocationDistance minAggregateDistance = CLLocationDistanceMax;
    __block MKPointAnnotation *optimalAnnotation;
    
    [userAnnotations enumerateObjectsUsingBlock:^(MKPointAnnotation *_Nonnull annotation, NSUInteger index, BOOL *_Nonnull stop) {
        CLLocationDistance aggregateDistance = AggregateDistance(annotation, userAnnotations);
        if (aggregateDistance < minAggregateDistance) {
            minAggregateDistance = aggregateDistance;
            optimalAnnotation = annotation;
        }
    }];
    return optimalAnnotation;
}

CLLocation * CentroidOfPointsOnSphere(NSArray<CLLocation *> *_Nonnull locations) {
    if (!locations) {
        return nil;
    }
    
    //transform each coordinate into a 3D vecotor (get the xyz) (can be on a unit sphere)
    NSMutableArray<Vector3D *> *vectors = [[NSMutableArray alloc] initWithCapacity:locations.count];
    for (CLLocation *location in locations) {
        Vector3D *vector = [Vector3D VectorFromCoordinate:location.coordinate];
        [vectors addObject:vector];
    }
    
    //calculate the mean vector
    Vector3D *meanVector = [Vector3D MeanVector:vectors];
    
    //return the lat long of the enpoint of the average vector
    CLLocationCoordinate2D centroidCoordinate = [Vector3D CoordinateFromVector:meanVector];
    CLLocation *centroidLocation = [[CLLocation alloc] initWithLatitude:centroidCoordinate.latitude
                                                              longitude:centroidCoordinate.longitude];
    
    return centroidLocation;
}

MKPointAnnotation * AnnotationClosestToLocation(NSArray<MKPointAnnotation *> *_Nonnull annotations, CLLocation *_Nonnull location) {
    if (!annotations || !location || annotations.count == 0) {
        return nil;
    }
    
    MKPointAnnotation *closestAnnotation;
    CLLocationDistance smallestDistance = CLLocationDistanceMax;
    
    for (MKPointAnnotation *annotation in annotations) {
        CLLocation *currentLocation = [[CLLocation alloc] initWithLatitude:annotation.coordinate.latitude
                                                                 longitude:annotation.coordinate.longitude];
        CLLocationDistance currentDistance = [currentLocation distanceFromLocation:location];
        if (currentDistance < smallestDistance) {
            smallestDistance = currentDistance;
            closestAnnotation = annotation;
        }
    }
    
    return closestAnnotation;
}

VenueAnnotation * AnnotationWithVenue(FoursquareVenue *_Nonnull venue) {
    if (!venue) {
        return nil;
    }
    
    VenueAnnotation *venueAnnotation = [VenueAnnotation new];
    venueAnnotation.coordinate = CLLocationCoordinate2DMake(venue.latitude, venue.longitude);
    venueAnnotation.title = venue.name;
    venueAnnotation.venue = venue;
    
    return venueAnnotation;
}

void ComputeOptimalLocationUsingAveregeLocation(NSArray<MKPointAnnotation *> *_Nonnull userAnnotations,
                                                OptimalLocationReturnBlock _Nonnull completion) {
    if (!completion) {
        return;
    }
    
    if (!userAnnotations ) {
        completion(nil, nil, nil);
    }
    
    NSMutableArray<CLLocation *> *locations = [[NSMutableArray alloc] initWithCapacity:userAnnotations.count];
    for (MKPointAnnotation *annotation in userAnnotations) {
        CLLocation *location = [[CLLocation alloc] initWithLatitude:annotation.coordinate.latitude
                                                          longitude:annotation.coordinate.longitude];
        
        [locations addObject:location];
    }
    
    //calculate average location
    CLLocation *averageLocation = CentroidOfPointsOnSphere(locations);
    MKPointAnnotation *optimalUserAnnotation = AnnotationClosestToLocation(userAnnotations, averageLocation);
    
    //fetch venues near average location
    [APIManager VenuesNear:averageLocation.coordinate query:PARK_QUERY completion:^(NSArray<FoursquareVenue *> *_Nullable venues){
        if (!venues) {
            completion(optimalUserAnnotation, nil, nil);
        }
        
        NSMutableArray *venueAnnotations = [[NSMutableArray alloc] initWithCapacity:venues.count];
        for (FoursquareVenue *venue in venues) {
            [venueAnnotations addObject:AnnotationWithVenue(venue)];
        }
        
        VenueAnnotation *optimalVenueAnnotation = AnnotationClosestToLocation(venueAnnotations, averageLocation);
        
        if (!optimalVenueAnnotation) {
            completion(optimalUserAnnotation, nil, venueAnnotations);
        }
        
        completion(optimalUserAnnotation, optimalVenueAnnotation, venueAnnotations);
    }];
}

MKPointAnnotation *_Nullable ComputeOptimalLocationUsingAveregeLocationIsolatedForTesting(NSArray<MKPointAnnotation *> *_Nonnull userAnnotations) {
    if (!userAnnotations) {
        return nil;
    }
    
    NSMutableArray<CLLocation *> *locations = [[NSMutableArray alloc] initWithCapacity:userAnnotations.count];
    for (MKPointAnnotation *annotation in userAnnotations) {
        CLLocation *location = [[CLLocation alloc] initWithLatitude:annotation.coordinate.latitude
                                                          longitude:annotation.coordinate.longitude];
        
        [locations addObject:location];
    }
    
    //calculate average location
    CLLocation *averageLocation = CentroidOfPointsOnSphere(locations);
    
    //return the point that is closest to the average
    return AnnotationClosestToLocation(userAnnotations, averageLocation);
}
