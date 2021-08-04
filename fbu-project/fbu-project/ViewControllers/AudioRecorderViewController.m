//
//  AudioRecorderViewController.m
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/12/21.
//

#import "AudioRecorderViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "DictionaryConstants.h"
#import "AudioAnalyzer.h"
#import "MediaPlayBackView.h"
#import "LikedEntityCollectionViewCell.h"
#import <Parse/Parse.h>

@interface AudioRecorderViewController () <AVAudioRecorderDelegate, AVAudioPlayerDelegate, UICollectionViewDelegate, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (strong, nonatomic) AVAudioSession *_Nonnull recordingSession;
@property (strong, nonatomic) AVAudioRecorder *_Nullable audioRecorder;
@property (strong, nonatomic) NSData *_Nullable recordingData;
@property (strong, nonatomic) NSMutableArray *_Nullable instrumentLabels;
@property (weak, nonatomic) IBOutlet UIView *_Nullable playbackContainerView;
@property (strong, nonatomic) UIView *_Nullable playbackView;
@property (weak, nonatomic) IBOutlet UICollectionView *_Nullable detectedInstrumentsCollectionView;
@property (weak, nonatomic) IBOutlet UILabel *collectionViewTitleLabel;

@end

static NSString * const RECORDING_BUTTON_IDLE_IMAGE_NAME = @"record.circle";
static NSString * const RECORDING_BUTTON_ACTIVE_IMAGE_NAME = @"record.circle.fill";
static NSString * const DETECTED_INSTRUMENT_CELL_IDENTIFIER = @"DetectedInstrumentCell";
static NSString * const RECORDING_TITLE = @"recording.m4a";
static const NSInteger INSTRUMENT_CELL_HEIGHT = 50;
static CGFloat SHOW_PLAY_BUTTON_ANIMATION_DURATION = 0.5;

@implementation AudioRecorderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupRecordButton];
    [self setupPlaybackView];
    [self setupCollectionView];
    self.submitButton.enabled = NO;
}

- (void)setupCollectionView {
    self.detectedInstrumentsCollectionView.delegate = self;
    self.detectedInstrumentsCollectionView.dataSource = self;
}

- (void)setupPlaybackView {
    self.playbackContainerView.alpha = 0;
    self.detectedInstrumentsCollectionView.alpha = 0;
    self.collectionViewTitleLabel.alpha = 0;
}

- (void)setupRecordButton {
    [self.recordButton setBackgroundImage:[UIImage systemImageNamed:RECORDING_BUTTON_ACTIVE_IMAGE_NAME]
                                 forState:UIControlStateSelected];
    [self.recordButton setBackgroundImage:[UIImage systemImageNamed:RECORDING_BUTTON_IDLE_IMAGE_NAME]
                                 forState:UIControlStateNormal];
}

- (void)viewDidDisappear:(BOOL)animated {
    [self deleteFile];
}

- (IBAction)didTapRecord:(UIButton *)sender {
    self.submitButton.enabled = NO;
    
    if (self.audioRecorder == nil) {
        [self startRecording];
    } else {
        [self finishRecording:YES];
    }
}

- (void)startRecording {
    self.recordingSession = [AVAudioSession sharedInstance];
    NSError *error = nil;
    [self.recordingSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    if (error) {
        return;
    }
    
    error = nil;
    [self.recordingSession setActive:YES error:&error];
    if (error) {
        return;
    }
    
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    
    [recordSetting setValue :@(kAudioFormatLinearPCM) forKey:AVFormatIDKey];
    [recordSetting setValue:@(44100.0) forKey:AVSampleRateKey];
    [recordSetting setValue:@(2) forKey:AVNumberOfChannelsKey];
    
    [recordSetting setValue :@(16) forKey:AVLinearPCMBitDepthKey];
    [recordSetting setValue :@(NO) forKey:AVLinearPCMIsBigEndianKey];
    [recordSetting setValue :@(NO) forKey:AVLinearPCMIsFloatKey];
    
    NSURL *audioFile = [AudioRecorderViewController getRecordingURL];
    error = nil;
    self.audioRecorder = [[ AVAudioRecorder alloc] initWithURL:audioFile settings:recordSetting error:&error];
    if(!self.audioRecorder){
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
    
    [self.recordButton setSelected:YES];
}

+ (NSURL *)getRecordingURL {
    NSArray *paths = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    
    NSURL *documentsDirectory = paths[0];
    NSURL *recordingURL = [documentsDirectory URLByAppendingPathComponent:RECORDING_TITLE];
    
    return recordingURL;
}

- (void)finishRecording:(BOOL)success {
    [self.audioRecorder stop];
    self.audioRecorder = nil;
    
    [self processRecording];
    
    if (success) {
        [self showPlaybackView];
    }
    
    [self.recordButton setSelected:NO];
}

- (void)showPlaybackView {
    if (self.playbackContainerView.alpha != 1 ||
        self.detectedInstrumentsCollectionView.alpha != 1 ||
        self.collectionViewTitleLabel.alpha != 1) {
        [UIView animateWithDuration:SHOW_PLAY_BUTTON_ANIMATION_DURATION
                         animations:^{
            self.playbackContainerView.alpha = 1;
            self.detectedInstrumentsCollectionView.alpha = 1;
            self.collectionViewTitleLabel.alpha = 1;
        }];
    }
}

- (void)addPlaybackView:(NSData *)recordingData {
    if(recordingData == nil) {
        return;
    }
    
    [self.playbackView removeFromSuperview];
    self.playbackView = nil;
    
    MediaPlayBackView *playbackView = [[MediaPlayBackView alloc]
                                       initWithFrame:CGRectMake(0, 0, self.playbackContainerView.frame.size.width, self.playbackContainerView.frame.size.height)
                                       andData:recordingData];
    self.playbackView = playbackView;
    [self.playbackContainerView addSubview:playbackView];
}

- (void)processRecording {
    [self.audioRecorder stop];
    
    NSURL *url = [AudioRecorderViewController getRecordingURL];
    NSError *error = nil;
    NSData *audioData = [NSData dataWithContentsOfURL:url options:0 error:&error];
    if (error || !audioData) {
        self.submitButton.enabled = NO;
        return;
    }
    
    self.recordingData = audioData;
    
    [self addPlaybackView:audioData];
    [self analyzeRecording];
}

- (IBAction)didTapSubmit:(UIButton *)sender {
    if (self.recordingData == nil) {
        return;
    }
    
    PFFileObject *recordingFile = [PFFileObject fileObjectWithData:self.recordingData];
    [[PFUser currentUser] setValue:recordingFile forKey:RECORDING_KEY];
    [[PFUser currentUser] setObject:self.instrumentLabels forKey:INSTRUMENTS_IN_RECORDING];
    
    [[PFUser currentUser] saveInBackground];
    
    if (self.updateLocalRecording) {
        self.updateLocalRecording(self.recordingData);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)analyzeRecording {
    AudioAnalyzer *analyzer = [[AudioAnalyzer alloc] init];
    [analyzer analyzeSoundFileWithURL:[AudioRecorderViewController getRecordingURL]
                           completion:^(NSSet *_Nullable instumentLabels) {
        self.instrumentLabels = [[instumentLabels allObjects] mutableCopy];
        
        dispatch_async(dispatch_get_main_queue(), ^() {
            [self.detectedInstrumentsCollectionView reloadData];
            self.submitButton.enabled = YES;
        });
    }];
}

- (void)deleteFile {
    NSURL *url = [AudioRecorderViewController getRecordingURL];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error;
    error = nil;
    [fm removeItemAtPath:[url path] error:&error];
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *) aRecorder
                           successfully:(BOOL)flag {
    if (!flag) {
        [self finishRecording:false];
    }
}

#pragma mark - CollectionView methods

- (nonnull UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    LikedEntityCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:DETECTED_INSTRUMENT_CELL_IDENTIFIER forIndexPath:indexPath];
    
    if (cell) {
        NSString *instumentTitle = self.instrumentLabels[indexPath.item];
        [cell setCellWithTitle:instumentTitle canRemove:YES];
        
        cell.removeLikedEntity = ^(LikedEntityCollectionViewCell *_Nonnull cell) {
            [self removeInstrumentLabel:cell];
        };
    }
    
    return cell;
}

- (void)removeInstrumentLabel:(LikedEntityCollectionViewCell *_Nonnull)cell {
    NSInteger indexToRemove = [self.detectedInstrumentsCollectionView indexPathForCell:cell].item;
    
    [self.instrumentLabels removeObjectAtIndex:indexToRemove];
    [self.detectedInstrumentsCollectionView reloadData];
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.instrumentLabels.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(self.detectedInstrumentsCollectionView.frame.size.width, INSTRUMENT_CELL_HEIGHT);
}

@end
