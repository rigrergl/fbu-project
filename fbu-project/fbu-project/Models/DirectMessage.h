//
//  DirectMessage.h
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/15/21.
//

#import <Parse/Parse.h>
#import "Match.h"
#import "Event.h"

NS_ASSUME_NONNULL_BEGIN

@interface DirectMessage : PFObject<PFSubclassing>

@property (strong, nonatomic) PFUser *_Nonnull author;
@property (strong, nonatomic) Match *_Nullable match;
@property (strong, nonatomic) Event *_Nullable event;
@property (copy, nonatomic) NSString *_Nonnull content;

typedef void(^DirectMessageReturnBlock)(BOOL succeeded, DirectMessage *_Nullable newMessage, NSError *_Nullable error);

+ (void)postMessageWithContent:(NSString *)content
                         match: (Match *_Nullable)match
                         event:(Event *_Nullable)event
                    completion:(DirectMessageReturnBlock _Nullable)completion;

@end

NS_ASSUME_NONNULL_END
