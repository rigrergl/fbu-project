//
//  Match.h
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/14/21.
//

#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface Match : PFObject<PFSubclassing>

@property (nonatomic, strong) NSArray *_Nonnull users;
@property (nonatomic, assign) BOOL hasConversationStarted;

+ (void)postMatchBetween:(PFUser *)user1
                 andUser:(PFUser *)user2
              completion:(PFBooleanResultBlock _Nullable)completion;

@end

NS_ASSUME_NONNULL_END
