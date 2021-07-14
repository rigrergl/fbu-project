//
//  Match.h
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/14/21.
//

#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface Match : PFObject<PFSubclassing>

@property (nonatomic, strong) PFUser *_Nonnull user1;
@property (nonatomic, strong) PFUser *_Nonnull user2;

+ (void)postMatchBetween:(PFUser *)user1
                     and:(PFUser *)user2
withCompletion:(PFBooleanResultBlock _Nullable)completion ;

@end

NS_ASSUME_NONNULL_END
