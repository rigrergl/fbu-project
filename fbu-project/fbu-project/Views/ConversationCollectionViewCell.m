//
//  ConversationCollectionViewCell.m
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/15/21.
//

#import "ConversationCollectionViewCell.h"

@implementation ConversationCollectionViewCell

- (void)setCellWithUser:(PFUser *)user
               andMatch:(Match *)match; {
    
    self.usernameLabel.text = user.username;
    //TODO: SET PROFILE IMAGE
    //TODO: FETCH LATEST MESSAGE IN MATCH
}

@end
