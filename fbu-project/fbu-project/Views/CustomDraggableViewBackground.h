//
//  CustomDraggableViewBackground.h
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/13/21.
//

#import "DraggableViewBackground.h"

NS_ASSUME_NONNULL_BEGIN

@interface CustomDraggableViewBackground : DraggableViewBackground

@property (nonatomic, copy, nonnull) void (^segueToProfile)(PFUser *_Nonnull user);
@property (retain,nonatomic) NSArray *_Nonnull users;

- (id)initWithFrame:(CGRect)frame
              users:(NSArray *)users
     segueToProfile:(void(^_Nonnull)(PFUser *_Nonnull user))segueToProfile;

@end

NS_ASSUME_NONNULL_END
