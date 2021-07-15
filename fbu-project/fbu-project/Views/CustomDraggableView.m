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

@interface CustomDraggableView ()


@property (nonatomic, strong) PFUser *user;
@property (nonatomic, strong) MediaPlayBackView *playbackView;


@end

@implementation CustomDraggableView


- (id)initWithFrame:(CGRect)frame andUser:(PFUser *)user
{
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
    PFFileObject *recordingFile = self.user[@"recording"];
    if(recordingFile == nil) {
        return;
    }
    
    [self.playButton setSelected:YES];
    
    [recordingFile getDataInBackgroundWithBlock:^(NSData *_Nullable data, NSError *_Nullable error){
        if (error) {
            NSLog(@"Error getting data from PFFileObject");
        } else {
            
            MediaPlayBackView *playbackView = [[MediaPlayBackView alloc]
                                               initWithFrame:CGRectMake(20, 200, self.frame.size.width - 40, 200)
                                               andData:data];
            self.playbackView = playbackView;
            [self addSubview:playbackView];
        }
    }];
}

- (void)setupUsernameLabel {
    self.usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, self.frame.size.width, 100)];
    self.usernameLabel.text = self.user[@"username"];
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
