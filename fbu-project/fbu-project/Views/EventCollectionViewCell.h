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

@property (copy, nonatomic, nullable) void (^acceptInvite)(EventCollectionViewCell *_Nonnull cell);
@property (copy, nonatomic, nullable) void (^segueToChat)(EventCollectionViewCell *_Nonnull cell);
@property (copy, nonatomic, nullable) void (^segueToInfo)(EventCollectionViewCell *_Nonnull cell);
@property (strong, nonatomic) Event *_Nonnull event;
- (void)setCell:(Event *_Nonnull)event;

@end

NS_ASSUME_NONNULL_END
