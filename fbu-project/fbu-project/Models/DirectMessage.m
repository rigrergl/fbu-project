//
//  DirectMessage.m
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/15/21.
//

#import "DirectMessage.h"

@implementation DirectMessage

+ (nonnull NSString *)parseClassName {
    return @"DirectMessage";
}

+ (void)postMessageWithContent:(NSString *)content
            inMatch: (Match *_Nonnull)match
     withCompletion:(void(^)(BOOL succeeded, DirectMessage *_Nullable newMessage, NSError *_Nullable error))completion {
    DirectMessage *newMessage = [DirectMessage new];
    newMessage.author = [PFUser currentUser];
    newMessage.match = match;
    newMessage.content = content;
    
    [newMessage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *_Nullable error){
        completion(succeeded, newMessage, error);
    }];
}


@end
