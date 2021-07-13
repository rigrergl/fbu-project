//
//  Like.h
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/13/21.
//

#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface Like : PFObject<PFSubclassing>

@property (nonatomic, strong) PFUser *_Nonnull originUser;
@property (nonatomic, strong) PFUser *_Nonnull destinationUser;

+ (void)postLikeFrom:(PFUser *_Nonnull)originUser
                  to:(PFUser *_Nonnull)destinationUser
      withCompletion:(PFBooleanResultBlock  _Nullable)completion;

@end

NS_ASSUME_NONNULL_END
