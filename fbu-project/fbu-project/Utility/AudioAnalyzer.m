//
//  AudioAnalyzer.m
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/26/21.
//

#import "MySoundClassifier.h"
#import "AudioAnalyzer.h"
#import "LikedInstrument.h"
#import <SoundAnalysis/SoundAnalysis.h>

@interface AudioAnalyzer () <SNResultsObserving>

@property (nonatomic, strong) NSMutableSet<NSString *> *_Nonnull setOfInstrumentLabels;

@end

static const NSInteger INTRUMENT_LABELS_SET_INITIAL_CAPACITY = 3;
static const CGFloat MIN_CONFIDENCE = 0.9;
NSString * const CELLO_IDENTIFIER = @"cel";
NSString * const CLARINET_IDENTIFIER = @"cla";
NSString * const FLUTE_IDENTIFIER = @"flu";
NSString * const ACOUSTIC_GUITAR_IDENTIFIER = @"gac";
NSString * const ELECTRIC_GUITAR_IDENTIFIER = @"gel";
NSString * const ORGAN_IDENTIFIER = @"org";
NSString * const PIANO_IDENTIFIER = @"pia";
NSString * const SAXOPHONE_IDENTIFIER = @"sax";
NSString * const TRUMPET_IDENTIFIER = @"tru";
NSString * const VIOLIN_IDENTIFIER = @"vio";
NSString * const HUMAN_SINGING_VOICE_IDENTIFIER = @"voi";

@implementation AudioAnalyzer

+ (SNClassifySoundRequest *)makeInstrumentClassifyRequest {
    MLModel *model = [MLModel modelWithContentsOfURL:[MySoundClassifier URLOfModelInThisBundle] error:nil];
    SNClassifySoundRequest *request = [[SNClassifySoundRequest alloc] initWithMLModel:model error:nil];
    return request;
}

- (void)request:(nonnull id<SNRequest>)request
didProduceResult:(nonnull id<SNResult>)result {
    
    SNClassificationResult *castedResult = (SNClassificationResult *)result;
    if (castedResult == nil) {
        return;
    }
    
    SNClassification *classification = castedResult.classifications.firstObject;
    if (classification == nil) {
        return;
    }
    
    [self addInstrumentLabelIfConfident:classification.identifier
                             confidence:classification.confidence];
}

- (void)addInstrumentLabelIfConfident:(NSString *)label
                           confidence:(CGFloat)confidence {
    if (confidence > MIN_CONFIDENCE) {
        [self.setOfInstrumentLabels addObject:[LikedInstrument getDisplayNameForInstrument:label]];
    }
}

- (void)analyzeSoundFileWithURL:(NSURL *)audioFileURL
                     completion:(DetectedInstrumentsResultBlock)completion {
    NSError *error;
    SNAudioFileAnalyzer *analyzer = [[SNAudioFileAnalyzer alloc] initWithURL:audioFileURL error:&error];
    if (error || !analyzer) {
        return;
    }
    error = nil;
    SNClassifySoundRequest *request = [AudioAnalyzer makeInstrumentClassifyRequest];
    [analyzer addRequest:request withObserver:self error:&error];
    if (error || !request) {
        return;
    }
    
    self.setOfInstrumentLabels = [[NSMutableSet alloc] initWithCapacity:INTRUMENT_LABELS_SET_INITIAL_CAPACITY];
    [analyzer analyzeWithCompletionHandler:^(BOOL didReachEndOfFile) {
        if (didReachEndOfFile) {
            completion(self.setOfInstrumentLabels);
        } else {
            completion(nil);
        }
    }];
}

@end
