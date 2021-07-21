//
//  AddInviteeCollectionViewCell.m
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/21/21.
//

#import "AddInviteeCollectionViewCell.h"
#import "DictionaryConstants.h"
#import "StylingConstants.h"

@implementation AddInviteeCollectionViewCell

- (void)setCell:(PFUser *_Nonnull)user {
    self.profileImageView.image = [UIImage imageNamed:DEFAULT_PROFILE_IMAGE_NAME];
    self.usernameLabel.text = user.username;
    [user[PROFILE_IMAGE_KEY] getDataInBackgroundWithBlock:^(NSData *_Nullable data, NSError *_Nullable error) {
        if (data) {
            self.profileImageView.image = [UIImage imageWithData:data];
        } else {
            self.profileImageView.image = [UIImage imageNamed:DEFAULT_PROFILE_IMAGE_NAME];
        }
    }];
}

@end
