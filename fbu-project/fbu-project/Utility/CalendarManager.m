//
//  CalendarManager.m
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 8/9/21.
//

#import "CalendarManager.h"

static NSString * const DEFAULT_CALENDAR_IDENTIDIER_KEY = @"defaultCalendarIdentifier";
static NSString * const DEFAULT_CALENDAR_TITLE = @"groovi jam sessions";
static const NSTimeInterval DEFAULT_EVENT_DURATION = 3600; //TODO: set event duration in-app

@implementation CalendarManager

+ (instancetype)shared {
    static CalendarManager *calendarManager = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        calendarManager = [[self alloc] init];;
    });
    
    return calendarManager;
}

- (instancetype) init {
    self = [super init];
    
    if (self) {
        self.eventStore = [[EKEventStore alloc] init];
    }
    
    return self;
}

- (void)addEvent:(Event *_Nonnull)event completion:(void (^_Nonnull)(BOOL addedEvent))completion {
    if (!event || !self.eventStore) {
        return;
    }
    
    [self.eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *_Nullable error){
        if (granted) {
            self.defaultCalendar = [self getCalendar];
            EKEvent *ekEvent = [EKEvent eventWithEventStore:self.eventStore];
            ekEvent.calendar = self.defaultCalendar;
            ekEvent.title = event.title;
            ekEvent.startDate = event.date;
            ekEvent.endDate = [NSDate dateWithTimeInterval:DEFAULT_EVENT_DURATION sinceDate:event.date];
            
            BOOL eventAdded = [self.eventStore saveEvent:ekEvent span:EKSpanThisEvent error:nil];
            completion(eventAdded);
        }
    }];
}

- (EKCalendar *_Nullable)getCalendar { //returns the default groovi calendar
    if (!self.eventStore) {
        return nil;
    }
    
    NSString *defaultCalendarIdentifier = [[NSUserDefaults standardUserDefaults] stringForKey:DEFAULT_CALENDAR_IDENTIDIER_KEY];
    EKCalendar *defaultCalendar = [self.eventStore calendarWithIdentifier:defaultCalendarIdentifier];
    
    if (!defaultCalendarIdentifier || !defaultCalendar) {
        //create the groovi calendar
        defaultCalendar = [EKCalendar calendarForEntityType:EKEntityTypeEvent eventStore:self.eventStore];
        [defaultCalendar setTitle:DEFAULT_CALENDAR_TITLE];
        defaultCalendar.source = [self findLocalSource];
        [[NSUserDefaults standardUserDefaults] setValue:defaultCalendar.calendarIdentifier forKey:DEFAULT_CALENDAR_IDENTIDIER_KEY];
        
        NSError *error;
        [self.eventStore saveCalendar:defaultCalendar commit:YES error:&error];
        if (error) {
            return nil;
        }
    }
    
    return defaultCalendar;
}

- (EKSource *_Nullable)findLocalSource {
    if (!self.eventStore) {
        return nil;
    }
    
    // find local source
    EKSource *localSource = nil;
    for (EKSource *source in self.eventStore.sources) {
        if (source.sourceType == EKSourceTypeLocal)
        {
            localSource = source;
            break;
        }
    }
    
    return localSource;
}

@end
