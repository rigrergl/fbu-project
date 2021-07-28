//
//  OptimalLocation.m
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/27/21.
//

#import "OptimalLocation.h"

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
