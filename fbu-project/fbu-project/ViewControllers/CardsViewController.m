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
#import "UserSorter.h"
#import "DictionaryConstants.h"
#import "ProfileViewController.h"

@interface CardsViewController () <AVAudioPlayerDelegate, CLLocationManagerDelegate>

@property (nonatomic, strong) AVAudioPlayer *_Nonnull audioPlayer;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CustomDraggableViewBackground *_Nonnull draggableViewBackground;
@property (nonatomic, strong) NSArray<PFUser *> *_Nullable users;

@end

static CGFloat CARDS_ENTRY_ANIMATION_DURATION = 0.5;
static NSString * const SEGUE_TO_PROFILE_IDENTIFIER = @"exploreToProfile";

@implementation CardsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self fetchRecommendedUsers];
    [self updateLocation];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceRotated)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}

- (IBAction)didTapRefresh:(UIButton *)sender {
    [self fetchRecommendedUsers];
}

- (void)deviceRotated {
    if (self.users) {
        [self.draggableViewBackground removeFromSuperview];
        [self insertDraggableView:self.users];
    }
}

- (void)fetchRecommendedUsers {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //async thread
        NSArray *users = Recommended();
        dispatch_sync(dispatch_get_main_queue(), ^{
            // This will be called on the main thread, so that UI  can be updated
            [self finishedFetchingRecommended:users];
        });
    });
}

- (void)finishedFetchingRecommended:(NSArray *_Nullable)users {    
    if (users) {
        self.users = users;
        [self insertDraggableView:users];
    }
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void)insertDraggableView:(NSArray *)users {
    CGFloat topBarHeight = self.navigationController.navigationBar.frame.size.height;
    CGFloat bottomBarHeight = self.tabBarController.tabBar.frame.size.height;
    
    CGRect frame = self.view.frame;
    frame.size.height = frame.size.height - topBarHeight - bottomBarHeight;
    frame.origin.y = -self.view.frame.size.height; //putting the view outside of the screen so it drops down
    CustomDraggableViewBackground *draggableBackground = [[CustomDraggableViewBackground alloc]initWithFrame:frame
                                                                                                       users:users
                                                                                              segueToProfile:^(PFUser *_Nonnull user){
        if (user) {
            [self performSegueWithIdentifier:SEGUE_TO_PROFILE_IDENTIFIER sender:user];
        }
    }];
    draggableBackground.alpha = 0; //making the view fade in
    
    self.draggableViewBackground = draggableBackground;
    [self.view addSubview:draggableBackground];
    
    //animate down and in
    [UIView animateWithDuration:CARDS_ENTRY_ANIMATION_DURATION
                     animations:^{
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
    NSNumber *latitude = @(latestLocation.coordinate.latitude);
    NSNumber *longitude = @(latestLocation.coordinate.longitude);
    currentUser[LATITUDE_KEY] = latitude;
    currentUser[LONGITUDE_KEY] = longitude;
    
    [[PFUser currentUser] saveInBackground];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:SEGUE_TO_PROFILE_IDENTIFIER]) {
        PFUser *user = (PFUser *)sender;
        if (user && [user isKindOfClass:[PFUser class]]) {
            ProfileViewController *destinationViewController = [segue destinationViewController];
            destinationViewController.targetUser = user;
        }
    }
}

@end
