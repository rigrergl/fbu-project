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

@property (strong, nonatomic) IBOutlet UILabel *_Nonnull contentLabel;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *_Nonnull wrappingViewWidth;
@property (strong, nonatomic) IBOutlet UIView *_Nonnull mainView;

- (void)setCellWithDirectMessage:(DirectMessage *)message;

@end

NS_ASSUME_NONNULL_END
