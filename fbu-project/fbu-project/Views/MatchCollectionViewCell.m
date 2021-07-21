//
//  MatchCollectionViewCell.m
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/14/21.
//

#import "MatchCollectionViewCell.h"
#import "DictionaryConstants.h"
#import "StylingConstants.h"

@implementation MatchCollectionViewCell


- (void)awakeFromNib {
    [super awakeFromNib];
    [self doStyling];
}

- (void)doStyling {
    //making profile image round
    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width / 2;
    self.profileImageView.clipsToBounds = YES;
}

- (void)setCellWithUser:(PFUser *)user {
    self.profileImageView.image = [UIImage imageNamed:DEFAULT_PROFILE_IMAGE_NAME];
    [user[PROFILE_IMAGE_KEY] getDataInBackgroundWithBlock:^(NSData *_Nullable data, NSError *_Nullable error) {
        if (!error) {
            self.profileImageView.image = [UIImage imageWithData:data];
        }
    }];
}

@end
