//
//  EventLocationPickerViewController.h
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/27/21.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface EventLocationPickerViewController : UIViewController

typedef void(^_Nonnull DidSelectLocationBlock)(CLLocation *_Nonnull location);

- (void)setViewController:(NSArray<PFUser *> *)eventUsers
   didSelectLocationBlock:(DidSelectLocationBlock _Nonnull)didSelectLocationBlock;

@end

NS_ASSUME_NONNULL_END
