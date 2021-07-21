//
//  CommonQueries.h
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/14/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^MatchingUsersReturnBlock)(NSArray *_Nullable matchedUsers,
                                        NSArray *_Nullable matches,
                                        NSError *_Nullable error);

extern void MatchingUsers(MatchingUsersReturnBlock _Nullable completion);


NS_ASSUME_NONNULL_END
