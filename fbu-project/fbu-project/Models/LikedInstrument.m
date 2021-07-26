//
//  LikedInstrument.m
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/26/21.
//

#import "LikedInstrument.h"
#import "DictionaryConstants.h"
#import "AudioAnalyzer.h"

@implementation LikedInstrument

+ (nonnull NSString *)parseClassName {
    return LIKED_INSTRUMENT_CLASS_NAME;
}

NSString * CELLO_DISPLAY_NAME = @"cello";
NSString * CLARINET_DISPLAY_NAME = @"clarinet";
NSString * FLUTE_DISPLAY_NAME = @"flute";
NSString * ACOUSTIC_GUITAR_DISPLAY_NAME = @"acoustic guitar";
NSString * ELECTRIC_GUITAR_DISPLAY_NAME = @"electric guitar";
NSString * ORGRAN_DISPLAY_NAME = @"organ";
NSString * PIANO_DISPLAY_NAME = @"piano";
NSString * SAXOPHONE_DISPLAY_NAME = @"saxophone";
NSString * TRUMPET_DISPLAY_NAME = @"trumpet";
NSString * VIOLIN_DISPLAY_NAME = @"violin";
NSString * HUMAN_SINGING_VOICE_DISPLAY_NAME = @"voice";

+ (NSDictionary<NSString *, NSString *> *_Nonnull)sharedTranslationDictionary {
    static NSDictionary<NSString *, NSString *> *fullInstrumentNamesDictionary = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        fullInstrumentNamesDictionary = [[NSDictionary alloc] init];
        fullInstrumentNamesDictionary = @{
            CELLO_IDENTIFIER:CELLO_DISPLAY_NAME,
            CLARINET_IDENTIFIER:CLARINET_DISPLAY_NAME,
            FLUTE_IDENTIFIER:FLUTE_DISPLAY_NAME,
            ACOUSTIC_GUITAR_IDENTIFIER:ACOUSTIC_GUITAR_DISPLAY_NAME,
            ELECTRIC_GUITAR_IDENTIFIER:ELECTRIC_GUITAR_DISPLAY_NAME,
            ORGAN_IDENTIFIER:ORGRAN_DISPLAY_NAME,
            PIANO_IDENTIFIER:PIANO_DISPLAY_NAME,
            SAXOPHONE_IDENTIFIER:SAXOPHONE_DISPLAY_NAME,
            TRUMPET_IDENTIFIER:TRUMPET_DISPLAY_NAME,
            VIOLIN_IDENTIFIER:VIOLIN_DISPLAY_NAME,
            HUMAN_SINGING_VOICE_IDENTIFIER:HUMAN_SINGING_VOICE_DISPLAY_NAME
        };
    });
    
    return fullInstrumentNamesDictionary;
}

+ (NSString *)getDisplayNameForInstrument:(NSString *)shortName {
    NSDictionary<NSString *, NSString *> *namesDictionary =  [self sharedTranslationDictionary];
    NSString *fullName =  [namesDictionary objectForKey:shortName];
    return fullName;
}


@end
