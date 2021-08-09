//
//  CalendarManager.h
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 8/9/21.
//

#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>
#import "Event.h"

NS_ASSUME_NONNULL_BEGIN

@interface CalendarManager : NSObject

@property (strong, nonatomic) EKEventStore *_Nullable eventStore;
@property (strong, nonatomic) EKCalendar *_Nullable defaultCalendar;

+ (instancetype)shared;
- (void)addEvent:(Event *_Nonnull)event completion:(void (^_Nonnull)(BOOL addedEvent))completion;

@end

NS_ASSUME_NONNULL_END
