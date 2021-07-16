//
//  CommonQueries.m
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/14/21.
//

#import "CommonQueries.h"
#import "Match.h"

#import <Parse/Parse.h>

void MatchingUsers( void (^completion)(NSArray *_Nullable matchedUsers, NSArray *_Nullable matches,
                                       NSError *_Nullable error) ){
    if ([PFUser currentUser] == nil) {
        NSError *error = [NSError errorWithDomain:@"com.eezytutorials.iosTuts"
                                             code:200
                                         userInfo:@{@"Error reason": @"Invalid Input"}];
        completion(nil, nil, error);
        return;
    }
    
    PFQuery *matchQuery = [PFQuery queryWithClassName:@"Match"];
    [matchQuery whereKey:@"users" containsAllObjectsInArray:@[[PFUser currentUser]]];
    [matchQuery includeKey:@"users"];
    
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
