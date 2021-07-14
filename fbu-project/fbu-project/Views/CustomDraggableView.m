//
//  CustomDraggableView.m
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/13/21.
//

#import "CustomDraggableView.h"
#import <AVFoundation/AVFoundation.h>
#import "Like.h"
#import "UnLike.h"

@interface CustomDraggableView () <AVAudioPlayerDelegate>

@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic, strong) PFUser *user;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) NSTimer *progressTimer;

@end

@implementation CustomDraggableView


- (id)initWithFrame:(CGRect)frame andUser:(PFUser *)user
{
    self = (CustomDraggableView *)[super initWithFrame:frame];
    if (self) {
        self.user = user;
        [self setupUsernameLabel];
        
        if (self.user[@"recording"] != nil) {
            [self setupPlayButton];
        }
    }
    return self;
}

#pragma mark - Setup

- (void)setupUsernameLabel {
    self.usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, self.frame.size.width, 100)];
    self.usernameLabel.text = self.user[@"username"];
    [self.usernameLabel setTextAlignment:NSTextAlignmentCenter];
    self.usernameLabel.textColor = [UIColor blackColor];
    
    [self addSubview:self.usernameLabel];
}

- (void)setupPlayButton {
    CGFloat buttonWidth = 50;
    self.playButton = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width/2 - buttonWidth/2, 200, buttonWidth, buttonWidth)];
    [self.playButton setTitle:@"" forState:UIControlStateNormal];
    [self.playButton setBackgroundImage:[UIImage systemImageNamed:@"play"] forState:UIControlStateNormal];
    [self.playButton setBackgroundImage:[UIImage systemImageNamed:@"stop"] forState:UIControlStateSelected];
    [self.playButton addTarget:self action:@selector(didTapPlayButton) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:self.playButton];
}

- (void)didTapPlayButton {
    if (self.playButton == nil) {
        NSLog(@"Error: nil play button");
        return;
    }
    
    if ([self.playButton isSelected]) {
        [self stopPlaying];
    } else {
        [self playRecording];
    }
}


- (void)afterSwipeAction {
    [self stopPlaying];
    [super afterSwipeAction];
}

#pragma mark - Recording playback

- (void)showProgressView {
    CGFloat barWidth = 300;
    self.progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(self.frame.size.width/2 - barWidth/2, 300, barWidth, 50)];
    self.progressView.progress = 0.5;
 
    [self addSubview:self.progressView];
    
    self.progressView.alpha = 0;
    [UIView animateWithDuration:.5 animations:^{
        self.progressView.alpha = 1;
    }];
    
    self.progressTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(updatePlaybackSlider:) userInfo:nil repeats:YES];
}

- (void)hideProgressView {
    [UIView animateWithDuration:0.5
                     animations:^{self.progressView.alpha = 0;}
                     completion:^(BOOL finished){
        if (finished) {
            [self.progressTimer invalidate];
            self.progressTimer = nil;
            [self.progressView removeFromSuperview];
            self.progressView = nil;
        }
    }];
}

- (void)updatePlaybackSlider:(NSTimer *)timer {
    if (self.audioPlayer == nil || self.progressView == nil) {
        NSLog(@"Not ready for progress bar");
    }
    
    float totalTime = self.audioPlayer.duration;
    float currentTime = self.audioPlayer.currentTime / totalTime;
    
    NSLog(@"Current time: %f", currentTime);
    
    self.progressView.progress = currentTime;
}

-(void)playRecording
{
    
    PFFileObject *recordingFile = self.user[@"recording"];
    if(recordingFile == nil) {
        NSLog(@"User has no recording");
        return;
    }
    
    [self.playButton setSelected:YES];
    
    [recordingFile getDataInBackgroundWithBlock:^(NSData *_Nullable data, NSError *_Nullable error){
        if (error) {
            NSLog(@"Error getting data from PFFileObject");
        } else {
            [self playRecordingWithData:data];
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
    [self showProgressView];
}


- (void)stopPlaying {
    [self.playButton setSelected:NO];
    
    if (self.progressView) {
        [self hideProgressView];
    }
    
    if (self.audioPlayer) {
        [self.audioPlayer stop];
        self.audioPlayer = nil;
    }
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    
    if (flag) {
        [self stopPlaying];
    } else {
        NSLog(@"audioPlayerDidFinishPlaying with error");
    }
}

#pragma mark - Card Swiped Override Methods

- (void)swipedRight {
    //YES
    [Like postLikeFrom:[PFUser currentUser] to:self.user withCompletion:^(BOOL succeeded, NSError *_Nullable error){
        if (error) {
            NSLog(@"Error posting like: %@", error.localizedDescription);
        }
    }];
}

- (void)swipedLeft {
    //NO
    [UnLike postUnLikeFrom:[PFUser currentUser] to:self.user withCompletion:^(BOOL succeeded, NSError *_Nullable error){
        if (error) {
            NSLog(@"Error posting like: %@", error.localizedDescription);
        }
    }];
}

@end
