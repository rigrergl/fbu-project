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
    [Like removeUnlikeFrom:originUser to:destinationUser];
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
            [Match postMatchBetween:newLike.originUser andUser:newLike.destinationUser withCompletion:^(BOOL succeeded, NSError *_Nullable error){
                if (error) {
                    NSLog(@"Error posting new match: %@", error.localizedDescription);
                } 
            }];
        } else if (error) {
            NSLog(@"Error posting match: %@", error.localizedDescription);
        } else if (likes.count > 1) {
            NSLog(@"Found inconsistency in database: duplicate likes. Fix bug and wipe database");
        }
    }];
}

+ (void)removeUnlikeFrom:(PFUser *_Nonnull)originUser
                      to:(PFUser *_Nonnull)destinationUser {
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
