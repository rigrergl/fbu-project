//
//  Event.h
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/21/21.
//

#import <Parse/Parse.h>
#import "FoursquareVenue.h"

NS_ASSUME_NONNULL_BEGIN

@interface Event : PFObject<PFSubclassing>

@property (nonatomic, strong) PFUser *_Nonnull organizer;
@property (nonatomic, strong) FoursquareVenue *_Nullable venue;
@property (nonatomic, strong) NSDate *_Nonnull date;
@property (nonatomic, copy) NSString *_Nonnull location;
@property (nonatomic, copy) NSString *_Nonnull title;
@property (nonatomic, strong) PFFileObject *_Nullable image;
@property (nonatomic, strong) NSMutableArray<PFUser *> *_Nullable invited;
@property (nonatomic, strong) NSMutableArray<PFUser *> *_Nullable accepted;

+ (Event *_Nullable)postEvent:(PFUser *_Nonnull)organizer
                        venue:(FoursquareVenue *_Nullable)venue
                         date:(NSDate *_Nonnull)date
                     location:(NSString *_Nonnull)location
                        title:(NSString *_Nonnull)title
                        image:(PFFileObject *_Nullable)image
                      invited:(NSMutableArray<PFUser *> *_Nullable)invited
                     accepted:(NSMutableArray<PFUser *> *_Nullable)accepted;

- (void)moveUserToAccepted:(PFUser *)user;

@end

NS_ASSUME_NONNULL_END
