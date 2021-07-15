//
//  MessageCollectionViewCell.h
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/14/21.
//

#import <UIKit/UIKit.h>
#import "DirectMessage.h"

NS_ASSUME_NONNULL_BEGIN

@interface MessageCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *contentLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *wrappingViewWidth;

- (void)setCellWithDirectMessage:(DirectMessage *)message;

@property (weak, nonatomic) IBOutlet UIView *mainView;

@end

NS_ASSUME_NONNULL_END
