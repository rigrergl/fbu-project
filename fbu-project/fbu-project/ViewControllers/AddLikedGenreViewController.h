//
//  AddLikedGenreViewController.h
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/18/21.
//

#import <UIKit/UIKit.h>
#import "LikedGenre.h"

NS_ASSUME_NONNULL_BEGIN

@interface AddLikedGenreViewController : UIViewController

@property (copy, nonatomic) void (^didAddLikedGenre)(LikedGenre *newLikedGenre);

@end

NS_ASSUME_NONNULL_END
