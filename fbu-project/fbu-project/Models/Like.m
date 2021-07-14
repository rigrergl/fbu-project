//
//  Like.m
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/13/21.
//

#import "Like.h"
#import "UnLike.h"

@implementation Like

+ (nonnull NSString *)parseClassName {
    return @"Like";
}

+ (void)postLikeFrom:(PFUser *_Nonnull)originUser
                  to:(PFUser *_Nonnull)destinationUser
      withCompletion:(PFBooleanResultBlock _Nullable)completion {
    
    Like *newLike = [Like new];
    newLike.originUser = originUser;
    newLike.destinationUser = destinationUser;
    
    [Like postLikeIfNew:newLike withCompletion:completion];
    [Like removeUnlikeFrom:originUser to:destinationUser];
}

+ (void)postLikeIfNew:(Like *)newLike withCompletion:(PFBooleanResultBlock _Nullable)completion {
    PFQuery *likeQuery = [PFQuery queryWithClassName:@"Like"];
    [likeQuery whereKey:@"originUser" equalTo:newLike.originUser];
    [likeQuery whereKey:@"destinationUser" equalTo:newLike.destinationUser];
    
    [likeQuery findObjectsInBackgroundWithBlock:^(NSArray *_Nullable likes, NSError *_Nullable error){
        if (!error && likes && likes.count == 0) {
            [newLike saveInBackgroundWithBlock:completion];
        }
    }];
}

+ (void)removeUnlikeFrom:(PFUser *_Nonnull)originUser to:(PFUser *_Nonnull)destinationUser {
    PFQuery *unlikeQuery = [PFQuery queryWithClassName:@"UnLike"];
    [unlikeQuery whereKey:@"originUser" equalTo:originUser];
    [unlikeQuery whereKey:@"destinationUser" equalTo:destinationUser];
    
    [unlikeQuery findObjectsInBackgroundWithBlock:^(NSArray *_Nullable unlikes, NSError *_Nullable error){
        if (unlikes) {
            [PFObject deleteAllInBackground:unlikes block:^(BOOL succeeded, NSError *_Nullable error){
                if (error) {
                    NSLog(@"Error deleting matching unlikes: %@", error.localizedDescription);
                }
            }];
        }
    }];
}

@end
