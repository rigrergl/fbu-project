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
                       inMatch: (Match *_Nonnull)match
                    completion:(DirectMessageReturnBlock _Nullable)completion {
    DirectMessage *newMessage = [DirectMessage new];
    newMessage.author = [PFUser currentUser];
    newMessage.match = match;
    newMessage.content = content;
    
    [newMessage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *_Nullable error){
        if (completion) {
            completion(succeeded, newMessage, error);
        }
    }];
    
    match.hasConversationStarted = true;
    [match saveInBackground];
}


@end
