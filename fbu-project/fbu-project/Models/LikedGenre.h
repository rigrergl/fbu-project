//
//  LikedGenre.h
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/18/21.
//

#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface LikedGenre : PFObject<PFSubclassing>

@property (nonatomic, strong) PFUser *user;
@property (nonatomic, strong) NSString *title;

+ (void)postLikedGenre:(NSString *)title
               forUser:(PFUser *)user
        withCompletion:(void(^)(LikedGenre *_Nullable newLikedGenre, NSError *error))completion;

+ (void)deleteLikedGenre:(LikedGenre *)likedGenre
          withCompletion:(void(^)(BOOL suceeded, NSError *_Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
