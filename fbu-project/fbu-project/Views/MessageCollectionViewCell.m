//
//  MessageCollectionViewCell.m
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/14/21.
//

#import "MessageCollectionViewCell.h"
#import "StylingConstants.h"

static NSInteger MESSAGE_BUBBLE_CORNER_RADIUS = 14;
static NSInteger LIKES_VIEW_CORNER_RADIUS = 14;
static CGFloat LIKES_VIEW_SHADOW_OPACITY = 0.2;
static CGFloat LIKES_VIEW_SHADOW_RADIUS = 2.0;
static CGFloat LIKES_VIEW_SHADOW_OFFSET_WIDTH = 2.0;
static CGFloat LIKES_VIEW_SHADOW_OFFSET_HEIGHT = 2.0;

@implementation MessageCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self doInitialStyling];
    [self setupGestures];
}

- (void)doInitialStyling {
    [self styleBubbleView];
    [self styleLikesView];
}

- (void)styleBubbleView {
    self.bubbleView.layer.cornerRadius = MESSAGE_BUBBLE_CORNER_RADIUS;
    self.bubbleView.layer.masksToBounds = YES;
}

- (void)styleLikesView {
    //corner radius
    self.likesView.layer.cornerRadius = LIKES_VIEW_CORNER_RADIUS;

    // drop shadow
    self.likesView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.likesView.layer.shadowOpacity = LIKES_VIEW_SHADOW_OPACITY;
    self.likesView.layer.shadowRadius = LIKES_VIEW_SHADOW_RADIUS;
    self.likesView.layer.shadowOffset = CGSizeMake(LIKES_VIEW_SHADOW_OFFSET_WIDTH, LIKES_VIEW_SHADOW_OFFSET_HEIGHT);
}

- (void)setupGestures {
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didDoubleTapMessage:)];
    tapGestureRecognizer.numberOfTapsRequired = 2;
    [self.bubbleView addGestureRecognizer:tapGestureRecognizer];
    [self.bubbleView setUserInteractionEnabled:YES];
}

- (void)didDoubleTapMessage:(UITapGestureRecognizer *_Nonnull)sender {
    [self.message userDidLike:[PFUser currentUser]];
    [self setLikes];
}

- (void)showOrHideLikesView {
    if (self.message.likes == 0) {
        [self hideLikesView];
    } else if (self.message.likes == 1) {
        [self showLikedView];
    }
}

- (void)hideLikesView {
    self.likesView.alpha = 0;
}

- (void)showLikedView {
    self.likesView.alpha = 1;
}

- (void)setCellWithDirectMessage:(DirectMessage *)message {
    if (!message) {
        return;
    }
    self.message = message;
    self.contentLabel.text = message.content;
    
    NSString *authorId = message.author.objectId;
    if ([authorId isEqualToString:[PFUser currentUser].objectId]) {
        [self styleForSentMessage];
    } else {
        [self styleForReceivedMessage];
    }
    [self setNeedsLayout];
    [self layoutIfNeeded];
    
    [self setLikes];
}

- (void)setLikes {
    self.likesCountLabel.text = [@(self.message.likes) stringValue];
    [self showOrHideLikesView];
}

- (void)styleForSentMessage {
    self.bubbleView.backgroundColor = SENT_MESSAGE_BACKGROUND_COLOR;
    self.contentLabel.textColor = [UIColor whiteColor];
}

- (void)styleForReceivedMessage {
    self.bubbleView.backgroundColor = RECEIVED_MESSAGE_BACKGROUND_COLOR;
    self.contentLabel.textColor = [UIColor blackColor];
}

@end
