//
//  Event.m
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/21/21.
//

#import "Event.h"

@implementation Event

+ (nonnull NSString *)parseClassName {
    return @"Event";
}

+ (void)postEvent:(PFUser *)organizer
             date:(NSDate *)date
         location:(NSString *)location
            title:(NSString *)title
            image:(UIImage *)image
          invited:(NSArray<PFUser *> *)invited
         accepted:(NSArray<PFUser *> *)accepted {
    
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

@end
