//
//  DraggableView.m
//  RKSwipeCards
//
//  Created by Richard Kim on 5/21/14.
//  Copyright (c) 2014 Richard Kim. All rights reserved.
//
//  @cwRichardKim for updates and requests

#define ACTION_MARGIN 120 //%%% distance from center where the action applies. Higher = swipe further in order for the action to be called
#define SCALE_STRENGTH 4 //%%% how quickly the card shrinks. Higher = slower shrinking
#define SCALE_MAX .93 //%%% upper bar for how much the card shrinks. Higher = shrinks less
#define ROTATION_MAX 1 //%%% the maximum rotation allowed in radians.  Higher = card can keep rotating longer
#define ROTATION_STRENGTH 320 //%%% strength of rotation. Higher = weaker rotation
#define ROTATION_ANGLE M_PI/8 //%%% Higher = stronger rotation angle


#import "DraggableView.h"
#import <AVFoundation/AVFoundation.h>

@interface DraggableView () <AVAudioPlayerDelegate>

@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic, strong) PFUser *user;

@end

@implementation DraggableView {
    CGFloat xFromCenter;
    CGFloat yFromCenter;
}

//delegate is instance of ViewController
@synthesize delegate;

@synthesize panGestureRecognizer;
@synthesize usernameLabel;
@synthesize overlayView;
@synthesize playButton;
@synthesize user;

- (id)initWithFrame:(CGRect)frame andUser:(PFUser *)user
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
        self.user = user;
#warning placeholder stuff, replace with card-specific information {
        [self setupUsernameLabel];
        [self setupPlayButton];
        
        self.backgroundColor = [UIColor whiteColor];
#warning placeholder stuff, replace with card-specific information }
        panGestureRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(beingDragged:)];
        
        [self addGestureRecognizer:panGestureRecognizer];
        
        overlayView = [[OverlayView alloc]initWithFrame:CGRectMake(self.frame.size.width/2-100, 0, 100, 100)];
        overlayView.alpha = 0;
        [self addSubview:overlayView];
    }
    return self;
}

#pragma mark - Setup

- (void)setupUsernameLabel {
    usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, self.frame.size.width, 100)];
    usernameLabel.text = user[@"username"];
    [usernameLabel setTextAlignment:NSTextAlignmentCenter];
    usernameLabel.textColor = [UIColor blackColor];
    
    [self addSubview:usernameLabel];
}

- (void)setupPlayButton {
//    CGRectMake(<#CGFloat x#>, <#CGFloat y#>, <#CGFloat width#>, <#CGFloat height#>)
    playButton = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width / 2 - 20, 200, 20, 20)];
    [playButton setTitle:@"" forState:UIControlStateNormal];
    [playButton setBackgroundImage:[UIImage systemImageNamed:@"play"] forState:UIControlStateNormal];
    [playButton addTarget:self action:@selector(playRecording) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:playButton];
}

- (void)setupView
{
    self.layer.cornerRadius = 4;
    self.layer.shadowRadius = 3;
    self.layer.shadowOpacity = 0.2;
    self.layer.shadowOffset = CGSizeMake(1, 1);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

//%%% called when you move your finger across the screen.
// called many times a second
-(void)beingDragged:(UIPanGestureRecognizer *)gestureRecognizer
{
    //%%% this extracts the coordinate data from your swipe movement. (i.e. How much did you move?)
    xFromCenter = [gestureRecognizer translationInView:self].x; //%%% positive for right swipe, negative for left
    yFromCenter = [gestureRecognizer translationInView:self].y; //%%% positive for up, negative for down
    
    //%%% checks what state the gesture is in. (are you just starting, letting go, or in the middle of a swipe?)
    switch (gestureRecognizer.state) {
            //%%% just started swiping
        case UIGestureRecognizerStateBegan:{
            self.originalPoint = self.center;
            break;
        };
            //%%% in the middle of a swipe
        case UIGestureRecognizerStateChanged:{
            //%%% dictates rotation (see ROTATION_MAX and ROTATION_STRENGTH for details)
            CGFloat rotationStrength = MIN(xFromCenter / ROTATION_STRENGTH, ROTATION_MAX);
            
            //%%% degree change in radians
            CGFloat rotationAngel = (CGFloat) (ROTATION_ANGLE * rotationStrength);
            
            //%%% amount the height changes when you move the card up to a certain point
            CGFloat scale = MAX(1 - fabsf(rotationStrength) / SCALE_STRENGTH, SCALE_MAX);
            
            //%%% move the object's center by center + gesture coordinate
            self.center = CGPointMake(self.originalPoint.x + xFromCenter, self.originalPoint.y + yFromCenter);
            
            //%%% rotate by certain amount
            CGAffineTransform transform = CGAffineTransformMakeRotation(rotationAngel);
            
            //%%% scale by certain amount
            CGAffineTransform scaleTransform = CGAffineTransformScale(transform, scale, scale);
            
            //%%% apply transformations
            self.transform = scaleTransform;
            [self updateOverlay:xFromCenter];
            
            break;
        };
            //%%% let go of the card
        case UIGestureRecognizerStateEnded: {
            [self afterSwipeAction];
            break;
        };
        case UIGestureRecognizerStatePossible:break;
        case UIGestureRecognizerStateCancelled:break;
        case UIGestureRecognizerStateFailed:break;
    }
}

//%%% checks to see if you are moving right or left and applies the correct overlay image
-(void)updateOverlay:(CGFloat)distance
{
    if (distance > 0) {
        overlayView.mode = GGOverlayViewModeRight;
    } else {
        overlayView.mode = GGOverlayViewModeLeft;
    }
    
    overlayView.alpha = MIN(fabsf(distance)/100, 0.4);
}

//%%% called when the card is let go
- (void)afterSwipeAction
{
    [self stopPlaying];
    
    if (xFromCenter > ACTION_MARGIN) {
        [self rightAction];
    } else if (xFromCenter < -ACTION_MARGIN) {
        [self leftAction];
    } else { //%%% resets the card
        [UIView animateWithDuration:0.3
                         animations:^{
                             self.center = self.originalPoint;
                             self.transform = CGAffineTransformMakeRotation(0);
                             overlayView.alpha = 0;
                         }];
    }
}

//%%% called when a swipe exceeds the ACTION_MARGIN to the right
-(void)rightAction
{
    CGPoint finishPoint = CGPointMake(500, 2*yFromCenter +self.originalPoint.y);
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.center = finishPoint;
                     }completion:^(BOOL complete){
                         [self removeFromSuperview];
                     }];
    
    [delegate cardSwipedRight:self];
    
    NSLog(@"YES");
}

//%%% called when a swip exceeds the ACTION_MARGIN to the left
-(void)leftAction
{
    CGPoint finishPoint = CGPointMake(-500, 2*yFromCenter +self.originalPoint.y);
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.center = finishPoint;
                     }completion:^(BOOL complete){
                         [self removeFromSuperview];
                     }];
    
    [delegate cardSwipedLeft:self];
    
    NSLog(@"NO");
}

-(void)rightClickAction
{
    CGPoint finishPoint = CGPointMake(600, self.center.y);
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.center = finishPoint;
                         self.transform = CGAffineTransformMakeRotation(1);
                     }completion:^(BOOL complete){
                         [self removeFromSuperview];
                     }];
    
    [delegate cardSwipedRight:self];
    
    NSLog(@"YES");
}

-(void)leftClickAction
{
    CGPoint finishPoint = CGPointMake(-600, self.center.y);
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.center = finishPoint;
                         self.transform = CGAffineTransformMakeRotation(-1);
                     }completion:^(BOOL complete){
                         [self removeFromSuperview];
                     }];
    
    [delegate cardSwipedLeft:self];
    
    NSLog(@"NO");
}


#pragma mark - Recording playback

-(void)playRecording
{
    PFFileObject *recordingFile = user[@"recording"];
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
}


- (void)stopPlaying {
    if (self.audioPlayer) {
        [self.audioPlayer stop];
        self.audioPlayer = nil;
    } else {
        NSLog(@"Tried to stop audio player but it was nil");
    }
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    
    if (flag) {
        [self stopPlaying];
    } else {
        NSLog(@"audioPlayerDidFinishPlaying with error");
    }
}



@end
