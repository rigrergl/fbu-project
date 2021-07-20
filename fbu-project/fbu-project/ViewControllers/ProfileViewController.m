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

@interface ProfileViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) IBOutlet UIView *_Nonnull playbackContainerView;
@property (strong, nonatomic) MediaPlayBackView *_Nullable playbackView;
@property (strong, nonatomic) IBOutlet UICollectionView *_Nonnull likedGenresCollectionView;
@property (assign, nonatomic) BOOL canEditProfile;
@property (strong, nonatomic) NSMutableArray *_Nullable likedGenres;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UIButton *changeProfileImageButton;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;

@end

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
    PFQuery *userQuery = [PFQuery queryWithClassName:@"_User"];
    NSString *userId = self.targetUser.objectId;
    [userQuery getObjectInBackgroundWithId:userId
                                 block:^(PFObject *object, NSError *error) {
        PFUser *user = (PFUser *)object;
        self.usernameLabel.text = user.username;
        [user[PROFILE_IMAGE_KEY] getDataInBackgroundWithBlock:^(NSData *_Nullable data, NSError *_Nullable error) {
            if (!error) {
                self.profileImageView.image = [UIImage imageWithData:data];
            }
        }];
    }];
}

- (void)setupEditRights {
    if (self.canEditProfile) {
        self.changeProfileImageButton.alpha = 1;
        self.changeProfileImageButton.enabled = YES;
        
    } else {
        self.changeProfileImageButton.alpha = 0;
        self.changeProfileImageButton.enabled = NO;
    }
}

- (void)setupCollectionView {
    self.likedGenresCollectionView.delegate = self;
    self.likedGenresCollectionView.dataSource = self;
}

- (void)viewWillDisappear:(BOOL)animated {
    if (self.playbackView) {
        [self.playbackView stopPlaying];
    }
}

- (void)fetchLikedGenres {
    PFQuery *likedGenreQuery = [PFQuery queryWithClassName:[LikedGenre parseClassName]];
    [likedGenreQuery whereKey:@"user" equalTo:self.targetUser];
    
    [likedGenreQuery findObjectsInBackgroundWithBlock:^(NSArray *_Nullable likedGenres, NSError *error){
        if (!error && likedGenres) {
            self.likedGenres = likedGenres;
            [self.likedGenresCollectionView reloadData];
        }
    }];
}

- (void)fetchRecording {
    PFQuery *userQuery = [PFQuery queryWithClassName:@"_User"];
    [userQuery includeKey:@"recording"];
    
    [userQuery getObjectInBackgroundWithId:[PFUser currentUser].objectId block:^(PFObject *_Nullable object, NSError *_Nullable error){

        if (object) {
            self.targetUser = (PFUser *)object;

            PFFileObject *recordingFile = self.targetUser[@"recording"];
            if(recordingFile == nil) {
                return;
            }

            
            [self addPlaybackView];
        }
    }];
}

- (void)addPlaybackView {
    PFFileObject *recordingFile = self.targetUser[@"recording"];
    if(recordingFile == nil) {
        return;
    }
    
    [recordingFile getDataInBackgroundWithBlock:^(NSData *_Nullable data, NSError *_Nullable error){
        if (data) {
            MediaPlayBackView *playbackView = [[MediaPlayBackView alloc]
                                               initWithFrame:CGRectMake(0, 0, self.playbackContainerView.frame.size.width, self.playbackContainerView.frame.size.height)
                                               andData:data];
            
            self.playbackView = playbackView;
            [self.playbackContainerView addSubview:playbackView];
        }
    }];
}

- (IBAction)didTapLogout:(UIBarButtonItem *)sender {
    SceneDelegate *sceneDelegate = (SceneDelegate *)[UIApplication sharedApplication].connectedScenes.allObjects[0].delegate;
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    AuthenticationViewController *userAuthenticationViewController = [storyboard instantiateViewControllerWithIdentifier:@"AuthenticationViewController"];
    sceneDelegate.window.rootViewController = userAuthenticationViewController;
    
    [PFUser logOutInBackground];
}

#pragma mark - CollectionView methods

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    LikedGenreCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"LikedGenreCollectionViewCell" forIndexPath:indexPath];
    
    if (cell) {
        LikedGenre *genre = self.likedGenres[indexPath.item];
        [cell setCellWithTitle:genre.title canRemove:self.canEditProfile];
        cell.removeLikedGenre = ^(LikedGenreCollectionViewCell *_Nonnull cell){
            [self removeLikedGenre:cell];
        };
    }
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(self.likedGenresCollectionView.frame.size.width, 50);
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.likedGenres.count;
}

- (IBAction)addLikedGenre:(UIButton *)sender {
    [self performSegueWithIdentifier:@"profileToAddLikedGenre" sender:nil];
}

- (void)removeLikedGenre:(LikedGenreCollectionViewCell *_Nonnull)cell {
    long indexToRemove = [self.likedGenresCollectionView indexPathForCell:cell].item;
    LikedGenre *genreToRemove = self.likedGenres[indexToRemove];
    
    //remove corresponding genre from the database
    [LikedGenre deleteLikedGenre:genreToRemove withCompletion:^(BOOL succeeded, NSError *_Nullable error){}];
    
    //remove the cell from the local collection view
    [self.likedGenres removeObjectAtIndex:indexToRemove];
    [self.likedGenresCollectionView reloadData];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"profileToAddLikedGenre"]) {
        AddLikedGenreViewController *destinationViewController = [segue destinationViewController];
        destinationViewController.didAddLikedGenre = ^(LikedGenre *newLikedGenre){
            if (newLikedGenre != nil) {
                [self.likedGenres insertObject:newLikedGenre atIndex:0];
                [self.likedGenresCollectionView reloadData];
            }
        };
    }
}

#pragma mark - Editing profile

- (IBAction)didTapChangeProfileImage:(UIButton *)sender {
    UIAlertController *photoAlert = [UIAlertController alertControllerWithTitle:nil
                                                                        message:nil
                                                                 preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *chooseAction = [UIAlertAction actionWithTitle:@"Choose From Photos" style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
        //choose from photos
        [self launchImagePicker:NO];
    }];
    
    UIAlertAction *takeAction = [UIAlertAction actionWithTitle:@"Take Photo" style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * action) {
        //take a photo
        [self launchImagePicker:YES];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
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
    
    newProfileImage = [ProfileViewController resizeImage:newProfileImage withSize:CGSizeMake(500, 500)];
    self.profileImageView.image = newProfileImage;
    
    PFFileObject *pfImage = [ProfileViewController getPFFileFromImage:newProfileImage];
    
    if (pfImage != nil) {
        [PFUser currentUser][PROFILE_IMAGE_KEY] = pfImage;
        [[PFUser currentUser] saveInBackground];
    }
}

+ (PFFileObject *)getPFFileFromImage:(UIImage * _Nullable)image {
    // check if image is not nil
    if (!image) {
        return nil;
    }
    
    NSData *imageData = UIImagePNGRepresentation(image);
    // get image data and check if that is not nil
    if (!imageData) {
        return nil;
    }
    
    return [PFFileObject fileObjectWithName:@"image.png" data:imageData];
}

+ (UIImage *)resizeImage:(UIImage *)image
                withSize:(CGSize)size {
    UIImageView *resizeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    
    resizeImageView.contentMode = UIViewContentModeScaleAspectFill;
    resizeImageView.image = image;
    
    UIGraphicsBeginImageContext(size);
    [resizeImageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end
