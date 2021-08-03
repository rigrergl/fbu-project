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

NSString * const NEW_MESSAGE_NOTIFICATION_NAME = @"NewMessageNotification";
static const CGFloat POLL_INTERVAL_SEC = 5;

@implementation MessagePoller {
    BOOL continuePolling;
}

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
        self.pollingLock = YES;
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

+ (BOOL)isDate:(NSDate *_Nonnull)date laterThanDate:(NSDate *_Nonnull)secondDate {
    if (date == nil || secondDate == nil) {
        return NO;
    }
    return [date compare:secondDate] == NSOrderedDescending;
}

- (void)poll {
    if (!continuePolling || self.pollingLock) {
        return;
    }
    
    if (self.match) {
        PFQuery *directMessageQuery = [PFQuery queryWithClassName:[DirectMessage parseClassName]];
        [directMessageQuery whereKey:DIRECT_MESSAGE_MATCH_KEY equalTo:self.match];
        [directMessageQuery orderByAscending:CREATED_AT_KEY];
        
        [directMessageQuery findObjectsInBackgroundWithBlock:^(NSArray *_Nullable messages, NSError *_Nullable error){
            if (messages && messages.count >= 1) {
                DirectMessage *latestMessage = (DirectMessage *)messages[messages.count - 1];
                if ([MessagePoller isDate:latestMessage.createdAt laterThanDate:self.dateOfLastLoadedMessage]) {
                    //new message detected
                    self.dateOfLastLoadedMessage = latestMessage.createdAt;
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
