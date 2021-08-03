//
//  ProfileViewController.m
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/12/21.
//

#import "ProfileViewController.h"
#import <Parse/Parse.h>
#import "SceneDelegate.h"
#import "AuthenticationViewController.h"
#import "MediaPlayBackView.h"
#import "LikedGenreCollectionViewCell.h"
#import "LikedGenre.h"
#import "AddLikedGenreViewController.h"
#import "DictionaryConstants.h"
#import "CommonFunctions.h"
#import "LikedInstrument.h"
#import "ComposeBioViewController.h"
#import "AudioRecorderViewController.h"

@interface ProfileViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *playbackContainerView;
@property (strong, nonatomic) MediaPlayBackView *_Nullable playbackView;
@property (weak, nonatomic) IBOutlet UICollectionView *likedGenresCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionView *likedInstrumentsCollectionView;
@property (assign, nonatomic) BOOL canEditProfile;
@property (strong, nonatomic) NSMutableArray<LikedGenre *> *_Nullable likedGenres;
@property (strong, nonatomic) NSMutableArray<LikedInstrument *> *_Nullable likedInstruments;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UIButton *changeProfileImageButton;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *bioLabel;
@property (weak, nonatomic) IBOutlet UIButton *editBioButton;
@property (weak, nonatomic) IBOutlet UIButton *addLikedGenreButton;
@property (weak, nonatomic) IBOutlet UIButton *addLikedInstrumentButton;
@property (weak, nonatomic) IBOutlet UIButton *recordAudioButton;

@end

static NSInteger SAVED_PROFILE_IMAGE_DIMENSIONS = 500; //limit the size of images being saved in database
static NSInteger GENRE_CELL_HEIGHT = 50;

static NSString * const LIKED_GENRE_CELL_IDENTIFIER = @"LikedGenreCollectionViewCell";
static NSString * const LIKED_INSTRUMENT_CELL_IDENTIFIER = @"LikedInstrumentCell";
static NSString * const PROFILE_TO_ADD_GENRE_SEGUE_IDENTIFIER = @"profileToAddLikedGenre";
static NSString * const PROFILE_TO_ADD_INSTRUMENT_SEGUE_IDENTIFIER = @"profileToAddLikedInstrument";
static NSString * const PROFILE_TO_COMPOSE_BIO_SEGUE_IDENTIFIER = @"profileToComposeBio";
static NSString * const PROFILE_TO_RECORD_SEGUE_IDENTIFIER = @"profileToRecord";
static NSString * const MAIN_STORYBOARD_NAME = @"Main";
static NSString * const ATHENTICATION_VIEW_CONTROLLER_NAME = @"AuthenticationViewController";
static NSString * const CHOOSE_ACTION_TITLE = @"Choose From Photos";
static NSString * const TAKE_ACTION_TITLE = @"Take Photo";
static NSString * const CANCEL_ACTION_TITLE = @"Cancel";
static NSString * const DEFAULT_BIO_STRING = @"No Bio";

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self fetchRecording];
    
    if(self.targetUser == nil) {
        self.targetUser = [PFUser currentUser];
        self.canEditProfile = YES;
    }
    
    [self setupEditRights];
    [self setupCollectionView];
    [self fetchLikedGenres];
    [self fetchLikedInstruments];
    [self fetchUserData];
    [self doStyling];
}

- (void)doStyling {
    //making profile image round
    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width / 2;
    self.profileImageView.clipsToBounds = YES;
}

- (void)fetchUserData {
    //fetch user profile image
    PFQuery *userQuery = [PFQuery queryWithClassName:[PFUser parseClassName]];
    NSString *userId = self.targetUser.objectId;
    [userQuery getObjectInBackgroundWithId:userId
                                     block:^(PFObject *object, NSError *error) {
        PFUser *user = (PFUser *)object;
        self.usernameLabel.text = user.username;
        
        NSString *userBio = user[BIO_KEY];
        if (userBio && userBio.length > 0) {
            self.bioLabel.text = user[BIO_KEY];
        } else {
            self.bioLabel.text = DEFAULT_BIO_STRING;
        }
        
        [user[PROFILE_IMAGE_KEY] getDataInBackgroundWithBlock:^(NSData *_Nullable data, NSError *_Nullable error) {
            if (!error) {
                self.profileImageView.image = [UIImage imageWithData:data];
            }
        }];
    }];
}

- (void)setupEditRights {
    if (self.canEditProfile) {
        enableButton(self.changeProfileImageButton);
        enableButton(self.editBioButton);
        enableButton(self.addLikedGenreButton);
        enableButton(self.addLikedInstrumentButton);
        enableButton(self.recordAudioButton);
    } else {
        disableButton(self.changeProfileImageButton);
        disableButton(self.editBioButton);
        disableButton(self.addLikedGenreButton);
        disableButton(self.addLikedInstrumentButton);
        disableButton(self.recordAudioButton);
    }
}

- (void)setupCollectionView {
    self.likedGenresCollectionView.delegate = self;
    self.likedGenresCollectionView.dataSource = self;
    
    self.likedInstrumentsCollectionView.delegate = self;
    self.likedInstrumentsCollectionView.dataSource = self;
}

- (void)viewWillDisappear:(BOOL)animated {
    if (self.playbackView) {
        [self.playbackView stopPlaying];
    }
}

- (void)fetchLikedInstruments {
    //TODO: fetch and reload collection view
    PFQuery *likedInstrumentsQuery = [PFQuery queryWithClassName:[LikedInstrument parseClassName]];
    [likedInstrumentsQuery whereKey:LIKED_INSTRUMENT_USER_KEY equalTo:self.targetUser];
    
    [likedInstrumentsQuery findObjectsInBackgroundWithBlock:^(NSArray<LikedInstrument *> *_Nullable likedInstruments, NSError *_Nullable error) {
        if (!error && likedInstruments) {
            self.likedInstruments = likedInstruments;
            [self.likedInstrumentsCollectionView reloadData];
        }
    }];
}

- (void)fetchLikedGenres {
    PFQuery *likedGenreQuery = [PFQuery queryWithClassName:[LikedGenre parseClassName]];
    [likedGenreQuery whereKey:LIKED_GENRE_USER_KEY equalTo:self.targetUser];
    
    [likedGenreQuery findObjectsInBackgroundWithBlock:^(NSArray<LikedGenre *> *_Nullable likedGenres, NSError *error){
        if (!error && likedGenres) {
            self.likedGenres = likedGenres;
            [self.likedGenresCollectionView reloadData];
        }
    }];
}

- (void)fetchRecording {
    PFQuery *userQuery = [PFQuery queryWithClassName:[PFUser parseClassName]];
    [userQuery includeKey:RECORDING_KEY];
    
    [userQuery getObjectInBackgroundWithId:[PFUser currentUser].objectId block:^(PFObject *_Nullable object, NSError *_Nullable error){
        if (object) {
            self.targetUser = (PFUser *)object;
            
            PFFileObject *recordingFile = self.targetUser[RECORDING_KEY];
            if(recordingFile == nil) {
                return;
            }
            
            [recordingFile getDataInBackgroundWithBlock:^(NSData *_Nullable data, NSError *_Nullable error){
                if (data) {
                    [self addPlaybackView:data];
                }
            }];
        }
    }];
}

- (void)addPlaybackView:(NSData *_Nullable)data {
    if(data == nil) {
        return;
    }
    if (self.playbackView) {
        [self.playbackView removeFromSuperview];
        self.playbackView = nil;
    }
    
    MediaPlayBackView *playbackView = [[MediaPlayBackView alloc]
                                       initWithFrame:CGRectMake(0, 0, self.playbackContainerView.frame.size.width, self.playbackContainerView.frame.size.height)
                                       andData:data];
    self.playbackView = playbackView;
    [self.playbackContainerView addSubview:playbackView];
}

- (IBAction)didTapLogout:(UIBarButtonItem *)sender {
    SceneDelegate *sceneDelegate = (SceneDelegate *)[UIApplication sharedApplication].connectedScenes.allObjects[0].delegate;
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:MAIN_STORYBOARD_NAME bundle:nil];
    AuthenticationViewController *userAuthenticationViewController = [storyboard instantiateViewControllerWithIdentifier:ATHENTICATION_VIEW_CONTROLLER_NAME];
    sceneDelegate.window.rootViewController = userAuthenticationViewController;
    
    [PFUser logOutInBackground];
}

#pragma mark - CollectionView methods

- (nonnull UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    NSString *cellIdentifier = collectionView == self.likedGenresCollectionView? LIKED_GENRE_CELL_IDENTIFIER : LIKED_INSTRUMENT_CELL_IDENTIFIER;
    
    LikedGenreCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    if (cell) {
        if (collectionView == self.likedGenresCollectionView) {
            LikedGenre *genre = self.likedGenres[indexPath.item];
            [cell setCellWithTitle:genre.title canRemove:self.canEditProfile];
            cell.removeLikedEntity = ^(LikedGenreCollectionViewCell *_Nonnull cell) {
                [self removeLikedGenre:cell];
            };
        } else {
            LikedInstrument *instrument = self.likedInstruments[indexPath.item];
            [cell setCellWithTitle:instrument.title canRemove:self.canEditProfile];
            cell.removeLikedEntity = ^(LikedGenreCollectionViewCell *_Nonnull cell) {
                [self removeLikedInstrument:cell];
            };
        }
    }
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(self.likedGenresCollectionView.frame.size.width, GENRE_CELL_HEIGHT);
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (collectionView == self.likedGenresCollectionView) {
        return self.likedGenres.count;
    } else {
        return self.likedInstruments.count;
    }
}

- (IBAction)addLikedGenre:(UIButton *)sender {
    [self performSegueWithIdentifier:PROFILE_TO_ADD_GENRE_SEGUE_IDENTIFIER sender:nil];
}

- (IBAction)addLikedInstrument:(UIButton *)sender {
    [self performSegueWithIdentifier:PROFILE_TO_ADD_INSTRUMENT_SEGUE_IDENTIFIER sender:nil];
}

- (void)removeLikedGenre:(LikedGenreCollectionViewCell *_Nonnull)cell {
    NSInteger indexToRemove = [self.likedGenresCollectionView indexPathForCell:cell].item;
    LikedGenre *genreToRemove = self.likedGenres[indexToRemove];
    
    //remove corresponding genre from the database
    [LikedGenre deleteLikedGenre:genreToRemove completion:nil];
    
    //remove the cell from the local collection view
    [self.likedGenres removeObjectAtIndex:indexToRemove];
    [self.likedGenresCollectionView reloadData];
}

- (void)removeLikedInstrument:(LikedGenreCollectionViewCell *_Nonnull)cell {
    NSInteger indexToRemove = [self.likedInstrumentsCollectionView indexPathForCell:cell].item;
    LikedInstrument *instrumentToRemove = self.likedInstruments[indexToRemove];
    
    //remove corresponding liked instrument from the database
    [LikedInstrument deleteLikedInstrument:instrumentToRemove completion:nil];
    
    //remove the cell from the local collection view
    [self.likedInstruments removeObjectAtIndex:indexToRemove];
    [self.likedInstrumentsCollectionView reloadData];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:PROFILE_TO_ADD_GENRE_SEGUE_IDENTIFIER]) {
        AddLikedGenreViewController *destinationViewController = [segue destinationViewController];
        destinationViewController.didAddLikedInstrument = nil;
        destinationViewController.didAddLikedGenre = ^(LikedGenre *newLikedGenre){
            if (newLikedGenre != nil) {
                [self.likedGenres insertObject:newLikedGenre atIndex:0];
                [self.likedGenresCollectionView reloadData];
            }
        };
    } else if ([segue.identifier isEqualToString:PROFILE_TO_ADD_INSTRUMENT_SEGUE_IDENTIFIER]) {
        AddLikedGenreViewController *destinationViewController = [segue destinationViewController];
        destinationViewController.didAddLikedGenre = nil;
        destinationViewController.didAddLikedInstrument = ^(LikedInstrument *newLikedInstrument) {
            if (newLikedInstrument != nil) {
                [self.likedInstruments insertObject:newLikedInstrument atIndex:0];
                [self.likedInstrumentsCollectionView reloadData];
            }
        };
    } else if ([segue.identifier isEqualToString:PROFILE_TO_COMPOSE_BIO_SEGUE_IDENTIFIER]) {
        ComposeBioViewController *destinationViewController = [segue destinationViewController];
        destinationViewController.didChangeBio = ^(NSString *_Nonnull newBio){
            self.bioLabel.text = newBio;
        };
    } else if ([segue.identifier isEqualToString:PROFILE_TO_RECORD_SEGUE_IDENTIFIER]) {
        AudioRecorderViewController *destinationViewController = [segue destinationViewController];
        destinationViewController.updateLocalRecording = ^(NSData *_Nullable data){
            [self addPlaybackView:data];
        };
    }
}

#pragma mark - Editing profile

- (IBAction)didTapEditBio:(UIButton *)sender {
    [self performSegueWithIdentifier:PROFILE_TO_COMPOSE_BIO_SEGUE_IDENTIFIER sender:nil];
}

- (IBAction)didTapChangeProfileImage:(UIButton *)sender {
    UIAlertController *photoAlert = [UIAlertController alertControllerWithTitle:nil
                                                                        message:nil
                                                                 preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *chooseAction = [UIAlertAction actionWithTitle:CHOOSE_ACTION_TITLE style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
        //choose from photos
        [self launchImagePicker:NO];
    }];
    
    UIAlertAction *takeAction = [UIAlertAction actionWithTitle:TAKE_ACTION_TITLE style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * action) {
        //take a photo
        [self launchImagePicker:YES];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(CANCEL_ACTION_TITLE, nil)
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    
    [photoAlert addAction:chooseAction];
    [photoAlert addAction:takeAction];
    [photoAlert addAction:cancelAction];
    [self presentViewController:photoAlert animated:YES completion:nil];
}

- (void)launchImagePicker:(BOOL)take {
    UIImagePickerController *imagePickerVC = [UIImagePickerController new];
    imagePickerVC.delegate = self;
    imagePickerVC.allowsEditing = YES;
    
    if (take && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    else {
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    [self presentViewController:imagePickerVC animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    // Get the image captured by the UIImagePickerController
    UIImage *editedImage = info[UIImagePickerControllerEditedImage];
    [self uploadProfileImage:editedImage];
    
    // Dismiss UIImagePickerController to go back to your original view controller
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)uploadProfileImage:(UIImage *)newProfileImage {
    if (![self.targetUser.objectId isEqualToString:[PFUser currentUser].objectId]) {
        return;
    }
    
    newProfileImage = resizeImage(newProfileImage,
                                  CGSizeMake(SAVED_PROFILE_IMAGE_DIMENSIONS,
                                             SAVED_PROFILE_IMAGE_DIMENSIONS));
    
    self.profileImageView.image = newProfileImage;
    
    PFFileObject *pfImage = getFileFromImage(newProfileImage);
    
    if (pfImage != nil) {
        [PFUser currentUser][PROFILE_IMAGE_KEY] = pfImage;
        [[PFUser currentUser] saveInBackground];
    }
}

@end
