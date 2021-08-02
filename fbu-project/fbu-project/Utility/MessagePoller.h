//
//  MessagePoller.h
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/21/21.
//

#import <Foundation/Foundation.h>
#import "Match.h"
#import "Event.h"

NS_ASSUME_NONNULL_BEGIN

@interface MessagePoller : NSObject

@property (atomic, assign) BOOL pollingLock;
extern NSString * const NEW_MESSAGE_NOTIFICATION_NAME;

+ (instancetype)shared;
+ (BOOL)isDate:(NSDate *_Nonnull)date laterThanDate:(NSDate *_Nonnull)secondDate;
- (void)startPollingMatch:(Match *_Nonnull)match;
- (void)startPollingEvent:(Event *_Nonnull)event;
- (void)stopPolling;

@end

NS_ASSUME_NONNULL_END
