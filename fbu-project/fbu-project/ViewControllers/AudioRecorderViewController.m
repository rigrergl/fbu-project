//
//  AudioRecorderViewController.m
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/12/21.
//

#import "AudioRecorderViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface AudioRecorderViewController () <AVAudioRecorderDelegate>

@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (strong, nonatomic) AVAudioSession *recordingSession;
@property (strong, nonatomic) AVAudioRecorder *audioRecorder;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;

@end

@implementation AudioRecorderViewController


- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)didTapRecord:(UIButton *)sender {
    [self startRecording];
}

- (void)startRecording {
    
    self.recordingSession = [AVAudioSession sharedInstance];
    NSError *error = nil;
    [self.recordingSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    if (error) {
        NSLog(@"audioSession: %@ %ld %@", [error domain], (long)[error code], [[error userInfo] description]);
        return;
    }
    
    error = nil;
    [self.recordingSession setActive:YES error:&error];
    if (error) {
        NSLog(@"audioSession: %@ %ld %@", [error domain], (long)[error code], [[error userInfo] description]);
        return;
    }
    
    
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    
    [recordSetting setValue :[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
    
    [recordSetting setValue :[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
    [recordSetting setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
    [recordSetting setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];
    
    // Create a new dated file
    NSDate *now = [NSDate dateWithTimeIntervalSinceNow:0];
    NSString *caldate = [now description];
    NSURL *documentsDirectory = [AudioRecorderViewController getDocumentsDirectory];
    NSString *recorderFilePath = [NSString stringWithFormat:@"%@/%@.caf", documentsDirectory, caldate];
    
    NSURL *url = [NSURL fileURLWithPath:recorderFilePath];
    error = nil;
    self.audioRecorder = [[ AVAudioRecorder alloc] initWithURL:url settings:recordSetting error:&error];
    if(!self.audioRecorder){
        NSLog(@"recorder: %@ %ld %@", [error domain], (long)[error code], [[error userInfo] description]);
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Warning"
                                                                       message:[error localizedDescription]
                                                                preferredStyle:(UIAlertControllerStyleAlert)];
        // create an OK action
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * _Nonnull action) {
            // handle response here.
        }];
        // add the OK action to the alert controller
        [alert addAction:okAction];
        
        [self presentViewController:alert animated:YES completion:^{}];
        return;
    }
    
    //prepare to record
    [self.audioRecorder setDelegate:self];
    [self.audioRecorder  prepareToRecord];
    self.audioRecorder .meteringEnabled = YES;
    
    BOOL audioHWAvailable = self.recordingSession.isInputAvailable;
    if (! audioHWAvailable) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Warning"
                                                                       message:@"Audio input hardware not available"
                                                                preferredStyle:(UIAlertControllerStyleAlert)];
        // create an OK action
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * _Nonnull action) {
            // handle response here.
        }];
        // add the OK action to the alert controller
        [alert addAction:okAction];
        
        [self presentViewController:alert animated:YES completion:^{}];
        return;
    }
    
    // start recording
    [self.audioRecorder recordForDuration:(NSTimeInterval) 10];
}

+ (NSURL *)getDocumentsDirectory {
    NSArray *paths = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSLog(@"Documents Directory: %@", paths[0]);
    return paths[0];
}

- (void) stopRecording{
    
    [self.audioRecorder stop];
    
    NSURL *url = [AudioRecorderViewController getDocumentsDirectory];
    NSError *error= nil;
    NSData *audioData = [NSData dataWithContentsOfFile:[url path] options: 0 error:&error];
    if(!audioData)
        NSLog(@"audio data: %@ %ld %@", [error domain], (long)[error code], [[error userInfo] description]);
//    [editedObject setValue:[NSData dataWithContentsOfURL:url] forKey:editedFieldKey];
    
    //[recorder deleteRecording];
    
    
    NSFileManager *fm = [NSFileManager defaultManager];
    
    error = nil;
    [fm removeItemAtPath:[url path] error:&error];
    if(error)
        NSLog(@"File Manager: %@ %ld %@", [error domain], (long)[error code], [[error userInfo] description]);
}

- (void)saveVideoData {
    
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *) aRecorder successfully:(BOOL)flag
{
    
    NSLog (@"audioRecorderDidFinishRecording:successfully:");
    // your actions here
    
}

@end
