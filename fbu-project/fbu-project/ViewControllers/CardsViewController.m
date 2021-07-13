//
//  CardsViewController.m
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/12/21.
//

#import "CardsViewController.h"
#import "DraggableViewBackground.h"
#import <AVFoundation/AVFoundation.h>
#import <Parse/Parse.h>
#import <MBProgressHUD/MBProgressHUD.h>

@interface CardsViewController () <AVAudioPlayerDelegate>

@property (nonatomic, strong) AVAudioPlayer *audioPlayer;

@end

@implementation CardsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self fetchRecommendedUsers];
}

- (void)fetchRecommendedUsers {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    PFQuery *userQuery = [PFQuery queryWithClassName:@"_User"];
    [userQuery whereKey:@"objectId" notEqualTo:[PFUser currentUser].objectId];
    [userQuery includeKey:@"recording"];
    
    [userQuery findObjectsInBackgroundWithBlock:^(NSArray *_Nullable matchingUsers, NSError *_Nullable error){
        if (error) {
            NSLog(@"Error fetching mathching users");
        } else {
            [self insertDraggableView:matchingUsers];
        }
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
}

- (void)insertDraggableView:(NSArray *)users {    
    CGRect frame = self.view.frame;
    frame.origin.y = -self.view.frame.size.height; //putting the view outside of the screen so it drops down
    DraggableViewBackground *draggableBackground = [[DraggableViewBackground alloc]initWithFrame:frame andUsers:users];
    draggableBackground.alpha = 0; //making the view fade in

    [self.view addSubview:draggableBackground];

    //animate down and in
    [UIView animateWithDuration:0.5 animations:^{
        draggableBackground.center = self.view.center;
        draggableBackground.alpha = 1;
    }];
}

@end
