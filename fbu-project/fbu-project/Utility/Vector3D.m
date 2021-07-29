//
//  Vector3D.m
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/28/21.
//

#import "Vector3D.h"

#define RADIANS_TO_DEGREES(radians) ((radians) * (180.0 / M_PI))
#define DEGREES_TO_RADIANS(degrees) ((degrees) * (M_PI / 180.0))

@implementation Vector3D

- (id)init:(CGFloat)x
         y:(CGFloat)y
         z:(CGFloat)z {
    self = [super init];
    
    if (self) {
        self.x = x;
        self.y = y;
        self.z = z;
    }
    
    return self;
}

+ (Vector3D *)VectorFromCoordinate:(CLLocationCoordinate2D)coordinate {
    CLLocationDegrees lat = DEGREES_TO_RADIANS(coordinate.latitude);
    CLLocationDegrees lon = DEGREES_TO_RADIANS(coordinate.longitude);
    
    CGFloat x = cos(lat) * cos(lon);
    CGFloat y = cos(lat) * sin(lon);
    CGFloat z = sin(lat);
    
    Vector3D *vector = [[Vector3D alloc] init:x y:y z:z];
    return vector;
}

+ (CLLocationCoordinate2D)CoordinateFromVector:(Vector3D *)vector {
    double latitudeRadians = atan2(vector.z, sqrt( pow(vector.x, 2) + pow(vector.y, 2) ));
    double longitudeRadians = atan2(vector.y, vector.x);
    
    CLLocationDegrees latitudeDegrees = RADIANS_TO_DEGREES(latitudeRadians);
    CLLocationDegrees longitudeDegrees = RADIANS_TO_DEGREES(longitudeRadians);
    
    return CLLocationCoordinate2DMake(latitudeDegrees, longitudeDegrees);
}

+ (Vector3D *)MeanVector:(NSArray<Vector3D *> *_Nonnull)vectors {
    if (vectors == nil) {
        return nil;
    }
    
    CGFloat xTotal = 0;
    CGFloat yTotal = 0;
    CGFloat zTotal = 0;
    
    for (Vector3D *vector in vectors) {
        xTotal += vector.x;
        yTotal += vector.y;
        zTotal += vector.z;
    }
    
    return [[Vector3D alloc] init:(xTotal/vectors.count) y:(yTotal/vectors.count) z:(zTotal/vectors.count)];
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        //pointer to same memory address (could be a nil)
        return YES;
    }
    if (object == nil || ![object isKindOfClass:[Vector3D class]]) {
        return NO;
    }
    Vector3D *otherVector = (Vector3D *)object;
    
    return (otherVector.x == self.x &&
            otherVector.y == self.y &&
            otherVector.z == self.z);
}

@end
