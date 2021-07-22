//
//  Event.m
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/21/21.
//

#import "Event.h"
#import "DictionaryConstants.h"

@implementation Event

+ (nonnull NSString *)parseClassName {
    return @"Event";
}

+ (void)postEvent:(PFUser *_Nonnull)organizer
             date:(NSDate *_Nonnull)date
         location:(NSString *_Nonnull)location
            title:(NSString *_Nonnull)title
            image:(PFFileObject *_Nullable)image
          invited:(NSMutableArray<PFUser *> *_Nullable)invited
         accepted:(NSMutableArray<PFUser *> *_Nullable)accepted {
    
    Event *newEvent = [Event new];
    newEvent.organizer = organizer;
    newEvent.date = date;
    newEvent.location = location;
    newEvent.title = title;
    newEvent.image = image;
    newEvent.invited = invited;
    newEvent.accepted = accepted;
    
    [newEvent saveInBackground];
}

- (void)moveUserToAccepted:(PFUser *)user {
    if (self.accepted == nil) {
        self.accepted = [[NSMutableArray alloc] init];
    }
    
    
    NSMutableSet<PFUser *> *acceptedSet = [[NSMutableSet alloc] initWithArray:self.accepted];
    [acceptedSet addObject:[PFUser currentUser]];
    
    self.accepted = (NSMutableArray *)[acceptedSet allObjects];
   
    int indexOfCurrentUserInInvited = 0;
    while (indexOfCurrentUserInInvited < self.invited.count) {
        if ([self.invited[indexOfCurrentUserInInvited].objectId isEqualToString:[PFUser currentUser].objectId]) {
            [self.invited removeObjectAtIndex:indexOfCurrentUserInInvited];
            break;
        }
        indexOfCurrentUserInInvited++;
    }
    
    [self setObject:self.invited forKey:EVENT_INVITED_KEY];
    [self saveInBackground];
}

@end
