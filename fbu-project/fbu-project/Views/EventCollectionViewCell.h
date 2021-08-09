//
//  EventCollectionViewCell.h
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/21/21.
//

#import <UIKit/UIKit.h>
#import "Event.h"

NS_ASSUME_NONNULL_BEGIN

@interface EventCollectionViewCell : UICollectionViewCell

typedef void (^EventCellBlock)(EventCollectionViewCell *_Nonnull cell);

//properties
@property (copy, nonatomic, nullable) void (^presentAlert)(UIAlertController *_Nonnull alert);
@property (copy, nonatomic, nullable) void (^acceptInvite)(EventCollectionViewCell *_Nonnull cell);
@property (copy, nonatomic, nullable) void (^segueToChat)(EventCollectionViewCell *_Nonnull cell);
@property (copy, nonatomic, nullable) void (^segueToInfo)(EventCollectionViewCell *_Nonnull cell);
@property (strong, nonatomic) Event *_Nonnull event;

//methods
- (void)setCellForAttending:(Event *_Nonnull)event
                segueToChat:(EventCellBlock _Nonnull)segueToChat;
- (void)setCellForInvited:(Event *_Nonnull)event
             acceptInvite:(EventCellBlock _Nonnull)acceptInvite;

@end

NS_ASSUME_NONNULL_END
