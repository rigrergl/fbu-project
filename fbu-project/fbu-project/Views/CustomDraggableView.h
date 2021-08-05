//
//  CustomDraggableView.h
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/13/21.
//

#import "DraggableView.h"

NS_ASSUME_NONNULL_BEGIN

@interface CustomDraggableView : DraggableView

@property (nonatomic, copy, nonnull) void (^segueToProfile)(PFUser *_Nonnull user);
@property (nonatomic, strong) UIButton *_Nonnull infoButton;
@property (nonatomic, strong) UILabel *_Nonnull usernameLabel;
@property (nonatomic, strong) UIButton *_Nonnull playButton;

- (id)initWithFrame:(CGRect)frame
               user:(PFUser *)user
     segueToProfile:(void (^_Nonnull)(PFUser *_Nonnull user))segueToProfile;

@end

NS_ASSUME_NONNULL_END
