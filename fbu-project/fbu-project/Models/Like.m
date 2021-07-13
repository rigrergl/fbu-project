//
//  Like.m
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/13/21.
//

#import "Like.h"

@implementation Like

+ (nonnull NSString *)parseClassName {
    return @"Like";
}

+ (void)postLikeFrom:(PFUser *_Nonnull)originUser to:(PFUser *_Nonnull)destinationUser withCompletion:(PFBooleanResultBlock _Nullable)completion {
    Like *newLike = [Like new];
    newLike.originUser = originUser;
    newLike.destinationUser = destinationUser;
    
    [newLike saveInBackgroundWithBlock:completion];
}

@end
