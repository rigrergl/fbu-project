//
//  MatchCollectionViewCell.h
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/14/21.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface MatchCollectionViewCell : UICollectionViewCell


@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;

- (void)setCellWithUser:(PFUser *)user;

@end

NS_ASSUME_NONNULL_END
