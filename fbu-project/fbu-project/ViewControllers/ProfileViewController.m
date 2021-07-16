//
//  ProfileViewController.m
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/12/21.
//

#import "ProfileViewController.h"
#import <Parse/Parse.h>
#import "SceneDelegate.h"
#import "AuthenticationViewController.h"
#import "MediaPlayBackView.h"

@interface ProfileViewController ()

@property (strong, nonatomic) IBOutlet UIView *_Nonnull playbackContainerView;
@property (strong, nonatomic) MediaPlayBackView *_Nullable playbackView;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self fetchRecording];
    
    if(self.targetUser == nil) {
        self.targetUser = [PFUser currentUser];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    if (self.playbackView) {
        [self.playbackView stopPlaying];
    }
}

- (void)fetchRecording {
    PFQuery *userQuery = [PFQuery queryWithClassName:@"_User"];
    [userQuery includeKey:@"recording"];
    
    [userQuery getObjectInBackgroundWithId:[PFUser currentUser].objectId block:^(PFObject *_Nullable object, NSError *_Nullable error){

        if (object) {
            self.targetUser = (PFUser *)object;

            PFFileObject *recordingFile = self.targetUser[@"recording"];
            if(recordingFile == nil) {
                return;
            }

            
            [self addPlaybackView];
        }
    }];
}

- (void)addPlaybackView {
    PFFileObject *recordingFile = self.targetUser[@"recording"];
    if(recordingFile == nil) {
        return;
    }
    
    [recordingFile getDataInBackgroundWithBlock:^(NSData *_Nullable data, NSError *_Nullable error){
        if (data) {
            MediaPlayBackView *playbackView = [[MediaPlayBackView alloc]
                                               initWithFrame:CGRectMake(0, 0, self.playbackContainerView.frame.size.width, self.playbackContainerView.frame.size.height)
                                               andData:data];
            
            self.playbackView = playbackView;
            [self.playbackContainerView addSubview:playbackView];
        }
    }];
}

- (IBAction)didTapLogout:(UIBarButtonItem *)sender {
    SceneDelegate *sceneDelegate = (SceneDelegate *)[UIApplication sharedApplication].connectedScenes.allObjects[0].delegate;
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    AuthenticationViewController *userAuthenticationViewController = [storyboard instantiateViewControllerWithIdentifier:@"AuthenticationViewController"];
    sceneDelegate.window.rootViewController = userAuthenticationViewController;
    
    [PFUser logOutInBackground];
}

@end
