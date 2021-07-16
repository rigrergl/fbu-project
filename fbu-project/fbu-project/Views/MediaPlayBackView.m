//
//  MediaPlayBackView.m
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/15/21.
//

#import "MediaPlayBackView.h"
#import <AVFoundation/AVFoundation.h>

@interface MediaPlayBackView () <AVAudioPlayerDelegate>

@property (nonatomic, strong) AVAudioPlayer *_Nonnull audioPlayer;
@property (nonatomic, strong) NSData *_Nonnull recordingData;
@property (nonatomic, strong) UIProgressView *_Nullable progressView;
@property (nonatomic, strong) NSTimer *_Nullable progressTimer;
@property (nonatomic, strong) UIButton *_Nullable playButton;

@end

@implementation MediaPlayBackView

- (id)initWithFrame:(CGRect)frame
            andData:(NSData *_Nonnull)data {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor whiteColor];
        if (data) {
            self.recordingData = data;
            [self setupPlayButton];
        }
    }
    return self;
}

- (void)setupPlayButton {
    CGFloat buttonWidth = 50;
    self.playButton = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width/2 - buttonWidth/2, 0, buttonWidth, buttonWidth)];
    [self.playButton setTitle:@"" forState:UIControlStateNormal];
    [self.playButton setBackgroundImage:[UIImage systemImageNamed:@"play"] forState:UIControlStateNormal];
    [self.playButton setBackgroundImage:[UIImage systemImageNamed:@"stop"] forState:UIControlStateSelected];
    [self.playButton addTarget:self action:@selector(didTapPlayButton) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:self.playButton];
}

- (void)didTapPlayButton {
    if (self.playButton == nil) {
        return;
    }
    
    if ([self.playButton isSelected]) {
        [self stopPlaying];
    } else {
        [self startPlaying];
    }
}

- (void)startPlaying {
    [self.playButton setSelected:YES];
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    
    NSError *error = nil;
    self.audioPlayer = [[AVAudioPlayer alloc] initWithData:self.recordingData error:&error];
    
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

- (void)showProgressView {
    CGFloat barWidth = self.frame.size.width;
    self.progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(self.frame.size.width/2 - barWidth/2, 70, barWidth, 50)];
    self.progressView.progress = 0.5;
 
    [self addSubview:self.progressView];
    
    self.progressView.alpha = 0;
    [UIView animateWithDuration:.5 animations:^{
        self.progressView.alpha = 1;
    }];
    
    self.progressTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(updatePlaybackSlider:) userInfo:nil repeats:YES];
}

- (void)updatePlaybackSlider:(NSTimer *)timer {
    if (self.audioPlayer == nil || self.progressView == nil) {
        return; //TODO: DOUBLE CHECK THIS
    }
    
    float totalTime = self.audioPlayer.duration;
    float currentTime = self.audioPlayer.currentTime / totalTime;
    
    self.progressView.progress = currentTime;
}

- (void)hideProgressView {
    [self.progressTimer invalidate];
    self.progressTimer = nil;
    [self.progressView removeFromSuperview];
    self.progressView = nil;
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player
                       successfully:(BOOL)flag {
    if (flag) {
        [self stopPlaying];
    }
}


@end
