//
//  MessageCollectionViewCell.m
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/14/21.
//

#import "MessageCollectionViewCell.h"
#import "StylingConstants.h"

static NSInteger MESSAGE_BUBBLE_CORNER_RADIUS = 14;

@implementation MessageCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setRoundedEdges];
}

- (void)setRoundedEdges {
    self.bubbleView.layer.cornerRadius = MESSAGE_BUBBLE_CORNER_RADIUS;
    self.bubbleView.layer.masksToBounds = YES;
}

- (void)setCellWithDirectMessage:(DirectMessage *)message {
    self.contentLabel.text = message.content;
    
    NSString *authorId = message.author.objectId;
    if ([authorId isEqualToString:[PFUser currentUser].objectId]) {
        [self styleForSentMessage];
    } else {
        [self styleForReceivedMessage];
    }
    [self setNeedsLayout];
    [self layoutIfNeeded];
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
