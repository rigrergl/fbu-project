//
//  Like.m
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/13/21.
//

#import "Like.h"
#import "UnLike.h"
#import "Match.h"
#import "DictionaryConstants.h"

@implementation Like

+ (nonnull NSString *)parseClassName {
    return LIKE_CLASS_NAME;
}

+ (void)postLikeFrom:(PFUser *_Nonnull)originUser
                  to:(PFUser *_Nonnull)destinationUser
          completion:(PFBooleanResultBlock _Nullable)completion {
    
    Like *newLike = [Like new];
    newLike.originUser = originUser;
    newLike.destinationUser = destinationUser;
    
    [Like postLikeIfNew:newLike completion:completion];
    [UnLike removeUnLikeFrom:originUser to:destinationUser completion:nil];
}

+ (void)postLikeIfNew:(Like *)newLike
           completion:(PFBooleanResultBlock _Nullable)completion {
    PFQuery *likeQuery = [PFQuery queryWithClassName:[Like parseClassName]];
    [likeQuery whereKey:ORIGIN_USER_KEY equalTo:newLike.originUser];
    [likeQuery whereKey:DESTINATION_USER_KEY equalTo:newLike.destinationUser];
    
    [likeQuery findObjectsInBackgroundWithBlock:^(NSArray *_Nullable likes, NSError *_Nullable error){
        if (!error && likes && likes.count == 0) {
            [newLike saveInBackgroundWithBlock:completion];
            [Like makeMatchIfApplicable:newLike];
        } else {
            completion(NO, error);
        }
    }];
}

+ (void)makeMatchIfApplicable:(Like *)newLike {
    //check if reverse like exists
    PFQuery *likeQuery = [PFQuery queryWithClassName:[Like parseClassName]];
    [likeQuery whereKey:ORIGIN_USER_KEY equalTo:newLike.destinationUser];
    [likeQuery whereKey:DESTINATION_USER_KEY equalTo:newLike.originUser];
    
    [likeQuery findObjectsInBackgroundWithBlock:^(NSArray *_Nullable likes, NSError *_Nullable error){
        if (!error && likes.count == 1) {
            //make new Match
            [Match postMatchBetween:newLike.originUser andUser:newLike.destinationUser completion:nil];
        }
    }];
}

+ (void)removeLikeFrom:(PFUser *_Nonnull)originUser
                    to:(PFUser *_Nonnull)destinationUser
            completion:(PFBooleanResultBlock _Nullable)completion {
    PFQuery *likeQuery = [PFQuery queryWithClassName:[Like parseClassName]];
    [likeQuery whereKey:ORIGIN_USER_KEY equalTo:originUser];
    [likeQuery whereKey:DESTINATION_USER_KEY equalTo:destinationUser];
    
    [likeQuery findObjectsInBackgroundWithBlock:^(NSArray *_Nullable likes, NSError *_Nullable error){
        if (likes) {
            [PFObject deleteAllInBackground:likes block:^(BOOL succeeded, NSError *_Nullable error){
                if (completion) {
                    completion(succeeded, error);
                }
            }];
        } else if (completion) {
            completion(NO, error);
        }
    }];
}

@end
