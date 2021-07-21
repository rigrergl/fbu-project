//
//  AddInviteeCollectionViewCell.h
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/21/21.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface AddInviteeCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;

- (void)setCell:(PFUser *_Nonnull)user;

@end

NS_ASSUME_NONNULL_END
