//
//  AudioRecorderViewController.h
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/12/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AudioRecorderViewController : UIViewController

@property (nonatomic, copy, nonnull) void (^updateLocalRecording)(NSData *_Nullable recordingData);

@end

NS_ASSUME_NONNULL_END
