//
//  CustomDraggableView.h
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/13/21.
//

#import "DraggableView.h"

NS_ASSUME_NONNULL_BEGIN

@interface CustomDraggableView : DraggableView

@property (nonatomic, strong) UILabel *_Nonnull usernameLabel;
@property (nonatomic, strong) UIButton *_Nonnull playButton;

- (id)initWithFrame:(CGRect)frame
            andUser:(PFUser *)user;

@end

NS_ASSUME_NONNULL_END
