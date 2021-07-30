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
#import "APIManager.h"
#import "VenueAnnotation.h"
#import "FoursquareVenue.h"
#import "StylingConstants.h"

@interface EventLocationPickerViewController () <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) NSArray<CLLocation *> *_Nonnull locationOptions;
@property (strong, nonatomic) NSArray<PFUser *> *_Nonnull usersInEvent;
@property (strong, nonatomic) NSDictionary<NSString *, UIImage *> *_Nonnull userImagesDictionary;
@property (strong, nonatomic) MKPointAnnotation *_Nullable selectedAnnotation;
@property (strong, nonatomic) MKPointAnnotation *_Nullable optimalUserAnnotation;
@property (strong, nonatomic) VenueAnnotation *_Nullable optimalVenueAnnotation;
@property (strong, nonatomic) MKMapItem *_Nullable selectedMapItem;
@property (strong, nonatomic) FoursquareVenue *_Nullable selectedVenue;
@property (copy, nonatomic, nonnull) void (^didSelectLocationBlock)(FoursquareVenue *_Nullable selectedVenue);

@end

static NSString * const PIN_ANNOTATION_IDENTIFIER = @"Pin";
static NSString * const OPTIMAL_USER_ANNOTATION_SUBTITLE = @"optimal user location";
static NSString * const OPTIMAL_VENUE_ANNOTATION_SUBTITLE = @"optimal venue location";
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
    [self putUserLocationOptionsOnMap];
    
    [self setOptimalAnnotationAsSelected];
}

- (void)setOptimalAnnotationAsSelected {
    NSArray<MKPointAnnotation *> *userAnnotations = (NSArray<MKPointAnnotation *> *)self.mapView.annotations;
    
    ComputeOptimalLocationUsingAveregeLocation(userAnnotations, ^(MKPointAnnotation *_Nullable optimalUserAnnotation, VenueAnnotation *_Nullable optimalVenueAnnotation, NSArray<VenueAnnotation *> *_Nullable venueAnnotations) {
        dispatch_async(dispatch_get_main_queue(), ^() {
            if (venueAnnotations) {
                [self.mapView addAnnotations:venueAnnotations];
            }
            
            if (optimalUserAnnotation) {
                self.optimalUserAnnotation = optimalUserAnnotation;
                [self.mapView removeAnnotation:optimalUserAnnotation];
                [self.mapView addAnnotation:optimalUserAnnotation];
                optimalUserAnnotation.subtitle = OPTIMAL_USER_ANNOTATION_SUBTITLE;
                [self.mapView setSelectedAnnotations:@[optimalUserAnnotation]];
                [self centerOnLocation:optimalUserAnnotation.coordinate];
            }
            if (optimalVenueAnnotation) {
                self.optimalVenueAnnotation = optimalVenueAnnotation;
                [self.mapView removeAnnotation:optimalVenueAnnotation];
                [self.mapView addAnnotation:optimalVenueAnnotation];
                optimalVenueAnnotation.subtitle = OPTIMAL_VENUE_ANNOTATION_SUBTITLE;
                [self.mapView setSelectedAnnotations:@[optimalVenueAnnotation]];
                [self centerOnLocation:optimalVenueAnnotation.coordinate];
            }
        });
    });
}

- (void)centerOnLocation:(CLLocationCoordinate2D)coordinate {
    MKCoordinateRegion mapRegion;
    mapRegion.center = coordinate;
    mapRegion.span.latitudeDelta = REGION_DELTA;
    mapRegion.span.longitudeDelta = REGION_DELTA;
    
    [self.mapView setRegion:mapRegion animated: YES];
}

- (void)putUserLocationOptionsOnMap {
    [self.locationOptions enumerateObjectsUsingBlock:^(CLLocation *_Nonnull location, NSUInteger index, BOOL *_Nonnull stop) {
        MKPointAnnotation *annotation = [MKPointAnnotation new];
        annotation.coordinate = location.coordinate;
        annotation.title = self.usersInEvent[index].username;
        [self.mapView addAnnotation:annotation];
    }];
    
    [self.mapView becomeFirstResponder];
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
    MKPinAnnotationView *annotationView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:PIN_ANNOTATION_IDENTIFIER];
    if (annotationView == nil) {
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:PIN_ANNOTATION_IDENTIFIER];
        annotationView.canShowCallout = true;
        
        if(![annotation isKindOfClass:[VenueAnnotation class]]) {
            annotationView.leftCalloutAccessoryView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, ANNOTATION_ACCESSORY_VIEW_DIMENSION, ANNOTATION_ACCESSORY_VIEW_DIMENSION)];
            
            UIImageView *imageView = (UIImageView*)annotationView.leftCalloutAccessoryView;
            UIImage *userProfileImage = [self.userImagesDictionary objectForKey:annotation.title];
            if (userProfileImage) {
                imageView.image = userProfileImage;
            } else {
                imageView.image = [UIImage imageNamed:DEFAULT_PROFILE_IMAGE_NAME];
            }
            
            annotationView.pinTintColor = USER_PIN_COLOR;
        } else {
            annotationView.pinTintColor = [MKPinAnnotationView greenPinColor];//VENUE_PIN_COLOR;
        }
        
        annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    } else {
        annotationView.annotation = annotation;
    }
    
    if ([annotation.title isEqualToString:self.optimalUserAnnotation.title]) {
        annotationView.pinTintColor = OPTIMAL_USER_PIN_COLOR;
    } else if ([annotation.title isEqualToString:self.optimalVenueAnnotation.title]) {
        annotationView.pinTintColor = OPTIMAL_VENUE_PIN_COLOR;
    }
    
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    if (view.annotation == nil) {
        return;
    }
    
    self.selectedAnnotation = (MKPointAnnotation *)view.annotation;
    
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:view.annotation.coordinate];
    self.selectedMapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
    
    if ([view.annotation isKindOfClass:[VenueAnnotation class]]) {
        VenueAnnotation *venueAnnotation = (VenueAnnotation *)view.annotation;
        self.selectedVenue = venueAnnotation.venue;
    } else {
        self.selectedVenue = [[FoursquareVenue alloc] init];
        self.selectedVenue.latitude = view.annotation.coordinate.latitude;
        self.selectedVenue.longitude = view.annotation.coordinate.longitude;
    }
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    NSDictionary *launchOptions = @{
        MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
    };
    
    [self.selectedMapItem openInMapsWithLaunchOptions:launchOptions];
}

#pragma mark - Button actions

- (IBAction)didTapCancel:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)didTapSave:(UIButton *)sender {
    if (self.didSelectLocationBlock && self.selectedVenue) {
        self.didSelectLocationBlock(self.selectedVenue);
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
