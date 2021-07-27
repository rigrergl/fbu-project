//
//  AddLikedGenreViewController.h
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/18/21.
//

#import <UIKit/UIKit.h>
#import "LikedGenre.h"
#import "LikedInstrument.h"

NS_ASSUME_NONNULL_BEGIN

@interface AddLikedGenreViewController : UIViewController

@property (copy, nonatomic) void (^_Nullable didAddLikedGenre)(LikedGenre *_Nullable newLikedGenre);
@property (copy, nonatomic) void (^_Nullable didAddLikedInstrument)(LikedInstrument *_Nullable newLikedInstrument);

@end

NS_ASSUME_NONNULL_END
