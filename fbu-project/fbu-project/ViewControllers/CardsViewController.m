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

@interface CardsViewController () <AVAudioPlayerDelegate>

@property (nonatomic, strong) AVAudioPlayer *audioPlayer;

@end

@implementation CardsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self insertDraggableView];
}

- (void)viewDidAppear:(BOOL)animated {
    [self playCurrentUserRecording];
}

- (void)insertDraggableView {
    CGRect frame = self.view.frame;
    frame.origin.y = -self.view.frame.size.height; //putting the view outside of the screen so it drops down
    DraggableViewBackground *draggableBackground = [[DraggableViewBackground alloc]initWithFrame:frame];
    draggableBackground.alpha = 0; //making the view fade in

    [self.view addSubview:draggableBackground];

    //animate down and in
    [UIView animateWithDuration:0.5 animations:^{
        draggableBackground.center = self.view.center;
        draggableBackground.alpha = 1;
    }];
}

#pragma mark - Testing audio playback from database

- (void)playCurrentUserRecording {
    PFQuery *userQuery = [PFQuery queryWithClassName:@"_User"];
    [userQuery whereKey:@"objectId" equalTo:[PFUser currentUser].objectId];
    [userQuery includeKey:@"recording"];
    
    [userQuery findObjectsInBackgroundWithBlock:^(NSArray *_Nullable matchingUsers, NSError *_Nullable error){
        if (error) {
            NSLog(@"Error fetching mathching users");
        } else {
            for (PFUser *user in matchingUsers) {
                PFFileObject *recordingFile = user[@"recording"];
                NSData *data = [recordingFile getData];
                [self playRecordingWithData:data];
            }
        }
    }];
}

- (void)playRecordingWithData:(NSData *)data {
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    NSError *error = nil;
    self.audioPlayer = [[AVAudioPlayer alloc] initWithData:data error:&error];
    self.audioPlayer.delegate = self;
    self.audioPlayer.numberOfLoops = 0;
    [self.audioPlayer play];
}

@end
