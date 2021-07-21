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

static int PLAYBACK_VIEW_X = 20;
static int PLAYBACK_VIEW_Y = 200;
static int PLAYBACK_VIEW_HEIGHT = 200;

static int USERNAME_LABEL_X = 0;
static int USERNAME_LABEL_Y = 50;
static int USERNAME_LABEL_HEIGHT = 100;

@interface CustomDraggableView ()

@property (nonatomic, strong) PFUser *_Nonnull user;
@property (nonatomic, strong) MediaPlayBackView *_Nonnull playbackView;

@end

@implementation CustomDraggableView


- (id)initWithFrame:(CGRect)frame
            andUser:(PFUser *)user {
    self = (CustomDraggableView *)[super initWithFrame:frame];
    if (self) {
        self.user = user;
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
                                                                        PLAYBACK_VIEW_Y,
                                                                        self.frame.size.width - (PLAYBACK_VIEW_X * 2),
                                                                        PLAYBACK_VIEW_HEIGHT)
                                               andData:data];
            self.playbackView = playbackView;
            [self addSubview:playbackView];
        }
    }];
}

- (void)setupUsernameLabel {
    self.usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(USERNAME_LABEL_X,
                                                                   USERNAME_LABEL_Y,
                                                                   self.frame.size.width,
                                                                   USERNAME_LABEL_HEIGHT)];
    self.usernameLabel.text = self.user.username;
    [self.usernameLabel setTextAlignment:NSTextAlignmentCenter];
    self.usernameLabel.textColor = [UIColor blackColor];
    
    [self addSubview:self.usernameLabel];
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
