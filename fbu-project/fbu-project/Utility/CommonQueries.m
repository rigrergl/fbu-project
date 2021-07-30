//
//  CommonQueries.m
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/14/21.
//

#import "CommonQueries.h"
#import "Match.h"
#import "DictionaryConstants.h"
#import <Parse/Parse.h>

void MatchingUsers(MatchingUsersReturnBlock _Nullable completion){
    if ([PFUser currentUser] == nil) {
        NSError *error = [NSError errorWithDomain:@""
                                             code:200
                                         userInfo:@{@"Error reason": @"Invalid Input"}];
        if (completion) {
            completion(nil, nil, error);
        }
        return;
    }
    
    PFQuery *matchQuery = [PFQuery queryWithClassName:[Match parseClassName]];
    [matchQuery whereKey:MATCH_USERS_KEY containsAllObjectsInArray:@[[PFUser currentUser]]];
    [matchQuery includeKey:MATCH_USERS_KEY];
    
    [matchQuery findObjectsInBackgroundWithBlock:^(NSArray *_Nullable matches, NSError *_Nullable error){
        NSMutableArray *matchedUsers = [[NSMutableArray alloc] initWithCapacity:matches.count];
        for (Match *match in matches) {
            NSArray *usersInMatch = match.users;
            PFUser *user1 = usersInMatch[0];
            PFUser *user2 = usersInMatch[1];
            if ([user1.objectId isEqualToString: [PFUser currentUser].objectId]) {
                [matchedUsers addObject:user2];
            } else {
                [matchedUsers addObject:user1];
            }
        }
        
        if (completion) {
            completion(matchedUsers, matches, nil);
        }
    }];
}
