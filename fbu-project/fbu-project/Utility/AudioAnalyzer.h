//
//  AudioAnalyzer.h
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/26/21.
//

NS_ASSUME_NONNULL_BEGIN

@interface AudioAnalyzer : NSObject

extern NSString * const CELLO_IDENTIFIER;
extern NSString * const CLARINET_IDENTIFIER;
extern NSString * const FLUTE_IDENTIFIER;
extern NSString * const ACOUSTIC_GUITAR_IDENTIFIER;
extern NSString * const ELECTRIC_GUITAR_IDENTIFIER;
extern NSString * const ORGAN_IDENTIFIER;
extern NSString * const PIANO_IDENTIFIER;
extern NSString * const SAXOPHONE_IDENTIFIER;
extern NSString * const TRUMPET_IDENTIFIER;
extern NSString * const VIOLIN_IDENTIFIER;
extern NSString * const HUMAN_SINGING_VOICE_IDENTIFIER;

typedef void (^DetectedInstrumentsResultBlock)(NSSet *_Nullable instumentLabels);

- (void)analyzeSoundFileWithURL:(NSURL *)audioFileURL completion:(DetectedInstrumentsResultBlock)completion;

@end

NS_ASSUME_NONNULL_END
