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
@property (weak, nonatomic) IBOutlet UIView *bubbleView;
@property (weak, nonatomic) IBOutlet UIView *likesView;
@property (weak, nonatomic) IBOutlet UILabel *likesCountLabel;
@property (strong, nonatomic) DirectMessage *_Nonnull message;

- (void)setCellWithDirectMessage:(DirectMessage *)message;

@end

NS_ASSUME_NONNULL_END
