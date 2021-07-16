//
//  ChatViewController.h
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/14/21.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "Match.h"

NS_ASSUME_NONNULL_BEGIN

@interface ChatViewController : UIViewController

@property (nonatomic, strong) Match *_Nonnull match;

@end

NS_ASSUME_NONNULL_END
