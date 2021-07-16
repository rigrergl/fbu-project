//
//  UnLike.m
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/13/21.
//

#import "UnLike.h"
#import "Like.h"

@implementation UnLike

+ (nonnull NSString *)parseClassName {
    return @"UnLike";
}

+ (void)postUnLikeFrom:(PFUser *_Nonnull)originUser
                  to:(PFUser *_Nonnull)destinationUser
      withCompletion:(PFBooleanResultBlock _Nullable)completion {
    
    UnLike *newUnLike = [UnLike new];
    newUnLike.originUser = originUser;
    newUnLike.destinationUser = destinationUser;
    
    [UnLike postUnLikeIfNew:newUnLike withCompletion:completion];
    [Like removeLikeFrom:originUser to:destinationUser withCompletion:nil];
}

+ (void)postUnLikeIfNew:(UnLike *)newUnLike
         withCompletion:(PFBooleanResultBlock _Nullable)completion {
    PFQuery *unLikeQuery = [PFQuery queryWithClassName:@"UnLike"];
    [unLikeQuery whereKey:@"originUser" equalTo:newUnLike.originUser];
    [unLikeQuery whereKey:@"destinationUser" equalTo:newUnLike.destinationUser];
    
    [unLikeQuery findObjectsInBackgroundWithBlock:^(NSArray *_Nullable unLikes, NSError *_Nullable error){
        if (!error && unLikes && unLikes.count == 0) {
            [newUnLike saveInBackgroundWithBlock:completion];
        }
    }];
}

+ (void)removeUnLikeFrom:(PFUser *_Nonnull)originUser
                      to:(PFUser *_Nonnull)destinationUser
          withCompletion:(PFBooleanResultBlock _Nullable)completion {
    PFQuery *unlikeQuery = [PFQuery queryWithClassName:@"UnLike"];
    [unlikeQuery whereKey:@"originUser" equalTo:originUser];
    [unlikeQuery whereKey:@"destinationUser" equalTo:destinationUser];
    
    [unlikeQuery findObjectsInBackgroundWithBlock:^(NSArray *_Nullable unlikes, NSError *_Nullable error){
        if (unlikes) {
            [PFObject deleteAllInBackground:unlikes block:^(BOOL succeeded, NSError *_Nullable error){
                if (completion) {
                    completion(succeeded, error);
                }
            }];
        }
    }];
}


@end
