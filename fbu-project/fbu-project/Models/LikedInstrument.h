//
//  LikedInstrument.h
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/26/21.
//

#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface LikedInstrument : PFObject<PFSubclassing>

extern NSString * CELLO_DISPLAY_NAME;
extern NSString * CLARINET_DISPLAY_NAME;
extern NSString * FLUTE_DISPLAY_NAME;
extern NSString * ACOUSTIC_GUITAR_DISPLAY_NAME;
extern NSString * ELECTRIC_GUITAR_DISPLAY_NAME;
extern NSString * ORGRAN_DISPLAY_NAME;
extern NSString * PIANO_DISPLAY_NAME;
extern NSString * SAXOPHONE_DISPLAY_NAME;
extern NSString * TRUMPET_DISPLAY_NAME;
extern NSString * VIOLIN_DISPLAY_NAME;
extern NSString * HUMAN_SINGING_VOICE_DISPLAY_NAME;

typedef void(^LikedInstrumentReturnBlock)(LikedInstrument *_Nullable newLikedInstrument, NSError *_Nullable error);

@property (nonatomic, copy) NSString *_Nonnull title;
@property (nonatomic, strong) PFUser *_Nonnull user;

+ (NSString *)getDisplayNameForInstrument:(NSString *)shortName;
+ (NSArray<NSString *> *)InstrumentNames;

+ (void)postLikedInstrument:(NSString *)title
                    forUser:(PFUser *)user
                 completion:(LikedInstrumentReturnBlock _Nullable)completion;

+ (void)deleteLikedInstrument:(LikedInstrument *)likedInstrument
                   completion:(PFBooleanResultBlock _Nullable)completion;

@end

NS_ASSUME_NONNULL_END
