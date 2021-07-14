//
//  Match.m
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/14/21.
//

#import "Match.h"

@implementation Match

+ (NSString *)parseClassName {
    return @"Match";
}

+ (void)postMatchBetween:(PFUser *)user1
                     and:(PFUser *)user2
          withCompletion:(PFBooleanResultBlock _Nullable)completion {
    
    Match *newMatch = [Match new];
    newMatch.user1 = user1;
    newMatch.user2 = user2;
    
    [newMatch saveInBackgroundWithBlock:completion];
}

@end
