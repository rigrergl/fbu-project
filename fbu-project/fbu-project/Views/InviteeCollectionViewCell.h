//
//  InviteeCollectionViewCell.h
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/21/21.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface InviteeCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (copy, nonatomic) void (^removeInvitee)(InviteeCollectionViewCell *_Nonnull cell);
@property (assign, nonatomic) BOOL canRemove;
@property (weak, nonatomic) IBOutlet UIButton *removeButton;

- (void)setCell:(PFUser *_Nonnull)user
      canRemove:(BOOL)canRemove;

@end

NS_ASSUME_NONNULL_END
