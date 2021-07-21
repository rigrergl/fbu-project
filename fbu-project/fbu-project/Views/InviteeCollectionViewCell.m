//
//  InviteeCollectionViewCell.m
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/21/21.
//

#import "InviteeCollectionViewCell.h"
#import "StylingConstants.h"
#import "DictionaryConstants.h"

@implementation InviteeCollectionViewCell

- (IBAction)didTapDelete:(UIButton *)sender {
    if (!self.canRemove) {
        return;
    } else if (self.removeInvitee) {
        self.removeInvitee(self);
    }
}

- (void)setCell:(PFUser *_Nonnull)user
      canRemove:(BOOL)canRemove {
    self.canRemove = canRemove;
    if (canRemove) {
        [self enableRemoveButton];
    } else {
        [self disableRemoveButton];
    }
    
    self.profileImageView.image = [UIImage imageNamed:DEFAULT_PROFILE_IMAGE_NAME];
    [user[PROFILE_IMAGE_KEY] getDataInBackgroundWithBlock:^(NSData *_Nullable data, NSError *_Nullable error) {
        if (data) {
            self.profileImageView.image = [UIImage imageWithData:data];
        } else {
            self.profileImageView.image = [UIImage imageNamed:DEFAULT_PROFILE_IMAGE_NAME];
        }
    }];
}

- (void)disableRemoveButton {
    self.removeButton.enabled = NO;
    self.removeButton.alpha = 0;
}

- (void)enableRemoveButton {
    self.removeButton.enabled = YES;
    self.removeButton.alpha = 1;
}


@end
