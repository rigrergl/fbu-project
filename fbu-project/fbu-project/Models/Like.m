//
//  Like.m
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/13/21.
//

#import "Like.h"
#import "UnLike.h"
#import "Match.h"

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
    [UnLike removeUnLikeFrom:originUser to:destinationUser withCompletion:nil];
}

+ (void)postLikeIfNew:(Like *)newLike
       withCompletion:(PFBooleanResultBlock _Nullable)completion {
    PFQuery *likeQuery = [PFQuery queryWithClassName:@"Like"];
    [likeQuery whereKey:@"originUser" equalTo:newLike.originUser];
    [likeQuery whereKey:@"destinationUser" equalTo:newLike.destinationUser];
    
    [likeQuery findObjectsInBackgroundWithBlock:^(NSArray *_Nullable likes, NSError *_Nullable error){
        if (!error && likes && likes.count == 0) {
            [newLike saveInBackgroundWithBlock:completion];
            [Like makeMatchIfApplicable:newLike];
        }
    }];
}

+ (void)makeMatchIfApplicable:(Like *)newLike {
    //check if reverse like exists
    PFQuery *likeQuery = [PFQuery queryWithClassName:@"Like"];
    [likeQuery whereKey:@"originUser" equalTo:newLike.destinationUser];
    [likeQuery whereKey:@"destinationUser" equalTo:newLike.originUser];
    
    [likeQuery findObjectsInBackgroundWithBlock:^(NSArray *_Nullable likes, NSError *_Nullable error){
        if (!error && likes.count == 1) {
            //make new Match
            [Match postMatchBetween:newLike.originUser andUser:newLike.destinationUser withCompletion:nil];
        }
    }];
}

+ (void)removeLikeFrom:(PFUser *_Nonnull)originUser
                    to:(PFUser *_Nonnull)destinationUser
        withCompletion:(PFBooleanResultBlock _Nullable)completion {
    PFQuery *Like = [PFQuery queryWithClassName:@"Like"];
    [Like whereKey:@"originUser" equalTo:originUser];
    [Like whereKey:@"destinationUser" equalTo:destinationUser];
    
    [Like findObjectsInBackgroundWithBlock:^(NSArray *_Nullable likes, NSError *_Nullable error){
        if (likes) {
            [PFObject deleteAllInBackground:likes block:^(BOOL succeeded, NSError *_Nullable error){
                if (completion) {
                    completion(succeeded, error);
                }
            }];
        }
    }];
}

@end
