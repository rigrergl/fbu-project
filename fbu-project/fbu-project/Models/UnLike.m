//
//  UnLike.m
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/13/21.
//

#import "UnLike.h"

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
    [UnLike removeLikeFrom:originUser to:destinationUser];
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

+ (void)removeLikeFrom:(PFUser *_Nonnull)originUser
                    to:(PFUser *_Nonnull)destinationUser {
    PFQuery *Like = [PFQuery queryWithClassName:@"Like"];
    [Like whereKey:@"originUser" equalTo:originUser];
    [Like whereKey:@"destinationUser" equalTo:destinationUser];
    
    [Like findObjectsInBackgroundWithBlock:^(NSArray *_Nullable likes, NSError *_Nullable error){
        if (likes) {
            [PFObject deleteAllInBackground:likes block:^(BOOL succeeded, NSError *_Nullable error){
                if (error) {
                    NSLog(@"Error deleting matching likes: %@", error.localizedDescription);
                }
            }];
        }
    }];
}

@end
