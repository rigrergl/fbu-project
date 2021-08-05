//
//  CustomDraggableView.m
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/13/21.
//

#import "CustomDraggableView.h"
#import "MediaPlayBackView.h"
#import "Like.h"
#import "UnLike.h"
#import "DictionaryConstants.h"

@interface CustomDraggableView ()

@property (nonatomic, strong) PFUser *_Nonnull user;
@property (nonatomic, strong) MediaPlayBackView *_Nonnull playbackView;

@end

static NSInteger PLAYBACK_VIEW_X = 20;

static NSInteger USERNAME_LABEL_X = 0;
static NSInteger USERNAME_LABEL_HEIGHT = 20;

static NSInteger INFO_BUTTON_WIDTH = 30;
static NSInteger INFO_BUTTON_EDGE_SPACING = 4;
static NSString * const INFO_BUTTON_IMAGE_NAME = @"info.circle";

@implementation CustomDraggableView

- (id)initWithFrame:(CGRect)frame
               user:(PFUser *)user
     segueToProfile:(void (^_Nonnull)(PFUser *_Nonnull user))segueToProfile {
    self = (CustomDraggableView *)[super initWithFrame:frame];
    
    if (self) {
        self.user = user;
        self.segueToProfile = segueToProfile;
        [self setupInfoButton];
        [self setupUsernameLabel];
        [self setupPlaybackSubview];
    }
    
    return self;
}

#pragma mark - Setup

- (void)setupPlaybackSubview {
    PFFileObject *recordingFile = self.user[RECORDING_KEY];
    if(recordingFile == nil) {
        return;
    }
    [self.playButton setSelected:YES];
    
    [recordingFile getDataInBackgroundWithBlock:^(NSData *_Nullable data, NSError *_Nullable error){
        if (!error) {
            MediaPlayBackView *playbackView = [[MediaPlayBackView alloc]
                                               initWithFrame:CGRectMake(PLAYBACK_VIEW_X,
                                                                        self.frame.size.height/2,
                                                                        self.frame.size.width - (PLAYBACK_VIEW_X * 2),
                                                                        self.frame.size.height/2)
                                               andData:data];
            self.playbackView = playbackView;
            [self addSubview:playbackView];
        }
    }];
}

- (void)setupUsernameLabel {
    NSInteger usernameLabelY = self.frame.size.height / 4;
    
    self.usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(USERNAME_LABEL_X,
                                                                   usernameLabelY,
                                                                   self.frame.size.width,
                                                                   USERNAME_LABEL_HEIGHT)];
    self.usernameLabel.text = self.user.username;
    [self.usernameLabel setTextAlignment:NSTextAlignmentCenter];
    self.usernameLabel.textColor = [UIColor blackColor];
    self.usernameLabel.font = [UIFont boldSystemFontOfSize:USERNAME_LABEL_HEIGHT];
    
    [self addSubview:self.usernameLabel];
}

- (void)setupInfoButton {
    CGRect buttonFrame = CGRectMake(self.frame.size.width - INFO_BUTTON_WIDTH - INFO_BUTTON_EDGE_SPACING, INFO_BUTTON_EDGE_SPACING, INFO_BUTTON_WIDTH, INFO_BUTTON_WIDTH);
    self.infoButton = [[UIButton alloc] initWithFrame:buttonFrame];
    
    UIImage *infoImage = [UIImage systemImageNamed:INFO_BUTTON_IMAGE_NAME];
    [self.infoButton setBackgroundImage:infoImage forState:UIControlStateNormal];
    [self.infoButton addTarget:self action:@selector(didTapInfoButton) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:self.infoButton];
}

- (void)didTapInfoButton {
    if (self.segueToProfile) {
        self.segueToProfile(self.user);
    }
}

- (void)afterSwipeAction {
    [self.playbackView stopPlaying];
    [super afterSwipeAction];
}

#pragma mark - Card Swiped Override Methods

- (void)swipedRight {
    //RIGHT = YES
    [Like postLikeFrom:[PFUser currentUser] to:self.user completion:nil];
}

- (void)swipedLeft {
    //LEFT = NO
    [UnLike postUnLikeFrom:[PFUser currentUser] to:self.user completion:nil];
}

@end
