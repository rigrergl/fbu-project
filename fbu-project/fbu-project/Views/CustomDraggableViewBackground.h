//
//  CustomDraggableViewBackground.h
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/13/21.
//

#import "DraggableViewBackground.h"

NS_ASSUME_NONNULL_BEGIN

@interface CustomDraggableViewBackground : DraggableViewBackground

@property (retain,nonatomic)NSArray *_Nonnull users;

- (id)initWithFrame:(CGRect)frame
           andUsers:(NSArray *)users;

@end

NS_ASSUME_NONNULL_END
