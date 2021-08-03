//
//  DirectMessage.m
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/15/21.
//

#import "DirectMessage.h"
#import "DictionaryConstants.h"

@implementation DirectMessage

+ (nonnull NSString *)parseClassName {
    return DIRECT_MESSAGE_CLASS_NAME;
}

+ (void)postMessageWithContent:(NSString *)content
                         match: (Match *_Nullable)match
                         event:(Event *_Nullable)event
                    completion:(DirectMessageReturnBlock _Nullable)completion {
    
    DirectMessage *newMessage = [DirectMessage new];
    newMessage.author = [PFUser currentUser];
    newMessage.match = match;
    newMessage.event = event;
    newMessage.content = content;
    newMessage.likes = 0;
    
    [newMessage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *_Nullable error){
        if (completion) {
            completion(succeeded, newMessage, error);
        }
    }];
    
    if (match) {
        match.hasConversationStarted = true;
        [match saveInBackground];
    }
}

- (void)userDidLike:(PFUser *_Nonnull)user {
    if (!user) {
        return;
    }
    
    if (!self.usersLiked) {
        self.usersLiked = [NSMutableArray new];
    }
    
    NSMutableArray *usersLikedMutableCopy = [self.usersLiked mutableCopy];
    BOOL hasUserLikedMessage = [usersLikedMutableCopy containsParseObjectWithId:user];
    
    if (hasUserLikedMessage) {
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(PFUser *_Nullable currentUser, NSDictionary *_Nullable bindings) {
            if (!user) {
                return NO;
            }
            return ![currentUser.objectId isEqualToString:user.objectId];
        }];
        usersLikedMutableCopy = [usersLikedMutableCopy filteredArrayUsingPredicate:predicate];
    } else {
        [usersLikedMutableCopy addObject:user];
    }
    
    self.usersLiked = usersLikedMutableCopy;
    self.likes = self.usersLiked.count;
    [self setValue:self.usersLiked forKey:DIRECT_MESSAGE_USERS_LIKED_KEY];
    [self saveInBackground];
}

@end
