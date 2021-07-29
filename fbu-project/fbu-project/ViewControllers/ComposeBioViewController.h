//
//  ComposeBioViewController.h
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/29/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ComposeBioViewController : UIViewController

@property (nonatomic, copy, nonnull) void (^didChangeBio)(NSString *_Nonnull newBio);

@end

NS_ASSUME_NONNULL_END
