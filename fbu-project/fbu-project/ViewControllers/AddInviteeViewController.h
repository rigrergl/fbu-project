//
//  AddInviteeViewController.h
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/21/21.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface AddInviteeViewController : UIViewController

@property (copy, nonatomic) void (^addInvitee)(PFUser *_Nonnull newInvitee);

@end

NS_ASSUME_NONNULL_END
