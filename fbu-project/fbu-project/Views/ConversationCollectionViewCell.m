//
//  ConversationCollectionViewCell.m
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/15/21.
//

#import "ConversationCollectionViewCell.h"
#import "DirectMessage.h"
#import "DictionaryConstants.h"

@implementation ConversationCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self doStyling];
}

- (void)doStyling {
    //making profile image round
    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width / 2;
    self.profileImageView.clipsToBounds = YES;
}

- (void)setCellWithUser:(PFUser *)user
               andMatch:(Match *)match {
    self.usernameLabel.text = user.username;
    
    [user[PROFILE_IMAGE_KEY] getDataInBackgroundWithBlock:^(NSData *_Nullable data, NSError *_Nullable error) {
        if (!error) {
            self.profileImageView.image = [UIImage imageWithData:data];
        }
    }];
    
    self.latestMessageLabel.alpha = 0;
    fetchLatestMessageInMatch(match, ^(DirectMessage *_Nullable latestMessage, NSError *_Nullable error){
        if (latestMessage) {
            self.latestMessageLabel.text = latestMessage.content;
            [UIView animateWithDuration:0.1 animations:^{
                self.latestMessageLabel.alpha = 1;
            }];
        }
    });
}

void fetchLatestMessageInMatch( Match *match,
                               void (^completion)(DirectMessage *_Nullable latestMessage, NSError *error) ){
    PFQuery *messageQuery = [PFQuery queryWithClassName:@"DirectMessage"];
    [messageQuery whereKey:@"match" equalTo:match];
    [messageQuery orderByDescending:@"createdAt"];
    messageQuery.limit = 1;
    
    [messageQuery findObjectsInBackgroundWithBlock:^(NSArray *_Nullable messages, NSError *_Nullable error){
        completion(messages[0], error);
    }];
}

@end
