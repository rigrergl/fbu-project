//
//  InviteeCollectionViewCell.m
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/21/21.
//

#import "InviteeCollectionViewCell.h"
#import "StylingConstants.h"
#import "DictionaryConstants.h"
#import "CommonFunctions.h"

@implementation InviteeCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setupGestures];
}

- (void)setupGestures {
    UITapGestureRecognizer *profileImageTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapProfileImage:)];
    [self.profileImageView addGestureRecognizer:profileImageTapGestureRecognizer];
    [self.profileImageView setUserInteractionEnabled:YES];
}

- (void)didTapProfileImage:(UITapGestureRecognizer *_Nonnull)sender {
    if (self.didTapProfileImage) {
        self.didTapProfileImage(self);
    }
}

- (IBAction)didTapDelete:(UIButton *)sender {
    if (!self.canRemove) {
        return;
    } else if (self.removeInvitee) {
        self.removeInvitee(self);
    }
}

- (void)setCell:(PFUser *_Nonnull)user
      canRemove:(BOOL)canRemove {
    if (!user) {
        return;
    }
    self.user = user;
    
    self.canRemove = canRemove;
    if (canRemove) {
        enableButton(self.removeButton);
    } else {
        disableButton(self.removeButton);
    }
    
    self.profileImageView.image = [UIImage imageNamed:DEFAULT_PROFILE_IMAGE_NAME];
    
    [user fetchIfNeededInBackgroundWithBlock:^(PFObject *_Nullable object, NSError *_Nullable error){
        if (object) {
            PFUser *user = (PFUser *)object;
            [user[PROFILE_IMAGE_KEY] getDataInBackgroundWithBlock:^(NSData *_Nullable data, NSError *_Nullable error) {
                if (data) {
                    self.profileImageView.image = [UIImage imageWithData:data];
                } else {
                    self.profileImageView.image = [UIImage imageNamed:DEFAULT_PROFILE_IMAGE_NAME];
                }
            }];
        }
    }];
}

@end
