//
//  EventLocationPickerViewController.m
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/27/21.
//

#import "EventLocationPickerViewController.h"
#import "UserSorter.h"
#import "OptimalLocation.h"
#import "StylingConstants.h"
#import "DictionaryConstants.h"
#import "CommonFunctions.h"

@interface EventLocationPickerViewController () <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) NSArray<CLLocation *> *_Nonnull locationOptions;
@property (strong, nonatomic) NSArray<PFUser *> *_Nonnull usersInEvent;
@property (strong, nonatomic) NSDictionary<NSString *, UIImage *> *_Nonnull userImagesDictionary;
@property (strong, nonatomic) MKPointAnnotation *_Nullable selectedAnnotation;
@property (copy, nonatomic, nonnull) void (^didSelectLocationBlock)(CLLocation *_Nonnull location);

@end

static NSString * const ANNOTATION_IDENTIFIER = @"Pin";
static NSString * const OPTIMAL_LOCATION_SUBTITLE = @"optimal location";
static CLLocationDegrees REGION_DELTA = 0.2;
static const CGFloat ANNOTATION_ACCESSORY_VIEW_DIMENSION = 50;

@implementation EventLocationPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupMapView];
}

- (void)setupMapView {
    //set populate map annotations
    self.mapView.delegate = self;
    [self putLocationOptionsOnMap];
    
    [self setOptimalAnnotationAsSelected];
}

- (void)setOptimalAnnotationAsSelected {
    NSArray<MKPointAnnotation *> *annotations = (NSArray<MKPointAnnotation *> *)self.mapView.annotations;
    
    MKPointAnnotation *optimalAnnotation = ComputeOptimalLocationUsingAveregeLocation(annotations);
    
    if (optimalAnnotation) {
        [self.mapView setSelectedAnnotations:@[optimalAnnotation]];
        [self centerOnLocation:optimalAnnotation.coordinate];
        optimalAnnotation.subtitle = OPTIMAL_LOCATION_SUBTITLE;
    }
}

- (void)centerOnLocation:(CLLocationCoordinate2D)coordinate {
    MKCoordinateRegion mapRegion;
    mapRegion.center = coordinate;
    mapRegion.span.latitudeDelta = REGION_DELTA;
    mapRegion.span.longitudeDelta = REGION_DELTA;
    
    [self.mapView setRegion:mapRegion animated: YES];
}

- (void)putLocationOptionsOnMap {
    [self.locationOptions enumerateObjectsUsingBlock:^(CLLocation *_Nonnull location, NSUInteger index, BOOL *_Nonnull stop) {
        MKPointAnnotation *annotation = [MKPointAnnotation new];
        annotation.coordinate = location.coordinate;
        annotation.title = self.usersInEvent[index].username;
        [self.mapView addAnnotation:annotation];
    }];
    
    
    [self.mapView becomeFirstResponder];
    [self.mapView reloadInputViews];
}

- (void)setViewController:(NSArray<PFUser *> *)eventUsers
   didSelectLocationBlock:(DidSelectLocationBlock _Nonnull)didSelectLocationBlock {
    self.usersInEvent = eventUsers;
    self.locationOptions = [EventLocationPickerViewController userLocations:eventUsers];
    self.didSelectLocationBlock = didSelectLocationBlock;
    [self generateImagesDictionary];
}

- (void)generateImagesDictionary {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //async thread
        NSMutableArray<NSString *> *usernames = [[NSMutableArray alloc] initWithCapacity:self.usersInEvent.count];
        NSMutableArray<UIImage *> *userImages = [[NSMutableArray alloc] initWithCapacity:self.usersInEvent.count];
        for (PFUser *user in self.usersInEvent) {
            UIImage *userImage = DownloadUserProfileImage(user);
            if (userImage) {
                [usernames addObject:user.username];
                [userImages addObject:userImage];
            }
        }
        
        self.userImagesDictionary = [[NSDictionary alloc] initWithObjects:userImages forKeys:usernames];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            // This will be called on the main thread, so that UI  can be updated
            [self.mapView reloadInputViews];
        });
    });
}

+ (NSArray<CLLocation *> *)userLocations:(NSArray<PFUser *> *_Nonnull)users {
    NSMutableArray<CLLocation *> *locations = [[NSMutableArray alloc] initWithCapacity:users.count];
    for (PFUser *user in users) {
        CLLocation *location = LocationForUser(user);
        [locations addObject:location];
    }
    
    return locations;
}

#pragma mark - MKMapView delegate methods

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    MKPinAnnotationView *annotationView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:ANNOTATION_IDENTIFIER];
    if (annotationView == nil) {
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:ANNOTATION_IDENTIFIER];
        annotationView.canShowCallout = true;
        annotationView.leftCalloutAccessoryView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, ANNOTATION_ACCESSORY_VIEW_DIMENSION, ANNOTATION_ACCESSORY_VIEW_DIMENSION)];
    } else {
        annotationView.annotation = annotation;
    }
    
    UIImageView *imageView = (UIImageView*)annotationView.leftCalloutAccessoryView;
    UIImage *userProfileImage = [self.userImagesDictionary objectForKey:annotation.title];
    if (userProfileImage) {
        imageView.image = userProfileImage;
    } else {
        imageView.image = [UIImage imageNamed:DEFAULT_PROFILE_IMAGE_NAME];
    }
    
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    self.selectedAnnotation = (MKPointAnnotation *)view.annotation;
}

#pragma mark - Button actions

- (IBAction)didTapCancel:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)didTapSave:(UIButton *)sender {
    if (self.didSelectLocationBlock) {
        CLLocationCoordinate2D coordinate =  self.selectedAnnotation.coordinate;
        CLLocationDegrees latitude = coordinate.latitude;
        CLLocationDegrees longitude = coordinate.longitude;
        
        CLLocation *location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
        self.didSelectLocationBlock(location);
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
