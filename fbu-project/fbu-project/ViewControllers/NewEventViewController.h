//
//  NewEventViewController.h
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/21/21.
//

#import <UIKit/UIKit.h>
#import "Event.h"

NS_ASSUME_NONNULL_BEGIN

@interface NewEventViewController : UIViewController

@property (nonatomic, strong) Event *event;
- (void)setEvent:(Event * _Nonnull)event;

@end

NS_ASSUME_NONNULL_END
