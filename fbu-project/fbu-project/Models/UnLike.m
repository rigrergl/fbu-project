//
//  UnLike.m
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/13/21.
//

#import "UnLike.h"
#import "Like.h"
#import "DictionaryConstants.h"

@implementation UnLike

+ (nonnull NSString *)parseClassName {
    return UNLIKE_CLASS_NAME;
}

+ (void)postUnLikeFrom:(PFUser *_Nonnull)originUser
                    to:(PFUser *_Nonnull)destinationUser
            completion:(PFBooleanResultBlock _Nullable)completion {
    
    UnLike *newUnLike = [UnLike new];
    newUnLike.originUser = originUser;
    newUnLike.destinationUser = destinationUser;
    
    [UnLike postUnLikeIfNew:newUnLike completion:completion];
    [Like removeLikeFrom:originUser to:destinationUser completion:nil];
}

+ (void)postUnLikeIfNew:(UnLike *)newUnLike
             completion:(PFBooleanResultBlock _Nullable)completion {
    PFQuery *unLikeQuery = [PFQuery queryWithClassName:[UnLike parseClassName]];
    [unLikeQuery whereKey:ORIGIN_USER_KEY equalTo:newUnLike.originUser];
    [unLikeQuery whereKey:DESTINATION_USER_KEY equalTo:newUnLike.destinationUser];
    
    [unLikeQuery findObjectsInBackgroundWithBlock:^(NSArray *_Nullable unLikes, NSError *_Nullable error){
        if (!error && unLikes && unLikes.count == 0) {
            [newUnLike saveInBackgroundWithBlock:completion];
        }
    }];
}

+ (void)removeUnLikeFrom:(PFUser *_Nonnull)originUser
                      to:(PFUser *_Nonnull)destinationUser
              completion:(PFBooleanResultBlock _Nullable)completion {
    PFQuery *unlikeQuery = [PFQuery queryWithClassName:[UnLike parseClassName]];
    [unlikeQuery whereKey:ORIGIN_USER_KEY equalTo:originUser];
    [unlikeQuery whereKey:DESTINATION_USER_KEY equalTo:destinationUser];
    
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
