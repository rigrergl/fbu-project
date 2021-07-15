//
//  DirectMessage.h
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/15/21.
//

#import <Parse/Parse.h>
#import "Match.h"

NS_ASSUME_NONNULL_BEGIN

@interface DirectMessage : PFObject<PFSubclassing>

@property (strong, nonatomic) PFUser *author;
@property (strong, nonatomic) Match *match;
@property (strong, nonatomic) NSString *content;

+ (void)postMessageWithContent:(NSString *)content
                       inMatch: (Match *_Nonnull)match
                withCompletion:(PFBooleanResultBlock _Nullable)completion;

@end

NS_ASSUME_NONNULL_END
