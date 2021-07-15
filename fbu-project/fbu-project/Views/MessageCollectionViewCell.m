//
//  MessageCollectionViewCell.m
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/14/21.
//

#import "MessageCollectionViewCell.h"
#import "StylingConstants.h"

@implementation MessageCollectionViewCell

- (void)setCellWithDirectMessage:(DirectMessage *)message {
    self.contentLabel.text = message.content;
    
    NSString *authorId = message.author.objectId;
    if ([authorId isEqualToString:[PFUser currentUser].objectId]) {
        [self styleForSentMessage];
    } else {
        [self styleForReceivedMessage];
    }
}

- (void)styleForSentMessage {
    self.mainView.backgroundColor = SENT_MESSAGE_BACKGROUND;
//    [self.mainView setBackgroundColor:[UIColor blackColor]];
}

- (void)styleForReceivedMessage {
    self.mainView.backgroundColor = RECEIVED_MESSAGE_BACKGROUND;
//    [self.mainView setBackgroundColor:[UIColor blackColor]];
}

@end
