//
//  LikedGenre.h
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/18/21.
//

#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface LikedGenre : PFObject<PFSubclassing>

@property (nonatomic, strong) PFUser *_Nonnull user;
@property (nonatomic, copy) NSString *_Nonnull title;

typedef void(^LikedGenreReturnBlock)(LikedGenre *_Nullable newLikedGenre, NSError *_Nullable error);

+ (void)postLikedGenre:(NSString *)title
               forUser:(PFUser *)user
            completion:(LikedGenreReturnBlock _Nullable)completion;

+ (void)deleteLikedGenre:(LikedGenre *)likedGenre
              completion:(PFBooleanResultBlock _Nullable)completion;

@end

NS_ASSUME_NONNULL_END
