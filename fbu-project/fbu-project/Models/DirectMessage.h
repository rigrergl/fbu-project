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
@property (copy, nonatomic) NSString *content;

typedef void(^DirectMessageReturnBlock)(BOOL succeeded, DirectMessage *_Nullable newMessage, NSError *_Nullable error);

+ (void)postMessageWithContent:(NSString *)content
                       inMatch: (Match *_Nonnull)match
                    completion:(DirectMessageReturnBlock _Nullable)completion;

@end

NS_ASSUME_NONNULL_END
