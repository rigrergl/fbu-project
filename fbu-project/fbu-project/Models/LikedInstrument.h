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

+ (NSString *)getDisplayNameForInstrument:(NSString *)shortName;

@end

NS_ASSUME_NONNULL_END
