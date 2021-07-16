//
//  UnLike.h
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/13/21.
//

#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface UnLike : PFObject<PFSubclassing>

@property (nonatomic, strong) PFUser *_Nonnull originUser;
@property (nonatomic, strong) PFUser *_Nonnull destinationUser;

+ (void)postUnLikeFrom:(PFUser *_Nonnull)originUser
                  to:(PFUser *_Nonnull)destinationUser
      withCompletion:(PFBooleanResultBlock  _Nullable)completion;

+ (void)removeUnLikeFrom:(PFUser *_Nonnull)originUser
                      to:(PFUser *_Nonnull)destinationUser
          withCompletion:(PFBooleanResultBlock _Nullable)completion;

@end

NS_ASSUME_NONNULL_END
