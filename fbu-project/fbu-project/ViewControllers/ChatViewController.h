//
//  ChatViewController.h
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/14/21.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "Match.h"
#import "Event.h"

NS_ASSUME_NONNULL_BEGIN

@interface ChatViewController : UIViewController

@property (nonatomic, strong) Match *_Nonnull match;
@property (nonatomic, strong) Event *_Nonnull event;

@end

NS_ASSUME_NONNULL_END
