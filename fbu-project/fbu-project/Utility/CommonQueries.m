//
//  CommonQueries.m
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/14/21.
//

#import "CommonQueries.h"

#import <Parse/Parse.h>

void MatchingUsers( void (^completion)(NSArray *_Nullable matchedUsers, NSError *_Nullable error) ){
    PFQuery *likedUsersQuery = [PFQuery queryWithClassName:@"Like"];
    [likedUsersQuery whereKey:@"originUser" equalTo: [PFUser currentUser].objectId];

    [likedUsersQuery findObjectsInBackgroundWithBlock:^(NSArray *_Nullable likedUsers, NSError *_Nullable error){
        completion(likedUsers, nil);
    }];
}
