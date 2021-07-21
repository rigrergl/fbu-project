//
//  Match.m
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/14/21.
//

#import "Match.h"
#import "DictionaryConstants.h"

@implementation Match

+ (NSString *)parseClassName {
    return MATCH_CLASS_NAME;
}

+ (void)postMatchBetween:(PFUser *)user1
                 andUser:(PFUser *)user2
              completion:(PFBooleanResultBlock _Nullable)completion {
    
    Match *newMatch = [Match new];
    NSArray *users = @[user1, user2];
    newMatch.users = users;
    newMatch.hasConversationStarted = NO;
    
    [newMatch saveInBackgroundWithBlock:completion];
}

@end
