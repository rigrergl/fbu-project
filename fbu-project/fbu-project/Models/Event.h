//
//  Event.h
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/21/21.
//

#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface Event : PFObject<PFSubclassing>

@property (nonatomic, strong) PFUser *_Nonnull organizer;
@property (nonatomic, strong) NSDate *_Nonnull date;
@property (nonatomic, copy) NSString *_Nonnull location;
@property (nonatomic, copy) NSString *_Nonnull title;
@property (nonatomic, strong) UIImage *_Nullable image;
@property (nonatomic, strong) NSArray<PFUser *> *_Nonnull invited;
@property (nonatomic, strong) NSArray<PFUser *> *_Nonnull accepted;

+ (void)postEvent:(PFUser *)organizer
             date:(NSDate *)date
         location:(NSString *)location
            title:(NSString *)title
            image:(UIImage *)image
          invited:(NSArray<PFUser *> *)invited
         accepted:(NSArray<PFUser *> *)accepted;

@end

NS_ASSUME_NONNULL_END
