//
//  AudioRecorderViewController.m
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/12/21.
//

#import "AudioRecorderViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <Parse/Parse.h>

@interface AudioRecorderViewController () <AVAudioRecorderDelegate, AVAudioPlayerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (strong, nonatomic) AVAudioSession *recordingSession;
@property (strong, nonatomic) AVAudioRecorder *audioRecorder;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;

@end

@implementation AudioRecorderViewController


- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)didTapRecord:(UIButton *)sender {
    if (self.audioRecorder == nil) {
        [self startRecording];
    } else {
        [self finishRecording:YES];
    }
}

- (IBAction)didTapPlay:(UIButton *)sender {
    if (self.audioPlayer == nil) {
        [self playRecording];
    } else {
        [self stopPlaying];
    }
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
    
    NSURL *audioFile = [AudioRecorderViewController getRecordingURL];
    error = nil;
    self.audioRecorder = [[ AVAudioRecorder alloc] initWithURL:audioFile settings:recordSetting error:&error];
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
    self.audioRecorder.delegate = self;
    [self.audioRecorder record];
    
    [self.recordButton setTitle:@"Tap to Stop" forState:UIControlStateNormal];
}

+ (NSURL *)getRecordingURL {
    NSArray *paths = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSLog(@"Documents Directory: %@", paths[0]);
    
    NSURL *documentsDirectory = paths[0];
    NSURL *recordingURL = [documentsDirectory URLByAppendingPathComponent:@"recording.m4a"];
    
    return recordingURL;
}


- (void)finishRecording:(BOOL)success {
    [self.audioRecorder stop];
    self.audioRecorder = nil;
    
    [self retrieveRecordedFile];
    
    if (success) {
        [self.recordButton setTitle:@"Tap to Re-record" forState:UIControlStateNormal];
    } else {
        [self.recordButton setTitle:@"Tap to Record" forState:UIControlStateNormal];
    }
}

- (void)retrieveRecordedFile{

    [self.audioRecorder stop];
    
    NSURL *url = [AudioRecorderViewController getRecordingURL];
    NSError *error= nil;
    NSData *audioData = [NSData dataWithContentsOfFile:[url path] options: 0 error:&error];
    if(!audioData)
        NSLog(@"audio data: %@ %ld %@", [error domain], (long)[error code], [[error userInfo] description]);
    
    [[PFUser currentUser] setValue:[NSData dataWithContentsOfURL:url] forKey:@"recording"];
    
    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *_Nullable error) {
        if(error) {
            NSLog(@"Error saving recording for user");
        } else {
            NSLog(@"Successfully saved recording for user");
        }
    }];
    
//    [self deleteFile]; TODO: uncomment this line
}

- (void)deleteFile {
    NSURL *url = [AudioRecorderViewController getRecordingURL];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error;
    error = nil;
    [fm removeItemAtPath:[url path] error:&error];
    if(error)
        NSLog(@"File Manager: %@ %ld %@", [error domain], (long)[error code], [[error userInfo] description]);
}

- (void)saveVideoData {
    
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *) aRecorder successfully:(BOOL)flag
{
    if (!flag) {
        [self finishRecording:false];
    } else {
        NSLog (@"audioRecorderDidFinishRecording:successfully:");
        // your actions here∫
    }
}


#pragma mark - Playing the recording

- (void)playRecording {
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    NSURL *url = [AudioRecorderViewController getRecordingURL];
    NSError *error = nil;
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    self.audioPlayer.delegate = self;
    self.audioPlayer.numberOfLoops = 0;
    [self.audioPlayer play];
    
    [self.playButton setTitle:@"Stop Playing" forState:UIControlStateNormal];
}

- (void)stopPlaying {
    if (self.audioPlayer) {
        [self.audioPlayer stop];
        self.audioPlayer = nil;
        
        [self.playButton setTitle:@"Play" forState:UIControlStateNormal];
    } else {
        NSLog(@"Tried to stop audio player but it was nil");
    }
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    
    
    if (flag) {
        [self stopPlaying];
    } else {
        NSLog(@"audioPlayerDidFinishPlaying with error");
    }
}

@end
