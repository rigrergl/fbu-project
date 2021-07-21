//
//  MessagePoller.m
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/21/21.
//

#import "MessagePoller.h"
#import "DirectMessage.h"
#import "DictionaryConstants.h"
#import <Parse/Parse.h>

@interface MessagePoller ()

@property (nonatomic, weak) Match *_Nullable match;
@property (nonatomic, weak) Event *_Nullable event;
@property (nonatomic, copy) NSDate *_Nullable dateOfLastLoadedMessage;


@end

@implementation MessagePoller {
    BOOL continuePolling;
}

NSString * const NEW_MESSAGE_NOTIFICATION_NAME = @"NewMessageNotification";
static const float POLL_INTERVAL_SEC = 5;

+ (instancetype)shared {
    static MessagePoller *sharedPoller = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedPoller = [[self alloc] init];;
    });
    return sharedPoller;
}

- (id)init {
    self = [super init];
    
    if (self) {
        self.pollingLock = NO;
    }
    
    return self;
}

- (void)startPollingMatch:(Match *_Nonnull)match {
    self.match = match;
    self.event = nil;
    continuePolling = YES;
    self.dateOfLastLoadedMessage = [NSDate date];
    [self poll];
}

- (void)startPollingEvent:(Event *_Nonnull)event {
    //TODO: poll event messages
    self.event = event;
    self.match = nil;
    continuePolling = YES;
    self.dateOfLastLoadedMessage = [NSDate date];
    [self poll];
}

- (void)stopPolling {
    continuePolling = NO;
}

- (BOOL)isLaterThanLatestMessageDate:(NSDate *)date {
    return ([self.dateOfLastLoadedMessage compare:date] == NSOrderedAscending);
}

- (void)poll {
    if (!continuePolling || self.pollingLock) {
        return;
    }
    
    if (self.match) {
        PFQuery *directMessageQuery = [PFQuery queryWithClassName:[DirectMessage parseClassName]];
        [directMessageQuery whereKey:DIRECT_MESSAGE_MATCH_KEY equalTo:self.match];
        
        [directMessageQuery findObjectsInBackgroundWithBlock:^(NSArray *_Nullable messages, NSError *_Nullable error){
            if (messages && messages.count >= 1) {
                DirectMessage *latestMessage = (DirectMessage *)messages[messages.count - 1];
                if ([self isLaterThanLatestMessageDate:latestMessage.createdAt]) {
                    //new message detected
                    [[NSNotificationCenter defaultCenter]
                     postNotificationName:NEW_MESSAGE_NOTIFICATION_NAME
                     object:messages];
                }
            }
        }];
    } else if (self.event) {
        //TODO: query group message
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(POLL_INTERVAL_SEC * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self poll];
    });
}

@end
