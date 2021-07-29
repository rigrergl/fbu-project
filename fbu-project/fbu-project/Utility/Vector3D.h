//
//  Vector3D.h
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/28/21.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Vector3D : NSObject

@property (assign, nonatomic) CGFloat x;
@property (assign, nonatomic) CGFloat y;
@property (assign, nonatomic) CGFloat z;

- (id)init:(CGFloat)x
         y:(CGFloat)y
         z:(CGFloat)z;
- (BOOL)isEqual:(Vector3D *_Nullable)object;
+ (Vector3D *)MeanVector:(NSArray<Vector3D *> *_Nonnull)vectors;
+ (Vector3D *)VectorFromCoordinate:(CLLocationCoordinate2D)coordinate;
+ (CLLocationCoordinate2D)CoordinateFromVector:(Vector3D *)vector;

@end

NS_ASSUME_NONNULL_END
