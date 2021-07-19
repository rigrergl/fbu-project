//
//  CardsViewController.m
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/12/21.
//

#import "CardsViewController.h"
#import "CustomDraggableViewBackground.h"
#import <AVFoundation/AVFoundation.h>
#import <Parse/Parse.h>
#import <MBProgressHUD/MBProgressHUD.h>

@interface CardsViewController () <AVAudioPlayerDelegate, CLLocationManagerDelegate>

@property (nonatomic, strong) AVAudioPlayer *_Nonnull audioPlayer;
@property (nonatomic, strong) CLLocationManager *locationManager;

@end

@implementation CardsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self fetchRecommendedUsers];
    [self updateLocation];
}

- (void)fetchRecommendedUsers {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    PFQuery *userQuery = [PFQuery queryWithClassName:@"_User"];
    [userQuery whereKey:@"objectId" notEqualTo:[PFUser currentUser].objectId];
    [userQuery includeKey:@"recording"];
    
    [userQuery findObjectsInBackgroundWithBlock:^(NSArray *_Nullable matchingUsers, NSError *_Nullable error){
        if (!error) {
            [self insertDraggableView:matchingUsers];
        }
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
}

- (void)insertDraggableView:(NSArray *)users {
    CGFloat topBarHeight = self.navigationController.navigationBar.frame.size.height;
    CGFloat bottomBarHeight = self.tabBarController.tabBar.frame.size.height;
    
    CGRect frame = self.view.frame;
    frame.size.height = frame.size.height - topBarHeight - bottomBarHeight;
    frame.origin.y = -self.view.frame.size.height; //putting the view outside of the screen so it drops down
    CustomDraggableViewBackground *draggableBackground = [[CustomDraggableViewBackground alloc]initWithFrame:frame andUsers:users];
    draggableBackground.alpha = 0; //making the view fade in

    [self.view addSubview:draggableBackground];

    //animate down and in
    [UIView animateWithDuration:0.5 animations:^{
        draggableBackground.center = self.view.center;
        draggableBackground.alpha = 1;
    }];
}

#pragma mark - Update Location

- (void)updateLocation {
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [self.locationManager requestWhenInUseAuthorization];
    
    [self.locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations {
    CLLocation *location = [locations lastObject];
    [self updateLatestLocationForCurrentUser:location];
    
    [manager stopUpdatingLocation];
    self.locationManager = nil;
}

- (void)updateLatestLocationForCurrentUser:(CLLocation *)latestLocation {
    PFUser *currentUser = [PFUser currentUser];
    NSNumber *latitude = [NSNumber numberWithDouble:latestLocation.coordinate.latitude];
    NSNumber *longitude = [NSNumber numberWithDouble:latestLocation.coordinate.longitude];
    currentUser[@"latestLatitude"] = latitude;
    currentUser[@"latestLongitude"] = longitude;
    
    [[PFUser currentUser] saveInBackground];
}

@end
