//
//  ConversationCollectionViewCell.h
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/15/21.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "Match.h"

NS_ASSUME_NONNULL_BEGIN

@interface ConversationCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *latestMessageLabel;

- (void)setCellWithUser:(PFUser *)user
               andMatch:(Match *)match;

@end

NS_ASSUME_NONNULL_END
